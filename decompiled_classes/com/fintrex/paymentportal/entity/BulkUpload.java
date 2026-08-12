/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  com.fintrex.paymentportal.entity.BulkUpload$BulkUploadBuilder
 *  jakarta.persistence.Entity
 *  jakarta.persistence.GeneratedValue
 *  jakarta.persistence.GenerationType
 *  jakarta.persistence.Id
 *  lombok.Generated
 */
package com.fintrex.paymentportal.entity;

import com.fintrex.paymentportal.entity.BulkUpload;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import java.time.LocalDateTime;
import lombok.Generated;

@Entity
public class BulkUpload {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long id;
    private LocalDateTime date;
    private String user;
    private String service;
    private String status;
    private String approvedUser;
    private String comment;
    private LocalDateTime approvedOn;

    @Generated
    public static BulkUploadBuilder builder() {
        return new BulkUploadBuilder();
    }

    @Generated
    public Long getId() {
        return this.id;
    }

    @Generated
    public LocalDateTime getDate() {
        return this.date;
    }

    @Generated
    public String getUser() {
        return this.user;
    }

    @Generated
    public String getService() {
        return this.service;
    }

    @Generated
    public String getStatus() {
        return this.status;
    }

    @Generated
    public String getApprovedUser() {
        return this.approvedUser;
    }

    @Generated
    public String getComment() {
        return this.comment;
    }

    @Generated
    public LocalDateTime getApprovedOn() {
        return this.approvedOn;
    }

    @Generated
    public void setId(Long id) {
        this.id = id;
    }

    @Generated
    public void setDate(LocalDateTime date) {
        this.date = date;
    }

    @Generated
    public void setUser(String user) {
        this.user = user;
    }

    @Generated
    public void setService(String service) {
        this.service = service;
    }

    @Generated
    public void setStatus(String status) {
        this.status = status;
    }

    @Generated
    public void setApprovedUser(String approvedUser) {
        this.approvedUser = approvedUser;
    }

    @Generated
    public void setComment(String comment) {
        this.comment = comment;
    }

    @Generated
    public void setApprovedOn(LocalDateTime approvedOn) {
        this.approvedOn = approvedOn;
    }

    @Generated
    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (!(o instanceof BulkUpload)) {
            return false;
        }
        BulkUpload other = (BulkUpload)o;
        if (!other.canEqual(this)) {
            return false;
        }
        Long this$id = this.getId();
        Long other$id = other.getId();
        if (this$id == null ? other$id != null : !((Object)this$id).equals(other$id)) {
            return false;
        }
        LocalDateTime this$date = this.getDate();
        LocalDateTime other$date = other.getDate();
        if (this$date == null ? other$date != null : !((Object)this$date).equals(other$date)) {
            return false;
        }
        String this$user = this.getUser();
        String other$user = other.getUser();
        if (this$user == null ? other$user != null : !this$user.equals(other$user)) {
            return false;
        }
        String this$service = this.getService();
        String other$service = other.getService();
        if (this$service == null ? other$service != null : !this$service.equals(other$service)) {
            return false;
        }
        String this$status = this.getStatus();
        String other$status = other.getStatus();
        if (this$status == null ? other$status != null : !this$status.equals(other$status)) {
            return false;
        }
        String this$approvedUser = this.getApprovedUser();
        String other$approvedUser = other.getApprovedUser();
        if (this$approvedUser == null ? other$approvedUser != null : !this$approvedUser.equals(other$approvedUser)) {
            return false;
        }
        String this$comment = this.getComment();
        String other$comment = other.getComment();
        if (this$comment == null ? other$comment != null : !this$comment.equals(other$comment)) {
            return false;
        }
        LocalDateTime this$approvedOn = this.getApprovedOn();
        LocalDateTime other$approvedOn = other.getApprovedOn();
        return !(this$approvedOn == null ? other$approvedOn != null : !((Object)this$approvedOn).equals(other$approvedOn));
    }

    @Generated
    protected boolean canEqual(Object other) {
        return other instanceof BulkUpload;
    }

    @Generated
    public int hashCode() {
        int PRIME = 59;
        int result = 1;
        Long $id = this.getId();
        result = result * 59 + ($id == null ? 43 : ((Object)$id).hashCode());
        LocalDateTime $date = this.getDate();
        result = result * 59 + ($date == null ? 43 : ((Object)$date).hashCode());
        String $user = this.getUser();
        result = result * 59 + ($user == null ? 43 : $user.hashCode());
        String $service = this.getService();
        result = result * 59 + ($service == null ? 43 : $service.hashCode());
        String $status = this.getStatus();
        result = result * 59 + ($status == null ? 43 : $status.hashCode());
        String $approvedUser = this.getApprovedUser();
        result = result * 59 + ($approvedUser == null ? 43 : $approvedUser.hashCode());
        String $comment = this.getComment();
        result = result * 59 + ($comment == null ? 43 : $comment.hashCode());
        LocalDateTime $approvedOn = this.getApprovedOn();
        result = result * 59 + ($approvedOn == null ? 43 : ((Object)$approvedOn).hashCode());
        return result;
    }

    @Generated
    public String toString() {
        return "BulkUpload(id=" + this.getId() + ", date=" + String.valueOf(this.getDate()) + ", user=" + this.getUser() + ", service=" + this.getService() + ", status=" + this.getStatus() + ", approvedUser=" + this.getApprovedUser() + ", comment=" + this.getComment() + ", approvedOn=" + String.valueOf(this.getApprovedOn()) + ")";
    }

    @Generated
    public BulkUpload() {
    }

    @Generated
    public BulkUpload(Long id, LocalDateTime date, String user, String service, String status, String approvedUser, String comment, LocalDateTime approvedOn) {
        this.id = id;
        this.date = date;
        this.user = user;
        this.service = service;
        this.status = status;
        this.approvedUser = approvedUser;
        this.comment = comment;
        this.approvedOn = approvedOn;
    }
}
