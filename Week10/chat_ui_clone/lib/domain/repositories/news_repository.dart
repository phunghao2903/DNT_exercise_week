import 'package:chat_ui_clone/core/result.dart';
import 'package:chat_ui_clone/domain/entities/article.dart';

abstract class NewsRepository {
  Future<Result<List<Article>>> getTopHeadlines({
    String? country,
    String? category,
  });
}
