import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:tbdex/src/protocol/models/resource_data.dart';
import 'package:tbdex/src/protocol/parser.dart';

class Offering extends Resource {
  @override
  final ResourceMetadata metadata;
  @override
  final OfferingData data;

  Offering._({
    required this.metadata,
    required this.data,
    String? signature,
  }) : super() {
    this.signature = signature;
  }

  static Offering create(
    String from,
    OfferingData data, {
    String? externalId,
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toIso8601String();
    final metadata = ResourceMetadata(
      kind: ResourceKind.offering,
      from: from,
      id: Resource.generateId(ResourceKind.offering),
      protocol: protocol,
      createdAt: now,
      updatedAt: now,
    );

    return Offering._(
      metadata: metadata,
      data: data,
    );
  }

  static Future<Offering> parse(String rawResource) async {
    final offering = Parser.parseResource(rawResource) as Offering;
    await offering.verify();
    return offering;
  }

  factory Offering.fromJson(Map<String, dynamic> json) {
    return Offering._(
      metadata: ResourceMetadata.fromJson(json['metadata']),
      data: OfferingData.fromJson(json['data']),
      signature: json['signature'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'data': data.toJson(),
      'signature': signature,
    };
  }
}
