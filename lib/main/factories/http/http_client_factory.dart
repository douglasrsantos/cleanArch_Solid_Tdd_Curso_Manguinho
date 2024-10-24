import 'dart:io';

import 'package:fordev/infra/http/http.dart';
import 'package:http/http.dart';

HttpClient makeHttpAdapter() {
  final client = Client();
  return HttpAdapter(client);
}
