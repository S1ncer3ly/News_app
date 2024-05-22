import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String author;
  final DateTime publishedAt;
  final String content;
  final String imageUrl;
  final String url;
  final String source;

  const NewsDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.author,
    required this.publishedAt,
    required this.content,
    required this.imageUrl,
    required this.url,
    required this.source
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 350,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                  color: Colors.black),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        // Adjust the radius as needed
                        bottomRight: Radius.circular(
                            30.0),
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'Summarized By $author',
                style: const TextStyle(fontSize: 14,color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'Published At: ${DateFormat('dd/MM/yyyy ').format(publishedAt)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                description,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                content,
                style: const TextStyle(fontSize: 16),
                maxLines: null,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  _launchURL(url);
                },
                child: const Text('Read More'),
              ),
            ),
            const SizedBox(height: 100,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Source: $source',
                style: const TextStyle(fontSize: 14,color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
