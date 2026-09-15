package com.fintrex.deviceportal.controller;

import com.fintrex.deviceportal.config.DataTableRequest;
import com.fintrex.deviceportal.config.DataTableResponse;
import com.fintrex.deviceportal.dto.User;
import com.fintrex.deviceportal.service.PaymentUploadService;
import com.fintrex.deviceportal.service.CbsReportService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.ResponseEntity;
import java.util.Map;

@Controller
public class PaymentUploadController {

    private final PaymentUploadService paymentUploadService;
    private final CbsReportService cbsReportService;

    public PaymentUploadController(PaymentUploadService paymentUploadService, CbsReportService cbsReportService) {
        this.paymentUploadService = paymentUploadService;
        this.cbsReportService = cbsReportService;
    }

    @GetMapping("/payments/upload")
    public String uploadPage(org.springframework.ui.Model model) {
        model.addAttribute("services", paymentUploadService.getActiveServices());
        return "payments-upload";
    }

    @GetMapping("/payments/approve")
    public String approvePage() {
        return "payments-approve";
    }

    @PostMapping("/api/payments/history")
    @ResponseBody
    public DataTableResponse paymentUploadHistory(@RequestBody DataTableRequest request) {
        return paymentUploadService.paymentUploadHistory(request);
    }

    @PostMapping("/api/payments/pending")
    @ResponseBody
    public DataTableResponse pendingApprovals(@RequestBody DataTableRequest request) {
        return paymentUploadService.pendingApprovals(request);
    }

    @PostMapping("/api/payments/detail")
    @ResponseBody
    public DataTableResponse bulkDetail(@RequestBody DataTableRequest request) {
        return paymentUploadService.bulkDetail(request);
    }

    @GetMapping("/api/payments/detail/download")
    public void downloadBulkDetail(
            @RequestParam("bulkId") String bulkId,
            HttpSession session,
            jakarta.servlet.http.HttpServletResponse response) throws java.io.IOException {
        User currentUser = (User) session.getAttribute("currentUser");
        String username = (currentUser != null) ? currentUser.getUsername() : "system";
        cbsReportService.logReportActivity(username, "Bulk Upload Detail Report", "DOWNLOAD", "bulkId=" + bulkId);

        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"bulk_upload_detail_" + bulkId + ".csv\"");

        java.util.List<java.util.Map<String, Object>> records = paymentUploadService.getBulkUploadDetailsForDownload(bulkId);

        java.io.PrintWriter writer = response.getWriter();
        writer.println("ID,Payment ID,Account No,Amount,Narration,Status,Response,Pushed At,Ended At");

        for (java.util.Map<String, Object> row : records) {
            writer.println(String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s",
                    cleanCsv(row.get("id")),
                    cleanCsv(row.get("payment_id")),
                    cleanCsv(row.get("account_no")),
                    cleanCsv(row.get("amount")),
                    cleanCsv(row.get("narration")),
                    cleanCsv(row.get("status")),
                    cleanCsv(row.get("response")),
                    cleanCsv(row.get("pushed")),
                    cleanCsv(row.get("ended"))
            ));
        }
        writer.flush();
    }

    private String cleanCsv(Object val) {
        if (val == null) {
            return "";
        }
        String s = val.toString().replace("\"", "\"\"");
        if (s.contains(",") || s.contains("\n") || s.contains("\r")) {
            return "\"" + s + "\"";
        }
        return s;
    }

    @PostMapping("/api/payments/upload")
    @ResponseBody
    public ResponseEntity<?> uploadBulkPayments(
            @RequestParam("file") MultipartFile file,
            @RequestParam("service") String service,
            @RequestParam("comment") String comment,
            HttpSession session) {
        try {
            User currentUser = (User) session.getAttribute("currentUser");
            String username = (currentUser != null) ? currentUser.getUsername() : "system";
            paymentUploadService.uploadBulkPayments(file, service, comment, username);
            cbsReportService.logReportActivity(username, "Bulk Payment Upload", "UPLOAD", "service=" + service + ", comment=" + comment + ", file=" + file.getOriginalFilename());
            return ResponseEntity.ok(Map.of("success", true, "message", "File uploaded successfully. Pending approval."));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @PostMapping("/api/payments/approve")
    @ResponseBody
    public ResponseEntity<?> approveAndUploadPayments(
            @RequestParam("bulkId") String bulkId,
            HttpSession session) {
        try {
            User currentUser = (User) session.getAttribute("currentUser");
            String username = (currentUser != null) ? currentUser.getUsername() : "system";
            paymentUploadService.approveAndUploadPayments(bulkId, username);
            cbsReportService.logReportActivity(username, "Bulk Payment Approval", "APPROVE", "bulkId=" + bulkId);
            return ResponseEntity.ok(Map.of("success", true, "message", "Approval successful. Payments posting processing in background."));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}
