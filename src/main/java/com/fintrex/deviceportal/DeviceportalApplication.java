package com.fintrex.deviceportal;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class DeviceportalApplication {

	public static void main(String[] args) {
		SpringApplication.run(DeviceportalApplication.class, args);
	}

}
