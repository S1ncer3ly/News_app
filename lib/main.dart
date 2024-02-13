import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> articles = [];
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode(); // Define a FocusNode for the search input
  bool _isSearching = false;
  bool _loading = false;
  int _pageSize = 10;
  int _currentPage = 1;

  ScrollController _scrollController = ScrollController();

  Future<void> getNews(String query) async {
    if (_loading) return; // Prevent multiple simultaneous requests
    _loading = true;

    String apiKey = '96bf0043f6d94973a2426018fbd78cb7';
    String region = 'in';
    String url =
        'https://newsapi.org/v2/top-headlines?country=in&pageSize=$_pageSize&page=$_currentPage&apiKey=$apiKey';

    if (query.isNotEmpty) {
      // Modify the URL to use the search query
      url = 'https://newsapi.org/v2/everything?q=$query&pageSize=$_pageSize&page=$_currentPage&apiKey=$apiKey';
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
      print('Failed to load news');
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
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _currentPage++;
      getNews(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? TextField(
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
            _currentPage = 1; // Reset page number when new search is performed
            getNews(value);
          },
        ) : const Text('Top News'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _currentPage = 1; // Reset page number when closing search
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
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('About Us'),
              onTap: () {
                // Navigate to the About Us screen
                Navigator.pop(context); // Close the drawer
                // Add navigation logic here
              },
            ),
            ListTile(
              title: Text('Contact Us'),
              onTap: () {
                // Navigate to the Contact Us screen
                Navigator.pop(context); // Close the drawer
                // Add navigation logic here
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
              // Navigate to NewsDetailScreen when tapped
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
              elevation: 3,
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: articles[index]['urlToImage'] != null
                    ? Image.network(
                  articles[index]['urlToImage'],
                  height: 100,
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
                      articles[index]['description'] ?? 'No description available',
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
    return Center(
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
        child: Text('Load More'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NewsScreen(),
  ));
}
