enum FiberSpeed { 
  speed300mb('300MB', 300),
  speed500mb('500MB', 500),
  speed1gb('1GB', 1000),
  speed2gb('2GB', 2000),
  speed5gb('5GB', 5000);

  const FiberSpeed(this.displayName, this.speedMbps);
  
  final String displayName;
  final int speedMbps;
}

class FiberPackage {
  final FiberSpeed speed;
  final double monthlyPrice;
  final double affiliateCommission;
  final double associateCommission;
  final String description;
  final List<String> features;

  FiberPackage({
    required this.speed,
    required this.monthlyPrice,
    required this.affiliateCommission,
    required this.associateCommission,
    required this.description,
    this.features = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'speed': speed.name,
      'monthlyPrice': monthlyPrice,
      'affiliateCommission': affiliateCommission,
      'associateCommission': associateCommission,
      'description': description,
      'features': features,
    };
  }

  factory FiberPackage.fromMap(Map<String, dynamic> map) {
    return FiberPackage(
      speed: FiberSpeed.values.firstWhere(
        (e) => e.name == map['speed'],
        orElse: () => FiberSpeed.speed300mb,
      ),
      monthlyPrice: (map['monthlyPrice'] ?? 0.0).toDouble(),
      affiliateCommission: (map['affiliateCommission'] ?? 0.0).toDouble(),
      associateCommission: (map['associateCommission'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      features: List<String>.from(map['features'] ?? []),
    );
  }

  FiberPackage copyWith({
    FiberSpeed? speed,
    double? monthlyPrice,
    double? affiliateCommission,
    double? associateCommission,
    String? description,
    List<String>? features,
  }) {
    return FiberPackage(
      speed: speed ?? this.speed,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      affiliateCommission: affiliateCommission ?? this.affiliateCommission,
      associateCommission: associateCommission ?? this.associateCommission,
      description: description ?? this.description,
      features: features ?? this.features,
    );
  }

  // Default packages
  static List<FiberPackage> getDefaultPackages() {
    return [
      FiberPackage(
        speed: FiberSpeed.speed300mb,
        monthlyPrice: 39.99,
        affiliateCommission: 50.0,
        associateCommission: 75.0,
        description: 'Perfect for basic browsing and streaming',
        features: ['300 Mbps download', 'Unlimited data', '24/7 support'],
      ),
      FiberPackage(
        speed: FiberSpeed.speed500mb,
        monthlyPrice: 49.99,
        affiliateCommission: 75.0,
        associateCommission: 100.0,
        description: 'Great for families and multiple devices',
        features: ['500 Mbps download', 'Unlimited data', '24/7 support', 'Free installation'],
      ),
      FiberPackage(
        speed: FiberSpeed.speed1gb,
        monthlyPrice: 69.99,
        affiliateCommission: 100.0,
        associateCommission: 125.0,
        description: 'High-speed for power users and gaming',
        features: ['1 Gbps download', 'Unlimited data', '24/7 support', 'Free installation', 'Wi-Fi 6 router included'],
      ),
      FiberPackage(
        speed: FiberSpeed.speed2gb,
        monthlyPrice: 99.99,
        affiliateCommission: 150.0,
        associateCommission: 200.0,
        description: 'Ultra-fast for businesses and heavy users',
        features: ['2 Gbps download', 'Unlimited data', '24/7 support', 'Free installation', 'Wi-Fi 6 router included', 'Priority support'],
      ),
      FiberPackage(
        speed: FiberSpeed.speed5gb,
        monthlyPrice: 149.99,
        affiliateCommission: 250.0,
        associateCommission: 300.0,
        description: 'Maximum speed for enterprise needs',
        features: ['5 Gbps download', 'Unlimited data', '24/7 support', 'Free installation', 'Wi-Fi 6 router included', 'Priority support', 'Dedicated account manager'],
      ),
    ];
  }
}