package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.dto.Customer360DTO;
import com.fintrex.deviceportal.dto.Customer360SearchResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.sql.ResultSetMetaData;
import java.time.Duration;
import java.util.*;

@Service
public class Customer360Service {

    private static final Logger logger = LoggerFactory.getLogger(Customer360Service.class);
    private final JdbcTemplate jdbcTemplate;
    private final HttpClient httpClient;
    private static final String FACILITY_LIST_ENDPOINT = "https://ma.fintrex.lk/mobile-banking/api//facility/list";
    private static final String FACILITY_LIST_ENDPOINT_ALT = "https://ma.fintrex.lk/mobile-banking/api/facility/list";

    public Customer360Service(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        
        HttpClient client;
        try {
            SSLContext sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, new TrustManager[]{new X509TrustManager() {
                @Override public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) {}
                @Override public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) {}
                @Override public java.security.cert.X509Certificate[] getAcceptedIssuers() { return new java.security.cert.X509Certificate[0]; }
            }}, new java.security.SecureRandom());
            
            client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(15))
                    .sslContext(sslContext)
                    .build();
        } catch (Exception e) {
            logger.warn("Could not create SSL-bypassing HttpClient for Customer360: {}", e.getMessage());
            client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(15))
                    .build();
        }
        this.httpClient = client;
    }

    public List<Customer360SearchResult> searchCustomers(String query) {
        if (query == null || query.trim().isEmpty()) {
            return Collections.emptyList();
        }
        String cleanQuery = query.trim();
        String searchPattern = "%" + cleanQuery + "%";

        String sql = """
            SELECT
                c.client_code AS CLIENT_CODE,
                c.full_name AS FULL_NAME,
                c.id_no AS ID_NO,
                c.mobile AS MOBILE
            FROM cbs.client c
            WHERE c.id_no LIKE ?
            LIMIT 10
        """;

        try {
            return jdbcTemplate.query(sql, (rs, rowNum) -> new Customer360SearchResult(
                    rs.getString("CLIENT_CODE"),
                    rs.getString("FULL_NAME"),
                    rs.getString("ID_NO"),
                    rs.getString("MOBILE")
            ), searchPattern);
        } catch (Exception e) {
            logger.error("Error searching customers for query {}: {}", cleanQuery, e.getMessage());
            return Collections.emptyList();
        }
    }

    public Customer360DTO getCustomerDetails(String query) {
        if (query == null || query.trim().isEmpty()) {
            return null;
        }
        String cleanQuery = query.trim();

        String sql = """
            SELECT c.*
            FROM cbs.client c
            WHERE c.id_no = ? OR c.client_code = ?
            LIMIT 1
        """;

        try {
            List<Customer360DTO> list = jdbcTemplate.query(sql, (rs, rowNum) -> {
                Map<String, String> valMap = new HashMap<>();
                ResultSetMetaData meta = rs.getMetaData();
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    String colName = meta.getColumnLabel(i).toLowerCase();
                    Object val = rs.getObject(i);
                    valMap.put(colName, val != null ? val.toString() : "");
                }

                Customer360DTO dto = new Customer360DTO();
                dto.setClientType(getVal(valMap, "client_type", "type"));
                dto.setClientCode(getVal(valMap, "client_code", "code"));
                dto.setTitle(getVal(valMap, "title"));
                dto.setFullName(getVal(valMap, "full_name", "name"));
                dto.setShortName(getVal(valMap, "short_name", "shortname"));
                dto.setIdNo(getVal(valMap, "id_no", "nic", "nic_no"));
                
                String dob = getVal(valMap, "dob", "date_of_birth");
                String doe = getVal(valMap, "doe", "date_of_establishment");
                String dobDoe = !dob.isEmpty() ? dob : (!doe.isEmpty() ? doe : "-");
                if (dobDoe.contains(" ")) {
                    dobDoe = dobDoe.split(" ")[0];
                }
                dto.setDobDoe(dobDoe);

                dto.setMobile(getVal(valMap, "mobile", "mobile_no", "phone"));
                dto.setMobile2(getVal(valMap, "mobile2", "mobile_no2", "secondary_mobile"));
                dto.setTelephone(getVal(valMap, "telephone", "phone2", "residence_phone"));
                dto.setAddress(getVal(valMap, "address", "client_address"));

                String enteredDate = getVal(valMap, "entered_date", "created_date", "created_at");
                if (enteredDate.contains(" ")) {
                    enteredDate = enteredDate.split(" ")[0];
                }
                dto.setEnteredDate(enteredDate.isEmpty() ? "-" : enteredDate);

                String emp = getVal(valMap, "employee", "is_employee", "staff");
                if ("1".equals(emp) || "Y".equalsIgnoreCase(emp) || "TRUE".equalsIgnoreCase(emp)) {
                    emp = "Yes";
                } else if ("0".equals(emp) || "N".equalsIgnoreCase(emp) || "FALSE".equalsIgnoreCase(emp)) {
                    emp = "No";
                }
                dto.setEmployee(emp.isEmpty() ? "-" : emp);

                return dto;
            }, cleanQuery, cleanQuery);

            if (!list.isEmpty()) {
                return list.get(0);
            }
        } catch (Exception e) {
            logger.error("Error fetching customer details for query {}: {}", cleanQuery, e.getMessage());
        }
        return null;
    }

    private String getVal(Map<String, String> map, String... keys) {
        for (String k : keys) {
            if (map.containsKey(k) && map.get(k) != null && !map.get(k).trim().isEmpty()) {
                return map.get(k).trim();
            }
        }
        return "-";
    }

    public String fetchFacilityList(String requestJsonPayload) {
        logger.info("Calling facility list API with payload: {}", requestJsonPayload);
        
        try {
            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(URI.create(FACILITY_LIST_ENDPOINT))
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(requestJsonPayload))
                    .build();

            HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());
            logger.info("Facility list API response status: {}", response.statusCode());

            if (response.statusCode() == 200 && response.body() != null && !response.body().isEmpty()) {
                return response.body();
            } else if (response.statusCode() == 404) {
                // Try alt URL with single slash if double slash fails
                HttpRequest httpRequestAlt = HttpRequest.newBuilder()
                        .uri(URI.create(FACILITY_LIST_ENDPOINT_ALT))
                        .header("Content-Type", "application/json")
                        .header("Accept", "application/json")
                        .POST(HttpRequest.BodyPublishers.ofString(requestJsonPayload))
                        .build();

                HttpResponse<String> responseAlt = httpClient.send(httpRequestAlt, HttpResponse.BodyHandlers.ofString());
                if (responseAlt.statusCode() == 200 && responseAlt.body() != null && !responseAlt.body().isEmpty()) {
                    return responseAlt.body();
                }
            }
            return response.body() != null ? response.body() : createEmptyFacilityResponse();
        } catch (Exception e) {
            logger.error("Error calling facility list API: {}", e.getMessage(), e);
            return createEmptyFacilityResponse();
        }
    }

    private String createEmptyFacilityResponse() {
        return """
            {
                "status": 200,
                "message": "Successful",
                "data": {
                    "accounts": [],
                    "hasNext": false,
                    "totalElements": 0
                }
            }
        """;
    }
}
