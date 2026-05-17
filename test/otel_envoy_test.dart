// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_envoy/otel_envoy.dart';
import 'package:test/test.dart';

void main() {
  group('otel_envoy', () {
    test('suppression toggles in zone', () async {
      expect(envoyInstrumentationSuppressed(), isFalse);
      await runWithoutEnvoyInstrumentationAsync(() async {
        expect(envoyInstrumentationSuppressed(), isTrue);
      });
      expect(envoyInstrumentationSuppressed(), isFalse);
    });

    test('EnvoyResult fields default null', () {
      const r = EnvoyResult();
      expect(r.statusCode, isNull);
    });
  });
}
