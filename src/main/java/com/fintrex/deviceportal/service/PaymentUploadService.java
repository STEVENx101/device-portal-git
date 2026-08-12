package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.config.DataTableRepo;
import com.fintrex.deviceportal.config.DataTableRequest;
import com.fintrex.deviceportal.config.DataTableResponse;
import com.fintrex.deviceportal.entity.BulkUpload;
import com.fintrex.deviceportal.entity.BulkUploadDetail;
import com.fintrex.deviceportal.repository.BulkUploadDetailRepository;
import com.fintrex.deviceportal.repository.BulkUploadRepository;
import java.io.IOException;
import java.net.http.HttpResponse;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class PaymentUploadService {
    private final BulkUploadRepository bulkUploadRepository;
    private final BulkUploadDetailRepository bulkUploadDetailRepository;
    private final DataTableRepo dataTableRepo;
    private final NimbleService nimbleService;
    private final org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate jdbc;
    private final DataFormatter FORMATTER = new DataFormatter();

    public PaymentUploadService(BulkUploadRepository bulkUploadRepository, 
                                BulkUploadDetailRepository bulkUploadDetailRepository, 
                                DataTableRepo dataTableRepo, 
                                NimbleService nimbleService,
                                org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate jdbc) {
        this.bulkUploadRepository = bulkUploadRepository;
        this.bulkUploadDetailRepository = bulkUploadDetailRepository;
        this.dataTableRepo = dataTableRepo;
        this.nimbleService = nimbleService;
        this.jdbc = jdbc;
    }

    public java.util.List<java.util.Map<String, Object>> getActiveServices() {
        return this.jdbc.getJdbcTemplate().queryForList("SELECT code, name FROM device_portal.payment_service ORDER BY name ASC");
    }

    public DataTableResponse paymentUploadHistory(DataTableRequest request) {
        return this.dataTableRepo.dataTable(request, "SELECT b.id, CONCAT(b.date) as date, b.user as uploaded, b.approved_user as approver, b.service, COUNT(d.id) as total, SUM(CASE WHEN d.status = 'Success' THEN 1 ELSE 0 END) as success, SUM(CASE WHEN d.status != 'Success' THEN 1 ELSE 0 END) as failed, b.status FROM device_portal.bulk_upload b LEFT JOIN device_portal.bulk_upload_detail d ON d.bulk_id=b.id GROUP BY b.id, b.date, b.user, b.approved_user, b.service, b.status", new Object[0]);
    }

    public DataTableResponse pendingApprovals(DataTableRequest request) {
        return this.dataTableRepo.dataTable(request, "SELECT b.id, CONCAT(b.date) as date, b.user as uploaded, b.service, b.comment, COUNT(d.id) as total FROM device_portal.bulk_upload b LEFT JOIN device_portal.bulk_upload_detail d ON d.bulk_id=b.id WHERE b.status='Pending Approval' GROUP BY b.id, b.date, b.user, b.service, b.comment", new Object[0]);
    }

    public DataTableResponse bulkDetail(DataTableRequest request) {
        return this.dataTableRepo.dataTable(request, "SELECT d.id, d.payment_id, d.account_no, d.amount, d.narration, d.status, d.pushed, d.ended FROM device_portal.bulk_upload_detail d WHERE d.bulk_id=?1", new Object[]{request.getData()});
    }

    public void uploadBulkPayments(MultipartFile paymentFile, String service, String comment, String username) {
        try {
            XSSFWorkbook workBook = new XSSFWorkbook(paymentFile.getInputStream());
            XSSFSheet workSheet = workBook.getSheetAt(0);
            BulkUpload bulkUpload = new BulkUpload();
            bulkUpload.setDate(LocalDateTime.now());
            bulkUpload.setService(service);
            bulkUpload.setComment(comment);
            bulkUpload.setStatus("Error");
            bulkUpload.setUser(username == null ? "" : username);
            this.bulkUploadRepository.save(bulkUpload);
            ArrayList<BulkUploadDetail> bulkDetails = new ArrayList<>();
            for (int i = 1; i <= workSheet.getLastRowNum(); ++i) {
                XSSFRow row = workSheet.getRow(i);
                if (row == null || row.getCell(0) == null) continue;
                String requestId = this.getCellValue(row, 0);
                String accountNo = this.getCellValue(row, 1);
                String amount = this.getCellValue(row, 2);
                String narration = this.getCellValue(row, 3);
                if (requestId.isEmpty()) {
                    throw new RuntimeException("Request ID is Missing in Row(" + i + ")");
                }
                if (accountNo.isEmpty()) {
                    throw new RuntimeException("Account Number is Missing in Row(" + i + ")");
                }
                if (amount.isEmpty()) {
                    throw new RuntimeException("Amount is Missing or Invalid in Row(" + i + ")");
                }
                narration = "User Bulk Upload | " + narration;
                BulkUploadDetail bulkUploadDetail = new BulkUploadDetail();
                bulkUploadDetail.setStatus("Pending");
                bulkUploadDetail.setBulkId(bulkUpload);
                bulkUploadDetail.setPaymentId(requestId);
                bulkUploadDetail.setAccountNo(accountNo);
                bulkUploadDetail.setAmount(Double.valueOf(amount));
                bulkUploadDetail.setNarration(narration);
                bulkDetails.add(bulkUploadDetail);
            }
            this.bulkUploadDetailRepository.saveAll(bulkDetails);
            bulkUpload.setStatus("Pending Approval");
            this.bulkUploadRepository.save(bulkUpload);
        } catch (IOException | RuntimeException e) {
            throw new RuntimeException(e.getMessage());
        }
    }

    public void approveAndUploadPayments(String bulkId, String approvedUser) {
        BulkUpload bulkUpload = this.bulkUploadRepository.findById(Long.valueOf(bulkId)).orElseThrow(() -> new RuntimeException("Bulk Upload not found"));
        bulkUpload.setApprovedOn(LocalDateTime.now());
        bulkUpload.setApprovedUser(approvedUser == null ? "" : approvedUser);
        bulkUpload.setStatus("Updating");
        this.bulkUploadRepository.save(bulkUpload);
        new Thread(() -> {
            BulkUpload bulk = this.bulkUploadRepository.findById(Long.valueOf(bulkId)).orElseThrow(() -> new RuntimeException("Bulk Upload not found"));
            List<BulkUploadDetail> bulkDetails = this.bulkUploadDetailRepository.findAllByBulkId(bulk);
            for (BulkUploadDetail bulkDetail : bulkDetails) {
                bulkDetail.setPushed(LocalDateTime.now());
                try {
                    HttpResponse<String> resp = this.nimbleService.updatePayment(bulkDetail.getPaymentId(), bulkDetail.getAccountNo(), bulkDetail.getAmount(), bulkDetail.getNarration(), bulkUpload.getService());
                    bulkDetail.setEnded(LocalDateTime.now());
                    if (resp.statusCode() == 200) {
                        bulkDetail.setStatus("Success");
                    } else {
                        bulkDetail.setStatus("Error");
                    }
                    bulkDetail.setResponse(resp.body());
                } catch (Exception e) {
                    bulkDetail.setStatus("Error");
                    bulkDetail.setResponse(e.getMessage());
                }
                this.bulkUploadDetailRepository.save(bulkDetail);
                try {
                    Thread.sleep(200L);
                } catch (InterruptedException interruptedException) {}
            }
            bulk.setStatus("Complete");
            this.bulkUploadRepository.save(bulk);
        }).start();
    }

    public String getCellValue(Row row, int column) {
        if (row == null) {
            return "";
        }
        Cell cell = row.getCell(column);
        if (cell == null) {
            return "";
        }
        return this.FORMATTER.formatCellValue(cell).trim();
    }
}
