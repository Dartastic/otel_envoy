// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_envoy/otel_envoy.dart';

/// Traces Envoy calls with OpenTelemetry.
///
/// `otel_envoy` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Envoy call in
/// [tracedEnvoy]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'envoy-example');

  // Traces a Envoy call.
  final envoyId = await tracedEnvoy<String>(
    operation: 'create',
    invoke: () async {
      // Make the Envoy call here, then report what it returned.
      const id = 'envoy_8f3a2c';
      return const EnvoyCallResult(
          value: id,
          result: EnvoyResult(
              cluster: 'example',
              upstreamHost: 'api.example.com',
              route: 'example',
              listener: 'example',
              filter: 'example',
              responseFlags: 'example',
              upstreamServiceTimeMs: 120,
              durationMs: 120,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedEnvoy create returned $envoyId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutEnvoyInstrumentationAsync.
  await runWithoutEnvoyInstrumentationAsync(
    () => tracedEnvoy<String>(
      operation: 'create',
      invoke: () async {
        const id = 'envoy_8f3a2c';
        return const EnvoyCallResult(
            value: id,
            result: EnvoyResult(
                cluster: 'example',
                upstreamHost: 'api.example.com',
                route: 'example',
                listener: 'example',
                filter: 'example',
                responseFlags: 'example',
                upstreamServiceTimeMs: 120,
                durationMs: 120,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
