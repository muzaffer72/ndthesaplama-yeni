import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  static const String _lastUpdateCheckKey = 'last_update_check';
  static const int _checkIntervalDays = 7; // Hafta da bir kontrol

  /// Uygulama başlangıcında güncelleme kontrolü
  static Future<void> checkForUpdatesOnStart(BuildContext context) async {
    try {
      // Sadece Android'de çalışır
      if (!defaultTargetPlatform.name.contains('android')) return;

      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getString(_lastUpdateCheckKey);
      final now = DateTime.now();

      bool shouldCheck = false;

      if (lastCheck == null) {
        // İlk kez kontrol ediliyor
        shouldCheck = true;
      } else {
        final lastCheckDate = DateTime.parse(lastCheck);
        final daysDifference = now.difference(lastCheckDate).inDays;

        if (daysDifference >= _checkIntervalDays) {
          shouldCheck = true;
        }
      }

      if (shouldCheck) {
        await _performUpdateCheck(context);
        await prefs.setString(_lastUpdateCheckKey, now.toIso8601String());
      }
    } catch (e) {
      debugPrint('Update check error: $e');
    }
  }

  /// Manuel güncelleme kontrolü
  static Future<void> checkForUpdatesManual(BuildContext context) async {
    try {
      if (!defaultTargetPlatform.name.contains('android')) {
        _showInfoDialog(
          context,
          'Güncelleme Kontrolü',
          'Uygulama içi güncelleme kontrolü bu cihazda desteklenmiyor.',
        );
        return;
      }

      // Loading dialog göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Güncelleme kontrol ediliyor...'),
            ],
          ),
        ),
      );

      final result = await _performUpdateCheck(context);
      Navigator.of(context).pop(); // Loading dialog'u kapat

      if (!result) {
        _showInfoDialog(
          context,
          'Güncelleme',
          'Uygulamanız güncel! Yeni güncelleme bulunmamaktadır.',
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Loading dialog'u kapat
      _showInfoDialog(
        context,
        'Hata',
        'Güncelleme kontrolü sırasında bir hata oluştu: $e',
      );
    }
  }

  /// Güncelleme kontrolü gerçekleştir
  static Future<bool> _performUpdateCheck(BuildContext context) async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Güncelleme mevcut
        if (updateInfo.immediateUpdateAllowed) {
          // Zorunlu güncelleme
          _showUpdateDialog(
            context,
            updateInfo,
            isFlexible: false,
          );
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Esnek güncelleme
          _showUpdateDialog(
            context,
            updateInfo,
            isFlexible: true,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update check failed: $e');
      return false;
    }
  }

  /// Güncelleme dialog'u göster
  static void _showUpdateDialog(BuildContext context, AppUpdateInfo updateInfo,
      {required bool isFlexible}) {
    showDialog(
      context: context,
      barrierDismissible: isFlexible,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.system_update,
              color: Colors.blue,
              size: 28,
            ),
            SizedBox(width: 8),
            Text('Güncelleme Mevcut'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NDT Toolbox uygulamasının yeni bir sürümü mevcut!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (updateInfo.availableVersionCode != null)
              Text(
                'Mevcut Sürüm: ${updateInfo.availableVersionCode}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              '• Yeni özellikler\n• Hata düzeltmeleri\n• Performans iyileştirmeleri',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (!isFlexible) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu güncelleme zorunludur.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (isFlexible)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Daha Sonra'),
            ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await _startUpdate(context, updateInfo, isFlexible);
            },
            icon: const Icon(Icons.download),
            label: Text(isFlexible ? 'Güncelle' : 'Şimdi Güncelle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Güncelleme başlat
  static Future<void> _startUpdate(
    BuildContext context,
    AppUpdateInfo updateInfo,
    bool isFlexible,
  ) async {
    try {
      if (isFlexible) {
        // Esnek güncelleme başlat
        await InAppUpdate.startFlexibleUpdate();

        // Güncelleme tamamlandığında bildir
        InAppUpdate.completeFlexibleUpdate().then((_) {
          _showInfoDialog(
            context,
            'Güncelleme Tamamlandı',
            'Uygulama başarıyla güncellendi!',
          );
        });
      } else {
        // Zorunlu güncelleme başlat
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      _showInfoDialog(
        context,
        'Güncelleme Hatası',
        'Güncelleme sırasında bir hata oluştu: $e',
      );
    }
  }

  /// Bilgi dialog'u göster
  static void _showInfoDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Son kontrol tarihini al
  static Future<String?> getLastUpdateCheckDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdateCheckKey);
  }

  /// Kontrol aralığını sıfırla (test için)
  static Future<void> resetUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastUpdateCheckKey);
  }
}
