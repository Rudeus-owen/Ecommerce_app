import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:new_ecommerce_app/admin%20site/widgets/theme_manager.dart';
import 'package:new_ecommerce_app/user%20site/providers/cart.dart';
import 'package:new_ecommerce_app/user%20site/screens/first_screen.dart';
import 'package:new_ecommerce_app/user%20site/screens/home.dart';
import 'package:new_ecommerce_app/user%20site/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // Set preferred orientations
  Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => Cart()), // Add Cart provider
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ecommerce App',
            themeMode: themeManager.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: FirstScreen(),
            routes: {
              '/home': (context) => HomeScreen(),
              '/product-detail': (context) => ProductViewScreen(productId: ModalRoute.of(context)!.settings.arguments as int),
            },
          );
        },
      ),
    );
  }
}
