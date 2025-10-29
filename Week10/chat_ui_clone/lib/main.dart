import 'package:chat_ui_clone/data/datasources/news_api_service.dart';
import 'package:chat_ui_clone/data/repositories/news_repository_impl.dart';
import 'package:chat_ui_clone/domain/entities/article.dart';
import 'package:chat_ui_clone/domain/usecases/get_top_headlines.dart';
import 'package:chat_ui_clone/presentation/pages/article_detail_page.dart';
import 'package:chat_ui_clone/presentation/pages/home_page.dart';
import 'package:chat_ui_clone/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final apiKey = dotenv.env['NEWS_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('NEWS_API_KEY is missing. Please provide it in the .env file.');
  }

  final client = http.Client();
  final newsApiService = NewsApiService(client: client, apiKey: apiKey);
  final newsRepository = NewsRepositoryImpl(newsApiService);
  final getTopHeadlines = GetTopHeadlines(newsRepository);

  runApp(
    NewsReaderApp(
      client: client,
      getTopHeadlines: getTopHeadlines,
    ),
  );
}

class NewsReaderApp extends StatefulWidget {
  const NewsReaderApp({
    super.key,
    required this.client,
    required this.getTopHeadlines,
  });

  final http.Client client;
  final GetTopHeadlines getTopHeadlines;

  @override
  State<NewsReaderApp> createState() => _NewsReaderAppState();
}

class _NewsReaderAppState extends State<NewsReaderApp> {
  @override
  void dispose() {
    widget.client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: HomePage(getTopHeadlines: widget.getTopHeadlines),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case ArticleDetailPage.routeName:
            final article = settings.arguments;
            if (article is! Article) {
              return _errorRoute();
            }
            return MaterialPageRoute(
              builder: (_) => ArticleDetailPage(article: article),
              settings: settings,
            );
          default:
            return null;
        }
      },
    );
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute<void>(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Something went wrong.'),
        ),
      ),
    );
  }
}
