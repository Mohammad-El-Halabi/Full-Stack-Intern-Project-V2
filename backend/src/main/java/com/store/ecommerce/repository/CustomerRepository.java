package com.store.ecommerce.repository;

import com.store.ecommerce.entity.Customer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {

    /** Search customers whose name contains the given text (case-insensitive), paged. */
    Page<Customer> findByNameContainingIgnoreCase(String name, Pageable pageable);

    boolean existsByEmailIgnoreCase(String email);
}
