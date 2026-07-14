/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.fintrex.deviceportal.dto;

import java.math.BigDecimal;

/**
 *
 * @author poornap
 */
public class Receipt {

    private String receiptNumber;
    private BigDecimal amount;
    private String receiptDate;

    public Receipt() {
    }

    public Receipt (String receiptNumber, BigDecimal amount, String receiptDate) {
        this.receiptNumber = receiptNumber;
        this.amount = amount;
        this.receiptDate = receiptDate;
    }

    public String getReceiptNumber() {
        return receiptNumber;
    }

    public void setReceiptNumber(String receiptNumber) {
        this.receiptNumber = receiptNumber;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getReceiptDate() {
        return receiptDate;
    }

    public void setReceiptDate(String receiptDate) {
        this.receiptDate = receiptDate;
    }
}
