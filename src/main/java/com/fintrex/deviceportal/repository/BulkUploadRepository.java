package com.fintrex.deviceportal.repository;

import com.fintrex.deviceportal.entity.BulkUpload;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BulkUploadRepository extends JpaRepository<BulkUpload, Long> {
}
