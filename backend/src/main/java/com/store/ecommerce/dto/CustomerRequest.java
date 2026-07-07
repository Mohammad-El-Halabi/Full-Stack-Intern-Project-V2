package com.store.ecommerce.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Payload for creating or updating a customer. */
public record CustomerRequest(

        @NotBlank(message = "name is required")
        @Size(max = 150, message = "name must be at most 150 characters")
        String name,

        @Email(message = "email must be a valid email address")
        @Size(max = 150, message = "email must be at most 150 characters")
        String email,

        @Size(max = 30, message = "phone must be at most 30 characters")
        String phone,

        @Size(max = 255, message = "address must be at most 255 characters")
        String address
) {
}
