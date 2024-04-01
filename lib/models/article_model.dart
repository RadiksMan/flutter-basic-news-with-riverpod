import 'package:flutter/material.dart';

@immutable
class Article {
  const Article({
    this.author,
    required this.title,
    this.description,
    this.publishedAt,
    this.content,
    this.url = '',
    this.urlToImage = '',
  });

  final String title;
  final String? author;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  Article.fromJsonMap(Map<String, dynamic> map)
      : author = map["author"],
        title = map["title"],
        description = map["description"],
        url = map["url"],
        urlToImage = map["urlToImage"],
        publishedAt = map["publishedAt"],
        content = map["content"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['author'] = author;
    data['title'] = title;
    data['description'] = description;
    data['url'] = url;
    data['urlToImage'] = urlToImage;
    data['content'] = content;
    return data;
  }

  Article copyWith({
    String? author,
    String? title,
    String? description,
    String? publishedAt,
    String? content,
    String? url,
    String? urlToImage,
  }) {
    return Article(
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
    );
  }
}

class ArticleState {
  ArticleState({
    required this.articles,
    this.page = 0,
    this.isLoading = true,
    this.isLoadMoreDone = false,
    this.errorMessage,
  });
  final List<Article> articles;
  final int page;
  final bool isLoading;
  final bool isLoadMoreDone;
  final String? errorMessage;

  ArticleState copyWith({
    List<Article>? articles,
    int? page,
    bool? isLoading,
    bool? isLoadMoreDone,
    String? errorMessage,
  }) {
    return ArticleState(
      articles: articles ?? this.articles,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLoadMoreDone: isLoadMoreDone ?? this.isLoadMoreDone,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
