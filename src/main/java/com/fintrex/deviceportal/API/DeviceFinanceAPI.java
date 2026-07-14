/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.fintrex.deviceportal.API;

//import com.fasterxml.jackson.databind.ObjectMapper;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.X509Certificate;
import java.time.Duration;
import java.util.Map;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import org.springframework.stereotype.Component;
import tools.jackson.databind.ObjectMapper;

/**
 *
 * @author poornap
 */
@Component
public class DeviceFinanceAPI {

    private final ObjectMapper mapper = new ObjectMapper();

    private String token = "";

//    private final HttpClient client = HttpClient.newBuilder()
//            .connectTimeout(Duration.ofSeconds(10))
//            .build();
    //
    private final HttpClient client;

    public DeviceFinanceAPI() {

        SSLContext sslContext;
        try {
            sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, new TrustManager[]{new X509TrustManager() {
                @Override
                public void checkClientTrusted(X509Certificate[] chain, String authType) {
                }

                @Override
                public void checkServerTrusted(X509Certificate[] chain, String authType) {

                }

                @Override
                public X509Certificate[] getAcceptedIssuers() {
                    return new X509Certificate[0];
                }
            }}, new java.security.SecureRandom());
        } catch (KeyManagementException | NoSuchAlgorithmException e) {
            sslContext = null;
        }
        client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(40))
                .sslContext(sslContext)
                .build();

    }
    //

    public void getAccessToken() throws Exception {
        //System.out.println(Db.device_finance_url + "/auth");
        HttpRequest request = HttpRequest.newBuilder()
                //.uri(new URI(Db.device_finance_url + "/auth"))
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(20))
                //.POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(Map.of("client_id", Db.device_finance_username, "client_secret", Db.device_finance_password)), StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() == 200) {

            token = mapper.readTree(response.body()).get("access_token").asText();
            System.out.println("Token " + token);
        } else {
            System.out.println(response + " No Token Generated");
        }

    }

    public HttpResponse<String> searchFacility(String fno) throws Exception {

        try {

            String payload = mapper.writeValueAsString(Map.of("financeNo", fno));

            System.out.println(payload + "....payload");
            HttpRequest request = HttpRequest.newBuilder()
                    //.uri(new URI(Db.device_finance_url + "/mobile/details?financeNo=" + fno))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + token)
                    .timeout(Duration.ofSeconds(20))
                    .GET()
                    .build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            System.out.println(response.body());
            return response;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;

    }

    public ObjectMapper getObjectMapper() {
        return mapper;
    }

}
