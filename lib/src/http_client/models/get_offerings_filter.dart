class GetOfferingsFilter {
  final String? payinCurrency;
  final String? payoutCurrency;
  final String? id;

  GetOfferingsFilter({
    this.payinCurrency,
    this.payoutCurrency,
    this.id,
  });

  factory GetOfferingsFilter.fromJson(Map<String, dynamic> json) {
    return GetOfferingsFilter(
      payinCurrency: json['payinCurrency'],
      payoutCurrency: json['payoutCurrency'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (payinCurrency != null) 'payinCurrency': payinCurrency,
      if (payoutCurrency != null) 'payoutCurrency': payoutCurrency,
      if (id != null) 'id': id,
    };
  }
}
