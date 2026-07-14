package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.config.DataTableRequest;
import com.fintrex.deviceportal.config.DataTableResponse;
import com.fintrex.deviceportal.dto.ContractDetails;
import com.fintrex.deviceportal.dto.ContractSearchResult;
import com.fintrex.deviceportal.config.DataTableRepo;
import com.fintrex.deviceportal.repository.ContractRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ContractService {

    private final ContractRepository contractRepository;
    private final DataTableRepo datatable;

    public ContractService(ContractRepository contractRepository, DataTableRepo datatable) {
        this.contractRepository = contractRepository;
        this.datatable = datatable;
    }

    public List<ContractSearchResult> searchContracts(String financeNo) {
        if (financeNo == null || financeNo.trim().isEmpty()) {
            return List.of();
        }
        return contractRepository.search(financeNo.trim());
    }

    public ContractDetails getContractDetails(String financeNo) {
        if (financeNo == null || financeNo.trim().isEmpty()) {
            return null;
        }
        return contractRepository.getDetails(financeNo.trim());
    }

    public DataTableResponse fetchreceiptdata(DataTableRequest req) throws Exception {

        String finNo = req.getData() != null ? req.getData().toString().trim() : null;

        System.out.println("FIN_NO: " + finNo);

        String innerQuery = """
            SELECT 
                r.REC_NO AS receipt_no, 
                DATE(r.VAL_DATE) AS receipt_date, 
                r.SETTLE_MODE AS receipt_mode, 
                r.REC_AMOUNT AS amount 
            FROM call_center.receipts r 
            WHERE r.FIN_NO = '""" + finNo + """
            ' 
            ORDER BY r.VAL_DATE DESC 
            LIMIT 5""";

        String finalQuery = """
            SELECT 
                t.receipt_no, 
                t.receipt_date, 
                t.receipt_mode, 
                t.amount 
            FROM (""" + innerQuery + ") t WHERE TRUE";

        return datatable.dataTable(req, finalQuery);
    }

    public DataTableResponse fetchsmsdata(DataTableRequest req) throws Exception {

        String finNo = req.getData() != null ? req.getData().toString().trim() : null;

        System.out.println("FIN_NO for SMS: " + finNo);

        String innerQuery = """
            SELECT 
                s.mobile, 
                s.msg, 
                s.date, 
                s.status 
            FROM sms_portal.sms_log s 
            WHERE s.finance_no = '""" + finNo + """
            ' 
            ORDER BY s.date DESC 
            LIMIT 5""";

        String finalQuery = """
            SELECT 
                t.mobile, 
                t.msg, 
                t.date, 
                t.status 
            FROM (""" + innerQuery + ") t WHERE TRUE";

        return datatable.dataTable(req, finalQuery);
    }
}
