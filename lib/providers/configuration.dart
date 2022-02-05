import 'package:flutter_dotenv/flutter_dotenv.dart';

class Configuration {
  static final Configuration _configuration = Configuration._internal();

  factory Configuration() {
    return _configuration;
  }

  Configuration._internal();

  String get firebaseKey => dotenv.env['FIREBASE_KEY']!;
}