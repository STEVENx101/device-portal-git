package com.fintrex.deviceportal.controller;

import com.fintrex.deviceportal.config.DataTableRequest;
import com.fintrex.deviceportal.config.DataTableResponse;
import com.fintrex.deviceportal.dto.ContractDetails;
import com.fintrex.deviceportal.dto.ContractSearchResult;
import com.fintrex.deviceportal.service.ContractService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

@RestController
@RequestMapping("/api/contracts")
public class ContractController {

    private final ContractService contractService;
    private final HttpClient httpClient;

    public ContractController(ContractService contractService) {
        this.contractService = contractService;
        
        SSLContext sslContext;
        try {
            sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, new TrustManager[]{new X509TrustManager() {
                @Override
                public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) {}
                @Override
                public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) {}
                @Override
                public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                    return new java.security.cert.X509Certificate[0];
                }
            }}, new java.security.SecureRandom());
        } catch (Exception e) {
            sslContext = null;
        }
        
        if (sslContext != null) {
            this.httpClient = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(15))
                    .sslContext(sslContext)
                    .build();
        } else {
            this.httpClient = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(15))
                    .build();
        }
    }

    @GetMapping("/search")
    public ResponseEntity<List<ContractSearchResult>> search(@RequestParam("query") String query) {
        List<ContractSearchResult> results = contractService.searchContracts(query);
        return ResponseEntity.ok(results);
    }

    @GetMapping("/details")
    public ResponseEntity<ContractDetails> getDetails(@RequestParam("financeNo") String financeNo) {
        ContractDetails details = contractService.getContractDetails(financeNo);
        if (details == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(details);
    }

    @PostMapping("/fetchreceiptdata")
    public DataTableResponse fetchreceiptdata(@RequestBody DataTableRequest request) throws Exception {
        return contractService.fetchreceiptdata(request);
    }

    @PostMapping("/fetchsmsdata")
    public DataTableResponse fetchsmsdata(@RequestBody DataTableRequest request) throws Exception {
        return contractService.fetchsmsdata(request);
    }

    @PostMapping("/fetchlockdata")
    public DataTableResponse fetchlockdata(@RequestBody DataTableRequest request) throws Exception {
        return contractService.fetchlockdata(request);
    }


    @GetMapping("/remarks")
    public ResponseEntity<List<java.util.Map<String, Object>>> getRemarks(@RequestParam("financeNo") String financeNo) {
        return ResponseEntity.ok(contractService.getRemarks(financeNo));
    }

    @PostMapping("/remarks")
    public ResponseEntity<java.util.Map<String, Object>> addRemark(
            @RequestParam("financeNo") String financeNo,
            @RequestParam("remark") String remark,
            jakarta.servlet.http.HttpSession session) {
        java.util.Map<String, Object> response = new java.util.HashMap<>();
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        contractService.addRemark(financeNo, remark, username);
        response.put("status", "success");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/datacultr-logs")
    public ResponseEntity<String> getDatacultrLogs(@RequestParam(value = "imei", required = false) String imei) {
        if (imei == null || imei.trim().isEmpty() || "-".equals(imei.trim())) {
            return ResponseEntity.ok("[]");
        }
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.fintrex.lk/datacultr/log/" + imei.trim()))
                    .timeout(Duration.ofSeconds(15))
                    .GET()
                    .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) {
                return ResponseEntity.ok(response.body());
            } else {
                return ResponseEntity.status(response.statusCode()).body(response.body());
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("[]");
        }
    }
}
