import 'package:chat_ui_clone/core/result.dart';
import 'package:chat_ui_clone/domain/entities/article.dart';
import 'package:chat_ui_clone/domain/usecases/get_top_headlines.dart';
import 'package:chat_ui_clone/presentation/pages/article_detail_page.dart';
import 'package:chat_ui_clone/presentation/widgets/article_tile.dart';
import 'package:chat_ui_clone/presentation/widgets/async_view.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.getTopHeadlines,
  });

  final GetTopHeadlines getTopHeadlines;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Result<List<Article>>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.getTopHeadlines(country: 'us');
  }

  Future<void> _refreshHeadlines() async {
    setState(() {
      _future = widget.getTopHeadlines(country: 'us');
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Reader'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _refreshHeadlines,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Result<List<Article>>>(
          future: _future,
          builder: (context, snapshot) {
            return AsyncView<List<Article>>(
              snapshot: snapshot,
              onRetry: () {
                _refreshHeadlines();
              },
              isDataEmpty: (articles) => articles.isEmpty,
              emptyBuilder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.newspaper_outlined,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No headlines right now.\nPull to refresh shortly.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              loadingBuilder: (context) => _ShimmerList(theme: theme),
              dataBuilder: (context, articles) => RefreshIndicator(
                onRefresh: () async {
                  await _refreshHeadlines();
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: articles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return ArticleTile(
                      article: article,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          ArticleDetailPage.routeName,
                          arguments: article,
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: theme.colorScheme.surfaceVariant.withOpacity(0.6),
          highlightColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            height: 220,
          ),
        );
      },
    );
  }
}
