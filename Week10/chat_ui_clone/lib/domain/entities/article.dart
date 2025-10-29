import 'package:equatable/equatable.dart';

class Article extends Equatable {
  const Article({
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

  @override
  List<Object?> get props => [
        title,
        sourceName,
        publishedAt,
        description,
        url,
        urlToImage,
        content,
      ];
}
