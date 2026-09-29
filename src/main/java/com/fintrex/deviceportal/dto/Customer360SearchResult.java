package com.fintrex.deviceportal.dto;

public class Customer360SearchResult {
    private String clientCode;
    private String fullName;
    private String idNo;
    private String mobile;

    public Customer360SearchResult() {}

    public Customer360SearchResult(String clientCode, String fullName, String idNo, String mobile) {
        this.clientCode = clientCode;
        this.fullName = fullName;
        this.idNo = idNo;
        this.mobile = mobile;
    }

    public String getClientCode() { return clientCode; }
    public void setClientCode(String clientCode) { this.clientCode = clientCode; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getIdNo() { return idNo; }
    public void setIdNo(String idNo) { this.idNo = idNo; }

    public String getMobile() { return mobile; }
    public void setMobile(String mobile) { this.mobile = mobile; }
}
