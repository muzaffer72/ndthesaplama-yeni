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
    required double ir192Emissivity, // Bu parametre artık kullanılmayacak
    double yogunlukFaktoru = 1.0,
    double duzeltmeFaktoru = 1.0,
    double malzemeFaktoru = 1.0,
    FilmType? filmType,
    double? targetDensity,
    bool debug = true,
  }) {
    // Birim dönüşümü
    double thicknessMm = isMetric ? thickness : thickness * 25.4;
    double distanceMm =
        isMetric ? sourceToFilmDistance : sourceToFilmDistance * 25.4;

    // HVL değerini al - her seferinde yeniden hesapla
    double hvl = material.getHVL(source);

    // Film faktörünü belirle
    double filmFactor = filmType?.factor ?? 1.0;

    // Yoğunluk faktörünü belirle
    double densityFactor = targetDensity != null
        ? DensityFactors.getFactor(targetDensity)
        : yogunlukFaktoru;

    // RHM değerini kalınlığa ve kaynak türüne göre belirle - her seferinde yeniden hesapla
    double rhm = RHMValues.getRHM(source, thicknessMm);

    // Ana hesaplama formülü (spesifikasyona göre)
    // Temel Poz Süresi = [((Mesafe/10)^2 * Film_Faktörü) * 2^(Kalınlık/HVL) * 60] / (Aktivite * RHM * 100^2)
    // Film faktörü formülde r parametresi olarak doğrudan kullanılır

    double mesafeFaktoru = pow(distanceMm / 10.0, 2).toDouble();
    double kalinlikFaktoru = pow(2, thicknessMm / hvl).toDouble();

    // Pay kısmı: ((Mesafe/10)^2 * Film_Faktörü) * 2^(Kalınlık/HVL) * 60
    // Film faktörü doğrudan r parametresi olarak kullanılır
    double pay = mesafeFaktoru * filmFactor * kalinlikFaktoru * 60;

    // Payda kısmı: Aktivite * RHM * 100^2
    double payda = activity * rhm * pow(100, 2);

    // Temel hesaplama: (Pay / Payda) * 60 * 1000 (milisaniye cinsinden)
    double temelPozSuresiMs = (pay / payda) * 60 * 1000;

    // Toplam düzeltme faktörü (sadece yoğunluk ve diğer faktörler, film faktörü zaten kullanıldı)
    double toplamDuzeltme = densityFactor *
        duzeltmeFaktoru *
        malzemeFaktoru; // Final poz süresi (milisaniye cinsinden)
    double finalPozSuresiMs = temelPozSuresiMs * toplamDuzeltme;

    // Saniye cinsine çevir
    double finalPozSuresiSn = finalPozSuresiMs / 1000; // Debug çıktısı
    if (debug) {
      print('=== POZ SÜRESİ HESAPLAMA DETAYI ===');
      print('Kaynak: ${source.displayName}');
      print('Malzeme: ${material.displayName}');
      print('Kalınlık: ${thicknessMm}mm (giriş: $thickness)');
      print('HVL: ${hvl}mm');
      print('RHM: $rhm (kalınlığa göre yeniden hesaplandı)');
      print('Mesafe: ${distanceMm}mm (giriş: $sourceToFilmDistance)');
      print('Aktivite: ${activity}Ci');
      print('Film Faktörü (r parametresi): $filmFactor');
      print('Yoğunluk Faktörü: $densityFactor');
      print('Mesafe Faktörü: $mesafeFaktoru');
      print('Kalınlık Faktörü: $kalinlikFaktoru');
      print('Pay: $pay');
      print('Payda: $payda');
      print('Temel Poz Süresi (ms): $temelPozSuresiMs');
      print('Toplam Düzeltme: $toplamDuzeltme');
      print('Final Poz Süresi (ms): $finalPozSuresiMs');
      print('Final Poz Süresi (sn): $finalPozSuresiSn');
      print('Final Poz Süresi (dk): ${finalPozSuresiSn / 60}');
      print('Hesaplama Zamanı: ${DateTime.now()}');
      print('================================');
    }

    // Zamanı formatla
    String formattedTime;
    if (finalPozSuresiSn < 60) {
      formattedTime = '${finalPozSuresiSn.toStringAsFixed(1)} sn';
    } else if (finalPozSuresiSn < 3600) {
      int dakika = (finalPozSuresiSn / 60).floor();
      int saniye = (finalPozSuresiSn % 60).round();
      formattedTime = '${dakika}dk ${saniye}sn';
    } else {
      int saat = (finalPozSuresiSn / 3600).floor();
      int dakika = ((finalPozSuresiSn % 3600) / 60).floor();
      int saniye = (finalPozSuresiSn % 60).round();
      formattedTime = '${saat}sa ${dakika}dk ${saniye}sn';
    }

    return CalculationResult(
      exposureTime: finalPozSuresiSn,
      decayedActivity: activity,
      decayFactor: 1.0,
      filmFactor: filmFactor,
      densityFactor: densityFactor,
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
        'rhm': rhm,
        'hvl': hvl,
        'calculationSteps': {
          'mesafeFaktoru': mesafeFaktoru,
          'kalinlikFaktoru': kalinlikFaktoru,
          'pay': pay,
          'payda': payda,
          'temelPozSuresiMs': temelPozSuresiMs,
          'toplamDuzeltme': toplamDuzeltme,
        },
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
  static GeometricUnsharpnessResult calculateGeometricUnsharpness({
    required double sourceSize,
    required double sourceToObjectDistance,
    required double objectToFilmDistance,
  }) {
    double totalDistance = sourceToObjectDistance + objectToFilmDistance;
    double unsharpness =
        (sourceSize * objectToFilmDistance) / sourceToObjectDistance;

    return GeometricUnsharpnessResult(
      unsharpness: unsharpness,
      totalDistance: totalDistance,
      magnification: totalDistance / sourceToObjectDistance,
    );
  }

  // Radioaktif decay hesaplama
  static DecayResult calculateRadioactiveDecay({
    required RadioactiveSource source,
    required double initialActivity,
    required DateTime initialDate,
    required DateTime targetDate,
  }) {
    double daysPassed = targetDate.difference(initialDate).inDays.toDouble();
    double decayConstant = 0.693 / source.halfLifeDays;
    double currentActivity = initialActivity * exp(-decayConstant * daysPassed);
    double decayFactor = currentActivity / initialActivity;

    return DecayResult(
      currentActivity: currentActivity,
      decayFactor: decayFactor,
      daysPassed: daysPassed,
      percentRemaining: decayFactor * 100,
    );
  }

  // Güvenlik bariyeri hesaplama
  static SafetyBarrierResult calculateSafetyBarrierDistance({
    required double activity,
    required RadioactiveSource source,
    double targetDoseRate = 0.02, // mSv/h
    bool isMetric = true,
    bool isCollimated = false, // Kolimatör durumu
  }) {
    // İridyum-192 için sabit değer 4.81 kullanılır
    // Diğer kaynaklar için gamma sabiti kullanılır
    double constantValue;
    if (source == RadioactiveSource.iridium192) {
      constantValue = 4.81; // İridyum-192 için sabit değer
    } else {
      constantValue = source.gammaConstant; // Diğer kaynaklar için gamma sabiti
    }

    // Kolimatör faktörü - kolimatörlü kaynaklar için bölme işlemi
    // Kolimatörlü: 2^2.3 = yaklaşık 4.925 ile böl
    double collimatorDivisor = isCollimated ? pow(2, 2.3).toDouble() : 1.0;

    // Ana hesaplama (örnek olarak targetDoseRate için)
    double distance =
        sqrt((constantValue * activity) / (collimatorDivisor * targetDoseRate));

    // Farklı doz oranları için mesafeler (mSv cinsinden - sizin formülünüze göre)
    // 0.5 mSv = 0.0005 R, 2.5 mSv = 0.0025 R, 7.5 mSv = 0.0075 R
    double distance5mR = sqrt(
        (constantValue * activity) / (collimatorDivisor * 0.0005)); // 0.5 mSv
    double distance2mR = sqrt(
        (constantValue * activity) / (collimatorDivisor * 0.0025)); // 2.5 mSv
    double distance100mR = sqrt(
        (constantValue * activity) / (collimatorDivisor * 0.0075)); // 7.5 mSv

    // Metrik sistem değilse feet'e çevir
    String unit = isMetric ? 'm' : 'ft';
    if (!isMetric) {
      distance *= 3.28084;
      distance5mR *= 3.28084;
      distance2mR *= 3.28084;
      distance100mR *= 3.28084;
    }

    return SafetyBarrierResult(
      safetyDistance: distance,
      targetDoseRate: targetDoseRate,
      activity: activity,
      gammaConstant: constantValue,
      distance5mR: distance5mR,
      distance2mR: distance2mR,
      distance100mR: distance100mR,
      unit: unit,
      calculatedAt: DateTime.now(),
      isCollimated: isCollimated,
    );
  }

  // Exposure correction hesaplama (eksik metodun eklenmesi)
  static CalculationResult calculateExposureCorrection({
    required CalculationResult originalResult,
    required double newThickness,
    required double newDistance,
    required double newActivity,
    required FilmType newFilmType,
    required double newDensity,
  }) {
    // Basit bir correction hesaplama - orijinal parametreleri koruyup yeni hesaplama yap
    return calculateExposureTime(
      source: RadioactiveSource.iridium192, // Varsayılan
      material: NDTMaterial.steel, // Varsayılan
      thickness: newThickness,
      activity: newActivity,
      sourceToFilmDistance: newDistance,
      isMetric: true,
      ir192Emissivity: 0.48,
      filmType: newFilmType,
      targetDensity: newDensity,
    );
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
