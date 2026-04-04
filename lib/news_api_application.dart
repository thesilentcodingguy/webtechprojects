import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: NewsApp()));
}

class News {
  final String title;
  final String description;
  final String image;
  final String category;
  final bool breaking;

  News(this.title, this.description, this.image, this.category, this.breaking);
}

class NewsApp extends StatefulWidget {
  @override
  State<NewsApp> createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  List<News> allNews = [
    News("Market crashes suddenly", "Stock market sees a huge dip today.", "https://picsum.photos/400/200?1", "Business", true),
    News("Football finals tonight", "Exciting match expected in finals.", "https://picsum.photos/400/200?2", "Sports", false),
    News("New tech unveiled", "Latest smartphone launched today.", "https://picsum.photos/400/200?3", "Technology", true),
    News("Movie breaks records", "Box office hits new high.", "https://picsum.photos/400/200?4", "Entertainment", false),
    News("Health tips trending", "Doctors share new wellness tips.", "https://picsum.photos/400/200?5", "Health", false),
  ];

  String selectedCategory = "All";
  Set<News> bookmarks = {};

  List<String> categories = ["All", "Business", "Sports", "Technology", "Entertainment", "Health"];

  @override
  Widget build(BuildContext context) {
    List<News> filtered = selectedCategory == "All"
        ? allNews
        : allNews.where((n) => n.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("News App"),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => BookmarkPage(bookmarks)));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = categories[i];
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: selectedCategory == categories[i] ? Colors.black : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      categories[i],
                      style: TextStyle(
                          color: selectedCategory == categories[i] ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final news = filtered[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(news)));
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image.network(news.image, fit: BoxFit.cover, width: double.infinity, height: 180),
                            if (news.breaking)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  color: Colors.red,
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text("BREAKING", style: TextStyle(color: Colors.white)),
                                ),
                              )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(news.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              IconButton(
                                icon: Icon(
                                  bookmarks.contains(news) ? Icons.bookmark : Icons.bookmark_border,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (bookmarks.contains(news)) {
                                      bookmarks.remove(news);
                                    } else {
                                      bookmarks.add(news);
                                    }
                                  });
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final News news;

  DetailPage(this.news);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(news.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(news.image, width: double.infinity, height: 250, fit: BoxFit.cover),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(news.description, style: TextStyle(fontSize: 18)),
          )
        ],
      ),
    );
  }
}

class BookmarkPage extends StatelessWidget {
  final Set<News> bookmarks;

  BookmarkPage(this.bookmarks);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bookmarks")),
      body: bookmarks.isEmpty
          ? Center(child: Text("No bookmarks"))
          : ListView(
              children: bookmarks.map((news) {
                return ListTile(
                  leading: Image.network(news.image, width: 60, fit: BoxFit.cover),
                  title: Text(news.title),
                );
              }).toList(),
            ),
    );
  }
}
