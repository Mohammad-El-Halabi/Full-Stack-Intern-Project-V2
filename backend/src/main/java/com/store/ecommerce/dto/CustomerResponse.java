package com.store.ecommerce.dto;

import java.time.LocalDateTime;

/** Customer data returned by the API. */
public record CustomerResponse(
        Long id,
        String name,
        String email,
        String phone,
        String address,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
