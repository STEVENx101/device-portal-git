package com.fintrex.deviceportal.service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.HashMap;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class NimbleService {
    @Value("${api.nimble.url:https://api.nimble.example.com}")
    private String rootUrl;
    @Value("${api.nimble.username:deviceportal_user}")
    private String username;
    @Value("${api.nimble.password:deviceportal_password}")
    private String password;
    private final ObjectMapper mapper = new ObjectMapper();
    private String jwtToken = "";
    private final Logger logger = LoggerFactory.getLogger(NimbleService.class);
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10L)).build();
    private final JdbcTemplate jdbcTemplate;

    public NimbleService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public HttpResponse<String> updatePayment(String requestId, String referenceNo, double amount, String narration, String serviceCode, String username) throws Exception {
        HashMap<String, Object> coreRequest = new HashMap<>();
        coreRequest.put("serviceCode", serviceCode);
        coreRequest.put("requestId", requestId);
        coreRequest.put("amount", amount);
        coreRequest.put("referenceNo", referenceNo);
        coreRequest.put("narration", narration == null ? "" : narration);
        String payload = this.mapper.writeValueAsString(coreRequest);
        HttpResponse<String> savePaymentRequest = this.postRequest("/payment/update", payload, username);
        if (savePaymentRequest.statusCode() == 401) {
            this.updateAuth(username);
            savePaymentRequest = this.postRequest("/payment/update", payload, username);
        }
        if (savePaymentRequest.statusCode() == 401) {
            this.updateAuth(username);
            savePaymentRequest = this.postRequest("/payment/update", payload, username);
        }
        return savePaymentRequest;
    }

    public boolean validateReference(String requestId, String referenceNo, String username) throws Exception {
        HashMap<String, String> coreRequest = new HashMap<>();
        coreRequest.put("requestId", requestId);
        coreRequest.put("referenceNo", referenceNo);
        String payload = this.mapper.writeValueAsString(coreRequest);
        HttpResponse<String> savePaymentRequest = this.postRequest("/payment/validate", payload, username);
        if (savePaymentRequest.statusCode() == 401) {
            this.updateAuth(username);
            savePaymentRequest = this.postRequest("/payment/validate", payload, username);
        }
        if (savePaymentRequest.statusCode() != 200) {
            throw new Exception("Nimble Error !");
        }
        JsonNode updateResp = this.mapper.readTree(savePaymentRequest.body());
        return updateResp.get("status").asText().equals("Success");
    }

    private HttpResponse<String> postRequest(String url, String payload, String username) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI(this.rootUrl + url))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + this.jwtToken)
                .timeout(Duration.ofSeconds(60L))
                .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                .build();
        this.logger.trace("PAYLOAD - {}", payload);
        System.out.println(payload);
        HttpResponse<String> response = this.client.send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println(response);
        this.logger.trace("REQUEST - {}", response);
        this.logger.trace("RESPONSE - {}", response.body());
        
        saveApiLog(this.rootUrl + url, "POST", payload, response.statusCode(), response.body(), username);
        
        return response;
    }

    private HttpResponse<String> authUser(String username, String password, String runAsUser) throws Exception {
        String payload = this.mapper.writeValueAsString(Map.of("username", username, "password", password));
        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI(this.rootUrl + "/authenticate"))
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(60L))
                .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                .build();
        HttpResponse<String> response = this.client.send(request, HttpResponse.BodyHandlers.ofString());
        this.logger.trace("AUTH REQUEST - {}", response.toString());
        
        saveApiLog(this.rootUrl + "/authenticate", "POST", payload, response.statusCode(), response.body(), runAsUser);
        
        return response;
    }

    private synchronized void updateAuth(String username) throws Exception {
        HttpResponse<String> authRequest = this.authUser(this.username, this.password, username);
        if (authRequest.statusCode() == 200) {
            JsonNode authData = this.mapper.readTree(authRequest.body());
            this.jwtToken = authData.get("data").get("jwt").asText();
        }
    }

    private void saveApiLog(String url, String method, String requestPayload, int responseStatus, String responsePayload, String username) {
        try {
            this.jdbcTemplate.update(
                "INSERT INTO device_portal.api_log (url, method, request_payload, response_status, response_payload, created_date, username) VALUES (?, ?, ?, ?, ?, NOW(), ?)",
                url, method, requestPayload, responseStatus, responsePayload, username
            );
        } catch (Exception e) {
            this.logger.error("Failed to write API log", e);
        }
    }
}
