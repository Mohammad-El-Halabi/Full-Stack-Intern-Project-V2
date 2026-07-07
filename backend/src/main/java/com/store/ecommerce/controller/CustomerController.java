package com.store.ecommerce.controller;

import com.store.ecommerce.dto.CustomerRequest;
import com.store.ecommerce.dto.CustomerResponse;
import com.store.ecommerce.dto.InvoiceResponse;
import com.store.ecommerce.dto.PageResponse;
import com.store.ecommerce.service.CustomerService;
import com.store.ecommerce.service.InvoiceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;
    private final InvoiceService invoiceService;

    /** Get all customers (paged). */
    @GetMapping
    public PageResponse<CustomerResponse> getAll(
            @PageableDefault(size = 10, sort = "name") Pageable pageable) {
        return PageResponse.from(customerService.findAll(pageable));
    }

    /** Search for customers by name (paged). */
    @GetMapping("/search")
    public PageResponse<CustomerResponse> search(
            @RequestParam("name") String name,
            @PageableDefault(size = 10, sort = "name") Pageable pageable) {
        return PageResponse.from(customerService.search(name, pageable));
    }

    @GetMapping("/{id}")
    public CustomerResponse getById(@PathVariable Long id) {
        return customerService.findById(id);
    }

    /** Get all invoices by customer id (paged). */
    @GetMapping("/{id}/invoices")
    public PageResponse<InvoiceResponse> getInvoicesByCustomer(
            @PathVariable Long id,
            @PageableDefault(size = 10, sort = "invoiceDate") Pageable pageable) {
        return PageResponse.from(invoiceService.findByCustomerId(id, pageable));
    }

    @PostMapping
    public ResponseEntity<CustomerResponse> create(@Valid @RequestBody CustomerRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(customerService.create(request));
    }

    @PutMapping("/{id}")
    public CustomerResponse update(@PathVariable Long id, @Valid @RequestBody CustomerRequest request) {
        return customerService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        customerService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
