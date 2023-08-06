import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:webview_flutter/webview_flutter.dart';

class ArticleList {
  final String img;
  final String category;
  final String title;
  final String description;
  final String link;

  ArticleList(this.img, this.category, this.title, this.description, this.link);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('d3h1 Blog')),
        body: FutureBuilder<List<ArticleList>>(
          future: getArticleData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            else if (snapshot.hasError) {
              return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error),
                      SizedBox(height: 8),
                      Text(
                        "블로그를 불러오는데 오류가 발생했어요.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "인터넷에 연결이 되어있지 않거나\n블로그 자체에 문제가 생긴 것일 수 있어요.\n",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "인터넷 연결에 문제가 없다면 개발자에게 문의해주세요.",
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              );
            }
            else {
               return ListView.builder(
                itemCount: snapshot.data!.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "홈",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                  var article = snapshot.data![index - 1];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticlePage(link: article.link),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Image.network(article.img),
                          const SizedBox(height: 8),
                          Text(
                            article.category,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            article.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

Future<List<ArticleList>> getArticleData() async {
  final response = await http.get(Uri.parse('https://blog.d3h1.com'));
  var document = parser.parse(response.body);

  List<dom.Element> articleList = document.querySelectorAll('main article');
  return articleList.map((article) {
    var img = article.querySelector('img');
    var category = article.querySelector('.post-category');
    var title = article.querySelector('.post-title');
    var description = article.querySelector('.post-description');
    var link = article.querySelector('a')?.attributes['href'] ?? '';

    if (img != null) {
      String src = img.attributes['src']!;
      return ArticleList(
        'https://blog.d3h1.com$src',
        category?.text ?? '',
        title?.text ?? '',
        description?.text ?? '',
        'https://blog.d3h1.com$link',
      );
    }
    else {
      return ArticleList(
        '',
        category?.text ?? '',
        title?.text ?? '',
        description?.text ?? '',
        ''
      );
    }
  }).toList();
}

Future<String> getArticleContent(String link) async {
  final response = await http.get(Uri.parse(link));
  var document = parser.parse(response.body);
  dom.Element? contentElement = document.querySelector('main article');

  if (contentElement != null) {
    return contentElement.innerHtml;
  } else {
    throw Exception("Failed to parse the article content");
  }
}

class ArticlePage extends StatelessWidget {
  final String link;

  const ArticlePage({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WebView(
        initialUrl: link,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}