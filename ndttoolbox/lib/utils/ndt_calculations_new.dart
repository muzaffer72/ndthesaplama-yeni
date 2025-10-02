import 'dart:math';
import '../models/ndt_models.dart';

class NDTCalculations {
  // Pozlama süresi hesaplama
  static CalculationResult calculateExposureTime({
    required RadioactiveSource source,
    required NDTMaterial material,
    required double thickness,
    required double activity,
    required double sourceToFilmDistance,
    required bool isMetric,
    required double ir192Emissivity,
    double rFactor = 1.0,
    double yogunlukFaktoru = 1.0,
    double duzeltmeFaktoru = 1.0,
    double malzemeFaktoru = 1.0,
    FilmType? filmType,
    double? targetDensity,
    bool debug = false,
  }) {
    // Birim dönüşümü
    double thicknessMm = isMetric ? thickness : thickness * 25.4;
    double distanceMm =
        isMetric ? sourceToFilmDistance : sourceToFilmDistance * 25.4;

    // HVL değerini al
    double hvl = material.getHVL(source);

    // Film faktörünü belirle
    double filmFactor = filmType?.factor ?? 1.0;

    // Yoğunluk faktörünü belirle
    double densityFactor = targetDensity != null
        ? DensityFactors.getFactor(targetDensity)
        : yogunlukFaktoru;

    // Ana hesaplama formülü
    double mesafeFaktoru = pow(distanceMm / 10.0, 2).toDouble();
    double kalinlikFaktoru = pow(2, thicknessMm / hvl).toDouble();
    double pay = mesafeFaktoru * rFactor * kalinlikFaktoru * 60;
    double payda = activity * ir192Emissivity * pow(100, 2);
    double temelPozSuresi = pay / payda;
    double dakikaCinsiPozSuresi = temelPozSuresi * 60;
    double saniyeCinsiPozSuresi = dakikaCinsiPozSuresi * 60;

    // Toplam düzeltme faktörü
    double toplamDuzeltme =
        filmFactor * densityFactor * duzeltmeFaktoru * malzemeFaktoru;
    double finalPozSuresi = saniyeCinsiPozSuresi * toplamDuzeltme;

    // Zamanı formatla
    String formattedTime;
    if (finalPozSuresi < 60) {
      formattedTime = '${finalPozSuresi.toStringAsFixed(1)} sn';
    } else if (finalPozSuresi < 3600) {
      int dakika = (finalPozSuresi / 60).floor();
      int saniye = (finalPozSuresi % 60).round();
      formattedTime = '${dakika}dk ${saniye}sn';
    } else {
      int saat = (finalPozSuresi / 3600).floor();
      int dakika = ((finalPozSuresi % 3600) / 60).floor();
      int saniye = (finalPozSuresi % 60).round();
      formattedTime = '${saat}sa ${dakika}dk ${saniye}sn';
    }

    return CalculationResult(
      exposureTime: finalPozSuresi,
      decayedActivity: activity,
      decayFactor: 1.0,
      filmFactor: filmFactor,
      densityFactor: densityFactor,
      rFactor: rFactor,
      thicknessFactor: kalinlikFaktoru,
      distanceFactor: mesafeFaktoru,
      totalCorrection: toplamDuzeltme,
      calculationDate: DateTime.now(),
      inputParameters: {
        'source': source.displayName,
        'material': material.displayName,
        'thickness': thickness,
        'activity': activity,
        'distance': sourceToFilmDistance,
        'filmType': filmType?.displayName ?? 'Bilinmiyor',
        'targetDensity': targetDensity ?? 'Manuel',
        'formattedTime': formattedTime,
      },
    );
  }

  // Basit string format fonksiyonu
  static String formatExposureTime(double seconds) {
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(1)} sn';
    } else if (seconds < 3600) {
      int dakika = (seconds / 60).floor();
      int saniye = (seconds % 60).round();
      return '${dakika}dk ${saniye}sn';
    } else {
      int saat = (seconds / 3600).floor();
      int dakika = ((seconds % 3600) / 60).floor();
      int saniye = (seconds % 60).round();
      return '${saat}sa ${dakika}dk ${saniye}sn';
    }
  }

  // Geometrik unsharpness hesaplama
  static Map<String, dynamic> calculateGeometricUnsharpness({
    required double sourceSize,
    required double sourceToObjectDistance,
    required double objectToFilmDistance,
  }) {
    double totalDistance = sourceToObjectDistance + objectToFilmDistance;
    double unsharpness =
        (sourceSize * objectToFilmDistance) / sourceToObjectDistance;

    return {
      'unsharpness': unsharpness,
      'totalDistance': totalDistance,
      'magnification': totalDistance / sourceToObjectDistance,
    };
  }

  // Radioaktif decay hesaplama
  static Map<String, dynamic> calculateRadioactiveDecay({
    required RadioactiveSource source,
    required double initialActivity,
    required DateTime initialDate,
    required DateTime targetDate,
  }) {
    double daysPassed = targetDate.difference(initialDate).inDays.toDouble();
    double decayConstant = 0.693 / source.halfLifeDays;
    double currentActivity = initialActivity * exp(-decayConstant * daysPassed);
    double decayFactor = currentActivity / initialActivity;

    return {
      'currentActivity': currentActivity,
      'decayFactor': decayFactor,
      'daysPassed': daysPassed,
      'percentRemaining': decayFactor * 100,
    };
  }

  // Güvenlik bariyeri hesaplama
  static Map<String, dynamic> calculateSafetyBarrierDistance({
    required double activity,
    required RadioactiveSource source,
    double targetDoseRate = 0.02, // mSv/h
  }) {
    double gammaConstant = source.gammaConstant;
    double distance = sqrt((activity * gammaConstant) / targetDoseRate);

    return {
      'safetyDistance': distance,
      'targetDoseRate': targetDoseRate,
      'activity': activity,
      'gammaConstant': gammaConstant,
    };
  }
}

// Eski CalculationResult class'ından kalan referanslar için basit bir wrapper
class ExposureCalculationResult {

  ExposureCalculationResult({
    required this.exposureTimeSeconds,
    required this.exposureTimeMinutes,
    required this.formattedTime,
    required this.effectiveThickness,
    required this.unit,
    required this.calculatedAt,
  });
  final double exposureTimeSeconds;
  final double exposureTimeMinutes;
  final String formattedTime;
  final double effectiveThickness;
  final String unit;
  final DateTime calculatedAt;
}
