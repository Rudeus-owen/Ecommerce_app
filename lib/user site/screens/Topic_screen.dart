import 'package:flutter/material.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  List items = [
    {
      "Topic": "New Arrivals",
      "imageUrl": "assets/images/new_arrivals.jpg",
    },
    {
      "Topic": "Dresses",
      "imageUrl": "assets/images/dresses.jpg",
    },
    {
      "Topic": "Tops",
      "imageUrl": "assets/images/tops.jpg",
    },
    {
      "Topic": "Jackets",
      "imageUrl": "assets/images/jackets.jpg",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Topic"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                print("tapping box $index...");
              },
              child: Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage(items[index]["imageUrl"]), fit: BoxFit.cover),
                      // color: Colors.red
                      ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        items[index]["Topic"],
                        style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
            ),
          );
        },
      ),
    );
  }
}
