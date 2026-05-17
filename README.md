# otel_envoy

Dartastic OpenTelemetry bridge for Envoy (service proxy).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_envoy/otel_envoy.dart';

await tracedEnvoy<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return EnvoyCallResult(value: r, result: EnvoyResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutEnvoyInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
