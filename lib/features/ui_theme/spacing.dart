import 'package:flutter/material.dart';

const kSingleSpacing = 8.0;
const kDoubleSpacing = 16.0;
const kTripleSpacing = 24.0;
const kQuadrupleSpacing = 32.0;

class AppSpacer extends StatelessWidget {
  final double? width;
  final double? height;

  const AppSpacer._({this.width, this.height});

  // Width and height
  factory AppSpacer.singleSpace() =>
      const AppSpacer._(width: kSingleSpacing, height: kSingleSpacing);
  factory AppSpacer.doubleSpace() =>
      const AppSpacer._(width: kDoubleSpacing, height: kDoubleSpacing);
  factory AppSpacer.tripleSpace() =>
      const AppSpacer._(width: kTripleSpacing, height: kTripleSpacing);
  factory AppSpacer.quadrupleSpace() =>
      const AppSpacer._(width: kQuadrupleSpacing, height: kQuadrupleSpacing);

  // Width only
  factory AppSpacer.singleWidth() =>
      const AppSpacer._(width: kSingleSpacing, height: 0);
  factory AppSpacer.doubleWidth() =>
      const AppSpacer._(width: kDoubleSpacing, height: 0);
  factory AppSpacer.tripleWidth() =>
      const AppSpacer._(width: kTripleSpacing, height: 0);
  factory AppSpacer.quadrupleWidth() =>
      const AppSpacer._(width: kQuadrupleSpacing, height: 0);

  // Height only
  factory AppSpacer.singleHeight() =>
      const AppSpacer._(width: 0, height: kSingleSpacing);
  factory AppSpacer.doubleHeight() =>
      const AppSpacer._(width: 0, height: kDoubleSpacing);
  factory AppSpacer.tripleHeight() =>
      const AppSpacer._(width: 0, height: kTripleSpacing);
  factory AppSpacer.quadrupleHeight() =>
      const AppSpacer._(width: 0, height: kQuadrupleSpacing);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
    );
  }
}
