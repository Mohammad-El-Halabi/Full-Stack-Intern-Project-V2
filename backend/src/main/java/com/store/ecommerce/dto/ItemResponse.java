package com.store.ecommerce.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Item data returned by the API. */
public record ItemResponse(
        Long id,
        String name,
        String description,
        BigDecimal price,
        Integer stockQuantity,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
