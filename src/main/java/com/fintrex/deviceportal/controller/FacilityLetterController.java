package com.fintrex.deviceportal.controller;

import com.fintrex.deviceportal.dto.User;
import com.fintrex.deviceportal.service.FacilityLetterService;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.NestedExceptionUtils;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/facility-letters")
public class FacilityLetterController {

    private static final Logger log = LoggerFactory.getLogger(FacilityLetterController.class);

    private final FacilityLetterService facilityLetterService;

    public FacilityLetterController(FacilityLetterService facilityLetterService) {
        this.facilityLetterService = facilityLetterService;
    }

    @GetMapping("/templates")
    public ResponseEntity<Map<String, Object>> getTemplates(
            @RequestParam(value = "category", required = false) String category) {
        Map<String, Object> res = new LinkedHashMap<>();
        res.put("templates", facilityLetterService.getLetterTemplates(category));
        res.put("templatesDir", facilityLetterService.getTemplatesDirectory().toString());
        return ResponseEntity.ok(res);
    }

    @GetMapping("/products")
    public ResponseEntity<?> searchProducts(
            @RequestParam(value = "category", required = false) String category,
            @RequestParam(value = "q", required = false) String q) {
        try {
            return ResponseEntity.ok(facilityLetterService.searchProducts(category, q));
        } catch (Exception e) {
            Throwable root = NestedExceptionUtils.getMostSpecificCause(e);
            String msg = root != null && root.getMessage() != null ? root.getMessage() : e.getMessage();
            log.warn("CMS product search failed: {}", msg);
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(Map.of("error", true, "message", msg));
        }
    }

    @GetMapping("/leases")
    public ResponseEntity<?> searchLeases(
            @RequestParam(value = "productId", required = false) String productId,
            @RequestParam(value = "productName", required = false) String productName,
            @RequestParam(value = "q", required = false) String q) {
        try {
            return ResponseEntity.ok(facilityLetterService.searchLeases(productId, productName, q));
        } catch (Exception e) {
            Throwable root = NestedExceptionUtils.getMostSpecificCause(e);
            String msg = root != null && root.getMessage() != null ? root.getMessage() : e.getMessage();
            log.warn("CMS lease search failed: {}", msg);
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(Map.of("error", true, "message", msg));
        }
    }

    @GetMapping("/logs")
    public ResponseEntity<List<Map<String, Object>>> getRecentLogs() {
        return ResponseEntity.ok(facilityLetterService.getRecentPrintLogs());
    }

    @PostMapping("/generate")
    public ResponseEntity<?> generateLetter(
            @RequestBody Map<String, String> payload,
            HttpSession session) {
        try {
            String leaseId = payload.getOrDefault("leaseId", "");
            String productCategory = payload.getOrDefault("productCategory", "");
            String productId = payload.getOrDefault("productId", "");
            String productName = payload.getOrDefault("productName", "");
            String letterFileName = payload.getOrDefault("letterFileName", "");
            String letterType = payload.getOrDefault("letterType", "Full_Document");
            String outputFormat = payload.getOrDefault("outputFormat", "PDF");
            boolean inline = "true".equalsIgnoreCase(payload.getOrDefault("inline", "false"));

            User user = (User) session.getAttribute("currentUser");
            String username = user != null ? user.getUsername() : "system";

            FacilityLetterService.GeneratedLetter doc = facilityLetterService.generateLetter(
                    leaseId, productCategory, productId, productName,
                    letterFileName, letterType, outputFormat, username);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType(doc.contentType()));
            ContentDisposition disposition = (inline ? ContentDisposition.inline() : ContentDisposition.attachment())
                    .filename(doc.downloadFileName(), StandardCharsets.UTF_8)
                    .build();
            headers.setContentDisposition(disposition);
            headers.add("X-Suggested-Filename", doc.downloadFileName());

            return new ResponseEntity<>(doc.bytes(), headers, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", true, "message", e.getMessage()));
        } catch (Exception e) {
            log.error("Failed to generate facility letter", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", true, "message", e.getMessage()));
        }
    }
}
