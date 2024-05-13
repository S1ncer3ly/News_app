import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  NewsScreenState createState() => NewsScreenState();
}

class NewsScreenState extends State<NewsScreen> {
  List<dynamic> articles = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _loading = false;
  final int _pageSize = 10;
  int _currentPage = 1;

  final ScrollController _scrollController = ScrollController();

  Future<void> getNews(String query) async {
    if (_loading) return;
    _loading = true;

    String apiKey = '96bf0043f6d94973a2426018fbd78cb7';
    String region = 'in';
    String url =
        'https://newsapi.org/v2/top-headlines?country=$region&pageSize=$_pageSize&page=$_currentPage&apiKey=$apiKey';

    if (query.isNotEmpty) {
      url =
          'https://newsapi.org/v2/everything?q=$query&pageSize=$_pageSize&page=$_currentPage&apiKey=$apiKey';
    }

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      setState(() {
        if (_currentPage == 1) {
          articles = jsonData['articles'];
        } else {
          articles.addAll(jsonData['articles']);
        }
        _loading = false;
      });
    } else {
      debugPrint('Failed to load news');
      _loading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    getNews('');
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _currentPage++;
      getNews(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: (value) {
                  _currentPage = 1;
                  getNews(value);
                },
              )
            : const Text('Top News'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _currentPage = 1;
                  getNews('');
                }
              });
              if (_isSearching) {
                _searchFocusNode.requestFocus();
              } else {
                FocusScope.of(context).unfocus();
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Stack(
                    fit: StackFit.loose,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //ToDo
            ListTile(
              title: const Text('Categories'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('About Us'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Contact Information'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Name: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Team News App\n',
                                    style: TextStyle(
                                        color: Colors.grey
                                    )
                                ),
                                TextSpan(
                                  text: 'Number: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '********77\n',
                                  style: TextStyle(
                                    color: Colors.grey
                                  )
                                ),
                                TextSpan(
                                  text: 'Email: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'news_app_support@gmail.com',
                                    style: TextStyle(
                                        color: Colors.grey
                                    )
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text('Contact Us'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Contact Information'),
                      content: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Email: sidd@xyz'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: articles.length + 1,
        itemBuilder: (context, index) {
          if (index == articles.length) {
            return _loading ? _buildLoadingIndicator() : _buildLoadMoreButton();
          }

          DateTime publishedAt = DateTime.parse(articles[index]['publishedAt']);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailScreen(
                    title: articles[index]['title'],
                    description: articles[index]['description'] ?? '',
                    author: articles[index]['author'] ?? 'Unknown',
                    publishedAt: publishedAt,
                    content: articles[index]['content'] ?? '',
                    imageUrl: articles[index]['urlToImage'] ?? '',
                    url: articles[index]['url'] ?? '',
                  ),
                ),
              );
            },
            child: Card(
              shape: const RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.zero)),
              elevation: 10,
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: articles[index]['urlToImage'] != null
                    ? Image.network(
                        articles[index]['urlToImage'],
                        height: 200,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(
                        height: 100,
                        width: 100,
                        child: Center(child: Text('No Image')),
                      ),
                title: Text(
                  articles[index]['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      articles[index]['description'] ??
                          'No description available',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Author: ${articles[index]['author'] ?? 'Unknown'}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Published At: ${DateFormat('dd/MM/yy hh:mm a').format(publishedAt)}',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          _currentPage++;
          getNews(_searchController.text);
        },
        child: const Text('Load More'),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: NewsScreen(),
  ));
}
