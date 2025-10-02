import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../providers/ndt_calculator_provider.dart';
import '../models/ndt_models.dart';
import '../widgets/custom_app_bar.dart';
import '../services/update_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Ayarlar',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppearanceSection(context),
              const SizedBox(height: 20),
              _buildCalculationSettingsSection(context),
              const SizedBox(height: 20),
              _buildAboutSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Görünüm',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                return SwitchListTile(
                  title: const Text('Koyu Tema'),
                  subtitle: const Text('Karanlık modu aktif et'),
                  value: appProvider.isDarkMode,
                  onChanged: (value) => appProvider.toggleTheme(),
                  secondary: Icon(
                    appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationSettingsSection(BuildContext context) {
    return Consumer<NDTCalculatorProvider>(
      builder: (context, ndtProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calculate,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Hesaplama Ayarları',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Metrik sistem seçimi geçici olarak gizlendi - varsayılan mm
                /*
                SwitchListTile(
                  title: const Text('Metrik Sistem'),
                  subtitle: Text(
                    ndtProvider.isMetricUnit
                        ? 'mm, metre kullanılıyor'
                        : 'inç, feet kullanılıyor',
                  ),
                  value: ndtProvider.isMetricUnit,
                  onChanged: (value) => ndtProvider.toggleUnit(),
                  secondary: Icon(
                    Icons.straighten,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const Divider(),
                */
                ListTile(
                  leading: Icon(
                    Icons.build,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: const Text('Varsayılan Malzeme'),
                  subtitle: Text(ndtProvider.selectedMaterial.displayName),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () =>
                      _showMaterialSelectionDialog(context, ndtProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Uygulama Hakkında',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.app_registration,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: const Text('NDT Toolbox'),
              subtitle: const Text(
                  'İlerde diğer NDT yöntemleri de eklenebilir diye  adını NDT Toolbox olarak kullandık.Bir hata ve Özellik bildiriminde bulunmak için lütfen iletişime geçin.'),
            ),

            const Divider(),
            ListTile(
              leading: Icon(
                Icons.help_outline,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: const Text('Kaliteciler.com'),
              subtitle: const Text('Türkiye\'nin Kalite Forumuna bekleriz.'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _openWebsite('https://kaliteciler.com'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: const Text('Geliştirici Bilgisi'),
              subtitle:
                  const Text('Muzaffer Şanlı tarafından geliştirilmiştir'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.system_update,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: const Text('Güncelleme Kontrolü'),
              subtitle: const Text('Yeni sürüm kontrolü yap'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => UpdateService.checkForUpdatesManual(context),
            ),
            const SizedBox(height: 8),
            // Geliştirici iletişim butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // LinkedIn Butonu
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWebsite(
                        'https://www.linkedin.com/in/muzaffersanli/'),
                    icon: const Icon(Icons.work, size: 16),
                    label:
                        const Text('LinkedIn', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Website Butonu
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWebsite('https://muzaffersanli.com'),
                    icon: const Icon(Icons.web, size: 16),
                    label:
                        const Text('Website', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mail Butonu
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openEmail('mail@muzaffersanli.com'),
                    icon: const Icon(Icons.email, size: 16),
                    label: const Text('E-mail', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // WhatsApp Butonu
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _openWebsite('https://wa.me/+905427347486'),
                    icon: const Icon(Icons.chat, size: 16),
                    label:
                        const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMaterialSelectionDialog(
      BuildContext context, NDTCalculatorProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Malzeme Seçin'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: NDTMaterial.values.length,
              itemBuilder: (context, index) {
                final material = NDTMaterial.values[index];
                return RadioListTile<NDTMaterial>(
                  title: Text(material.displayName),
                  subtitle: Text(
                    'HVL (${provider.selectedSource.displayName}): '
                    '${material.getHVL(provider.selectedSource).toStringAsFixed(1)} mm',
                  ),
                  value: material,
                  groupValue: provider.selectedMaterial,
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSelectedMaterial(value);
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  void _openWebsite(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      print('Attempting to launch URL: $url');

      // İlk önce canLaunchUrl kontrolü yap
      final bool canLaunch = await canLaunchUrl(uri);
      print('Can launch URL: $canLaunch');

      if (canLaunch) {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('URL launched successfully: $launched');

        if (!launched) {
          print('Failed to launch URL despite canLaunchUrl returning true');
          // Alternatif mode dene
          try {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          } catch (e) {
            print('Platform default launch failed: $e');
          }
        }
      } else {
        print('Cannot launch URL: $url - trying alternative methods');
        // Alternatif olarak platformDefault mode dene
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          print('Alternative launch failed: $e');
        }
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  void _openEmail(String email) async {
    try {
      final Uri uri = Uri.parse('mailto:$email');
      print('Attempting to launch email: $email');

      final bool canLaunch = await canLaunchUrl(uri);
      print('Can launch email: $canLaunch');

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch email: $email');
      }
    } catch (e) {
      print('Error launching email: $e');
    }
  }
}
