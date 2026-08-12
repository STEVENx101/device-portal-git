package com.fintrex.deviceportal.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "bulk_upload_detail", schema = "device_portal")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BulkUploadDetail {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "bulk_id")
    private BulkUpload bulkId;

    private String paymentId;
    private String accountNo;
    private Double amount;
    private String narration;
    private LocalDateTime pushed;
    private LocalDateTime ended;
    private String status;
    private String response;
}
