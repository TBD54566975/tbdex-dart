import 'package:tbdex/tbdex.dart';

class Balance extends Resource {
  @override
  final ResourceMetadata metadata;
  @override
  final BalanceData data;

  Balance._({
    required this.metadata,
    required this.data,
    String? signature,
  }) : super() {
    this.signature = signature;
  }

  static Balance create(
    String from,
    BalanceData data, {
    String? externalId,
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final metadata = ResourceMetadata(
      kind: ResourceKind.balance,
      from: from,
      id: Resource.generateId(ResourceKind.balance),
      protocol: protocol,
      createdAt: now,
      updatedAt: now,
    );

    return Balance._(
      metadata: metadata,
      data: data,
    );
  }

  static Future<Balance> parse(String rawResource) async {
    final balance = Parser.parseResource(rawResource) as Balance;
    await balance.verify();
    return balance;
  }

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance._(
      metadata: ResourceMetadata.fromJson(json['metadata']),
      data: BalanceData.fromJson(json['data']),
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
