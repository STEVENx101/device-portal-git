package com.fintrex.deviceportal.controller;

import com.fintrex.deviceportal.config.DataTableRequest;
import com.fintrex.deviceportal.config.DataTableResponse;
import com.fintrex.deviceportal.service.CbsReportService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.PrintWriter;
import java.util.*;

@RestController
@RequestMapping("/api/cbs")
public class CbsReportController {

    private final CbsReportService cbsReportService;

    public CbsReportController(CbsReportService cbsReportService) {
        this.cbsReportService = cbsReportService;
    }

    @GetMapping("/metadata")
    public ResponseEntity<Map<String, Object>> getMetadata() {
        return ResponseEntity.ok(cbsReportService.getMetadata());
    }

    @PostMapping("/report1")
    public DataTableResponse getReport1(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Portfolio Report", "VIEW", filtersStr);
        return cbsReportService.fetchReport1(request);
    }

    @GetMapping("/report1/download")
    public void downloadReport1(
            @RequestParam(value = "branch", required = false) String branch,
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "asAt", required = false) String asAt,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {

        List<com.fintrex.deviceportal.dto.Screen> permittedScreens = (List<com.fintrex.deviceportal.dto.Screen>) session.getAttribute("permittedScreens");
        boolean canDownload = permittedScreens != null && permittedScreens.stream()
                .anyMatch(s -> s.getPath().equalsIgnoreCase("/download-reports"));
        if (!canDownload) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to download reports.");
            return;
        }

        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("branch=%s, products=%s, asAt=%s", branch, products, asAt);
        cbsReportService.logReportActivity(username, "Portfolio Report", "DOWNLOAD", filtersStr);

        if (downloadToken != null) {
            response.setHeader("Set-Cookie", "downloadToken=" + downloadToken + "; Path=/");
        }

        List<Map<String, Object>> data = cbsReportService.getReport1Data(branch, products, asAt);

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"portfolio_loan_report.csv\"");

        PrintWriter writer = response.getWriter();
        writer.println("Portfolio Date,Account No,Series,Legacy Account No,Branch Name,Product Name,Loan Amount,Rental,Total Due,Exposure,DPD,Performing Status,Loan Status,Disbursed Date,Closed Date,IMEI No,Device Status,Workhub SP No,Platform");

        for (Map<String, Object> row : data) {
            writer.println(String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s",
                    cleanCsv(row.get("portfolio_date")),
                    cleanCsv(row.get("account_no")),
                    cleanCsv(row.get("series")),
                    cleanCsv(row.get("legacy_account_no")),
                    cleanCsv(row.get("branch_name")),
                    cleanCsv(row.get("product_name")),
                    cleanCsv(row.get("loan_amount")),
                    cleanCsv(row.get("rental")),
                    cleanCsv(row.get("total_due")),
                    cleanCsv(row.get("exposure")),
                    cleanCsv(row.get("dpd")),
                    cleanCsv(row.get("performing_status")),
                    cleanCsv(row.get("portfolio_loan_status")),
                    cleanCsv(row.get("disbursed_date")),
                    cleanCsv(row.get("closed_date")),
                    cleanCsv(row.get("device_id")),
                    cleanCsv(row.get("device_status")),
                    cleanCsv(row.get("external_id")),
                    cleanCsv(row.get("platform"))
            ));
        }
        writer.flush();
    }

    @PostMapping("/report2")
    public DataTableResponse getReport2(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Client Report", "VIEW", filtersStr);
        return cbsReportService.fetchReport2(request);
    }

    @GetMapping("/report2/download")
    public void downloadReport2(
            @RequestParam(value = "branch", required = false) String branch,
            @RequestParam(value = "fromDate", required = false) String fromDate,
            @RequestParam(value = "toDate", required = false) String toDate,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {

        List<com.fintrex.deviceportal.dto.Screen> permittedScreens = (List<com.fintrex.deviceportal.dto.Screen>) session.getAttribute("permittedScreens");
        boolean canDownload = permittedScreens != null && permittedScreens.stream()
                .anyMatch(s -> s.getPath().equalsIgnoreCase("/download-reports"));
        if (!canDownload) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to download reports.");
            return;
        }

        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("branch=%s, fromDate=%s, toDate=%s", branch, fromDate, toDate);
        cbsReportService.logReportActivity(username, "Client Report", "DOWNLOAD", filtersStr);

        if (downloadToken != null) {
            response.setHeader("Set-Cookie", "downloadToken=" + downloadToken + "; Path=/");
        }

        List<Map<String, Object>> data = cbsReportService.getReport2Data(branch, fromDate, toDate);

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"client_report.csv\"");

        PrintWriter writer = response.getWriter();
        writer.println("Client Code,Client Type,Title,Full Name,NIC No,Mobile,Address,Branch Name,Entered Date");

        for (Map<String, Object> row : data) {
            writer.println(String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s",
                     cleanCsv(row.get("client_code")),
                     cleanCsv(row.get("client_type")),
                     cleanCsv(row.get("title")),
                     cleanCsv(row.get("full_name")),
                     cleanCsv(row.get("id_no")),
                     cleanCsv(row.get("mobile")),
                     cleanCsv(row.get("address")),
                     cleanCsv(row.get("branch_name")),
                     cleanCsv(row.get("entered_date"))
            ));
        }
        writer.flush();
    }

    @PostMapping("/report3")
    public DataTableResponse getReport3(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Transaction Report", "VIEW", filtersStr);
        return cbsReportService.fetchReport3(request);
    }

    @GetMapping("/report3/download")
    public void downloadReport3(
            @RequestParam(value = "branch", required = false) String branch,
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "fromDate", required = false) String fromDate,
            @RequestParam(value = "toDate", required = false) String toDate,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {

        List<com.fintrex.deviceportal.dto.Screen> permittedScreens = (List<com.fintrex.deviceportal.dto.Screen>) session.getAttribute("permittedScreens");
        boolean canDownload = permittedScreens != null && permittedScreens.stream()
                .anyMatch(s -> s.getPath().equalsIgnoreCase("/download-reports"));
        if (!canDownload) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to download reports.");
            return;
        }

        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("branch=%s, products=%s, fromDate=%s, toDate=%s", branch, products, fromDate, toDate);
        cbsReportService.logReportActivity(username, "Transaction Report", "DOWNLOAD", filtersStr);

        if (downloadToken != null) {
            response.setHeader("Set-Cookie", "downloadToken=" + downloadToken + "; Path=/");
        }

        List<Map<String, Object>> data = cbsReportService.getReport3Data(branch, products, fromDate, toDate);

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"transaction_report.csv\"");

        PrintWriter writer = response.getWriter();
        writer.println("Transaction ID,Account No,Legacy Account No,Amount,Date,User,Narration,Branch Name,Product Name");

        for (Map<String, Object> row : data) {
            writer.println(String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s",
                    cleanCsv(row.get("tran_id")),
                    cleanCsv(row.get("account_no")),
                    cleanCsv(row.get("legacy_account_no")),
                    cleanCsv(row.get("amount")),
                    cleanCsv(row.get("date")),
                    cleanCsv(row.get("user")),
                    cleanCsv(row.get("narration")),
                    cleanCsv(row.get("branch_name")),
                    cleanCsv(row.get("product_name"))
            ));
        }
        writer.flush();
    }

    @PostMapping("/report4")
    public DataTableResponse getReport4(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Agreement Report", "VIEW", filtersStr);
        return cbsReportService.fetchReport4(request);
    }

    @GetMapping("/report4/download")
    public void downloadReport4(
            @RequestParam(value = "branch", required = false) String branch,
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "fromDate", required = false) String fromDate,
            @RequestParam(value = "toDate", required = false) String toDate,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {

        List<com.fintrex.deviceportal.dto.Screen> permittedScreens = (List<com.fintrex.deviceportal.dto.Screen>) session.getAttribute("permittedScreens");
        boolean canDownload = permittedScreens != null && permittedScreens.stream()
                .anyMatch(s -> s.getPath().equalsIgnoreCase("/download-reports"));
        if (!canDownload) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to download reports.");
            return;
        }

        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("branch=%s, products=%s, fromDate=%s, toDate=%s", branch, products, fromDate, toDate);
        cbsReportService.logReportActivity(username, "Agreement Report", "DOWNLOAD", filtersStr);

        if (downloadToken != null) {
            response.setHeader("Set-Cookie", "downloadToken=" + downloadToken + "; Path=/");
        }

        List<Map<String, Object>> data = cbsReportService.getReport4Data(branch, products, fromDate, toDate);

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"agreement_report.csv\"");

        PrintWriter writer = response.getWriter();
        writer.println("Account No,Series,Legacy Account No,Client Code,Client Name,NIC No,Branch Name,Product Name,Loan Amount,Period,Rental,Rate,Disbursed Date,Closed Date");

        for (Map<String, Object> row : data) {
            writer.println(String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s",
                    cleanCsv(row.get("account_no")),
                    cleanCsv(row.get("series")),
                    cleanCsv(row.get("legacy_account_no")),
                    cleanCsv(row.get("client_code")),
                    cleanCsv(row.get("client_name")),
                    cleanCsv(row.get("id_no")),
                    cleanCsv(row.get("branch_name")),
                    cleanCsv(row.get("product_name")),
                    cleanCsv(row.get("loan_amount")),
                    cleanCsv(row.get("period")),
                    cleanCsv(row.get("rental")),
                    cleanCsv(row.get("rate")),
                    cleanCsv(row.get("disbursed_date")),
                    cleanCsv(row.get("closed_date"))
            ));
        }
        writer.flush();
    }

    @PostMapping("/report-logs")
    public DataTableResponse getReportLogs(@RequestBody DataTableRequest request) {
        return cbsReportService.fetchReportLogs(request);
    }

    @PostMapping("/arrears")
    public DataTableResponse getArrears(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Arrears Report", "VIEW", filtersStr);
        return cbsReportService.fetchArrearsReport(request);
    }

    @GetMapping("/arrears/download")
    public void downloadArrears(
            @RequestParam(value = "asAt", required = false) String asAt,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s", asAt);
        cbsReportService.logReportActivity(username, "Arrears Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getArrearsReportData(asAt);
        writeRecoveryCsv(response, "arrears_report.csv", data);
    }

    @PostMapping("/npa")
    public DataTableResponse getNpa(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "NPA Report", "VIEW", filtersStr);
        return cbsReportService.fetchNpaReport(request);
    }

    @GetMapping("/npa/download")
    public void downloadNpa(
            @RequestParam(value = "asAt", required = false) String asAt,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s", asAt);
        cbsReportService.logReportActivity(username, "NPA Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getNpaReportData(asAt);
        writeRecoveryCsv(response, "npa_report.csv", data);
    }

    @PostMapping("/nearing-npa")
    public DataTableResponse getNearingNpa(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Nearing NPA Report", "VIEW", filtersStr);
        return cbsReportService.fetchNearingNpaReport(request);
    }

    @GetMapping("/nearing-npa/download")
    public void downloadNearingNpa(
            @RequestParam(value = "asAt", required = false) String asAt,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s", asAt);
        cbsReportService.logReportActivity(username, "Nearing NPA Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getNearingNpaReportData(asAt);
        writeRecoveryCsv(response, "nearing_npa_report.csv", data);
    }

    @PostMapping("/duplicate-loans")
    public DataTableResponse getDuplicateLoans(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Duplicate Loans Report", "VIEW", filtersStr);
        return cbsReportService.fetchDuplicateLoansReport(request);
    }

    @GetMapping("/duplicate-loans/download")
    public void downloadDuplicateLoans(
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        cbsReportService.logReportActivity(username, "Duplicate Loans Report", "DOWNLOAD", "none");

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getDuplicateLoansReportData();
        writeDuplicateLoansCsv(response, "duplicate_loans_report.csv", data);
    }

    @PostMapping("/unlock-arrears")
    public DataTableResponse getUnlockArrears(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Unlock with Arrears Exception Report", "VIEW", filtersStr);
        return cbsReportService.fetchUnlockArrearsReport(request);
    }

    @GetMapping("/unlock-arrears/download")
    public void downloadUnlockArrears(
            @RequestParam(value = "asAt", required = false) String asAt,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s", asAt);
        cbsReportService.logReportActivity(username, "Unlock with Arrears Exception Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getUnlockArrearsReportData(asAt);
        writeExceptionLockCsv(response, "unlock_with_arrears_report.csv", data);
    }

    @PostMapping("/lock-no-arrears")
    public DataTableResponse getLockNoArrears(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Lock with No Arrears Exception Report", "VIEW", filtersStr);
        return cbsReportService.fetchLockNoArrearsReport(request);
    }

    @GetMapping("/lock-no-arrears/download")
    public void downloadLockNoArrears(
            @RequestParam(value = "asAt", required = false) String asAt,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s", asAt);
        cbsReportService.logReportActivity(username, "Lock with No Arrears Exception Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getLockNoArrearsReportData(asAt);
        writeExceptionLockCsv(response, "lock_with_no_arrears_report.csv", data);
    }

    private void writeExceptionLockCsv(HttpServletResponse response, String filename, List<Map<String, Object>> data) throws Exception {
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        PrintWriter writer = response.getWriter();
        writer.println("Account No,Series,Legacy Account No,Customer Name,NIC/ID No,Mobile No,Address,Loan Amount,Rental,Total Due,Exposure,DPD,Locked Status,Recovery Officer");

        for (Map<String, Object> row : data) {
            writer.println(String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s",
                    cleanCsv(row.get("account_no")),
                    cleanCsv(row.get("series")),
                    cleanCsv(row.get("legacy_account_no")),
                    cleanCsv(row.get("client_name")),
                    cleanCsv(row.get("client_nic")),
                    cleanCsv(row.get("client_mobile")),
                    cleanCsv(row.get("client_address")),
                    cleanCsv(row.get("loan_amount")),
                    cleanCsv(row.get("rental")),
                    cleanCsv(row.get("total_due")),
                    cleanCsv(row.get("exposure")),
                    cleanCsv(row.get("dpd")),
                    cleanCsv(row.get("lock_status")),
                    cleanCsv(row.get("recovery_officer"))
            ));
        }
        writer.flush();
    }

    private void verifyDownloadPermission(HttpSession session, HttpServletResponse response) throws Exception {
        List<com.fintrex.deviceportal.dto.Screen> permittedScreens = (List<com.fintrex.deviceportal.dto.Screen>) session.getAttribute("permittedScreens");
        boolean canDownload = permittedScreens != null && permittedScreens.stream()
                .anyMatch(s -> s.getPath().equalsIgnoreCase("/download-reports"));
        if (!canDownload) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to download reports.");
            throw new SecurityException("No download permission");
        }
    }

    private void setDownloadTokenCookie(HttpServletResponse response, String downloadToken) {
        if (downloadToken != null) {
            response.setHeader("Set-Cookie", "downloadToken=" + downloadToken + "; Path=/");
        }
    }

    private void writeRecoveryCsv(HttpServletResponse response, String filename, List<Map<String, Object>> data) throws Exception {
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        PrintWriter writer = response.getWriter();
        writer.println("Account No,Series,Legacy Account No,Customer Name,NIC/ID No,Mobile No,Address,Loan Amount,Rental,Total Due,Exposure,DPD,Status,Performing Status,NPL Status,Recovery Officer,Last Payment Date,Last Payment Amount");

        for (Map<String, Object> row : data) {
            writer.println(String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s",
                    cleanCsv(row.get("account_no")),
                    cleanCsv(row.get("series")),
                    cleanCsv(row.get("legacy_account_no")),
                    cleanCsv(row.get("client_name")),
                    cleanCsv(row.get("client_nic")),
                    cleanCsv(row.get("client_mobile")),
                    cleanCsv(row.get("client_address")),
                    cleanCsv(row.get("loan_amount")),
                    cleanCsv(row.get("rental")),
                    cleanCsv(row.get("total_due")),
                    cleanCsv(row.get("exposure")),
                    cleanCsv(row.get("dpd")),
                    cleanCsv(row.get("loan_status")),
                    cleanCsv(row.get("performing_status")),
                    cleanCsv(row.get("npl_status")),
                    cleanCsv(row.get("recovery_officer")),
                    cleanCsv(row.get("last_payment_date")),
                    cleanCsv(row.get("last_payment_amount"))
            ));
        }
        writer.flush();
    }

    private void writeDuplicateLoansCsv(HttpServletResponse response, String filename, List<Map<String, Object>> data) throws Exception {
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        PrintWriter writer = response.getWriter();
        writer.println("IMEI No,Account No,Series,Legacy Account No,Customer Name,NIC/ID No,Loan Amount,Vendor Name");

        for (Map<String, Object> row : data) {
            writer.println(String.format("%s,%s,%s,%s,%s,%s,%s,%s",
                    cleanCsv(row.get("imei_no")),
                    cleanCsv(row.get("account_no")),
                    cleanCsv(row.get("series")),
                    cleanCsv(row.get("legacy_account_no")),
                    cleanCsv(row.get("client_name")),
                    cleanCsv(row.get("client_nic")),
                    cleanCsv(row.get("loan_amount")),
                    cleanCsv(row.get("vendor_name"))
            ));
        }
        writer.flush();
    }

    private String cleanCsv(Object val) {
        if (val == null) {
            return "";
        }
        String s = val.toString().replace("\"", "\"\"");
        if (s.contains(",") || s.contains("\n") || s.contains("\r")) {
            return "\"" + s + "\"";
        }
        return s;
    }
}
