import 'package:chat_ui_clone/core/exceptions.dart';
import 'package:chat_ui_clone/core/result.dart';
import 'package:flutter/material.dart';

typedef RetryCallback = void Function();

class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.snapshot,
    required this.dataBuilder,
    required this.onRetry,
    this.loadingBuilder,
    this.emptyBuilder,
    this.isDataEmpty,
  });

  final AsyncSnapshot<Result<T>> snapshot;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final RetryCallback onRetry;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final bool Function(T data)? isDataEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget view;

    if (snapshot.connectionState == ConnectionState.waiting) {
      view = loadingBuilder?.call(context) ??
          const _DefaultLoading(
            key: ValueKey('loading'),
          );
    } else {
      final result = snapshot.data;
      if (result == null) {
        view = _ErrorView(
          key: const ValueKey('no-data'),
          message: 'No data available yet.',
          onRetry: onRetry,
        );
      } else {
        view = result.when(
          success: (data) {
            final empty = isDataEmpty?.call(data) ?? false;
            if (empty) {
              return emptyBuilder?.call(context) ??
                  const _EmptyView(
                    key: ValueKey('empty'),
                    message: 'No content available.',
                  );
            }
            return dataBuilder(context, data);
          },
          failure: (error) => _ErrorView(
            key: ValueKey('error-${error.message}'),
            message: error.message,
            onRetry: onRetry,
          ),
        );
      }
    }

    final wrapped = _wrapWithPadding(
      view,
      theme: theme,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: wrapped,
    );
  }

  Widget _wrapWithPadding(
    Widget child, {
    required ThemeData theme,
  }) {
    if (child is ListView ||
        child is GridView ||
        child is CustomScrollView ||
        child is RefreshIndicator) {
      return KeyedSubtree(
        key: ValueKey(child.hashCode),
        child: child,
      );
    }

    return AnimatedContainer(
      key: ValueKey(child.hashCode),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: child,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.article_outlined,
          size: 48,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final RetryCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_off_outlined,
          size: 48,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        )
      ],
    );
  }
}
