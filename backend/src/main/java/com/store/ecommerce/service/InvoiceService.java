package com.store.ecommerce.service;

import com.store.ecommerce.dto.InvoiceLineRequest;
import com.store.ecommerce.dto.InvoiceRequest;
import com.store.ecommerce.dto.InvoiceResponse;
import com.store.ecommerce.entity.Customer;
import com.store.ecommerce.entity.Invoice;
import com.store.ecommerce.entity.InvoiceItem;
import com.store.ecommerce.entity.Item;
import com.store.ecommerce.exception.BadRequestException;
import com.store.ecommerce.exception.ResourceNotFoundException;
import com.store.ecommerce.mapper.EntityMapper;
import com.store.ecommerce.repository.InvoiceRepository;
import com.store.ecommerce.repository.ItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashSet;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final ItemRepository itemRepository;
    private final CustomerService customerService;

    @Transactional(readOnly = true)
    public Page<InvoiceResponse> findAll(Pageable pageable) {
        return invoiceRepository.findAll(pageable).map(EntityMapper::toInvoiceResponse);
    }

    @Transactional(readOnly = true)
    public InvoiceResponse findById(Long id) {
        return EntityMapper.toInvoiceResponse(getEntity(id));
    }

    /** Get all invoices for a given customer id, paged. */
    @Transactional(readOnly = true)
    public Page<InvoiceResponse> findByCustomerId(Long customerId, Pageable pageable) {
        // 404 early if the customer does not exist, for a clearer error.
        customerService.getEntity(customerId);
        return invoiceRepository.findByCustomerId(customerId, pageable)
                .map(EntityMapper::toInvoiceResponse);
    }

    /** Get all invoices whose customer's name contains the given text, paged. */
    @Transactional(readOnly = true)
    public Page<InvoiceResponse> findByCustomerName(String name, Pageable pageable) {
        return invoiceRepository.findByCustomer_NameContainingIgnoreCase(name, pageable)
                .map(EntityMapper::toInvoiceResponse);
    }

    /**
     * The single endpoint that creates an invoice including all of its items.
     * Prices are snapshotted from the current item data and stock is decremented.
     */
    @Transactional
    public InvoiceResponse create(InvoiceRequest req) {
        Customer customer = customerService.getEntity(req.customerId());

        Invoice invoice = new Invoice();
        invoice.setCustomer(customer);
        invoice.setStatus("CREATED");

        BigDecimal total = buildLinesAndComputeTotal(invoice, req);
        invoice.setTotalAmount(total);

        return EntityMapper.toInvoiceResponse(invoiceRepository.save(invoice));
    }

    /**
     * Replaces an existing invoice's customer and line items. Stock taken by the
     * old lines is returned first, then the new lines are applied.
     */
    @Transactional
    public InvoiceResponse update(Long id, InvoiceRequest req) {
        Invoice invoice = getEntity(id);

        // Return stock reserved by the current lines before rebuilding.
        restoreStock(invoice);
        invoice.getItems().clear();

        Customer customer = customerService.getEntity(req.customerId());
        invoice.setCustomer(customer);

        BigDecimal total = buildLinesAndComputeTotal(invoice, req);
        invoice.setTotalAmount(total);

        return EntityMapper.toInvoiceResponse(invoiceRepository.save(invoice));
    }

    @Transactional
    public void delete(Long id) {
        Invoice invoice = getEntity(id);
        restoreStock(invoice);           // give the stock back
        invoiceRepository.delete(invoice); // cascade removes the line items
    }

    @Transactional(readOnly = true)
    public Invoice getEntity(Long id) {
        return invoiceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Invoice", id));
    }

    // ------------------------------------------------------------------
    //  helpers
    // ------------------------------------------------------------------

    /** Builds line items on the invoice, decrements stock and returns the total. */
    private BigDecimal buildLinesAndComputeTotal(Invoice invoice, InvoiceRequest req) {
        Set<Long> seen = new HashSet<>();
        BigDecimal total = BigDecimal.ZERO;

        for (InvoiceLineRequest line : req.items()) {
            if (!seen.add(line.itemId())) {
                throw new BadRequestException(
                        "Item id " + line.itemId() + " appears more than once; combine it into a single line.");
            }

            Item item = itemRepository.findById(line.itemId())
                    .orElseThrow(() -> new ResourceNotFoundException("Item", line.itemId()));

            if (item.getStockQuantity() < line.quantity()) {
                throw new BadRequestException(
                        "Not enough stock for item '" + item.getName() + "' (id " + item.getId()
                                + "): requested " + line.quantity() + ", available " + item.getStockQuantity() + ".");
            }
            item.setStockQuantity(item.getStockQuantity() - line.quantity());

            BigDecimal unitPrice = item.getPrice();
            BigDecimal lineTotal = unitPrice
                    .multiply(BigDecimal.valueOf(line.quantity()))
                    .setScale(2, RoundingMode.HALF_UP);

            InvoiceItem invoiceItem = new InvoiceItem();
            invoiceItem.setItem(item);
            invoiceItem.setQuantity(line.quantity());
            invoiceItem.setUnitPrice(unitPrice);
            invoiceItem.setLineTotal(lineTotal);
            invoice.addItem(invoiceItem);

            total = total.add(lineTotal);
        }
        return total.setScale(2, RoundingMode.HALF_UP);
    }

    /** Returns the stock that this invoice's line items reserved. */
    private void restoreStock(Invoice invoice) {
        for (InvoiceItem line : invoice.getItems()) {
            Item item = line.getItem();
            item.setStockQuantity(item.getStockQuantity() + line.getQuantity());
        }
    }
}
