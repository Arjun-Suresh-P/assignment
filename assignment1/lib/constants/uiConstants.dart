import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UiConstants {
  final spinkit = SpinKitFadingCircle(
    itemBuilder: (BuildContext context, int index) {
      return SpinKitRotatingCircle(
        color: Colors.black,
        size: 50.0,
      );
    },
  );
}
