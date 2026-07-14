package com.fintrex.deviceportal.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Screen {
    private Integer id;
    private String name;
    private String path;
    private String icon;
    private String groupName;
}
