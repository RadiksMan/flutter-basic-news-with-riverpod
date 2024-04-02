import 'package:flutter/material.dart';
import 'package:flutter_basic_news_with_riverpod/models/article_model.dart';
import 'package:flutter_basic_news_with_riverpod/providers/article_provider.dart';
import 'package:flutter_basic_news_with_riverpod/screens/article_single_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ArticleList extends ConsumerStatefulWidget {
  const ArticleList({super.key});

  @override
  ConsumerState<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends ConsumerState<ArticleList> {
  final _scrollController = ScrollController();
  double _lastScrollPosition = 0.0;
  static const _edgeHeight = 70;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(articleProvider).isLoading;
    final isLoadMoreDone = ref.watch(articleProvider).isLoadMoreDone;
    final articles = ref.watch(articleProvider).articles;
    final errorMessage = ref.watch(articleProvider).errorMessage;

    final isInitionError = errorMessage != null && articles.isEmpty;

    _bindErrorSnackbar();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isInitionError
                  ? Center(child: Text(errorMessage, textAlign: TextAlign.center))
                  : CustomScrollView(controller: _scrollController, slivers: [
                      //first loading indicator
                      if (isLoading && articles.isEmpty)
                        const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, int index) {
                              final article = articles[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 20.0),
                                child: Card(
                                  child: _buildListTile(article),
                                ),
                              );
                            },
                            childCount: articles.length,
                          ),
                        ),

                      // loading indicator at end of list
                      if (isLoading && !isLoadMoreDone && errorMessage == null)
                        SliverToBoxAdapter(
                          child: Container(
                            // color: Colors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ]),
            ),
          ],
        ),
      ),
    );
  }

  void _onScroll() {
    final currentScrollPosition = _scrollController.position.pixels;
    final maxScrollPosition = _scrollController.position.maxScrollExtent;
    final isLoading = ref.read(articleProvider).isLoading;

    if ((maxScrollPosition - currentScrollPosition) <= _edgeHeight &&
        (_lastScrollPosition - currentScrollPosition) < 0 &&
        !isLoading) {
      //reached end of the list - load more articles
      ref.read(articleProvider.notifier).loadArticles();
    }

    _lastScrollPosition = currentScrollPosition;
  }

  void _bindErrorSnackbar() {
    ref.listen(articleProvider, (previous, next) {
      if (previous?.errorMessage == null && next.errorMessage != null) {
        final snackBar = SnackBar(
          content: Text(next.errorMessage!),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  void _onArticleTap(Article article) {
    final route = MaterialPageRoute(
      builder: (ctx) => ArticleSingleScreen(article: article),
    );
    Navigator.push(context, route);
  }

  Widget _buildListTile(Article article) {
    final description = (article.description ?? '').split(' ').take(5).join(' ');

    final formatedDate = () {
      if (article.publishedAt != null) {
        final date = DateTime.parse(article.publishedAt!);
        return DateFormat.yMMMMd().format(date);
      }
      return '';
    }();

    return ListTile(
      onTap: () => _onArticleTap(article),
      visualDensity: const VisualDensity(vertical: 1),
      title: Text(
        article.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('$description...'),
      trailing: Text(formatedDate),
    );
  }
}
