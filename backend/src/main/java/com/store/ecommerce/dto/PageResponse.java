package com.store.ecommerce.dto;

import org.springframework.data.domain.Page;

import java.util.List;

/**
 * A stable, explicit pagination envelope so the JSON shape returned to
 * clients does not depend on Spring's internal Page serialization.
 */
public record PageResponse<T>(
        List<T> content,
        int page,
        int size,
        long totalElements,
        int totalPages,
        boolean first,
        boolean last
) {
    public static <T> PageResponse<T> from(Page<T> page) {
        return new PageResponse<>(
                page.getContent(),
                page.getNumber(),
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages(),
                page.isFirst(),
                page.isLast()
        );
    }
}
