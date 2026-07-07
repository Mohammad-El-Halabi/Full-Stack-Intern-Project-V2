package com.store.ecommerce.exception;

/** Thrown when the request is semantically invalid. Maps to HTTP 400. */
public class BadRequestException extends RuntimeException {

    public BadRequestException(String message) {
        super(message);
    }
}
