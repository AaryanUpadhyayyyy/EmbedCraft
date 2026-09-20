import 'package:flutter/material.dart';
import 'package:in_app_ninja/in_app_ninja.dart';

void main() {
  Widget testWidget = InkWell(
    onTap: () {},
    child: Container(),
  ).appNinjaIdentifier('test_id');

  print('Success! $testWidget');
}
