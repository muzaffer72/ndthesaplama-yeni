import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ndt_calculator_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/calculator_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'NDT Radyografi Hesaplayıcı'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context),
            const SizedBox(height: 24),
            _buildCalculatorsSection(context),
            const SizedBox(height: 24),
            _buildQuickInfoSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/settings'),
        child: const Icon(Icons.settings),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.radio_button_checked,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NDT Radyografi Hesaplayıcı',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tahribatsız Muayene Teknikleri',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ir-192, Se-75 ve Co-60 kaynakları için pozlama süresi, geometrik bulanıklık ve güvenlik hesaplamalarınızı hızlı ve doğru şekilde yapın.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Consumer<NDTCalculatorProvider>(
              builder: (context, ndtProvider, child) {
                return Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Birim: ${ndtProvider.isMetricUnit ? "Metrik (mm)" : "İnç"}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.source,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ndtProvider.selectedSource.displayName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hesaplama Araçları',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            CalculatorCard(
              icon: Icons.timer,
              title: 'Pozlama Süresi',
              description: 'Süre hesaplama',
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/exposure'),
            ),
            CalculatorCard(
              icon: Icons.blur_on,
              title: 'Geometrik Bulanıklık',
              description: 'Bulanıklık hesaplama',
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/geometric'),
            ),
            CalculatorCard(
              icon: Icons.tune,
              title: 'Pozlama Düzeltme',
              description: 'Mesafe düzeltmesi',
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(context, '/correction'),
            ),
            CalculatorCard(
              icon: Icons.trending_down,
              title: 'Radyoaktif Bozunma',
              description: 'Aktivite hesaplama',
              color: Colors.red,
              onTap: () => Navigator.pushNamed(context, '/decay'),
            ),
            CalculatorCard(
              icon: Icons.security,
              title: 'Güvenlik Mesafesi',
              description: '5mR barikat hesabı',
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/safety'),
            ),
            CalculatorCard(
              icon: Icons.settings,
              title: 'Ayarlar',
              description: 'Kaynak ve birim',
              color: Colors.grey,
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInfoSection(BuildContext context) {
    return Consumer<NDTCalculatorProvider>(
      builder: (context, ndtProvider, child) {
        final lastResult = ndtProvider.lastExposureResult;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Son Hesaplama',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (lastResult != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pozlama Süresi:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        lastResult.formattedTime,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Malzeme Kalınlığı satırı kaldırıldı
                ] else ...[
                  Text(
                    'Henüz hesaplama yapılmadı. Yukarıdaki araçları kullanarak hesaplamalarınızı başlatın.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
