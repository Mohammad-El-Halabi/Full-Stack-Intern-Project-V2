package com.store.ecommerce;

import com.store.ecommerce.dto.InvoiceLineRequest;
import com.store.ecommerce.dto.InvoiceRequest;
import com.store.ecommerce.dto.InvoiceResponse;
import com.store.ecommerce.entity.Customer;
import com.store.ecommerce.entity.Item;
import com.store.ecommerce.exception.BadRequestException;
import com.store.ecommerce.repository.CustomerRepository;
import com.store.ecommerce.repository.ItemRepository;
import com.store.ecommerce.service.InvoiceService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Verifies the core invoice-creation logic: totals, price snapshotting and
 * stock decrement. Runs against in-memory H2 (see application-test.properties).
 */
@SpringBootTest
@ActiveProfiles("test")
class InvoiceServiceTest {

    @Autowired
    private InvoiceService invoiceService;
    @Autowired
    private CustomerRepository customerRepository;
    @Autowired
    private ItemRepository itemRepository;

    @Test
    void contextLoads() {
        assertThat(invoiceService).isNotNull();
    }

    @Test
    void createsInvoiceWithCorrectTotalAndDecrementsStock() {
        Customer customer = new Customer();
        customer.setName("Test Customer");
        customer = customerRepository.save(customer);

        Item mouse = new Item();
        mouse.setName("Mouse");
        mouse.setPrice(new BigDecimal("19.99"));
        mouse.setStockQuantity(10);
        mouse = itemRepository.save(mouse);

        Item keyboard = new Item();
        keyboard.setName("Keyboard");
        keyboard.setPrice(new BigDecimal("79.99"));
        keyboard.setStockQuantity(5);
        keyboard = itemRepository.save(keyboard);

        InvoiceRequest req = new InvoiceRequest(customer.getId(), List.of(
                new InvoiceLineRequest(mouse.getId(), 2),      // 39.98
                new InvoiceLineRequest(keyboard.getId(), 1)    // 79.99
        ));

        InvoiceResponse response = invoiceService.create(req);

        assertThat(response.totalAmount()).isEqualByComparingTo("119.97");
        assertThat(response.items()).hasSize(2);
        assertThat(itemRepository.findById(mouse.getId()).orElseThrow().getStockQuantity()).isEqualTo(8);
        assertThat(itemRepository.findById(keyboard.getId()).orElseThrow().getStockQuantity()).isEqualTo(4);
    }

    @Test
    void rejectsInvoiceWhenStockInsufficient() {
        Customer customer = new Customer();
        customer.setName("Broke Buyer");
        customer = customerRepository.save(customer);

        Item scarce = new Item();
        scarce.setName("Rare Item");
        scarce.setPrice(new BigDecimal("5.00"));
        scarce.setStockQuantity(1);
        scarce = itemRepository.save(scarce);

        InvoiceRequest req = new InvoiceRequest(customer.getId(), List.of(
                new InvoiceLineRequest(scarce.getId(), 3)
        ));

        assertThatThrownBy(() -> invoiceService.create(req))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("Not enough stock");
    }
}
