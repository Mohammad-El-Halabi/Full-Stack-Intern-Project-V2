package com.store.ecommerce.controller;

import com.store.ecommerce.dto.InvoiceRequest;
import com.store.ecommerce.dto.InvoiceResponse;
import com.store.ecommerce.dto.PageResponse;
import com.store.ecommerce.service.InvoiceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/invoices")
@RequiredArgsConstructor
public class InvoiceController {

    private final InvoiceService invoiceService;

    /** Get all invoices (paged). */
    @GetMapping
    public PageResponse<InvoiceResponse> getAll(
            @PageableDefault(size = 10, sort = "invoiceDate") Pageable pageable) {
        return PageResponse.from(invoiceService.findAll(pageable));
    }

    /** Get all invoices by the customer's name (paged). */
    @GetMapping("/search")
    public PageResponse<InvoiceResponse> searchByCustomerName(
            @RequestParam("customerName") String customerName,
            @PageableDefault(size = 10, sort = "invoiceDate") Pageable pageable) {
        return PageResponse.from(invoiceService.findByCustomerName(customerName, pageable));
    }

    /** Get all invoices by customer id (paged). */
    @GetMapping("/by-customer/{customerId}")
    public PageResponse<InvoiceResponse> getByCustomerId(
            @PathVariable Long customerId,
            @PageableDefault(size = 10, sort = "invoiceDate") Pageable pageable) {
        return PageResponse.from(invoiceService.findByCustomerId(customerId, pageable));
    }

    @GetMapping("/{id}")
    public InvoiceResponse getById(@PathVariable Long id) {
        return invoiceService.findById(id);
    }

    /** The single endpoint that creates an invoice including all the items related to the invoice. */
    @PostMapping
    public ResponseEntity<InvoiceResponse> create(@Valid @RequestBody InvoiceRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(invoiceService.create(request));
    }

    @PutMapping("/{id}")
    public InvoiceResponse update(@PathVariable Long id, @Valid @RequestBody InvoiceRequest request) {
        return invoiceService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        invoiceService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
