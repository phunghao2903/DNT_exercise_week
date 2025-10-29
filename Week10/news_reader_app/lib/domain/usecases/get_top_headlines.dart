import 'package:chat_ui_clone/core/result.dart';
import 'package:chat_ui_clone/domain/entities/article.dart';
import 'package:chat_ui_clone/domain/repositories/news_repository.dart';

class GetTopHeadlines {
  const GetTopHeadlines(this._repository);

  final NewsRepository _repository;

  Future<Result<List<Article>>> call({
    String? country,
    String? category,
  }) {
    return _repository.getTopHeadlines(
      country: country,
      category: category,
    );
  }
}
