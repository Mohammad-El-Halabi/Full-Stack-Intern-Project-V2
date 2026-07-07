package com.store.ecommerce.service;

import com.store.ecommerce.dto.CustomerRequest;
import com.store.ecommerce.dto.CustomerResponse;
import com.store.ecommerce.entity.Customer;
import com.store.ecommerce.exception.ConflictException;
import com.store.ecommerce.exception.ResourceNotFoundException;
import com.store.ecommerce.mapper.EntityMapper;
import com.store.ecommerce.repository.CustomerRepository;
import com.store.ecommerce.repository.InvoiceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CustomerService {

    private final CustomerRepository customerRepository;
    private final InvoiceRepository invoiceRepository;

    @Transactional(readOnly = true)
    public Page<CustomerResponse> findAll(Pageable pageable) {
        return customerRepository.findAll(pageable).map(EntityMapper::toCustomerResponse);
    }

    @Transactional(readOnly = true)
    public Page<CustomerResponse> search(String name, Pageable pageable) {
        return customerRepository.findByNameContainingIgnoreCase(name, pageable)
                .map(EntityMapper::toCustomerResponse);
    }

    @Transactional(readOnly = true)
    public CustomerResponse findById(Long id) {
        return EntityMapper.toCustomerResponse(getEntity(id));
    }

    @Transactional
    public CustomerResponse create(CustomerRequest req) {
        Customer c = new Customer();
        apply(c, req);
        return EntityMapper.toCustomerResponse(customerRepository.save(c));
    }

    @Transactional
    public CustomerResponse update(Long id, CustomerRequest req) {
        Customer c = getEntity(id);
        apply(c, req);
        return EntityMapper.toCustomerResponse(customerRepository.save(c));
    }

    @Transactional
    public void delete(Long id) {
        Customer c = getEntity(id);
        long invoices = invoiceRepository.countByCustomerId(id);
        if (invoices > 0) {
            throw new ConflictException(
                    "Cannot delete customer '" + c.getName() + "' because they have "
                            + invoices + " invoice(s). Delete those invoices first.");
        }
        customerRepository.delete(c);
    }

    /** Loads the entity or throws 404. Used internally and by other services. */
    @Transactional(readOnly = true)
    public Customer getEntity(Long id) {
        return customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer", id));
    }

    private void apply(Customer c, CustomerRequest req) {
        c.setName(req.name().trim());
        c.setEmail(req.email() == null || req.email().isBlank() ? null : req.email().trim());
        c.setPhone(req.phone());
        c.setAddress(req.address());
    }
}
