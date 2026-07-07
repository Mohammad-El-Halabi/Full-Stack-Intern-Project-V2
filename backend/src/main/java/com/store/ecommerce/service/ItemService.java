package com.store.ecommerce.service;

import com.store.ecommerce.dto.ItemRequest;
import com.store.ecommerce.dto.ItemResponse;
import com.store.ecommerce.entity.Item;
import com.store.ecommerce.exception.ConflictException;
import com.store.ecommerce.exception.ResourceNotFoundException;
import com.store.ecommerce.mapper.EntityMapper;
import com.store.ecommerce.repository.InvoiceItemRepository;
import com.store.ecommerce.repository.ItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ItemService {

    private final ItemRepository itemRepository;
    private final InvoiceItemRepository invoiceItemRepository;

    @Transactional(readOnly = true)
    public Page<ItemResponse> findAll(Pageable pageable) {
        return itemRepository.findAll(pageable).map(EntityMapper::toItemResponse);
    }

    @Transactional(readOnly = true)
    public Page<ItemResponse> search(String name, Pageable pageable) {
        return itemRepository.findByNameContainingIgnoreCase(name, pageable)
                .map(EntityMapper::toItemResponse);
    }

    @Transactional(readOnly = true)
    public ItemResponse findById(Long id) {
        return EntityMapper.toItemResponse(getEntity(id));
    }

    @Transactional
    public ItemResponse create(ItemRequest req) {
        Item i = new Item();
        apply(i, req);
        return EntityMapper.toItemResponse(itemRepository.save(i));
    }

    @Transactional
    public ItemResponse update(Long id, ItemRequest req) {
        Item i = getEntity(id);
        apply(i, req);
        return EntityMapper.toItemResponse(itemRepository.save(i));
    }

    @Transactional
    public void delete(Long id) {
        Item i = getEntity(id);
        long usedIn = invoiceItemRepository.countByItemId(id);
        if (usedIn > 0) {
            throw new ConflictException(
                    "Cannot delete item '" + i.getName() + "' because it is used in "
                            + usedIn + " invoice line(s). Remove those invoices first.");
        }
        itemRepository.delete(i);
    }

    @Transactional(readOnly = true)
    public Item getEntity(Long id) {
        return itemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Item", id));
    }

    private void apply(Item i, ItemRequest req) {
        i.setName(req.name().trim());
        i.setDescription(req.description());
        i.setPrice(req.price());
        i.setStockQuantity(req.stockQuantity());
    }
}
