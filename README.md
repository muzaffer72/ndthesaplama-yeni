# Flutter Template

Bu proje, Flutter uygulaması geliştirmek için hazırlanmış kapsamlı bir template'tir.

## Özellikler

- ✅ **Modern Material Design 3** - En güncel tasarım standartları
- ✅ **Provider State Management** - Etkili durum yönetimi
- ✅ **Açık/Koyu Tema Desteği** - Kullanıcı tercihi ile tema değiştirme
- ✅ **Özel Widget'lar** - Yeniden kullanılabilir UI bileşenleri
- ✅ **API Servisleri** - HTTP istekleri için hazır servis katmanı
- ✅ **Local Storage** - SharedPreferences ile veri saklama
- ✅ **Test Yapısı** - Widget ve unit testler için örnek yapı
- ✅ **Responsive Tasarım** - Farklı ekran boyutlarına uyumlu

## Proje Yapısı

```
lib/
├── main.dart                 # Ana uygulama giriş noktası
├── screens/                  # Uygulama ekranları
│   └── home_screen.dart     # Ana sayfa
├── widgets/                  # Özel widget'lar
│   ├── custom_app_bar.dart  # Özel AppBar
│   └── feature_card.dart    # Özellik kartı widget'ı
├── providers/                # State management
│   └── app_provider.dart    # Ana uygulama provider'ı
├── services/                 # API ve servis katmanları
│   └── api_service.dart     # HTTP API servisi
└── utils/                    # Yardımcı sınıflar
    ├── theme.dart           # Tema tanımlamaları
    └── constants.dart       # Sabit değerler
```

## Kurulum

1. Flutter SDK'nın yüklü olduğundan emin olun
2. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```

## Çalıştırma

### Android/iOS Emulator
```bash
flutter run
```

### Web
```bash
flutter run -d chrome
```

### Specific Device
```bash
flutter devices
flutter run -d [device-id]
```

## Test Etme

### Widget Testleri
```bash
flutter test
```

### Test Coverage
```bash
flutter test --coverage
```

## Özelleştirme

### Tema Değiştirme
`lib/utils/theme.dart` dosyasında renk paleti ve tema ayarlarını özelleştirebilirsiniz.

### Yeni Sayfa Ekleme
1. `lib/screens/` klasörüne yeni sayfa dosyası ekleyin
2. `lib/main.dart` dosyasında route tanımını ekleyin

### API Entegrasyonu
`lib/services/api_service.dart` dosyasında bulunan hazır HTTP servislerini kullanarak API entegrasyonu yapabilirsiniz.

## Kullanılan Paketler

- **provider**: State management
- **http**: API istekleri
- **shared_preferences**: Local data storage
- **cupertino_icons**: iOS style icons

## Platform Desteği

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## Lisans

Bu proje MIT lisansı altında sunulmaktadır.

## Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'i push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## Destek

Herhangi bir sorun yaşarsanız, [Issues](https://github.com/example/flutter-template/issues) bölümünden bildirebilirsiniz.# ndthesaplama-yeni
