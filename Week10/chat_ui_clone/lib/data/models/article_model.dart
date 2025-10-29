import 'package:chat_ui_clone/core/exceptions.dart';
import 'package:chat_ui_clone/domain/entities/article.dart';

class ArticleModel {
  ArticleModel({
    required this.title,
    required this.sourceName,
    required this.publishedAt,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.content,
  });

  final String title;
  final String sourceName;
  final DateTime publishedAt;
  final String? description;
  final String url;
  final String? urlToImage;
  final String? content;

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    try {
      final source = json['source'] as Map<String, dynamic>? ?? {};
      final publishedAt = DateTime.tryParse(json['publishedAt'] as String? ?? '');

      return ArticleModel(
        title: (json['title'] as String? ?? '').trim(),
        sourceName: (source['name'] as String? ?? 'Unknown Source').trim(),
        publishedAt: publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        description: _emptyToNull(json['description'] as String?),
        url: (json['url'] as String? ?? '').trim(),
        urlToImage: _emptyToNull(json['urlToImage'] as String?),
        content: _emptyToNull(json['content'] as String?),
      );
    } catch (error) {
      throw ParsingException('Failed to parse article', cause: error);
    }
  }

  Article toEntity() {
    return Article(
      title: title,
      sourceName: sourceName,
      publishedAt: publishedAt,
      description: description,
      url: url,
      urlToImage: urlToImage,
      content: content,
    );
  }

  static String? _emptyToNull(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
