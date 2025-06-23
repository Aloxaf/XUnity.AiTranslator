import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:logger/logger.dart';
import 'enhanced_translation_service.dart';

class HttpTranslationServer {
  HttpServer? _server;
  final Logger _logger = Logger();
  final EnhancedTranslationService _translationService;

  HttpTranslationServer(this._translationService);

  Future<void> start(int port) async {
    await stop();

    final router = Router();

    // 翻译端点
    router.get('/translate', _handleTranslate);

    // 健康检查端点
    router.get('/health', _handleHealth);

    final handler = Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addHandler(router.call);

    try {
      _server = await serve(handler, InternetAddress.anyIPv4, port);
      _logger.i('HTTP server started on port $port');
    } catch (e) {
      _logger.e('Failed to start HTTP server: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      _logger.i('HTTP server stopped');
    }
  }

  Future<Response> _handleTranslate(Request request) async {
    try {
      final params = request.url.queryParameters;
      final from = params['from'];
      final to = params['to'];
      final text = params['text'];

      if (from == null || to == null || text == null) {
        return Response.badRequest(
          body: 'Missing required parameters: from, to, text',
          headers: {'Content-Type': 'text/plain; charset=utf-8'},
        );
      }

      if (text.isEmpty) {
        return Response.badRequest(
          body: 'Text parameter cannot be empty',
          headers: {'Content-Type': 'text/plain; charset=utf-8'},
        );
      }

      final result = await _translationService.translate(
        text: text,
        from: from,
        to: to,
      );

      return Response.ok(
        result,
        headers: {'Content-Type': 'text/plain; charset=utf-8'},
      );
    } catch (e) {
      _logger.e('Translation request failed: $e');
      return Response.internalServerError(
        body: 'Translation failed: ${e.toString()}',
        headers: {'Content-Type': 'text/plain; charset=utf-8'},
      );
    }
  }

  Future<Response> _handleHealth(Request request) async {
    return Response.ok(
      json.encode({
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  bool get isRunning => _server != null;
  int? get port => _server?.port;
}
