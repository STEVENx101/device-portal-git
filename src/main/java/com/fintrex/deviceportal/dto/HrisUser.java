package com.fintrex.deviceportal.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class HrisUser {
    private Integer employeeId;
    private String username;
    private String callname;
    private String email;
    private String status;
}
