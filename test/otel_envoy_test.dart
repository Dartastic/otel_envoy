// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

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
