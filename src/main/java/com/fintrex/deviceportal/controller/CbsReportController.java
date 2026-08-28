package com.fintrex.deviceportal.controller;

import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Cell;
import com.fintrex.deviceportal.config.DataTableRequest;
import com.fintrex.deviceportal.config.DataTableResponse;
import com.fintrex.deviceportal.service.CbsReportService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
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

        List<String> headersList = new java.util.ArrayList<>();
        List<String> keysList = new java.util.ArrayList<>();

        if (data != null && !data.isEmpty()) {
            Map<String, Object> firstRow = data.get(0);
            for (String key : firstRow.keySet()) {
                keysList.add(key);
                String header = key.replace("portfolio_", "");
                header = header.replace("_", " ");
                StringBuilder title = new StringBuilder();
                for (String word : header.split(" ")) {
                    if (word.length() > 0) {
                        title.append(Character.toUpperCase(word.charAt(0))).append(word.substring(1)).append(" ");
                    }
                }
                headersList.add(title.toString().trim());
            }
        } else {
            headersList.addAll(java.util.Arrays.asList("Portfolio Date","Account No","Series","Legacy Account No","Branch Name","Client Code","Product Name","Loan Amount","Rental","Rate","Period","Total Due","Exposure","DPD","Performing Status","Loan Status","Disbursed Date","Closed Date","IMEI No","Device Status","Workhub SP No","Platform"));
            keysList.addAll(java.util.Arrays.asList("portfolio_date","account_no","series","legacy_account_no","branch_name","client_code","product_name","loan_amount","rental","rate","period","total_due","exposure","dpd","performing_status","portfolio_loan_status","disbursed_date","closed_date","device_id","device_status","external_id","platform"));
        }

        String[] headers = headersList.toArray(new String[0]);
        String[] keys = keysList.toArray(new String[0]);
        writeExcel(response, "portfolio_loan_report.xlsx", headers, keys, data);
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
        cbsReportService.logReportActivity(username, "Client Report", "DOWNLOAD", filtersStr);

        if (downloadToken != null) {
            response.setHeader("Set-Cookie", "downloadToken=" + downloadToken + "; Path=/");
        }

        List<Map<String, Object>> data = cbsReportService.getReport2Data(branch, products, fromDate, toDate);

        String[] headers = {"Client Code","Client Type","Title","NIC No","Mobile","Address","Entered Date","Full Name"};
        String[] keys = {"client_code","client_type","title","id_no","mobile","address","entered_date","full_name"};
        writeExcel(response, "client_report.xlsx", headers, keys, data);
    }

    @PostMapping("/report3")
    public DataTableResponse getReport3(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Customer Payments Report", "VIEW", filtersStr);
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
        cbsReportService.logReportActivity(username, "Customer Payments Report", "DOWNLOAD", filtersStr);

        if (downloadToken != null) {
            response.setHeader("Set-Cookie", "downloadToken=" + downloadToken + "; Path=/");
        }

        List<Map<String, Object>> data = cbsReportService.getReport3Data(branch, products, fromDate, toDate);

        String[] headers = {"Transaction ID","Account No","Legacy Account No","Amount","Date","User","Channel","Narration","Product Name"};
        String[] keys = {"tran_id","account_no","legacy_account_no","amount","date","user","channel","narration","product_name"};
        writeExcel(response, "customer_payments_report.xlsx", headers, keys, data);
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

        String[] headers = {"Account No","Series","Legacy Account No","Client Code","NIC No","Product Name","Loan Amount","Period","Rental","Rate","Disbursed Date","Closed Date","Client Name"};
        String[] keys = {"account_no","series","legacy_account_no","client_code","id_no","product_name","loan_amount","period","rental","rate","disbursed_date","closed_date","client_name"};
        writeExcel(response, "agreement_report.xlsx", headers, keys, data);
    }

    @PostMapping("/report-logs")
    public DataTableResponse getReportLogs(@RequestBody DataTableRequest request) {
        return cbsReportService.fetchReportLogs(request);
    }

    @PostMapping("/access-logs")
    public DataTableResponse getAccessLogs(@RequestBody DataTableRequest request) {
        return cbsReportService.fetchAccessLogs(request);
    }

    @PostMapping("/permission-logs")
    public DataTableResponse getPermissionLogs(@RequestBody DataTableRequest request) {
        return cbsReportService.fetchPermissionLogs(request);
    }

    @PostMapping("/arrears")
    public DataTableResponse getArrears(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Arrears Report", "VIEW", filtersStr);
        return cbsReportService.fetchArrearsReport(request);
    }

    @PostMapping("/arrears/summary")
    public ResponseEntity<Map<String, Object>> getArrearsSummary(@RequestBody Map<String, Object> filters) {
        return ResponseEntity.ok(cbsReportService.getArrearsSummary(filters));
    }

    @GetMapping("/arrears/download")
    public void downloadArrears(
            @RequestParam(value = "asAt", required = false) String asAt,
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s, products=%s", asAt, products);
        cbsReportService.logReportActivity(username, "Arrears Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getArrearsReportData(asAt, products);
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
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s, products=%s", asAt, products);
        cbsReportService.logReportActivity(username, "NPA Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getNpaReportData(asAt, products);
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
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s, products=%s", asAt, products);
        cbsReportService.logReportActivity(username, "Nearing NPA Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getNearingNpaReportData(asAt, products);
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
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("products=%s", products);
        cbsReportService.logReportActivity(username, "Duplicate Loans Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getDuplicateLoansReportData(products);
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
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s, products=%s", asAt, products);
        cbsReportService.logReportActivity(username, "Unlock with Arrears Exception Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getUnlockArrearsReportData(asAt, products);
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
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s, products=%s", asAt, products);
        cbsReportService.logReportActivity(username, "Lock with No Arrears Exception Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getLockNoArrearsReportData(asAt, products);
        writeExceptionLockCsv(response, "lock_with_no_arrears_report.csv", data);
    }

    @PostMapping("/one-rental")
    public DataTableResponse getOneRental(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Last Rental Remaining Exception Report", "VIEW", filtersStr);
        return cbsReportService.fetchOneRentalReport(request);
    }

    @GetMapping("/one-rental/download")
    public void downloadOneRental(
            @RequestParam(value = "asAt", required = false) String asAt,
            @RequestParam(value = "arrearsFilter", required = false) String arrearsFilter,
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s, arrearsFilter=%s, products=%s", asAt, arrearsFilter, products);
        cbsReportService.logReportActivity(username, "Last Rental Remaining Exception Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getOneRentalReportData(asAt, arrearsFilter, products);
        writeExceptionLockCsv(response, "last_rental_remaining_report.csv", data);
    }

    @PostMapping("/settled-report")
    public DataTableResponse getSettledReport(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Settled & Early Settled Exception Report", "VIEW", filtersStr);
        return cbsReportService.fetchSettledReport(request);
    }

    @GetMapping("/settled-report/download")
    public void downloadSettledReport(
            @RequestParam(value = "fromDate", required = false) String fromDate,
            @RequestParam(value = "toDate", required = false) String toDate,
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("fromDate=%s, toDate=%s, products=%s", fromDate, toDate, products);
        cbsReportService.logReportActivity(username, "Settled & Early Settled Exception Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getSettledReportData(fromDate, toDate, products);
        String xlsxFilename = "settled_and_early_settled_report.xlsx";
        String[] headers = {"Account No","Series","Legacy Account No","NIC/ID No","Mobile No","Address","Loan Amount","Rental","Disbursed Date","Closed Date","Account Status","Customer Name"};
        String[] keys = {"account_no","series","legacy_account_no","client_nic","client_mobile","client_address","loan_amount","rental","disbursed_date","closed_date","account_status","client_name"};
        writeExcel(response, xlsxFilename, headers, keys, data);
    }

    @PostMapping("/multiple-payments-report")
    public DataTableResponse getMultiplePaymentsReport(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Multiple Payments Exception Report", "VIEW", filtersStr);
        return cbsReportService.fetchMultiplePaymentsReport(request);
    }

    @GetMapping("/multiple-payments-report/download")
    public void downloadMultiplePaymentsReport(
            @RequestParam(value = "fromDate", required = false) String fromDate,
            @RequestParam(value = "toDate", required = false) String toDate,
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("fromDate=%s, toDate=%s, products=%s", fromDate, toDate, products);
        cbsReportService.logReportActivity(username, "Multiple Payments Exception Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getMultiplePaymentsReportData(fromDate, toDate, products);
        writeMultiplePaymentsCsv(response, "multiple_payments_report.csv", data);
    }

    private void writeMultiplePaymentsCsv(HttpServletResponse response, String filename, List<Map<String, Object>> data) throws Exception {
        String xlsxFilename = filename.replace(".csv", ".xlsx");
        String[] headers = {"Tran ID", "Account No", "Legacy Account No", "Amount", "Date", "User", "Narration", "Channel", "Same Amount Duplicate"};
        String[] keys = {"tran_id", "account_no", "legacy_account_no", "amount", "date", "user", "narration", "channel", "same_amount_duplicate"};
        writeExcel(response, xlsxFilename, headers, keys, data);
    }

    @PostMapping("/matured-low-balance")
    public DataTableResponse getMaturedLowBalance(@RequestBody DataTableRequest request, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = request.getData() != null ? request.getData().toString() : "none";
        cbsReportService.logReportActivity(username, "Matured Low Balance Exception Report", "VIEW", filtersStr);
        return cbsReportService.fetchMaturedLowBalanceReport(request);
    }

    @GetMapping("/matured-low-balance/download")
    public void downloadMaturedLowBalance(
            @RequestParam(value = "asAt", required = false) String asAt,
            @RequestParam(value = "lowAmount", required = false) Double lowAmount,
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "downloadToken", required = false) String downloadToken,
            HttpSession session,
            HttpServletResponse response) throws Exception {
        verifyDownloadPermission(session, response);
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = String.format("asAt=%s, lowAmount=%s, products=%s", asAt, lowAmount, products);
        cbsReportService.logReportActivity(username, "Matured Low Balance Exception Report", "DOWNLOAD", filtersStr);

        setDownloadTokenCookie(response, downloadToken);
        List<Map<String, Object>> data = cbsReportService.getMaturedLowBalanceReportData(asAt, lowAmount, products);
        writeMaturedLowBalanceCsv(response, "matured_low_balance_report.csv", data);
    }

    private void writeExceptionLockCsv(HttpServletResponse response, String filename, List<Map<String, Object>> data) throws Exception {
        String xlsxFilename = filename.replace(".csv", ".xlsx");
        String[] headers = {"Account No","Series","Legacy Account No","NIC/ID No","Mobile No","Address","Loan Amount","Rental","Total Due","Exposure","DPD","Locked Status","Recovery Officer","Customer Name"};
        String[] keys = {"account_no","series","legacy_account_no","client_nic","client_mobile","client_address","loan_amount","rental","total_due","exposure","dpd","lock_status","recovery_officer","client_name"};
        writeExcel(response, xlsxFilename, headers, keys, data);
    }

    private void writeMaturedLowBalanceCsv(HttpServletResponse response, String filename, List<Map<String, Object>> data) throws Exception {
        String xlsxFilename = filename.replace(".csv", ".xlsx");
        String[] headers = {"Account No","Series","Legacy Account No","NIC/ID No","Mobile No","Mature Date","Loan Amount","Rental","Total Due","Exposure","DPD","Account Status","Locked Status","Recovery Officer","Customer Name"};
        String[] keys = {"account_no","series","legacy_account_no","client_nic","client_mobile","mature_date","loan_amount","rental","total_due","exposure","dpd","account_status","lock_status","recovery_officer","client_name"};
        writeExcel(response, xlsxFilename, headers, keys, data);
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
        String xlsxFilename = filename.replace(".csv", ".xlsx");
        String[] headers = {"Account No","Series","Legacy Account No","NIC/ID No","Mobile No","Address","Loan Amount","Rental","Total Due","Exposure","DPD","Status","Performing Status","NPL Status","Recovery Officer","Last Payment Date","Last Payment Amount","Customer Name"};
        String[] keys = {"account_no","series","legacy_account_no","client_nic","client_mobile","client_address","loan_amount","rental","total_due","exposure","dpd","loan_status","performing_status","npl_status","recovery_officer","last_payment_date","last_payment_amount","client_name"};
        writeExcel(response, xlsxFilename, headers, keys, data);
    }

    private void writeDuplicateLoansCsv(HttpServletResponse response, String filename, List<Map<String, Object>> data) throws Exception {
        String xlsxFilename = filename.replace(".csv", ".xlsx");
        String[] headers = {"IMEI No","Account No","Series","Legacy Account No","NIC/ID No","Loan Amount","Vendor Name","Customer Name"};
        String[] keys = {"imei_no","account_no","series","legacy_account_no","client_nic","loan_amount","vendor_name","client_name"};
        writeExcel(response, xlsxFilename, headers, keys, data);
    }


    private void writeExcel(HttpServletResponse response, String filename, String[] headers, String[] keys, List<Map<String, Object>> data) throws Exception {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
        
        try (SXSSFWorkbook workbook = new SXSSFWorkbook(100)) {
            Sheet sheet = workbook.createSheet("Report Data");
            
            // Header row
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
            }
            
            // Data rows
            for (int r = 0; r < data.size(); r++) {
                Map<String, Object> rowMap = data.get(r);
                Row row = sheet.createRow(r + 1);
                for (int c = 0; c < keys.length; c++) {
                    Object val = rowMap.get(keys[c]);
                    Cell cell = row.createCell(c);
                    if (val != null) {
                        if (val instanceof Number) {
                            cell.setCellValue(((Number) val).doubleValue());
                        } else {
                            cell.setCellValue(val.toString());
                        }
                    }
                }
            }
            
            workbook.write(response.getOutputStream());
        }
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

    @PostMapping("/dpd-bucket")
    public ResponseEntity<Map<String, Object>> getDpdBucketReport(@RequestBody(required = false) Map<String, Object> filters, HttpSession session) {
        com.fintrex.deviceportal.dto.User currentUser = (com.fintrex.deviceportal.dto.User) session.getAttribute("currentUser");
        String username = currentUser != null ? currentUser.getUsername() : "system";
        String filtersStr = filters != null ? filters.toString() : "none";
        cbsReportService.logReportActivity(username, "DPD Bucket Report", "VIEW", filtersStr);
        return ResponseEntity.ok(cbsReportService.fetchDpdBucketReport(filters));
    }

    @GetMapping("/dpd-bucket/download")
    public void downloadDpdBucketReport(
            @RequestParam(value = "dimension", required = false, defaultValue = "dealer") String dimension,
            @RequestParam(value = "branch", required = false) String branch,
            @RequestParam(value = "products", required = false) List<String> products,
            @RequestParam(value = "asAt", required = false) String asAt,
            @RequestParam(value = "dealer", required = false) String dealer,
            @RequestParam(value = "model", required = false) String model,
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
        String filtersStr = String.format("dimension=%s, branch=%s, products=%s, asAt=%s, dealer=%s, model=%s", dimension, branch, products, asAt, dealer, model);
        cbsReportService.logReportActivity(username, "DPD Bucket Report", "DOWNLOAD", filtersStr);

        if (downloadToken != null) {
            response.setHeader("Set-Cookie", "downloadToken=" + downloadToken + "; Path=/");
        }

        Map<String, Object> filters = new HashMap<>();
        filters.put("dimension", dimension);
        filters.put("branch", branch);
        filters.put("products", products);
        filters.put("asAt", asAt);
        filters.put("dealer", dealer);
        filters.put("model", model);

        Map<String, Object> reportData = cbsReportService.fetchDpdBucketReport(filters);

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"dpd_bucket_report_" + dimension + ".xlsx\"");

        try (SXSSFWorkbook workbook = new SXSSFWorkbook(100)) {
            Sheet sheet = workbook.createSheet("DPD Bucket Report");
            String[] headers = {"Category","DPD 0 No","DPD 0 Val (Mn)","DPD 0 %","DPD 1-30 No","DPD 1-30 Val (Mn)","DPD 1-30 %","DPD 31-60 No","DPD 31-60 Val (Mn)","DPD 31-60 %","DPD 61-90 No","DPD 61-90 Val (Mn)","DPD 61-90 %","Over 90 DPD No","Over 90 DPD Val (Mn)","Over 90 DPD %","Total No","Total Val (Mn)","Total %"};
            
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) {
                headerRow.createCell(i).setCellValue(headers[i]);
            }

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> rows = (List<Map<String, Object>>) reportData.get("rows");
            int rowIndex = 1;
            String[] keys = {"category","dpd0Count","dpd0ValMn","dpd0Pct","dpd1_30Count","dpd1_30ValMn","dpd1_30Pct","dpd31_60Count","dpd31_60ValMn","dpd31_60Pct","dpd61_90Count","dpd61_90ValMn","dpd61_90Pct","dpdAbove90Count","dpdAbove90ValMn","dpdAbove90Pct","totalCount","totalValMn","totalPct"};
            if (rows != null) {
                for (Map<String, Object> row : rows) {
                    Row rRow = sheet.createRow(rowIndex++);
                    for (int c = 0; c < keys.length; c++) {
                        Object val = row.get(keys[c]);
                        Cell cell = rRow.createCell(c);
                        if (val != null) {
                            if (val instanceof Number) {
                                cell.setCellValue(((Number) val).doubleValue());
                            } else {
                                cell.setCellValue(val.toString());
                            }
                        }
                    }
                }
            }

            @SuppressWarnings("unchecked")
            Map<String, Object> totals = (Map<String, Object>) reportData.get("totals");
            if (totals != null) {
                Row tRow = sheet.createRow(rowIndex);
                String[] totalKeys = {"category","dpd0Count","dpd0ValMn","dpd0Pct","dpd1_30Count","dpd1_30ValMn","dpd1_30Pct","dpd31_60Count","dpd31_60ValMn","dpd31_60Pct","dpd61_90Count","dpd61_90ValMn","dpd61_90Pct","above90Count","above90ValMn","above90Pct","totalCount","totalValMn","totalPct"};
                for (int c = 0; c < totalKeys.length; c++) {
                    Object val = totals.get(totalKeys[c]);
                    Cell cell = tRow.createCell(c);
                    if (val != null) {
                        if (val instanceof Number) {
                            cell.setCellValue(((Number) val).doubleValue());
                        } else {
                            cell.setCellValue(val.toString());
                        }
                    }
                }
            }

            workbook.write(response.getOutputStream());
        }
    }

    @GetMapping("/vendors")
    @ResponseBody
    public List<Map<String, Object>> getDistinctVendors() {
        return cbsReportService.fetchDistinctVendors();
    }

    @GetMapping("/dealers")
    @ResponseBody
    public List<Map<String, Object>> getDistinctDealers() {
        return cbsReportService.fetchDistinctDealers();
    }

    @GetMapping("/models")
    @ResponseBody
    public List<Map<String, Object>> getDistinctModels() {
        return cbsReportService.fetchDistinctModels();
    }

    @PostMapping("/vendor-payments")
    @ResponseBody
    public Map<String, Object> getVendorPaymentsReport(@RequestBody Map<String, Object> filters) {
        return cbsReportService.fetchVendorPaymentsReport(filters, false);
    }

    @GetMapping("/vendor-payments/download")
    public void downloadVendorPaymentsReport(
            @RequestParam(required = false) String dateMode,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String year,
            @RequestParam(required = false) String month,
            @RequestParam(required = false) String fromDate,
            @RequestParam(required = false) String toDate,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String vendor,
            @RequestParam(value = "products", required = false) List<String> products,
            HttpServletResponse response) throws Exception {

        Map<String, Object> filters = new HashMap<>();
        filters.put("dateMode", dateMode);
        filters.put("status", status);
        filters.put("year", year);
        filters.put("month", month);
        filters.put("fromDate", fromDate);
        filters.put("toDate", toDate);
        filters.put("search", search);
        filters.put("vendor", vendor);
        filters.put("products", products);

        Map<String, Object> reportData = cbsReportService.fetchVendorPaymentsReport(filters, false);

        writeVendorPaymentsExcel(response, "vendor_payments_report.xlsx", reportData);
    }

    @PostMapping("/vendor-payments-exception")
    @ResponseBody
    public Map<String, Object> getVendorPaymentsExceptionReport(@RequestBody Map<String, Object> filters) {
        return cbsReportService.fetchVendorPaymentsReport(filters, true);
    }

    @GetMapping("/vendor-payments-exception/download")
    public void downloadVendorPaymentsExceptionReport(
            @RequestParam(required = false) String dateMode,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String year,
            @RequestParam(required = false) String month,
            @RequestParam(required = false) String fromDate,
            @RequestParam(required = false) String toDate,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String vendor,
            @RequestParam(value = "products", required = false) List<String> products,
            HttpServletResponse response) throws Exception {

        Map<String, Object> filters = new HashMap<>();
        filters.put("dateMode", dateMode);
        filters.put("status", status);
        filters.put("year", year);
        filters.put("month", month);
        filters.put("fromDate", fromDate);
        filters.put("toDate", toDate);
        filters.put("search", search);
        filters.put("vendor", vendor);
        filters.put("products", products);

        Map<String, Object> reportData = cbsReportService.fetchVendorPaymentsReport(filters, true);

        writeVendorPaymentsExcel(response, "vendor_payments_exception_report.xlsx", reportData);
    }

    private void writeVendorPaymentsExcel(HttpServletResponse response, String filename, Map<String, Object> reportData) throws Exception {
        String[] headers = {"CEFT ID","Consumer Tran ID","Account ID","Vendor Code","Vendor Name","Destination Account","Destination Account Name","Bank Code","Bank Name","Branch Code","Amount","Trx Date","Ref","SP Number","Status"};
        String[] keys = {"ceft_id","consumer_tran_id","account_id","vendor_code","vendor_name","destination_account","destination_account_name","bank_code","bank_name","branch_code","amount","trx_date","ref","sp_number","status"};
        
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> rows = (List<Map<String, Object>>) reportData.get("rows");
        if (rows == null) {
            rows = new ArrayList<>();
        }
        writeExcel(response, filename, headers, keys, rows);
    }
}
