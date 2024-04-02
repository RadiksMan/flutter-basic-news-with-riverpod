import 'package:dio/dio.dart';
import 'package:flutter_basic_news_with_riverpod/models/article_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiUtils {
  static const String url = 'https://newsapi.org/v2/'; // with fixed CORS for newsapi.org
  //static const String apiKey = '9d1ddd9b5aa04506b12a5f35a28a7e3a';
  static const String apiKey = 'b934e64150484c21b11bcfb2430c18bc';
  static const String noImage = 'https://upload.wikimedia.org/wikipedia/commons/a/a3/Image-not-found.png';
  static const int pageSize = 15;
}

final articleServiceProvider = Provider<ArticleService>((_) {
  return ArticleService();
});

class ArticleService {
  late final _dio = Dio(
    BaseOptions(
      baseUrl: ApiUtils.url,
      responseType: ResponseType.json,
      headers: {
        'X-Api-Key': ApiUtils.apiKey,
      },
      queryParameters: {
        'sortBy': 'popularity',
        'language': 'en',
        'pageSize': ApiUtils.pageSize,
      },
    ),
  );

  Future<List<Article>> fetchArticles({required int page}) async {
    final result = await _dio.get(
      'top-headlines',
      queryParameters: {
        'page': page,
      },
    );

    if (result.data['status'] != 'ok') {
      throw Exception(result.data.message);
    }

    final articles = <Article>[];

    if (result.data['articles'] != null) {
      final rawArticleList = result.data['articles'] as List;
      for (final rawArticle in rawArticleList) {
        articles.add(Article.fromJsonMap(rawArticle));
      }
    }

    return articles;
  }
}
