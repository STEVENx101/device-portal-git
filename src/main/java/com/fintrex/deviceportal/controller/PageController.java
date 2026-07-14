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
        return "cbs-reports";
    }

}
