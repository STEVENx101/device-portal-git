/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  com.fintrex.paymentportal.datatable.DataTableRepo
 *  com.fintrex.paymentportal.datatable.DataTableRequest
 *  com.fintrex.paymentportal.datatable.DataTableResponse
 *  com.fintrex.paymentportal.entity.BulkUpload
 *  com.fintrex.paymentportal.entity.BulkUploadDetail
 *  com.fintrex.paymentportal.repository.BulkUploadDetailRepository
 *  com.fintrex.paymentportal.repository.BulkUploadRepository
 *  lombok.Generated
 *  org.apache.poi.ss.usermodel.Cell
 *  org.apache.poi.ss.usermodel.DataFormatter
 *  org.apache.poi.ss.usermodel.Row
 *  org.apache.poi.xssf.usermodel.XSSFRow
 *  org.apache.poi.xssf.usermodel.XSSFSheet
 *  org.apache.poi.xssf.usermodel.XSSFWorkbook
 *  org.springframework.stereotype.Service
 *  org.springframework.web.multipart.MultipartFile
 */
package com.fintrex.paymentportal.service;

import com.fintrex.paymentportal.datatable.DataTableRepo;
import com.fintrex.paymentportal.datatable.DataTableRequest;
import com.fintrex.paymentportal.datatable.DataTableResponse;
import com.fintrex.paymentportal.entity.BulkUpload;
import com.fintrex.paymentportal.entity.BulkUploadDetail;
import com.fintrex.paymentportal.repository.BulkUploadDetailRepository;
import com.fintrex.paymentportal.repository.BulkUploadRepository;
import com.fintrex.paymentportal.service.NimbleService;
import java.io.IOException;
import java.net.http.HttpResponse;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import lombok.Generated;
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
    private final DataFormatter FORMATTER = new DataFormatter();

    public DataTableResponse paymentUploadHistory(DataTableRequest request) {
        return this.dataTableRepo.dataTable(request, "SELECT b.id,CONCAT(b.date) as date,b.user as uploaded,b.approvedUser as approver,b.service,COUNT(d) as total,SUM(CASE WHEN d.status = 'success' THEN 1 ELSE 0 END) as success,SUM(CASE WHEN d.status != 'success' THEN 1 ELSE 0 END) as failed,b.status FROM BulkUpload b LEFT JOIN BulkUploadDetail d ON d.bulkId=b GROUP BY b.id,b.date,b.user,b.approvedUser,b.service,b.status", new Object[0]);
    }

    public DataTableResponse pendingApprovals(DataTableRequest request) {
        return this.dataTableRepo.dataTable(request, "SELECT b.id,CONCAT(b.date) as date,b.user as uploaded,b.service,b.comment,COUNT(d) as total FROM BulkUpload b LEFT JOIN BulkUploadDetail d ON d.bulkId=b WHERE b.status='Pending Approval' GROUP BY b.id,b.date,b.user,b.service,b.comment", new Object[0]);
    }

    public DataTableResponse bulkDetail(DataTableRequest request) {
        return this.dataTableRepo.dataTable(request, "SELECT d.id,d.paymentId,d.accountNo,d.amount,d.narration,d.status,d.pushed,d.ended FROM BulkUploadDetail d WHERE d.bulkId.id=?1", new Object[]{request.getData()});
    }

    public void uploadBulkPayments(MultipartFile paymentFile, String service, String comment) {
        try {
            XSSFWorkbook workBook = new XSSFWorkbook(paymentFile.getInputStream());
            XSSFSheet workSheet = workBook.getSheetAt(0);
            BulkUpload bulkUpload = new BulkUpload();
            bulkUpload.setDate(LocalDateTime.now());
            bulkUpload.setService(service);
            bulkUpload.setComment(comment);
            bulkUpload.setStatus("Error");
            bulkUpload.setUser("");
            this.bulkUploadRepository.save((Object)bulkUpload);
            ArrayList<BulkUploadDetail> bulkDetails = new ArrayList<BulkUploadDetail>();
            for (int i = 1; i <= workSheet.getLastRowNum(); ++i) {
                XSSFRow row = workSheet.getRow(i);
                if (row == null || row.getCell(0) == null) continue;
                String requestId = this.getCellValue((Row)row, 0);
                String accountNo = this.getCellValue((Row)row, 1);
                String amount = this.getCellValue((Row)row, 2);
                Object narration = this.getCellValue((Row)row, 3);
                if (requestId.isEmpty()) {
                    throw new RuntimeException("Request ID is Missing in Row(" + i + ")");
                }
                if (accountNo.isEmpty()) {
                    throw new RuntimeException("Account Number is Missing in Row(" + i + ")");
                }
                if (amount.isEmpty()) {
                    throw new RuntimeException("Amount is Missing or Invalid in Row(" + i + ")");
                }
                narration = "User Bulk Upload | " + (String)narration;
                BulkUploadDetail bulkUploadDetail = new BulkUploadDetail();
                bulkUploadDetail.setStatus("Pending");
                bulkUploadDetail.setBulkId(bulkUpload);
                bulkUploadDetail.setPaymentId(requestId);
                bulkUploadDetail.setAccountNo(accountNo);
                bulkUploadDetail.setAmount(Double.valueOf(amount));
                bulkUploadDetail.setNarration((String)narration);
                bulkDetails.add(bulkUploadDetail);
            }
            this.bulkUploadDetailRepository.saveAll(bulkDetails);
            bulkUpload.setStatus("Pending Approval");
            this.bulkUploadRepository.save((Object)bulkUpload);
        }
        catch (IOException | RuntimeException e) {
            throw new RuntimeException(e.getMessage());
        }
    }

    public void approveAndUploadPayments(String bulkId) {
        BulkUpload bulkUpload = (BulkUpload)this.bulkUploadRepository.findById((Object)Long.valueOf(bulkId)).get();
        bulkUpload.setApprovedOn(LocalDateTime.now());
        bulkUpload.setApprovedUser("");
        bulkUpload.setStatus("Updating");
        this.bulkUploadRepository.save((Object)bulkUpload);
        new Thread(() -> {
            BulkUpload bulk = (BulkUpload)this.bulkUploadRepository.findById((Object)Long.valueOf(bulkId)).get();
            List bulkDetails = this.bulkUploadDetailRepository.findAllByBulkId(bulk);
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
                }
                catch (Exception e) {
                    bulkDetail.setStatus("Error");
                    bulkDetail.setResponse(e.getMessage());
                }
                this.bulkUploadDetailRepository.save((Object)bulkDetail);
                try {
                    Thread.sleep(200L);
                }
                catch (InterruptedException interruptedException) {}
            }
            bulk.setStatus("Complete");
            this.bulkUploadRepository.save((Object)bulk);
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

    @Generated
    public PaymentUploadService(BulkUploadRepository bulkUploadRepository, BulkUploadDetailRepository bulkUploadDetailRepository, DataTableRepo dataTableRepo, NimbleService nimbleService) {
        this.bulkUploadRepository = bulkUploadRepository;
        this.bulkUploadDetailRepository = bulkUploadDetailRepository;
        this.dataTableRepo = dataTableRepo;
        this.nimbleService = nimbleService;
    }
}
