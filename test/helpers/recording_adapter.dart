import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A Dio transport that records each request and answers from [respond].
///
/// Using it on a real [Dio] rather than mocking [Dio] keeps its headers,
/// base options and status handling in the test — which is what a header or
/// status-code test is actually about.
class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter(this.respond);

  /// Status and JSON body for a request. Throw a [DioException] to simulate a
  /// transport failure.
  (int, Object?) Function(RequestOptions options) respond;

  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = respond(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
