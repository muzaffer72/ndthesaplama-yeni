import 'dart:math';

// Basit test fonksiyonu
void testCalculation() {
  print('=== BASIT HESAPLAMA TEST ===');

  // Talimat örneği
  double thicknessMm = 20.0;
  double hvl = 12.7;
  double rhm = 0.48;
  double distanceMm = 700.0;
  double filmFactor = 2.8; // CARESTREAM T200
  double activity = 30.0;
  double densityFactor = 1.20; // 3.0 yoğunluk için

  // Manuel hesaplama
  double mesafeFaktoru = pow(distanceMm / 10.0, 2).toDouble();
  double kalinlikFaktoru = pow(2, thicknessMm / hvl).toDouble();
  double pay = mesafeFaktoru * filmFactor * kalinlikFaktoru * 60;
  double payda = activity * rhm * pow(100, 2);
  double temelPozSuresiMs = (pay / payda) * 60 * 1000;
  double finalPozSuresiMs = temelPozSuresiMs * densityFactor;
  double finalPozSuresiSn = finalPozSuresiMs / 1000;
  double finalPozSuresiDk = finalPozSuresiSn / 60;

  print('Kalınlık: ${thicknessMm}mm');
  print('HVL: ${hvl}mm');
  print('RHM: $rhm');
  print('Mesafe: ${distanceMm}mm');
  print('Film Faktörü (r): $filmFactor');
  print('Aktivite: ${activity}Ci');
  print('Yoğunluk Faktörü: $densityFactor');
  print('');
  print('Mesafe Faktörü: $mesafeFaktoru');
  print('Kalınlık Faktörü: $kalinlikFaktoru');
  print('Pay: $pay');
  print('Payda: $payda');
  print('Temel Poz Süresi (ms): $temelPozSuresiMs');
  print('Final Poz Süresi (ms): $finalPozSuresiMs');
  print('Final Poz Süresi (sn): $finalPozSuresiSn');
  print('Final Poz Süresi (dk): $finalPozSuresiDk');
  print('');

  // Talimat beklentisi (r=1.0, density factor yok): 6.08 dk
  // Bizim hesap (r=2.8, density factor=1.20): ?

  // Talimat benzeri hesap (r=1.0 ile)
  double talimatPay = mesafeFaktoru * 1.0 * kalinlikFaktoru * 60;
  double talimatTemelMs = (talimatPay / payda) * 60 * 1000;
  double talimatSn = talimatTemelMs / 1000;
  double talimatDk = talimatSn / 60;

  print('--- TALİMAT BENZERİ (r=1.0) ---');
  print('Temel Poz Süresi (dk): $talimatDk');
  print('Beklenen: 6.08 dk');
  print('==============================');
}

void main() {
  testCalculation();
}
