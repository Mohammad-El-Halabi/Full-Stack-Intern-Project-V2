package com.store.ecommerce.exception;

/** Thrown when an operation conflicts with existing data. Maps to HTTP 409. */
public class ConflictException extends RuntimeException {

    public ConflictException(String message) {
        super(message);
    }
}
