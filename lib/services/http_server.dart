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

    if (port <= 0 || port > 65535) {
      throw ArgumentError('Port must be between 1 and 65535, got: $port');
    }

    final router = _createRouter();
    final handler = _createPipeline(router);

    try {
      _server = await serve(handler, InternetAddress.anyIPv4, port);
      _logger.i('HTTP translation server started successfully on port $port');
    } catch (e) {
      _logger.e('Failed to start HTTP server on port $port: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    if (_server != null) {
      try {
        await _server!.close(force: true);
        _logger.i('HTTP translation server stopped successfully');
      } catch (e) {
        _logger.w('Error stopping HTTP server: $e');
      } finally {
        _server = null;
      }
    }
  }

  Router _createRouter() {
    final router = Router();

    // 翻译端点
    router.get('/translate', _handleTranslate);
    router.post('/translate', _handleTranslatePost);

    // 健康检查端点
    router.get('/health', _handleHealth);

    // 服务信息端点
    router.get('/info', _handleInfo);

    // 404 处理
    router.all('/<path|.*>', _handleNotFound);

    return router;
  }

  Handler _createPipeline(Router router) {
    return Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(_customLogMiddleware())
        .addMiddleware(_errorHandlingMiddleware())
        .addHandler(router.call);
  }

  Middleware _customLogMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        final watch = Stopwatch()..start();
        final response = await handler(request);
        watch.stop();

        _logger.i(
          '${request.method} ${request.requestedUri.path} '
          '${response.statusCode} ${watch.elapsedMilliseconds}ms',
        );

        return response;
      };
    };
  }

  Middleware _errorHandlingMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        try {
          return await handler(request);
        } catch (e, stackTrace) {
          _logger.e(
            'Unhandled error in request handler',
            error: e,
            stackTrace: stackTrace,
          );
          return Response.internalServerError(
            body: json.encode({
              'error': 'Internal server error',
              'message': 'An unexpected error occurred',
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      };
    };
  }

  Future<Response> _handleTranslate(Request request) async {
    try {
      final params = request.url.queryParameters;
      final validationResult = _validateTranslationParams(params);

      if (validationResult != null) {
        return validationResult;
      }

      final result = await _performTranslation(
        text: params['text']!,
        from: params['from']!,
        to: params['to']!,
      );

      return Response.ok(
        result,
        headers: {'Content-Type': 'text/plain; charset=utf-8'},
      );
    } catch (e) {
      return _handleTranslationError(e);
    }
  }

  Future<Response> _handleTranslatePost(Request request) async {
    try {
      final contentType = request.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        return Response.badRequest(
          body: json.encode({
            'error': 'Invalid content type',
            'message': 'Expected application/json',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;

      final from = data['from'] as String?;
      final to = data['to'] as String?;
      final text = data['text'] as String?;

      final validationError = _validateTranslationData(from, to, text);
      if (validationError != null) {
        return validationError;
      }

      final result = await _performTranslation(
        text: text!,
        from: from!,
        to: to!,
      );

      return Response.ok(
        json.encode({'translation': result}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _handleTranslationError(e);
    }
  }

  Response? _validateTranslationParams(Map<String, String> params) {
    final from = params['from'];
    final to = params['to'];
    final text = params['text'];

    return _validateTranslationData(from, to, text);
  }

  Response? _validateTranslationData(String? from, String? to, String? text) {
    if (from == null || to == null || text == null) {
      return Response.badRequest(
        body: json.encode({
          'error': 'Missing required parameters',
          'message': 'Parameters "from", "to", and "text" are required',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (text.trim().isEmpty) {
      return Response.badRequest(
        body: json.encode({
          'error': 'Invalid text parameter',
          'message': 'Text parameter cannot be empty',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (from.trim().isEmpty || to.trim().isEmpty) {
      return Response.badRequest(
        body: json.encode({
          'error': 'Invalid language parameters',
          'message': 'Language parameters cannot be empty',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return null;
  }

  Future<String> _performTranslation({
    required String text,
    required String from,
    required String to,
  }) async {
    if (_translationService.isDisposed) {
      throw StateError('Translation service is not available');
    }

    return await _translationService.translate(text: text, from: from, to: to);
  }

  Response _handleTranslationError(Object error) {
    _logger.e('Translation request failed: $error');

    if (error is ArgumentError) {
      return Response.badRequest(
        body: json.encode({
          'error': 'Invalid request',
          'message': error.message,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (error is StateError) {
      return Response(
        503,
        body: json.encode({
          'error': 'Service unavailable',
          'message': error.message,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.internalServerError(
      body: json.encode({
        'error': 'Translation failed',
        'message': error.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _handleHealth(Request request) async {
    return Response.ok(
      json.encode({
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'translation-server',
        'version': '1.0.0',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _handleInfo(Request request) async {
    return Response.ok(
      json.encode({
        'name': 'XUnity AI Translator Server',
        'version': '1.0.0',
        'endpoints': [
          'GET /translate?from=<lang>&to=<lang>&text=<text>',
          'POST /translate',
          'GET /health',
          'GET /info',
        ],
        'active_requests': _translationService.activeRequestsCount,
        'max_concurrency': _translationService.maxConcurrency,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _handleNotFound(Request request) async {
    return Response.notFound(
      json.encode({
        'error': 'Not found',
        'message': 'The requested endpoint does not exist',
        'path': request.requestedUri.path,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  bool get isRunning => _server != null;
  int? get port => _server?.port;
}
