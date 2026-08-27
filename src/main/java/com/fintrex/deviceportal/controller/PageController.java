/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.fintrex.deviceportal.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 *
 * @author thisara
 */
@Controller
public class PageController {

    @GetMapping("/test")
    public String testPage() {
        return "page";
    }

    @GetMapping("/mobile")
    public String mobileDetails() {
        return "mf-details";
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }

    @GetMapping("/dashboard")
    public String dashboard() {
        return "empty_dashboard";
    }

    @GetMapping("/cbs-reports")
    public String cbsReports() {
        return "redirect:/portfolio";
    }

    @GetMapping("/portfolio")
    public String portfolioReport() {
        return "portfolio-report";
    }

    @GetMapping("/client")
    public String clientReport() {
        return "client-report";
    }

    @GetMapping("/transaction")
    public String transactionReport() {
        return "transaction-report";
    }

    @GetMapping("/agreement")
    public String agreementReport() {
        return "agreement-report";
    }

    @GetMapping("/report-logs")
    public String reportLogs() {
        return "report-logs";
    }

    @GetMapping("/access-logs")
    public String accessLogs() {
        return "access-logs";
    }

    @GetMapping("/permission-logs")
    public String permissionLogs() {
        return "permission-logs";
    }

    @GetMapping("/arrears-report")
    public String arrearsReport() {
        return "arrears-report";
    }

    @GetMapping("/npa-report")
    public String npaReport() {
        return "npa-report";
    }

    @GetMapping("/nearing-npa-report")
    public String nearingNpaReport() {
        return "nearing-npa-report";
    }

    @GetMapping("/duplicate-loans-report")
    public String duplicateLoansReport() {
        return "duplicate-loans-report";
    }

    @GetMapping("/unlock-arrears-report")
    public String unlockArrearsReport() {
        return "unlock-arrears-report";
    }

    @GetMapping("/lock-no-arrears-report")
    public String lockNoArrearsReport() {
        return "lock-no-arrears-report";
    }

    @GetMapping("/one-rental-report")
    public String oneRentalReport() {
        return "one-rental-report";
    }

    @GetMapping("/settled-report")
    public String settledReport() {
        return "settled-report";
    }

    @GetMapping("/matured-low-balance-report")
    public String maturedLowBalanceReport() {
        return "matured-low-balance-report";
    }

    @GetMapping("/multiple-payments-report")
    public String multiplePaymentsReport() {
        return "multiple-payments-report";
    }

    @GetMapping("/dpd-bucket-report")
    public String dpdBucketReport() {
        return "dpd-bucket-report";
    }

    @GetMapping("/vendor-payments")
    public String vendorPaymentsReport() {
        return "vendor-payments";
    }

    @GetMapping("/vendor-payments-exception")
    public String vendorPaymentsExceptionReport() {
        return "vendor-payments-exception";
    }

}

