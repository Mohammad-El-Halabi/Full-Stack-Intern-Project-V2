package com.store.ecommerce.controller;

import com.store.ecommerce.dto.ItemRequest;
import com.store.ecommerce.dto.ItemResponse;
import com.store.ecommerce.dto.PageResponse;
import com.store.ecommerce.service.ItemService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/items")
@RequiredArgsConstructor
public class ItemController {

    private final ItemService itemService;

    /** Get all items (paged). */
    @GetMapping
    public PageResponse<ItemResponse> getAll(
            @PageableDefault(size = 10, sort = "name") Pageable pageable) {
        return PageResponse.from(itemService.findAll(pageable));
    }

    /** Search for items by item name (paged). */
    @GetMapping("/search")
    public PageResponse<ItemResponse> search(
            @RequestParam("name") String name,
            @PageableDefault(size = 10, sort = "name") Pageable pageable) {
        return PageResponse.from(itemService.search(name, pageable));
    }

    @GetMapping("/{id}")
    public ItemResponse getById(@PathVariable Long id) {
        return itemService.findById(id);
    }

    @PostMapping
    public ResponseEntity<ItemResponse> create(@Valid @RequestBody ItemRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(itemService.create(request));
    }

    @PutMapping("/{id}")
    public ItemResponse update(@PathVariable Long id, @Valid @RequestBody ItemRequest request) {
        return itemService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        itemService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
