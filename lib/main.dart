import 'package:flutter/material.dart';
import 'package:prolist/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/favorite_provider.dart';
import 'screens/homescreen.dart';
import 'utils/apptheme.dart'; // Import the theme

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('main dart running');
    // MultiProvider is used to provide multiple objects down the widget tree.
    return MultiProvider(
      providers: [
        // FavoritesProvider should be available before ProductProvider
        // if ProductProvider depends on it during initialization.
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        // ProductProvider depends on FavoritesProvider, so we use a ProxyProvider
        // or pass it in the constructor after FavoritesProvider is created.
        // Here, we'll pass it via constructor after ensuring FavoritesProvider is available.
        ChangeNotifierProxyProvider<FavoritesProvider, ProductProvider>(
          create: (context) => ProductProvider(
            Provider.of<FavoritesProvider>(context, listen: false),
          ),
          update: (context, favoritesProvider, previousProductProvider) {
            // This update callback is useful if ProductProvider needs to react to FavoritesProvider changes
            // at a higher level, or if its creation depends on dynamic values from FavoritesProvider.
            // For simple constructor dependency, the 'create' is often sufficient.
            // If ProductProvider was already created, you might update it.
            // For this setup, just re-creating or ensuring it has the latest favProvider is key.
            // A simpler way if no complex updates are needed:
            // return previousProductProvider ?? ProductProvider(favoritesProvider);
            // However, since ProductProvider fetches data in its constructor,
            // we might not want to re-create it on every FavoritesProvider update unless necessary.
            // Let's stick to the constructor injection via 'create' and ensure ProductProvider
            // internally listens or syncs with FavoritesProvider as needed.
            // The current ProductProvider setup syncs when products are fetched/refreshed.
            if (previousProductProvider == null) {
              return ProductProvider(favoritesProvider);
            }
            // If you need to pass the updated favoritesProvider to an existing productProvider instance
            // you would need a method in ProductProvider like `updateFavoritesProvider(newProvider)`
            // For now, the create method handles the initial dependency.
            return previousProductProvider; // Or handle updates if necessary
          },
        ),
      ],
      child: MaterialApp(
        title: 'Product Listing App',
        theme: AppTheme.lightTheme, // Apply the custom theme
        debugShowCheckedModeBanner: false, // Remove debug banner
        home: const SplashScreen(),
        // You can define routes here for named navigation if preferred:
        // routes: {
        //   '/': (context) => HomeScreen(),
        //   ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
        //   FavoritesScreen.routeName: (context) => FavoritesScreen(),
        // },
      ),
    );
  }
}
