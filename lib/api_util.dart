import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';

Uri apiUrl = Uri.parse("");

void setHttp() {
  HttpOverrides.global = new MyHttpOverrides();
}

Future<List<dynamic>> runApiGet(username, password, apiUrl) async {
  setHttp();
  String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
  try {
    var result = await http.get(
      apiUrl,
      headers: {
        'Connection': 'keep-alive',
        'X-Atlassian-Token': 'no-check',
        'authorization': basicAuth
      },
    ).timeout(const Duration(seconds: 5)).whenComplete(() => null);
    var bodyRes = result.body;
    if (result.statusCode != 401) {
      var newBodyRes = bodyRes.substring(bodyRes.indexOf("["), bodyRes.lastIndexOf("]")+1);
      return json.decode(newBodyRes);
    } else {
      return [];
    }
  } on Exception catch (_) {
    return [];
  }
}

Future<dynamic> runApiPost(username, password, apiUrl, body) async {
  setHttp();
  var bodyRes = "error";
  String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
  var result = await http
      .post(Uri.parse(apiUrl),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            'Connection': 'keep-alive',
            'X-Atlassian-Token': 'no-check',
            'Accept-Charset': 'ISO-8859-1',
            'authorization': basicAuth
          },
          body: json.encode(body));
//      .timeout(const Duration(seconds: 5));
  var statusCode = result.statusCode;
  return statusCode;
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<List<dynamic>> getCrossApp(_apiLink) async {
  setHttp();
  var result = await http
      .get(
        Uri.parse(_apiLink),
        headers: {'Connection': 'keep-alive', 'X-Atlassian-Token': 'no-check'},
      )
      .timeout(const Duration(seconds: 5))
      .whenComplete(() => null);
  var bodyRes = result.body;
  var ujResult = json.decode(bodyRes);
  return await ujResult;
}

Future<dynamic> insertLog(userId, muvelet) async {
  setHttp();
  String _apiLink = "https://crossapp.hu/jira_app/application/api/insert_log.php?userId=${userId}&muvelet=${muvelet}";
  var result = await http
      .post(
    Uri.parse(_apiLink),
    headers: {'Connection': 'keep-alive', 'X-Atlassian-Token': 'no-check'},
  )
      .timeout(const Duration(seconds: 5))
      .whenComplete(() => null);
  var statusCode = result.statusCode;
  return await statusCode;
}
