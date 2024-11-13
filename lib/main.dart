import 'package:barikoi_map/Screens/MapScreen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/LocationProvider.dart';
import 'Screens/MapScreen.dart';
import 'Provider/LocationProvider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => LocationProvider(),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barikoi Map App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(),
    );
  }
}
