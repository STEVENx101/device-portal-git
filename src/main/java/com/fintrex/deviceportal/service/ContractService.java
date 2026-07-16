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
                t.tran_id AS receipt_no, 
                DATE(t.date) AS receipt_date, 
                t.narration AS receipt_mode, 
                t.narration AS narration, 
                t.amount AS amount 
            FROM cbs.transaction t 
            JOIN cbs.loan l ON t.account_no = l.account_no
            WHERE l.account_no = '""" + finNo + """
            ' OR l.legacy_account_no = '""" + finNo + """
            ' 
            ORDER BY t.date DESC 
            LIMIT 5""";

        String finalQuery = """
            SELECT 
                t.receipt_no, 
                t.receipt_date, 
                t.receipt_mode, 
                t.narration, 
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
            JOIN cbs.loan l ON s.finance_no = l.account_no
            WHERE l.account_no = '""" + finNo + """
            ' OR l.legacy_account_no = '""" + finNo + """
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

    public DataTableResponse fetchlockdata(DataTableRequest req) throws Exception {
        String finNo = req.getData() != null ? req.getData().toString().trim() : null;
        System.out.println("FIN_NO for Lock Log: " + finNo);

        String innerQuery = """
            SELECT 
                l.status, 
                l.date, 
                l.changed_by, 
                l.reason 
            FROM loan.lock_log l 
            JOIN cbs.loan cl ON l.finance_no = cl.account_no
            WHERE cl.account_no = '""" + finNo + """
            ' OR cl.legacy_account_no = '""" + finNo + """
            ' 
            ORDER BY l.date DESC""";

        String finalQuery = """
            SELECT 
                t.status, 
                t.date, 
                t.changed_by, 
                t.reason 
            FROM (""" + innerQuery + ") t WHERE TRUE";

        return datatable.dataTable(req, finalQuery);
    }

    public java.util.Map<String, Object> getDashboardStats() {
        return contractRepository.getDashboardStats();
    }

    public List<java.util.Map<String, Object>> getRecentLocks() {
        return contractRepository.getRecentLocks();
    }

    public List<java.util.Map<String, Object>> getRemarks(String financeNo) {
        if (financeNo == null || financeNo.trim().isEmpty()) {
            return List.of();
        }
        return contractRepository.getRemarks(financeNo.trim());
    }

    public void addRemark(String financeNo, String remark, String username) {
        if (financeNo == null || financeNo.trim().isEmpty() || remark == null || remark.trim().isEmpty()) {
            return;
        }
        contractRepository.addRemark(financeNo.trim(), remark.trim(), username);
    }
}
