// Radyoaktif kaynaklar
enum RadioactiveSource {
  iridium192('Ir-192', 73.827, 0.48),
  selenium75('Se-75', 119.779, 0.20),
  cobalt60('Co-60', 1925.28, 1.25),
  ytterbium169('Yb-169', 32.02, 0.125);

  const RadioactiveSource(
    this.displayName,
    this.halfLifeDays,
    this.gammaConstant,
  );

  final String displayName;
  final double halfLifeDays;
  final double gammaConstant;
}

// Malzemeler ve HVL değerleri (mm)
enum NDTMaterial {
  steel({
    'tr': 'Demir (Çelik)',
    'en': 'Steel',
    'ru': 'Сталь',
  }, {
    RadioactiveSource.iridium192: 12.7,
    RadioactiveSource.selenium75: 12.7,
    RadioactiveSource.cobalt60: 20.0,
    RadioactiveSource.ytterbium169: 9.0,
  }),
  concrete({
    'tr': 'Beton',
    'en': 'Concrete',
    'ru': 'Бетон',
  }, {
    RadioactiveSource.iridium192: 44.5,
    RadioactiveSource.selenium75: 44.5,
    RadioactiveSource.cobalt60: 75.0,
    RadioactiveSource.ytterbium169: 30.0,
  }),
  tungsten({
    'tr': 'Tungsten',
    'en': 'Tungsten',
    'ru': 'Вольфрам',
  }, {
    RadioactiveSource.iridium192: 3.3,
    RadioactiveSource.selenium75: 3.3,
    RadioactiveSource.cobalt60: 5.8,
    RadioactiveSource.ytterbium169: 2.5,
  }),
  lead({
    'tr': 'Kurşun',
    'en': 'Lead',
    'ru': 'Свинец',
  }, {
    RadioactiveSource.iridium192: 4.8,
    RadioactiveSource.selenium75: 4.8,
    RadioactiveSource.cobalt60: 8.3,
    RadioactiveSource.ytterbium169: 3.5,
  }),
  aluminum({
    'tr': 'Alüminyum',
    'en': 'Aluminum',
    'ru': 'Алюминий',
  }, {
    RadioactiveSource.iridium192: 84.0,
    RadioactiveSource.selenium75: 84.0,
    RadioactiveSource.cobalt60: 130.0,
    RadioactiveSource.ytterbium169: 65.0,
  }),
  titanium({
    'tr': 'Titanyum',
    'en': 'Titanium',
    'ru': 'Титан',
  }, {
    RadioactiveSource.iridium192: 25.0,
    RadioactiveSource.selenium75: 25.0,
    RadioactiveSource.cobalt60: 40.0,
    RadioactiveSource.ytterbium169: 18.0,
  }),
  copper({
    'tr': 'Bakır',
    'en': 'Copper',
    'ru': 'Медь',
  }, {
    RadioactiveSource.iridium192: 15.0,
    RadioactiveSource.selenium75: 15.0,
    RadioactiveSource.cobalt60: 25.0,
    RadioactiveSource.ytterbium169: 12.0,
  });

  const NDTMaterial(this.displayNames, this.hvlValues);

  final Map<String, String> displayNames;
  final Map<RadioactiveSource, double> hvlValues;

  /// Aktif dili parametre olarak alır, yoksa 'tr' döner
  String getDisplayName([String? langCode]) {
    final code = langCode ?? 'tr';
    return displayNames[code] ?? displayNames['tr']!;
  }

  double getHVL(RadioactiveSource source) {
    return hvlValues[source] ?? 12.7;
  }
}

// Film türleri ve faktörleri
enum FilmType {
  // AGFA Films
  agfaD2('AGFA D2', 9.0),
  agfaD3('AGFA D3', 3.8),
  agfaD4('AGFA D4', 2.4),
  agfaD5('AGFA D5', 1.6),
  agfaD7('AGFA D7', 1.0),
  agfaD8('AGFA D8', 0.5),

  // FUJI Films
  fujiIX25('FUJI IX 25', 9.0),
  fujiIX50('FUJI IX 50', 3.8),
  fujiIX80('FUJI IX 80', 1.8),
  fujiIX100('FUJI IX 100', 1.4),
  fujiIX150('FUJI IX 150', 0.57),

  // KODAK Films
  kodakM100('CARESTREAM M100', 8.0),
  kodakMX125('CARESTREAM MX125', 4.8),
  kodakT200('CARESTREAM T200', 2.8),
  kodakAA400('CARESTREAM AA400', 1.7),
  kodakSH800('CARESTREAM HS800', 1.1);

  const FilmType(this.displayName, this.factor);

  final String displayName;
  final double factor;
}

// Yoğunluk seçenekleri
enum DensityOption {
  density1_0('1.0', 1.0),
  density1_1('1.1', 1.1),
  density1_2('1.2', 1.2),
  density1_3('1.3', 1.3),
  density1_4('1.4', 1.4),
  density1_5('1.5', 1.5),
  density1_6('1.6', 1.6),
  density1_7('1.7', 1.7),
  density1_8('1.8', 1.8),
  density1_9('1.9', 1.9),
  density2_0('2.0', 2.0),
  density2_1('2.1', 2.1),
  density2_2('2.2', 2.2),
  density2_3('2.3', 2.3),
  density2_4('2.4', 2.4),
  density2_5('2.5', 2.5),
  density2_6('2.6', 2.6),
  density2_7('2.7', 2.7),
  density2_8('2.8', 2.8),
  density2_9('2.9', 2.9),
  density3_0('3.0', 3.0),
  density3_1('3.1', 3.1),
  density3_2('3.2', 3.2),
  density3_3('3.3', 3.3),
  density3_4('3.4', 3.4),
  density3_5('3.5', 3.5),
  density3_6('3.6', 3.6),
  density3_7('3.7', 3.7),
  density3_8('3.8', 3.8),
  density3_9('3.9', 3.9),
  density4_0('4.0', 4.0);

  const DensityOption(this.displayName, this.value);

  final String displayName;
  final double value;

  // Varsayılan yoğunluk
  static DensityOption get defaultDensity => density2_5;

  // Tüm seçenekler
  static List<DensityOption> get allOptions => DensityOption.values;

  // Değerden DensityOption bul
  static DensityOption? fromValue(double value) {
    for (DensityOption option in DensityOption.values) {
      if ((option.value - value).abs() < 0.001) {
        return option;
      }
    }
    return null;
  }

  // En yakın değeri bul
  static DensityOption findNearest(double value) {
    DensityOption? nearest;
    double minDistance = double.infinity;

    for (DensityOption option in DensityOption.values) {
      double distance = (option.value - value).abs();
      if (distance < minDistance) {
        minDistance = distance;
        nearest = option;
      }
    }

    return nearest ?? defaultDensity;
  }
}

// Yoğunluk faktörleri
class DensityFactors {
  static final Map<double, double> _densityMap = {
    1.0: 0.40,
    1.1: 0.44,
    1.2: 0.48,
    1.3: 0.52,
    1.4: 0.56,
    1.5: 0.60,
    1.6: 0.64,
    1.7: 0.68,
    1.8: 0.72,
    1.9: 0.76,
    2.0: 0.80,
    2.1: 0.84,
    2.2: 0.88,
    2.3: 0.92,
    2.4: 0.96,
    2.5: 1.00,
    2.6: 1.04,
    2.7: 1.08,
    2.8: 1.12,
    2.9: 1.16,
    3.0: 1.20,
    3.1: 1.24,
    3.2: 1.28,
    3.3: 1.32,
    3.4: 1.36,
    3.5: 1.40,
    3.6: 1.44,
    3.7: 1.48,
    3.8: 1.52,
    3.9: 1.56,
    4.0: 1.60,
  };

  // Yoğunluk değerine göre faktör döndür
  static double getFactor(double density) {
    // Tam eşleşme varsa onu döndür
    if (_densityMap.containsKey(density)) {
      return _densityMap[density]!;
    }

    // Interpolasyon yap
    List<double> keys = _densityMap.keys.toList()..sort();

    // En düşük değerden küçükse
    if (density < keys.first) {
      return _densityMap[keys.first]!;
    }

    // En yüksek değerden büyükse
    if (density > keys.last) {
      return _densityMap[keys.last]!;
    }

    // Ara değer için interpolasyon
    for (int i = 0; i < keys.length - 1; i++) {
      double lower = keys[i];
      double upper = keys[i + 1];

      if (density >= lower && density <= upper) {
        double lowerFactor = _densityMap[lower]!;
        double upperFactor = _densityMap[upper]!;

        // Linear interpolasyon
        double ratio = (density - lower) / (upper - lower);
        return lowerFactor + (upperFactor - lowerFactor) * ratio;
      }
    }

    return 1.0; // Varsayılan değer
  }

  // Tüm yoğunluk değerlerini listele
  static List<double> getAllDensities() {
    return _densityMap.keys.toList()..sort();
  }

  // Belirli bir yoğunluk değerinin geçerli olup olmadığını kontrol et
  static bool isValidDensity(double density) {
    return density >= 1.0 && density <= 4.0;
  }
}

// R faktör hesaplama fonksiyonları
class RFactorCalculations {
  // R faktör hesaplama fonksiyonu - temiz ve basit
  static double getRFactor({
    required RadioactiveSource source,
    required FilmType filmType,
    required double targetDensity,
  }) {
    // KODAK filmleri için artık sabit faktör kullanıyoruz
    return 0.0; // R-factor ihtiyacımız yok, sadece film faktörünü kullanacağız
  }

  // KODAK film türü kontrolü
  static bool isKodakFilm(FilmType filmType) {
    return [
      FilmType.kodakM100,
      FilmType.kodakMX125,
      FilmType.kodakT200,
      FilmType.kodakAA400,
      FilmType.kodakSH800,
    ].contains(filmType);
  }

  // R faktör çarpanını hesapla
  static double calculateRFactorMultiplier(
    RadioactiveSource source,
    FilmType filmType,
    double density,
  ) {
    // Artık R-factor kullanmıyoruz, direkt film faktörünü kullanacağız
    return 1.0;
  }

  // Gelişmiş R faktör tahmini (kullanılmıyor)
  static double estimateAdvancedRFactor({
    required RadioactiveSource source,
    required FilmType filmType,
    required double targetDensity,
  }) {
    return 0.0;
  }
}

// Penetrametre hesaplamaları
class PenetrametreCalculations {
  // Delik çapı hesaplama
  static double calculateHoleDiameter(double thickness) {
    if (thickness <= 6) {
      return 0.5;
    } else if (thickness <= 10) {
      return 0.7;
    } else if (thickness <= 15) {
      return 1.0;
    } else if (thickness <= 25) {
      return 1.5;
    } else if (thickness <= 40) {
      return 2.0;
    } else if (thickness <= 60) {
      return 2.5;
    } else if (thickness <= 100) {
      return 3.5;
    } else if (thickness <= 150) {
      return 5.0;
    } else {
      return 7.0;
    }
  }

  // Tel çapı hesaplama
  static double calculateWireDiameter(double thickness) {
    if (thickness <= 6) {
      return 0.1;
    } else if (thickness <= 10) {
      return 0.13;
    } else if (thickness <= 15) {
      return 0.16;
    } else if (thickness <= 25) {
      return 0.2;
    } else if (thickness <= 40) {
      return 0.25;
    } else if (thickness <= 60) {
      return 0.32;
    } else if (thickness <= 100) {
      return 0.4;
    } else if (thickness <= 150) {
      return 0.5;
    } else {
      return 0.63;
    }
  }

  // Penetrametre kalınlığı hesaplama (malzeme kalınlığının %2'si)
  static double calculatePenetrametreThickness(double materialThickness) {
    return materialThickness * 0.02;
  }
}

// Hesaplama sonuçları modeli
class CalculationResult {
  CalculationResult({
    required this.exposureTime,
    required this.decayedActivity,
    required this.decayFactor,
    required this.filmFactor,
    required this.densityFactor,
    required this.thicknessFactor,
    required this.distanceFactor,
    required this.totalCorrection,
    required this.calculationDate,
    required this.inputParameters,
  });

  // JSON'dan nesne oluşturma
  factory CalculationResult.fromJson(Map<String, dynamic> json) {
    return CalculationResult(
      exposureTime: json['exposureTime']?.toDouble() ?? 0.0,
      decayedActivity: json['decayedActivity']?.toDouble() ?? 0.0,
      decayFactor: json['decayFactor']?.toDouble() ?? 0.0,
      filmFactor: json['filmFactor']?.toDouble() ?? 0.0,
      densityFactor: json['densityFactor']?.toDouble() ?? 0.0,
      thicknessFactor: json['thicknessFactor']?.toDouble() ?? 0.0,
      distanceFactor: json['distanceFactor']?.toDouble() ?? 0.0,
      totalCorrection: json['totalCorrection']?.toDouble() ?? 0.0,
      calculationDate: DateTime.parse(json['calculationDate']),
      inputParameters: json['inputParameters'] ?? {},
    );
  }
  final double exposureTime;
  final double decayedActivity;
  final double decayFactor;
  final double filmFactor;
  final double densityFactor;
  final double thicknessFactor;
  final double distanceFactor;
  final double totalCorrection;
  final DateTime calculationDate;
  final Map<String, dynamic> inputParameters;

  // JSON serileştirme
  Map<String, dynamic> toJson() {
    return {
      'exposureTime': exposureTime,
      'decayedActivity': decayedActivity,
      'decayFactor': decayFactor,
      'filmFactor': filmFactor,
      'densityFactor': densityFactor,
      'thicknessFactor': thicknessFactor,
      'distanceFactor': distanceFactor,
      'totalCorrection': totalCorrection,
      'calculationDate': calculationDate.toIso8601String(),
      'inputParameters': inputParameters,
    };
  }
}

// Geometrik unsharpness sonucu
class GeometricUnsharpnessResult {
  GeometricUnsharpnessResult({
    required this.unsharpness,
    required this.totalDistance,
    required this.magnification,
  });
  final double unsharpness;
  final double totalDistance;
  final double magnification;
}

// Decay hesaplama sonucu
class DecayResult {
  DecayResult({
    required this.currentActivity,
    required this.decayFactor,
    required this.daysPassed,
    required this.percentRemaining,
  });
  final double currentActivity;
  final double decayFactor;
  final double daysPassed;
  final double percentRemaining;
}

// Güvenlik bariyeri sonucu
class SafetyBarrierResult {
  // Kolimatör durumu

  SafetyBarrierResult({
    required this.safetyDistance,
    required this.targetDoseRate,
    required this.activity,
    required this.gammaConstant,
    required this.distance5mR,
    required this.distance2mR,
    required this.distance100mR,
    required this.unit,
    required this.calculatedAt,
    required this.isCollimated,
  });
  final double safetyDistance;
  final double targetDoseRate;
  final double activity;
  final double gammaConstant;
  final double distance5mR; // 0.5 mSv için mesafe
  final double distance2mR; // 2.5 mSv için mesafe
  final double distance100mR; // 7.5 mSv için mesafe
  final String unit; // Mesafe birimi (m veya ft)
  final DateTime calculatedAt; // Hesaplama zamanı
  final bool isCollimated;
}

// RHM (Roentgen per Hour at 1 Meter) değerleri
class RHMValues {
  // İridyum (Ir-192) için RHM değerleri (kalınlığa göre)
  static double getIridiumRHM(double thicknessMm) {
    if (thicknessMm <= 5) return 0.44;
    if (thicknessMm <= 10) return 0.45;
    if (thicknessMm <= 20) return 0.48;
    if (thicknessMm <= 30) return 0.51;
    if (thicknessMm <= 40) return 0.53;
    if (thicknessMm <= 60) return 0.60;
    if (thicknessMm <= 70) return 0.65;
    if (thicknessMm <= 80) return 0.72;
    return 0.80; // >80mm
  }

  // Selenyum (Se-75) için RHM değerleri (kalınlığa göre)
  static double getSeleniumRHM(double thicknessMm) {
    if (thicknessMm <= 5) return 0.215;
    if (thicknessMm <= 10) return 0.205;
    if (thicknessMm <= 15) return 0.192;
    if (thicknessMm <= 20) return 0.184;
    if (thicknessMm <= 25) return 0.170;
    if (thicknessMm <= 30) return 0.163;
    if (thicknessMm <= 35) return 0.155;
    if (thicknessMm <= 40) return 0.145;
    if (thicknessMm <= 50) return 0.130;
    return 0.120; // >50mm
  }

  // Kobalt (Co-60) için RHM değerleri (kalınlığa göre)
  static double getCobaltRHM(double thicknessMm) {
    if (thicknessMm <= 40) return 0.30;
    if (thicknessMm <= 80) return 0.33;
    if (thicknessMm <= 120) return 0.36;
    if (thicknessMm <= 200) return 0.40;
    return 0.44; // >200mm
  }

  // İterbiyum (Yb-169) için RHM değeri (sabit)
  static double getYtterbiumRHM(double thicknessMm) {
    return 0.125; // Sabit değer
  }

  // Kaynak türüne göre RHM değeri döndür
  static double getRHM(RadioactiveSource source, double thicknessMm) {
    double rhm;
    switch (source) {
      case RadioactiveSource.iridium192:
        rhm = getIridiumRHM(thicknessMm);
        break;
      case RadioactiveSource.selenium75:
        rhm = getSeleniumRHM(thicknessMm);
        break;
      case RadioactiveSource.cobalt60:
        rhm = getCobaltRHM(thicknessMm);
        break;
      case RadioactiveSource.ytterbium169:
        rhm = getYtterbiumRHM(thicknessMm);
        break;
    }

    // Debug için RHM seçimini logla
    print('RHM Seçimi: ${source.displayName} - ${thicknessMm}mm = $rhm');
    return rhm;
  }
}
