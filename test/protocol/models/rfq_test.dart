// import 'dart:convert';

// import 'package:tbdex/src/protocol/models/message_data.dart';
// import 'package:tbdex/src/protocol/models/offering.dart';
// import 'package:tbdex/src/protocol/models/resource.dart';
// import 'package:tbdex/src/protocol/models/resource_data.dart';
// import 'package:tbdex/src/protocol/models/rfq.dart';
// import 'package:test/test.dart';
// import 'package:typeid/typeid.dart';

// import '../../test_data.dart';

// void main() async {
//   await TestData.initializeDids();

//   group('RfqTest', () {
//     test('can create a new offering', () {
//       final offering = Rfq.create(
//         TestData.pfi,
//         TestData.alice
//         RfqData(
//           offeringId: TypeId.generate(ResourceKind.offering.name),
//           payinAmount: '1',
//           payinCurrency: PayinDetails(currencyCode: 'AUD'),
//           payoutCurrency: PayinDetails(currencyCode: 'BTC'),
//           payinMethods: [],
//           payoutMethods: [],
//         ),
//       );

//       expect(offering.data.description, equals('my fake offering'));
//       expect(offering.metadata.id, startsWith('offering'));
//       expect(offering.metadata.protocol, equals('1.0'));
//     });

//     test('can parse offering from a json string', () async {
//       final offering = TestData.getOffering();
//       await offering.sign(TestData.pfiDid);
//       final jsonResource = jsonEncode(offering.toJson());
//       final parsed = Resource.parse(jsonResource);

//       expect(parsed, isA<Offering>());
//       expect(parsed.toString(), equals(jsonResource));
//     });

//     test('can parse an offering', () async {
//       final offering = TestData.getOffering();
//       await offering.sign(TestData.pfiDid);
//       final jsonResource = jsonEncode(offering.toJson());
//       final parsedOffering = Resource.parse(jsonResource) as Offering;

//       expect(parsedOffering, isA<Offering>());
//     });

//     test('can parse an offering explicitly', () async {
//       final offering = TestData.getOffering();
//       await offering.sign(TestData.pfiDid);
//       final jsonResource = jsonEncode(offering.toJson());
//       final parsedOffering = Offering.parse(jsonResource);

//       expect(parsedOffering, isA<Offering>());
//     });
//   });
// }
