package com.fintrex.deviceportal.repository;

import com.fintrex.deviceportal.entity.BulkUpload;
import com.fintrex.deviceportal.entity.BulkUploadDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BulkUploadDetailRepository extends JpaRepository<BulkUploadDetail, Long> {
    List<BulkUploadDetail> findAllByBulkId(BulkUpload bulkId);
}
