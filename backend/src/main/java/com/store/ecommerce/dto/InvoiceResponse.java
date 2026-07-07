package com.store.ecommerce.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/** A full invoice as returned by the API, including its line items. */
public record InvoiceResponse(
        Long id,
        Long customerId,
        String customerName,
        LocalDateTime invoiceDate,
        BigDecimal totalAmount,
        String status,
        List<InvoiceLineResponse> items,
        LocalDateTime createdAt
) {
}
