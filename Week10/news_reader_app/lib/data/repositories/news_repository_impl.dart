import 'package:chat_ui_clone/core/exceptions.dart';
import 'package:chat_ui_clone/core/result.dart';
import 'package:chat_ui_clone/data/datasources/news_api_service.dart';
import 'package:chat_ui_clone/domain/entities/article.dart';
import 'package:chat_ui_clone/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl(this._service);

  final NewsApiService _service;

  @override
  Future<Result<List<Article>>> getTopHeadlines({
    String? country,
    String? category,
  }) async {
    try {
      final models = await _service.getTopHeadlines(
        country: country,
        category: category,
      );
      final articles = models.map((model) => model.toEntity()).toList();
      return Success<List<Article>>(articles);
    } on AppException catch (error) {
      return Failure<List<Article>>(error);
    } catch (error) {
      return Failure<List<Article>>(
        NetworkException('Unexpected error', cause: error),
      );
    }
  }
}
