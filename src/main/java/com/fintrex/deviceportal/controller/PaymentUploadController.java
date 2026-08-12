package com.fintrex.deviceportal.controller;

import com.fintrex.deviceportal.config.DataTableRequest;
import com.fintrex.deviceportal.config.DataTableResponse;
import com.fintrex.deviceportal.dto.User;
import com.fintrex.deviceportal.service.PaymentUploadService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.ResponseEntity;
import java.util.Map;

@Controller
public class PaymentUploadController {

    private final PaymentUploadService paymentUploadService;

    public PaymentUploadController(PaymentUploadService paymentUploadService) {
        this.paymentUploadService = paymentUploadService;
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
            return ResponseEntity.ok(Map.of("success", true, "message", "Approval successful. Payments posting processing in background."));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}
