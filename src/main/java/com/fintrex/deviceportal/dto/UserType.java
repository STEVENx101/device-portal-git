package com.fintrex.deviceportal.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserType {
    private Integer id;
    private String name;
    private String description;
}
