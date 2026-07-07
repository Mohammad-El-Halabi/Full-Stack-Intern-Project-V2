package com.store.ecommerce.repository;

import com.store.ecommerce.entity.InvoiceItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface InvoiceItemRepository extends JpaRepository<InvoiceItem, Long> {

    /** How many invoice lines reference the given item (used to guard deletes). */
    long countByItemId(Long itemId);
}
