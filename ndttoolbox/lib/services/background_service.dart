import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'notification_service.dart';

// Arka plan hizmetini başlatmak ve yapılandırmak için kullanılır.
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Bildirim kanalını ve bildirim ayarlarını yapılandır.
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false, // Uygulama açıldığında otomatik başlama
      notificationChannelId: NotificationService.channelId,
      initialNotificationTitle: 'NDT Toolbox',
      initialNotificationContent: 'Arka plan hizmeti çalışıyor.',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false, // Uygulama açıldığında otomatik başlama
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

// iOS'ta arka plan işlemleri için özel bir metot.
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

// Arka plan hizmeti başladığında çalışacak ana metot.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Arka plan izolatı için eklentileri kaydet
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.initialize();

  // Arka plan hizmeti bir Android hizmeti olarak ayarlanır.
  // Platform kontrolü kaldırıldı - uyumluluk için
  /*
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  */

  // Zamanlayıcıyı yönetmek için değişkenler.
  Timer? timer;
  int? totalSeconds;
  DateTime? timerEndTime;

  // UI'dan gelen komutları dinle.
  service.on('startTimer').listen((data) async {
    if (data == null) return;

    final remaining = data['remaining_seconds'] as int?;
    totalSeconds = data['total_seconds'] as int?;

    if (remaining == null || totalSeconds == null) return;

    timerEndTime = DateTime.now().add(Duration(seconds: remaining));

    // Bildirimi hemen göster.
    await notificationService.showTimerNotification(
      remainingSeconds: remaining,
      title: 'NDT Toolbox Timer',
      body: 'Pozlama devam ediyor...',
    );

    // Her saniye çalışan zamanlayıcıyı başlat.
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timerEndTime == null) return;

      final now = DateTime.now();
      final remainingSeconds = timerEndTime!.difference(now).inSeconds;

      // UI'a kalan süreyi gönder.
      service.invoke('update', {'remaining_seconds': remainingSeconds});

      if (remainingSeconds > 0) {
        // Bildirimi güncelle.
        await notificationService.updateTimerNotification(
          remainingSeconds: remainingSeconds,
          totalSeconds: totalSeconds!,
          title: 'NDT Toolbox Timer',
        );
      } else {
        // Zamanlayıcı bittiğinde.
        await notificationService.hideTimerNotification();
        await notificationService.showWarningNotification(remainingSeconds: 0);
        timer.cancel();
        service.invoke('timerFinished');
      }
    });
  });

  service.on('pauseTimer').listen((event) {
    timer?.cancel();
    timer = null;
    timerEndTime = null;
  });

  service.on('stopTimer').listen((event) async {
    timer?.cancel();
    timer = null;
    timerEndTime = null;
    await notificationService.hideTimerNotification();
    service.invoke('update', {'remaining_seconds': 0});
  });

  service.on('stopService').listen((event) {
    timer?.cancel();
    service.stopSelf();
  });
}
