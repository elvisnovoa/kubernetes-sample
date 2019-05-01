package com.everis.hackathon;

import lombok.Data;
import org.springframework.data.annotation.Id;

import java.math.BigDecimal;

@Data
public class Account {
    @Id
    private String id;
    private String name;
    private String type;
    private BigDecimal postedBalance;
    private BigDecimal availableBalance;
}
