import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

abstract class ServerHealthDataSource {
  Future<bool> isServerRunning();
}

class ServerHealthDataSourceImpl implements ServerHealthDataSource {
  final http.Client client;

  ServerHealthDataSourceImpl({required this.client});

  @override
  Future<bool> isServerRunning() async {
    try {
      final response = await client
          .get(Uri.parse('${ApiConstants.baseUrl}/health'))
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
