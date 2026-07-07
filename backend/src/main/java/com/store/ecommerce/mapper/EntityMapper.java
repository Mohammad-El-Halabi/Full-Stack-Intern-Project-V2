package com.store.ecommerce.mapper;

import com.store.ecommerce.dto.*;
import com.store.ecommerce.entity.Customer;
import com.store.ecommerce.entity.Invoice;
import com.store.ecommerce.entity.InvoiceItem;
import com.store.ecommerce.entity.Item;

import java.util.List;

/**
 * Central place that maps JPA entities to the response DTOs returned by the API.
 */
public final class EntityMapper {

    private EntityMapper() {
    }

    public static CustomerResponse toCustomerResponse(Customer c) {
        return new CustomerResponse(
                c.getId(),
                c.getName(),
                c.getEmail(),
                c.getPhone(),
                c.getAddress(),
                c.getCreatedAt(),
                c.getUpdatedAt()
        );
    }

    public static ItemResponse toItemResponse(Item i) {
        return new ItemResponse(
                i.getId(),
                i.getName(),
                i.getDescription(),
                i.getPrice(),
                i.getStockQuantity(),
                i.getCreatedAt(),
                i.getUpdatedAt()
        );
    }

    public static InvoiceLineResponse toLineResponse(InvoiceItem line) {
        return new InvoiceLineResponse(
                line.getId(),
                line.getItem().getId(),
                line.getItem().getName(),
                line.getQuantity(),
                line.getUnitPrice(),
                line.getLineTotal()
        );
    }

    public static InvoiceResponse toInvoiceResponse(Invoice inv) {
        List<InvoiceLineResponse> lines = inv.getItems().stream()
                .map(EntityMapper::toLineResponse)
                .toList();
        return new InvoiceResponse(
                inv.getId(),
                inv.getCustomer().getId(),
                inv.getCustomer().getName(),
                inv.getInvoiceDate(),
                inv.getTotalAmount(),
                inv.getStatus(),
                lines,
                inv.getCreatedAt()
        );
    }
}
