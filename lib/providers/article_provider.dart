import 'package:dio/dio.dart';
import 'package:flutter_basic_news_with_riverpod/models/article_model.dart';
import 'package:flutter_basic_news_with_riverpod/services/article_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final articleProvider = StateNotifierProvider<ArticleNotifier, ArticleState>((ref) {
  return ArticleNotifier(ref);
});

class ArticleNotifier extends StateNotifier<ArticleState> {
  ArticleNotifier(this.ref) : super(ArticleState(articles: [])) {
    loadArticles(); // init loading articles for 1 page
  }
  final Ref ref;

  loadArticles() async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      final newArticles = await ref.read(articleServiceProvider).fetchArticles(page: state.page + 1);

      if (newArticles.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          isLoadMoreDone: false,
          page: state.page + 1,
          articles: [...state.articles, ...newArticles],
        );
      } else {
        // reached end of articles
        state = state.copyWith(isLoading: false, isLoadMoreDone: true);
      }
    } on DioException catch (e) {
      // get error message from dio
      final message = e.response?.data['message'] ?? e.message;
      state = state.copyWith(isLoading: false, errorMessage: message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
