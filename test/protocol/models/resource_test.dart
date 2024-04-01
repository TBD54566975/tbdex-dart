import 'dart:convert';

import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:test/test.dart';
import 'package:web5/web5.dart';

import '../../test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('ResourceTest', () {
    test('sign populates resource signature', () async {
      final offering = TestData.getOffering();
      await offering.sign(TestData.pfiDid);

      expect(offering.signature, isNotNull);
      final jws = Jws.decode(offering.signature!);
      expect(jws.header.alg, isNotNull);
      expect(jws.header.kid, contains(TestData.pfiDid.uri));
    });

    test('parse throws error if json string is not valid', () async {
      await expectLater(
        Resource.parse(';;;;'),
        throwsA(isA<FormatException>()),
      );
    });

    test('resources must be signed by the sender', () async {
      final offeringFromPfi = TestData.getOffering();
      // Sign it with the wrong DID
      await offeringFromPfi.sign(TestData.aliceDid);

      await expectLater(
        Resource.parse(jsonEncode(offeringFromPfi.toJson())),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'signature verification',
            contains(
              'signature verification failed: was not signed by the expected DID',
            ),
          ),
        ),
      );
    });
  });
}
