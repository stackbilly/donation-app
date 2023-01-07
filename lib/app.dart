import 'package:donations_app/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:splashscreen/splashscreen.dart';
// ignore: depend_on_referenced_packages

class DonationsApp extends StatelessWidget {
  const DonationsApp({super.key});

  static Route bounceInRoute(Widget widget) {
    return PageRouteBuilder(
        pageBuilder: ((context, animation, secondaryAnimation) => widget),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.bounceOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(seconds: 1));
  }

  static Route<dynamic> route(Widget widget) {
    return CupertinoPageRoute(builder: (BuildContext context) {
      return widget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Donation Application',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.indigo,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: SplashScreen(
          seconds: 8,
          navigateAfterSeconds: HomePage(
            theme: false,
          ),
          backgroundColor: Colors.indigo,
          loaderColor: Colors.white,
          title: const Text(
            "TUN Charity Association",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.white),
          ),
          image: Image.asset('assets/logo.png'),
          photoSize: 75,
        ));
  }
}
