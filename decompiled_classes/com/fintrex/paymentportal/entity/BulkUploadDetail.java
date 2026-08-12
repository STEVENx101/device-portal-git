/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  com.fintrex.paymentportal.entity.BulkUploadDetail$BulkUploadDetailBuilder
 *  jakarta.persistence.Entity
 *  jakarta.persistence.GeneratedValue
 *  jakarta.persistence.GenerationType
 *  jakarta.persistence.Id
 *  jakarta.persistence.JoinColumn
 *  jakarta.persistence.ManyToOne
 *  lombok.Generated
 */
package com.fintrex.paymentportal.entity;

import com.fintrex.paymentportal.entity.BulkUpload;
import com.fintrex.paymentportal.entity.BulkUploadDetail;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.time.LocalDateTime;
import lombok.Generated;

@Entity
public class BulkUploadDetail {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;
    @ManyToOne
    @JoinColumn(name="bulk_id")
    private BulkUpload bulkId;
    private String paymentId;
    private String accountNo;
    private Double amount;
    private String narration;
    private LocalDateTime pushed;
    private LocalDateTime ended;
    private String status;
    private String response;

    @Generated
    public static BulkUploadDetailBuilder builder() {
        return new BulkUploadDetailBuilder();
    }

    @Generated
    public Long getId() {
        return this.id;
    }

    @Generated
    public BulkUpload getBulkId() {
        return this.bulkId;
    }

    @Generated
    public String getPaymentId() {
        return this.paymentId;
    }

    @Generated
    public String getAccountNo() {
        return this.accountNo;
    }

    @Generated
    public Double getAmount() {
        return this.amount;
    }

    @Generated
    public String getNarration() {
        return this.narration;
    }

    @Generated
    public LocalDateTime getPushed() {
        return this.pushed;
    }

    @Generated
    public LocalDateTime getEnded() {
        return this.ended;
    }

    @Generated
    public String getStatus() {
        return this.status;
    }

    @Generated
    public String getResponse() {
        return this.response;
    }

    @Generated
    public void setId(Long id) {
        this.id = id;
    }

    @Generated
    public void setBulkId(BulkUpload bulkId) {
        this.bulkId = bulkId;
    }

    @Generated
    public void setPaymentId(String paymentId) {
        this.paymentId = paymentId;
    }

    @Generated
    public void setAccountNo(String accountNo) {
        this.accountNo = accountNo;
    }

    @Generated
    public void setAmount(Double amount) {
        this.amount = amount;
    }

    @Generated
    public void setNarration(String narration) {
        this.narration = narration;
    }

    @Generated
    public void setPushed(LocalDateTime pushed) {
        this.pushed = pushed;
    }

    @Generated
    public void setEnded(LocalDateTime ended) {
        this.ended = ended;
    }

    @Generated
    public void setStatus(String status) {
        this.status = status;
    }

    @Generated
    public void setResponse(String response) {
        this.response = response;
    }

    @Generated
    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (!(o instanceof BulkUploadDetail)) {
            return false;
        }
        BulkUploadDetail other = (BulkUploadDetail)o;
        if (!other.canEqual(this)) {
            return false;
        }
        Long this$id = this.getId();
        Long other$id = other.getId();
        if (this$id == null ? other$id != null : !((Object)this$id).equals(other$id)) {
            return false;
        }
        Double this$amount = this.getAmount();
        Double other$amount = other.getAmount();
        if (this$amount == null ? other$amount != null : !((Object)this$amount).equals(other$amount)) {
            return false;
        }
        BulkUpload this$bulkId = this.getBulkId();
        BulkUpload other$bulkId = other.getBulkId();
        if (this$bulkId == null ? other$bulkId != null : !((Object)this$bulkId).equals(other$bulkId)) {
            return false;
        }
        String this$paymentId = this.getPaymentId();
        String other$paymentId = other.getPaymentId();
        if (this$paymentId == null ? other$paymentId != null : !this$paymentId.equals(other$paymentId)) {
            return false;
        }
        String this$accountNo = this.getAccountNo();
        String other$accountNo = other.getAccountNo();
        if (this$accountNo == null ? other$accountNo != null : !this$accountNo.equals(other$accountNo)) {
            return false;
        }
        String this$narration = this.getNarration();
        String other$narration = other.getNarration();
        if (this$narration == null ? other$narration != null : !this$narration.equals(other$narration)) {
            return false;
        }
        LocalDateTime this$pushed = this.getPushed();
        LocalDateTime other$pushed = other.getPushed();
        if (this$pushed == null ? other$pushed != null : !((Object)this$pushed).equals(other$pushed)) {
            return false;
        }
        LocalDateTime this$ended = this.getEnded();
        LocalDateTime other$ended = other.getEnded();
        if (this$ended == null ? other$ended != null : !((Object)this$ended).equals(other$ended)) {
            return false;
        }
        String this$status = this.getStatus();
        String other$status = other.getStatus();
        if (this$status == null ? other$status != null : !this$status.equals(other$status)) {
            return false;
        }
        String this$response = this.getResponse();
        String other$response = other.getResponse();
        return !(this$response == null ? other$response != null : !this$response.equals(other$response));
    }

    @Generated
    protected boolean canEqual(Object other) {
        return other instanceof BulkUploadDetail;
    }

    @Generated
    public int hashCode() {
        int PRIME = 59;
        int result = 1;
        Long $id = this.getId();
        result = result * 59 + ($id == null ? 43 : ((Object)$id).hashCode());
        Double $amount = this.getAmount();
        result = result * 59 + ($amount == null ? 43 : ((Object)$amount).hashCode());
        BulkUpload $bulkId = this.getBulkId();
        result = result * 59 + ($bulkId == null ? 43 : ((Object)$bulkId).hashCode());
        String $paymentId = this.getPaymentId();
        result = result * 59 + ($paymentId == null ? 43 : $paymentId.hashCode());
        String $accountNo = this.getAccountNo();
        result = result * 59 + ($accountNo == null ? 43 : $accountNo.hashCode());
        String $narration = this.getNarration();
        result = result * 59 + ($narration == null ? 43 : $narration.hashCode());
        LocalDateTime $pushed = this.getPushed();
        result = result * 59 + ($pushed == null ? 43 : ((Object)$pushed).hashCode());
        LocalDateTime $ended = this.getEnded();
        result = result * 59 + ($ended == null ? 43 : ((Object)$ended).hashCode());
        String $status = this.getStatus();
        result = result * 59 + ($status == null ? 43 : $status.hashCode());
        String $response = this.getResponse();
        result = result * 59 + ($response == null ? 43 : $response.hashCode());
        return result;
    }

    @Generated
    public String toString() {
        return "BulkUploadDetail(id=" + this.getId() + ", bulkId=" + String.valueOf(this.getBulkId()) + ", paymentId=" + this.getPaymentId() + ", accountNo=" + this.getAccountNo() + ", amount=" + this.getAmount() + ", narration=" + this.getNarration() + ", pushed=" + String.valueOf(this.getPushed()) + ", ended=" + String.valueOf(this.getEnded()) + ", status=" + this.getStatus() + ", response=" + this.getResponse() + ")";
    }

    @Generated
    public BulkUploadDetail() {
    }

    @Generated
    public BulkUploadDetail(Long id, BulkUpload bulkId, String paymentId, String accountNo, Double amount, String narration, LocalDateTime pushed, LocalDateTime ended, String status, String response) {
        this.id = id;
        this.bulkId = bulkId;
        this.paymentId = paymentId;
        this.accountNo = accountNo;
        this.amount = amount;
        this.narration = narration;
        this.pushed = pushed;
        this.ended = ended;
        this.status = status;
        this.response = response;
    }
}
