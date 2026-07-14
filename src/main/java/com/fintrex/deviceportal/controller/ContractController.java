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

@RestController
@RequestMapping("/api/contracts")
public class ContractController {

    private final ContractService contractService;

    public ContractController(ContractService contractService) {
        this.contractService = contractService;
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
}
