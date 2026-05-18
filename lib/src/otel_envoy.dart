// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_envoy_suppression.dart';

class EnvoyResult {
  const EnvoyResult({
    this.cluster,
    this.upstreamHost,
    this.route,
    this.listener,
    this.filter,
    this.responseFlags,
    this.upstreamServiceTimeMs,
    this.durationMs,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? cluster;
  final String? upstreamHost;
  final String? route;
  final String? listener;
  final String? filter;
  final String? responseFlags;
  final int? upstreamServiceTimeMs;
  final int? durationMs;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class EnvoyCallResult<T> {
  const EnvoyCallResult({required this.value, this.result});
  final T value;
  final EnvoyResult? result;
}

Future<T> tracedEnvoy<T>({
  required String operation,
  required Future<EnvoyCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (envoyInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_envoy');
  final span = t.startSpan('envoy $operation', kind: SpanKind.server);
  try {
    span.setStringAttribute('http.route', '$operation');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.cluster != null) {
        span.setStringAttribute('envoy.cluster', res.cluster!);
      }
      if (res.upstreamHost != null) {
        span.setStringAttribute('server.address', res.upstreamHost!);
      }
      if (res.route != null) {
        span.setStringAttribute('http.route', res.route!);
      }
      if (res.listener != null) {
        span.setStringAttribute('envoy.listener', res.listener!);
      }
      if (res.filter != null) {
        span.setStringAttribute('envoy.filter', res.filter!);
      }
      if (res.responseFlags != null) {
        span.setStringAttribute('envoy.response_flags', res.responseFlags!);
      }
      if (res.upstreamServiceTimeMs != null) {
        span.setIntAttribute(
          'envoy.upstream.service_time',
          res.upstreamServiceTimeMs!,
        );
      }
      if (res.durationMs != null) {
        span.setIntAttribute('http.server.duration', res.durationMs!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('envoy.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'envoy.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
