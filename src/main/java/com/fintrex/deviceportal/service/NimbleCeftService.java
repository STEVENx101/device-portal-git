/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
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
/**
 *
 * @author Janudav
 */
@Service

public class NimbleCeftService {

    private final HttpClient http = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    ObjectMapper mapper = new ObjectMapper();

    @Value("${api.nimbleceft.url:https://api.fintrex.lk/cbs}")
    private String baseUrl;
    @Value("${api.nimbleceft.username:MOB}")
    private String username;
    @Value("${api.nimbleceft.password:k*u=J53pU2IN}")
    private String password;
    private String token = "";

    private synchronized void refreshAuth() throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI(baseUrl + "/authenticate"))
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(20))
                .POST(HttpRequest.BodyPublishers.ofString(
                        mapper.writeValueAsString(Map.of("username", username, "password", password)),
                        StandardCharsets.UTF_8))
                .build();
        HttpResponse<String> resp = http.send(request, HttpResponse.BodyHandlers.ofString());
        token = mapper.readTree(resp.body()).get("data").get("jwt").asText();
    }

    private HttpResponse<String> getRequest(String url) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI(url))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + token)
                .timeout(Duration.ofSeconds(60))
                .GET()
                .build();
        return http.send(request, HttpResponse.BodyHandlers.ofString());
    }

    private HttpResponse<String> postRequest(String url, Object payload) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI(url))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + token)
                .timeout(Duration.ofSeconds(60))
                .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(payload), StandardCharsets.UTF_8))
                .build();
        return http.send(request, HttpResponse.BodyHandlers.ofString());
    }

    public HttpResponse<String> forwardGetRequet(String url) throws Exception {
        HttpResponse<String> request = getRequest(baseUrl + url);
        System.out.println(request);
        if (request.statusCode() == 401) {
            System.out.println("getting auth");
            refreshAuth();
            request = getRequest(baseUrl + url);
        }
        System.out.println(request);
        return request;
    }

    public HttpResponse<String> forwardPostRequet(String url, Object payload) throws Exception {
        HttpResponse<String> request = postRequest(baseUrl + url, payload);
        if (request.statusCode() == 401) {
            refreshAuth();
            request = postRequest(baseUrl + url, payload);
        }
        return request;
    }

    public HttpResponse<String> updatePayment(String requestId, String referenceNo, double amount, String narration, String serviceCode) throws Exception {
        Map<String, Object> data = new HashMap<>();
        data.put("fromAccount", "10108126");
        data.put("amount", amount);
        data.put("chargeAmount", 0d);
        data.put("referenceNo", requestId);
        data.put("narration", narration);
        data.put("rrn", requestId);
        data.put("stan", "");
        data.put("channel", "CEFT MANUAL");
        data.put("type", "CEFT_FP_IN");
        data.put("accountType", "LOAN");
        data.put("toAccount", referenceNo);

        HttpResponse<String> resp = forwardPostRequet("/transaction/do-transaction", data);
        if (resp.statusCode() == 401) {
            refreshAuth();
            resp = forwardPostRequet("/transaction/do-transaction", data);
        }

        return resp;

    }

}

