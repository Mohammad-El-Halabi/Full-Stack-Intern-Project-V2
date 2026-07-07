package com.store.ecommerce.dto;

import java.math.BigDecimal;

/** A single line as returned on an invoice. */
public record InvoiceLineResponse(
        Long id,
        Long itemId,
        String itemName,
        Integer quantity,
        BigDecimal unitPrice,
        BigDecimal lineTotal
) {
}
