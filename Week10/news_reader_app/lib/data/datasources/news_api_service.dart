import 'dart:convert';

import 'package:chat_ui_clone/core/exceptions.dart';
import 'package:chat_ui_clone/data/models/article_model.dart';
import 'package:http/http.dart' as http;

class NewsApiService {
  NewsApiService({
    required http.Client client,
    required String apiKey,
    String baseUrl = 'newsapi.org',
  })  : _client = client,
        _apiKey = apiKey,
        _baseUrl = baseUrl;

  final http.Client _client;
  final String _apiKey;
  final String _baseUrl;

  Future<List<ArticleModel>> getTopHeadlines({
    String? country,
    String? category,
  }) async {
    final query = <String, String>{
      'apiKey': _apiKey,
    };

    if (country != null && country.isNotEmpty) {
      query['country'] = country;
    }
    if (category != null && category.isNotEmpty) {
      query['category'] = category;
    }

    final uri = Uri.https(_baseUrl, '/v2/top-headlines', query);

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to fetch headlines (${response.statusCode})',
          cause: response.body,
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final status = decoded['status'] as String? ?? 'error';
      if (status != 'ok') {
        final message = decoded['message'] as String? ?? 'Unknown API error';
        throw ApiException(message);
      }

      final articles = decoded['articles'] as List<dynamic>? ?? [];
      return articles
          .map((article) => ArticleModel.fromJson(article as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } on http.ClientException catch (error) {
      throw NetworkException('Network error occurred', cause: error);
    } catch (error) {
      throw NetworkException('Unexpected error occurred', cause: error);
    }
  }
}
