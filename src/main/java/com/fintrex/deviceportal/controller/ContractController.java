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
                return ResponseEntity.ok("[]");
            }
        } catch (Exception e) {
            return ResponseEntity.ok("[]");
        }
    }

    @PostMapping("/datacultr/resend-unlock")
    public ResponseEntity<String> resendUnlock(
            @RequestParam("accountNo") String accountNo,
            @RequestParam("financeNo") String financeNo,
            jakarta.servlet.http.HttpSession session) {
        try {
            List<com.fintrex.deviceportal.dto.Screen> permittedScreens = (List<com.fintrex.deviceportal.dto.Screen>) session.getAttribute("permittedScreens");
            boolean hasPermission = permittedScreens != null && permittedScreens.stream()
                    .anyMatch(s -> s.getPath().equalsIgnoreCase("/device-lock-control"));
            if (!hasPermission) {
                return ResponseEntity.status(403).body("{\"status\": 403, \"message\": \"Access Denied: You do not have permission to control this device.\"}");
            }

            String payload = "[{\"accountNo\":\"" + accountNo.trim() + "\"}]";
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.fintrex.lk/datacultr/resend-unlock"))
                    .timeout(Duration.ofSeconds(15))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload))
                    .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            
            if (response.statusCode() == 200) {
                com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
                String username = currentUser != null ? currentUser.getUsername() : "system";
                contractService.addRemark(financeNo, "Device Unlock command resent successfully.", username);
            }
            
            return ResponseEntity.status(response.statusCode()).body(response.body());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("{\"status\": 500, \"message\": \"Failed: " + e.getMessage() + "\"}");
        }
    }

    @PostMapping("/datacultr/resend-lock")
    public ResponseEntity<String> resendLock(
            @RequestParam("accountNo") String accountNo,
            @RequestParam("financeNo") String financeNo,
            jakarta.servlet.http.HttpSession session) {
        try {
            List<com.fintrex.deviceportal.dto.Screen> permittedScreens = (List<com.fintrex.deviceportal.dto.Screen>) session.getAttribute("permittedScreens");
            boolean hasPermission = permittedScreens != null && permittedScreens.stream()
                    .anyMatch(s -> s.getPath().equalsIgnoreCase("/device-lock-control"));
            if (!hasPermission) {
                return ResponseEntity.status(403).body("{\"status\": 403, \"message\": \"Access Denied: You do not have permission to control this device.\"}");
            }

            String payload = "[{\"accountNo\":\"" + accountNo.trim() + "\"}]";
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.fintrex.lk/datacultr/resend-lock"))
                    .timeout(Duration.ofSeconds(15))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload))
                    .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            
            if (response.statusCode() == 200) {
                com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
                String username = currentUser != null ? currentUser.getUsername() : "system";
                contractService.addRemark(financeNo, "Device Lock command resent successfully.", username);
            }
            
            return ResponseEntity.status(response.statusCode()).body(response.body());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("{\"status\": 500, \"message\": \"Failed: " + e.getMessage() + "\"}");
        }
    }

    private String statementApiToken = null;

    private synchronized String getStatementToken() throws Exception {
        if (statementApiToken != null) {
            return statementApiToken;
        }

        String authUrl = "https://ma.fintrex.lk/mobile-banking/api/authenticate";
        String authBody = "{\"username\": \"df\", \"password\": \"9wXE8nc9j1Uy\"}";

        HttpRequest authRequest = HttpRequest.newBuilder()
                .uri(URI.create(authUrl))
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(15))
                .POST(HttpRequest.BodyPublishers.ofString(authBody))
                .build();

        HttpResponse<String> authResponse = httpClient.send(authRequest, HttpResponse.BodyHandlers.ofString());
        if (authResponse.statusCode() != 200) {
            throw new RuntimeException("Authentication failed");
        }

        tools.jackson.databind.ObjectMapper mapper = new tools.jackson.databind.ObjectMapper();
        tools.jackson.databind.JsonNode authRoot = mapper.readTree(authResponse.body());
        String token = null;
        if (authRoot.has("access_token")) {
            token = authRoot.get("access_token").asText();
        } else if (authRoot.has("token")) {
            token = authRoot.get("token").asText();
        } else if (authRoot.has("accessToken")) {
            token = authRoot.get("accessToken").asText();
        } else if (authRoot.has("jwt")) {
            token = authRoot.get("jwt").asText();
        } else if (authRoot.has("data")) {
            tools.jackson.databind.JsonNode dataNode = authRoot.get("data");
            if (dataNode.has("jwt")) {
                token = dataNode.get("jwt").asText();
            } else if (dataNode.has("access_token")) {
                token = dataNode.get("access_token").asText();
            } else if (dataNode.has("token")) {
                token = dataNode.get("token").asText();
            } else if (dataNode.has("accessToken")) {
                token = dataNode.get("accessToken").asText();
            } else if (dataNode.isTextual()) {
                token = dataNode.asText();
            }
        }

        if (token != null && !token.isEmpty()) {
            statementApiToken = token;
        }
        return statementApiToken;
    }

    @GetMapping("/statement")
    public ResponseEntity<String> getAccountStatement(
            @RequestParam("financeNo") String financeNo,
            @RequestParam("fromDate") String fromDate,
            @RequestParam("toDate") String toDate) {
        try {
            String earliestDate = java.time.LocalDate.now().getYear() + "-06-01";
            if (fromDate != null && fromDate.compareTo(earliestDate) < 0) {
                fromDate = earliestDate;
            }

            java.util.Map<String, Object> mapping = contractService.getAccountMapping(financeNo);
            String accountNo = financeNo;
            if (mapping.get("ACCOUNT_NO") != null) {
                accountNo = mapping.get("ACCOUNT_NO").toString();
            } else if (mapping.get("account_no") != null) {
                accountNo = mapping.get("account_no").toString();
            }

            String legacyAccountNo = "";
            if (mapping.get("LEGACY_ACCOUNT_NO") != null) {
                legacyAccountNo = mapping.get("LEGACY_ACCOUNT_NO").toString();
            } else if (mapping.get("legacy_account_no") != null) {
                legacyAccountNo = mapping.get("legacy_account_no").toString();
            }

            String token = getStatementToken();
            if (token == null || token.isEmpty()) {
                return ResponseEntity.status(500).body("{\"status\": 500, \"message\": \"Token not found\"}");
            }

            tools.jackson.databind.ObjectMapper mapper = new tools.jackson.databind.ObjectMapper();
            boolean hasNext = true;
            int page = 0;
            int size = 100;
            tools.jackson.databind.node.ArrayNode allTransactions = mapper.createArrayNode();

            while (hasNext && page < 50) {
                String statementUrl = "https://ma.fintrex.lk/mobile-banking/api/account/statement";
                String statementBody = String.format(
                        "{\"type\": \"LOAN\", \"accountNo\": \"%s\", \"fromDate\": \"%s\", \"toDate\": \"%s\", \"page\": %d, \"size\": %d}",
                        accountNo, fromDate, toDate, page, size
                );

                HttpRequest stmtRequest = HttpRequest.newBuilder()
                        .uri(URI.create(statementUrl))
                        .header("Content-Type", "application/json")
                        .header("Authorization", "Bearer " + token)
                        .timeout(Duration.ofSeconds(15))
                        .POST(HttpRequest.BodyPublishers.ofString(statementBody))
                        .build();

                HttpResponse<String> stmtResponse = httpClient.send(stmtRequest, HttpResponse.BodyHandlers.ofString());
                
                // If token expired, clear cached token, fetch a new one and retry
                if (stmtResponse.statusCode() == 401 || stmtResponse.statusCode() == 403) {
                    statementApiToken = null;
                    token = getStatementToken();
                    if (token != null) {
                        stmtRequest = HttpRequest.newBuilder()
                                .uri(URI.create(statementUrl))
                                .header("Content-Type", "application/json")
                                .header("Authorization", "Bearer " + token)
                                .timeout(Duration.ofSeconds(15))
                                .POST(HttpRequest.BodyPublishers.ofString(statementBody))
                                .build();
                        stmtResponse = httpClient.send(stmtRequest, HttpResponse.BodyHandlers.ofString());
                    }
                }

                if (stmtResponse.statusCode() != 200) {
                    break;
                }

                tools.jackson.databind.JsonNode stmtRoot = mapper.readTree(stmtResponse.body());
                if (stmtRoot.has("data") && stmtRoot.get("data").has("transactions")) {
                    tools.jackson.databind.JsonNode transactionsNode = stmtRoot.get("data").get("transactions");
                    if (transactionsNode.isArray()) {
                        for (tools.jackson.databind.JsonNode tx : transactionsNode) {
                            allTransactions.add(tx);
                        }
                    }
                }

                if (stmtRoot.has("data") && stmtRoot.get("data").has("hasNext")) {
                    hasNext = stmtRoot.get("data").get("hasNext").asBoolean();
                } else {
                    hasNext = false;
                }

                page++;
            }

            tools.jackson.databind.node.ObjectNode successResponse = mapper.createObjectNode();
            successResponse.put("status", 200);
            successResponse.put("message", "Successful");

            tools.jackson.databind.node.ObjectNode dataNode = mapper.createObjectNode();
            dataNode.set("transactions", allTransactions);
            dataNode.put("legacyAccountNo", legacyAccountNo);
            successResponse.set("data", dataNode);

            return ResponseEntity.ok(mapper.writeValueAsString(successResponse));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("{\"status\": 500, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}
