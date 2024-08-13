import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:new_ecommerce_app/user%20site/screens/home.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: WelcomeScreens(),
    );
  }
}

class WelcomeScreens extends StatefulWidget {
  const WelcomeScreens({super.key});

  @override
  WelcomeScreensState createState() => WelcomeScreensState();
}

class WelcomeScreensState extends State<WelcomeScreens> {
  final LiquidController _liquidController = LiquidController();
  bool _isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (_isLastPage && details.primaryDelta! < 0) {
          // Do nothing if it's the last page and swiping left
        } else {
          _liquidController.jumpToPage(
            page: _liquidController.currentPage + (details.primaryDelta! > 0 ? -1 : 1),
          );
        }
      },
      child: Stack(
        children: [
          LiquidSwipe(
            pages: [
              buildPage(
                image: 'assets/images/shop4.png',
                title: 'Welcome to GEEZE',
                description: 'Discover the latest trends and exclusive deals in sportswear for all your fitness needs.',
                buttonText: 'Next',
                buttonAction: () {
                  _liquidController.animateToPage(page: 1);
                },
                backgroundColor: Color(0xFFF4595F),
                titleColor: Colors.white,
                textColor: Colors.white,
              ),
              buildPage(
                image: 'assets/images/shop2.png',
                title: 'Our Offerings',
                description: 'At Geeze, we offer a wide range of high-quality sportswear. From running gear to gym essentials, our products are designed to enhance your performance and keep you comfortable. Browse through our categories to find the perfect gear for your sport.',
                buttonText: 'Next',
                buttonAction: () {
                  _liquidController.animateToPage(page: 2);
                },
                backgroundColor: Color(0xFFF57859),
                titleColor: Colors.white,
                textColor: Colors.white,
              ),
              buildPage(
                image: 'assets/images/shop3.png',
                title: 'Delivery Service',
                description: 'Enjoy our fast and reliable delivery service. At Geeze, we ensure that your orders reach you on time, no matter where you are. With multiple shipping options and real-time tracking, you can shop with confidence and get your sportswear delivered right to your doorstep.',
                buttonText: 'Shop Now',
                 buttonAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                backgroundColor: Color(0xFF667D96),
                titleColor: Colors.white,
                textColor: Colors.white,
              ),
            ],
            liquidController: _liquidController,
            enableLoop: false,
            positionSlideIcon: 0.8, // Adjust the swipe sensitivity
            // slideIconWidget: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24), 
            onPageChangeCallback: (index) {
              setState(() {
                _isLastPage = index == 2; // Set true when last page is reached
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback buttonAction,
    Color backgroundColor = const Color.fromRGBO(238, 241, 242, 1),
    Color titleColor = const Color.fromRGBO(0, 116, 207, 1),
    Color textColor = const Color.fromRGBO(0, 116, 207, 1),
  }) {
    return Container(
      color: backgroundColor, // Set the background color
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(image, height: 250), // Increased image size
                SizedBox(height: 20),
                Text(
                  title,
                  style: GoogleFonts.ubuntu(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: titleColor, // Title color
                    shadows: [
                      const Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    fontSize: 18,
                    height: 1.5,
                    color: textColor, // Text color
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(3, (index) => buildDot(index, context)),
              ),
              ElevatedButton(
                onPressed: buttonAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(63, 67, 101, 1), // Button color
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5.0,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(color: Colors.white, fontSize: 16), // Button text color
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: _liquidController.currentPage.round() == index ? const Color.fromRGBO(63, 67, 101, 1) : Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
