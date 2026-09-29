package com.fintrex.deviceportal.dto;

public class Customer360DTO {
    private String clientType;
    private String clientCode;
    private String title;
    private String fullName;
    private String shortName;
    private String idNo;
    private String dobDoe;
    private String mobile;
    private String mobile2;
    private String telephone;
    private String address;
    private String enteredDate;
    private String employee;

    public Customer360DTO() {}

    public Customer360DTO(String clientType, String clientCode, String title, String fullName, 
                          String shortName, String idNo, String dobDoe, String mobile, 
                          String mobile2, String telephone, String address, 
                          String enteredDate, String employee) {
        this.clientType = clientType;
        this.clientCode = clientCode;
        this.title = title;
        this.fullName = fullName;
        this.shortName = shortName;
        this.idNo = idNo;
        this.dobDoe = dobDoe;
        this.mobile = mobile;
        this.mobile2 = mobile2;
        this.telephone = telephone;
        this.address = address;
        this.enteredDate = enteredDate;
        this.employee = employee;
    }

    public String getClientType() { return clientType; }
    public void setClientType(String clientType) { this.clientType = clientType; }

    public String getClientCode() { return clientCode; }
    public void setClientCode(String clientCode) { this.clientCode = clientCode; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getShortName() { return shortName; }
    public void setShortName(String shortName) { this.shortName = shortName; }

    public String getIdNo() { return idNo; }
    public void setIdNo(String idNo) { this.idNo = idNo; }

    public String getDobDoe() { return dobDoe; }
    public void setDobDoe(String dobDoe) { this.dobDoe = dobDoe; }

    public String getMobile() { return mobile; }
    public void setMobile(String mobile) { this.mobile = mobile; }

    public String getMobile2() { return mobile2; }
    public void setMobile2(String mobile2) { this.mobile2 = mobile2; }

    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getEnteredDate() { return enteredDate; }
    public void setEnteredDate(String enteredDate) { this.enteredDate = enteredDate; }

    public String getEmployee() { return employee; }
    public void setEmployee(String employee) { this.employee = employee; }
}
