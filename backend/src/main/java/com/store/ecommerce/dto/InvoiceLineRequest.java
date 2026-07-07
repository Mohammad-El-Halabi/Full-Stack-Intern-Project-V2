package com.store.ecommerce.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/** A single requested line when creating an invoice: which item and how many. */
public record InvoiceLineRequest(

        @NotNull(message = "itemId is required")
        Long itemId,

        @NotNull(message = "quantity is required")
        @Min(value = 1, message = "quantity must be at least 1")
        Integer quantity
) {
}
