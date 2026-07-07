package com.store.ecommerce.repository;

import com.store.ecommerce.entity.Invoice;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {

    /** All invoices for a given customer id, paged. */
    Page<Invoice> findByCustomerId(Long customerId, Pageable pageable);

    /** All invoices whose customer's name contains the given text (case-insensitive), paged. */
    Page<Invoice> findByCustomer_NameContainingIgnoreCase(String name, Pageable pageable);
}
