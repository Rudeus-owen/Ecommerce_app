import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
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
      body: SafeArea(
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
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
      ),
    );
  }
}
