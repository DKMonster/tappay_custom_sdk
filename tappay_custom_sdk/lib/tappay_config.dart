class TapPayConfig {
  final String appId;
  final String appKey;
  final bool isProduction;

  TapPayConfig({
    required this.appId,
    required this.appKey,
    this.isProduction = false,
  });

  Map<String, dynamic> toJson() => {
        'appId': appId,
        'appKey': appKey,
        'isProduction': isProduction,
      };
}
