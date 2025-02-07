import 'package:flutter/material.dart';
import 'package:crop_weed_detector/services/api_service.dart';

class NewsScreen extends StatelessWidget {
  Future<List<dynamic>> _fetchNews() async => await ApiService.fetchNews();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agricultural News")),
      body: FutureBuilder(
        future: _fetchNews(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          List<dynamic> news = snapshot.data!;
          return ListView.builder(
            itemCount: news.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(news[index]["title"], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(news[index]["subtitle"]),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(news[index]["title"]),
                    content: Text(news[index]["content"]),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
