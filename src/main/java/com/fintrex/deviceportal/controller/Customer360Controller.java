package com.fintrex.deviceportal.controller;

import com.fintrex.deviceportal.dto.Customer360DTO;
import com.fintrex.deviceportal.dto.Customer360SearchResult;
import com.fintrex.deviceportal.service.Customer360Service;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
public class Customer360Controller {

    private final Customer360Service customer360Service;

    public Customer360Controller(Customer360Service customer360Service) {
        this.customer360Service = customer360Service;
    }

    @GetMapping("/api/customer360/search")
    public ResponseEntity<List<Customer360SearchResult>> search(@RequestParam("query") String query) {
        List<Customer360SearchResult> results = customer360Service.searchCustomers(query);
        return ResponseEntity.ok(results);
    }

    @GetMapping("/api/customer360/details")
    public ResponseEntity<Customer360DTO> getDetails(@RequestParam("query") String query) {
        Customer360DTO details = customer360Service.getCustomerDetails(query);
        if (details == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(details);
    }

    @PostMapping(value = {"/api/customer360/facility/list", "/api/facility/list"}, 
                 consumes = MediaType.APPLICATION_JSON_VALUE, 
                 produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> getFacilityList(@RequestBody String requestBody) {
        String responseBody = customer360Service.fetchFacilityList(requestBody);
        return ResponseEntity.ok(responseBody);
    }
}
