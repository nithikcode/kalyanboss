import 'dart:typed_data';


abstract class BaseApiServices {
  Future<dynamic> getApi(String url);

  Future<dynamic> postApi(String url, dynamic data);

  Future<dynamic> putApi(String url, dynamic data);

  Future<dynamic> patchApi(String url, dynamic data);

  Future<dynamic> deleteApi(String url, dynamic data);

  Future<dynamic> postFormData(String url, Map<String, dynamic> data);

  /// Multipart (supports ANY file type)
  Future<dynamic> postMultipart(
      String url,
      Map<String, String> fields,
      List<Uint8List> files,
      List<String> fileNames, // <-- Added for multi-file / multi-type support
      );
}
