package com.store.ecommerce.repository;

import com.store.ecommerce.entity.Item;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ItemRepository extends JpaRepository<Item, Long> {

    /** Search items whose name contains the given text (case-insensitive), paged. */
    Page<Item> findByNameContainingIgnoreCase(String name, Pageable pageable);
}
