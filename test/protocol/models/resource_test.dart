import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:test/test.dart';
import 'package:web5/web5.dart';

import '../../helpers/test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('Resource', () {
    test('can generate resource type ids', () {
      final offeringId = Resource.generateId(ResourceKind.offering);
      expect(offeringId, startsWith(ResourceKind.offering.name));
    });

    test('sign populates resource signature', () async {
      final offering = TestData.getOffering();
      await offering.sign(TestData.pfiDid);

      expect(offering.signature, isNotNull);
      final jws = Jws.decode(offering.signature!);
      expect(jws.header.alg, isNotNull);
      expect(jws.header.kid, contains(TestData.pfiDid.uri));
    });

    test('resources must be signed by the sender', () async {
      final offeringFromPfi = TestData.getOffering();
      // Sign it with the wrong DID
      await offeringFromPfi.sign(TestData.aliceDid);

      await expectLater(
        offeringFromPfi.verify(),
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
