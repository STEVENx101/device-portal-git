package com.fintrex.deviceportal.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "bulk_upload", schema = "device_portal")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BulkUpload {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private LocalDateTime date;
    private String user;
    private String service;
    private String status;
    private String approvedUser;
    private String comment;
    private LocalDateTime approvedOn;
}
