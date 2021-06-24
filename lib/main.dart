import 'package:flutter/material.dart';
import 'package:person_picker/views/mainView.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: ThemeData(
          primarySwatch: Colors.green,
          brightness: Brightness.light,
          primaryColor: Colors.green,
          accentColor: Colors.greenAccent,
          canvasColor: Colors.white,
          backgroundColor: Colors.grey[400],
          selectedRowColor: Colors.green[900],
          errorColor: Colors.redAccent[700],
          iconTheme: IconThemeData(color: Colors.white),
          textTheme: TextTheme(bodyText1: TextStyle(color: Colors.black), button: TextStyle(color: Colors.black)),
          elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(20),
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),

          )),
        ),
        dark: ThemeData(
          primarySwatch: Colors.purple,
          brightness: Brightness.dark,
          primaryColor: Colors.purple,
          accentColor: Colors.purpleAccent[100],
          canvasColor: Colors.grey[900],
          backgroundColor: Colors.grey[700],
          selectedRowColor: Colors.purpleAccent,
          errorColor: Colors.red[900],
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple, brightness: Brightness.dark),
          textTheme: TextTheme(bodyText1: TextStyle(color: Colors.grey[400]), button: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.grey[200]),
          elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(20),
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),

          )),
        ),
        initial: AdaptiveThemeMode.dark,
        builder: (theme, dark) =>
            MaterialApp(
                title: "Person Picker",
                theme: theme,
                darkTheme: dark,
                home: MainView()
            )
    );
  }
}
