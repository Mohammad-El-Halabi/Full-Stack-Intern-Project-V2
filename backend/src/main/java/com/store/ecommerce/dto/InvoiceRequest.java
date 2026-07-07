package com.store.ecommerce.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

/**
 * Payload for the single endpoint that creates an invoice including all of
 * its items. The server computes unit prices and totals from the current
 * item data, so the client only needs to say which items and how many.
 */
public record InvoiceRequest(

        @NotNull(message = "customerId is required")
        Long customerId,

        @NotEmpty(message = "an invoice must contain at least one line item")
        @Valid
        List<InvoiceLineRequest> items
) {
}
