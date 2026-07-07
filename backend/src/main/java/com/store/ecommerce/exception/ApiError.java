package com.store.ecommerce.exception;

import java.time.LocalDateTime;
import java.util.Map;

/** Standard error body returned for every handled error. */
public record ApiError(
        LocalDateTime timestamp,
        int status,
        String error,
        String message,
        String path,
        Map<String, String> fieldErrors
) {
}
