import 'package:flutter_basic_news_with_riverpod/models/article_model.dart';
import 'package:flutter_basic_news_with_riverpod/providers/article_provider.dart';
import 'package:flutter_basic_news_with_riverpod/services/article_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockArticleService extends Mock implements ArticleService {}

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  ProviderContainer makeProviderContainer(MockArticleService articleService) {
    final container = ProviderContainer(
      overrides: [
        articleServiceProvider.overrideWithValue(articleService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('initial state is for articleProvider', () async {
    final articleService = MockArticleService();

    when(() => articleService.fetchArticles(page: any(named: 'page'))).thenAnswer((_) async => []);

    // create the ProviderContainer with the mock article service
    final container = makeProviderContainer(articleService);

    final listener = Listener<ArticleState>();

    container.listen(
      articleProvider,
      listener,
      fireImmediately: true,
    );
    verify(() => articleService.fetchArticles(page: any(named: 'page'))).called(1);

    expect(container.read(articleProvider.notifier).state.articles, isEmpty);

    // verify(
    //   () => listener(null, ArticleState(articles: [])),
    // );
  });

  test('Loading articles and showing them', () async {
    final articleService = MockArticleService();

    when(() => articleService.fetchArticles(page: any(named: 'page')))
        .thenAnswer((_) async => [const Article(title: 'Test1')]);

    final container = makeProviderContainer(articleService);
    // initial values:
    expect(container.read(articleProvider.notifier).state.articles.length, 0);
    expect(container.read(articleProvider.notifier).state.isLoading, isTrue);
    expect(container.read(articleProvider.notifier).state.errorMessage, isNull);
    expect(container.read(articleProvider.notifier).state.page, 0);

    await container.read(articleProvider.notifier).loadArticles(); // user scroll page - load more items
    expect(container.read(articleProvider.notifier).state.articles.length, 2);
    expect(container.read(articleProvider.notifier).state.page, 2);

    expect(container.read(articleProvider.notifier).state.isLoading, isFalse);
    expect(container.read(articleProvider.notifier).state.errorMessage, isNull);
  });
}
