package com.fintrex.deviceportal.scratch;

import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import java.io.FileOutputStream;

public class CreateSampleExcel {
    public static void main(String[] args) {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            XSSFSheet sheet = workbook.createSheet("Payments");
            
            // Header Row
            XSSFRow header = sheet.createRow(0);
            header.createCell(0).setCellValue("Request ID");
            header.createCell(1).setCellValue("Account No");
            header.createCell(2).setCellValue("Amount");
            header.createCell(3).setCellValue("Narration");
            
            // Row 1
            XSSFRow row1 = sheet.createRow(1);
            row1.createCell(0).setCellValue("REQ001");
            row1.createCell(1).setCellValue("ACC1000293");
            row1.createCell(2).setCellValue("15000.00");
            row1.createCell(3).setCellValue("Test Payment 1");
            
            // Row 2
            XSSFRow row2 = sheet.createRow(2);
            row2.createCell(0).setCellValue("REQ002");
            row2.createCell(1).setCellValue("ACC1000305");
            row2.createCell(2).setCellValue("7500.50");
            row2.createCell(3).setCellValue("Test Payment 2");
            
            try (FileOutputStream fos = new FileOutputStream("sample_payment_upload.xlsx")) {
                workbook.write(fos);
            }
            System.out.println("Sample excel file generated successfully.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
