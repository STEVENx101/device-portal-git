package com.fintrex.deviceportal.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ContractDetails {
    private String financeNo;
    private String contractStatus;
    private BigDecimal amtToCollected;
    private BigDecimal exposure;
    private String performingStatus;
    private String security;
    private String model;
    private String nicNo;
    private String fullName;
    private String address;
    private String mobileNo;

    private String g1;
    private String g1Address;
    private String g1Contact;

    private String g2;
    private String g2Address;
    private String g2Contact;

    private String g3;
    private String g3Address;
    private String g3Contact;

    private String facilityGrantDate;
    private String maturityDate;
    private String dueDate;
    private BigDecimal rental;
    private Integer period;
    private BigDecimal financeAmount;
    private Integer arrDays;

    private String nextLockDate;
    private Integer locked;
    private String product;
    private String currentDeviceStatus;

    private String imeiNo;
    private String workhubSpNo;
    private String g1Nic;
    private String g2Nic;
    private String g3Nic;
    private String vendorName;

    public void setReceipts(List<Receipt> receipts) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
