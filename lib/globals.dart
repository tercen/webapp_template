
import 'package:kumo_api/kumo_api.dart' as kumo;
import 'package:dio/dio.dart';
class States {
  static bool hasError = false;
  static String loadedProject = "";
  static String projectUser = "";
}


kumo.KumoApi _api = kumo.KumoApi(
    dio: Dio(BaseOptions(
  baseUrl: 'https://kumo-server-tn732wfkfa-an.a.run.app',
  connectTimeout: const Duration(seconds: 600),
  receiveTimeout: const Duration(seconds: 600),
)));



kumo.KumoApi get kumoApi => _api;