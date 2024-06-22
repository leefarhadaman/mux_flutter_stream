import 'package:flutter_dotenv/flutter_dotenv.dart';

class Secrets {
  static final String? accessTokenMUX = dotenv.env['MUX_TOKEN_ID'];
  static final String? secretTokenMUX = dotenv.env['MUX_TOKEN_SECRET'];

  static String get authToken => '$accessTokenMUX:$secretTokenMUX';
}
