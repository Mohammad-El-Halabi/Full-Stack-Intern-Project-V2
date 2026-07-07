/// Mirrors the backend `PageResponse<T>` pagination envelope.
class PageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final rawContent = (json['content'] as List<dynamic>? ?? []);
    return PageResponse<T>(
      content: rawContent
          .map((e) => itemFromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? rawContent.length,
      totalElements: json['totalElements'] as int? ?? rawContent.length,
      totalPages: json['totalPages'] as int? ?? 1,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
    );
  }
}
