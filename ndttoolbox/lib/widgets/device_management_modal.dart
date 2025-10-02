import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/device_model.dart';
import '../models/ndt_models.dart';
import '../providers/device_provider.dart';
import '../services/analytics_service.dart';

class DeviceManagementModal extends StatefulWidget {
  const DeviceManagementModal({super.key});

  @override
  State<DeviceManagementModal> createState() => _DeviceManagementModalState();
}

class _DeviceManagementModalState extends State<DeviceManagementModal> {
  bool _showAddForm = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ciController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  RadioactiveSource _selectedSource = RadioactiveSource.iridium192;

  // Güvenli setState fonksiyonu
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ciController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      _safeSetState(() => _selectedDate = picked);
    }
  }

  void _saveDevice() {
    if (!_formKey.currentState!.validate()) return;

    final newDevice = Device(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      fillDate: _selectedDate,
      initialCiValue: double.parse(_ciController.text),
      sourceType: _selectedSource,
    );

    Provider.of<DeviceProvider>(context, listen: false)
        .addDevice(newDevice)
        .then((_) {
      // Analytics tracking
      AnalyticsService.logDeviceAdded(
        deviceType: 'radiographic_source',
        deviceName: newDevice.name,
        sourceType: newDevice.sourceType.displayName,
        initialActivity: newDevice.initialCiValue,
      );

      _safeSetState(() {
        _showAddForm = false;
        _nameController.clear();
        _ciController.clear();
        _selectedDate = DateTime.now();
        _selectedSource = RadioactiveSource.iridium192;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cihaz başarıyla eklendi')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          minHeight: 200,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.device_hub, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Cihaz Yönetimi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Modal content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_showAddForm) ...[
                      _buildDeviceSelection(),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _safeSetState(() => _showAddForm = true),
                        icon: const Icon(Icons.add),
                        label: const Text('Yeni Cihaz Ekle'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ] else ...[
                      _buildAddDeviceForm(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSelection() {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, _) {
        if (deviceProvider.devices.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.device_hub_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz cihaz eklenmemiş',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk cihazınızı eklemek için aşağıdaki butonu kullanın',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktif Cihaz Seçin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hesaplamalarda kullanılacak cihazı seçin:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            ...deviceProvider.devices.map(
                (device) => _buildDeviceSelectionCard(device, deviceProvider)),
          ],
        );
      },
    );
  }

  Widget _buildDeviceSelectionCard(
      Device device, DeviceProvider deviceProvider) {
    final isSelected = deviceProvider.selectedDeviceId == device.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color:
          isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Radio<String>(
          value: device.id,
          groupValue: deviceProvider.selectedDeviceId,
          onChanged: (value) {
            if (value != null) {
              deviceProvider.setSelectedDevice(value);
              AnalyticsService.logFeatureUsed(
                featureName: 'device_selected',
                additionalParams: {
                  'device_name': device.name,
                  'source_type': device.sourceType.displayName,
                },
              );
            }
          },
        ),
        title: Text(
          device.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kaynak: ${device.sourceType.displayName}'),
            Text('Dolum: ${DateFormat('dd.MM.yyyy').format(device.fillDate)}'),
            Text(
              'Güncel: ${device.currentActivity.toStringAsFixed(4)} Ci', // 4 ondalık hassasiyet
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.green,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditDialog(context, device, deviceProvider),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _showDeleteDialog(context, device.id, device.name),
            ),
          ],
        ),
        onTap: () {
          deviceProvider.setSelectedDevice(device.id);
          AnalyticsService.logFeatureUsed(
            featureName: 'device_selected',
            additionalParams: {
              'device_name': device.name,
              'source_type': device.sourceType.displayName,
            },
          );
        },
      ),
    );
  }

  Widget _buildAddDeviceForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Yeni Cihaz Ekle',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _safeSetState(() => _showAddForm = false),
                    child: const Text('İptal'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Cihaz Adı',
                  prefixIcon: const Icon(Icons.device_hub),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Lütfen bir cihaz adı giriniz'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ciController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Başlangıç Aktivitesi (Ci)',
                  prefixIcon: const Icon(Icons.speed),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Lütfen bir değer giriniz';
                  if (double.tryParse(value!) == null) {
                    return 'Geçerli bir sayı giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Dolum Tarihi'),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RadioactiveSource>(
                value: _selectedSource,
                decoration: const InputDecoration(
                  labelText: 'Kaynak Tipi',
                  border: OutlineInputBorder(),
                ),
                items: RadioactiveSource.values.map((source) {
                  return DropdownMenuItem(
                    value: source,
                    child: Text(source.displayName),
                  );
                }).toList(),
                onChanged: (source) {
                  if (source != null) {
                    _safeSetState(() => _selectedSource = source);
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveDevice,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Cihazı Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, Device device, DeviceProvider deviceProvider) {
    final editNameController = TextEditingController(text: device.name);
    final editCiController =
        TextEditingController(text: device.initialCiValue.toString());
    DateTime editSelectedDate = device.fillDate;
    RadioactiveSource editSelectedSource = device.sourceType;
    final editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cihaz Düzenle'),
          content: SingleChildScrollView(
            child: Form(
              key: editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: editNameController,
                    decoration: const InputDecoration(
                      labelText: 'Cihaz Adı',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Cihaz adı gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RadioactiveSource>(
                    value: editSelectedSource,
                    decoration: const InputDecoration(
                      labelText: 'Kaynak Türü',
                      border: OutlineInputBorder(),
                    ),
                    items: RadioactiveSource.values
                        .map((source) => DropdownMenuItem(
                              value: source,
                              child: Text(source.displayName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null && mounted) {
                        setState(() => editSelectedSource = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: editCiController,
                    decoration: const InputDecoration(
                      labelText: 'Aktivite (Ci)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Aktivite gerekli';
                      if (double.tryParse(value!) == null) {
                        return 'Geçerli bir sayı girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: editSelectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null &&
                          picked != editSelectedDate &&
                          mounted) {
                        setState(() => editSelectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dolum Tarihi: ${DateFormat('dd.MM.yyyy').format(editSelectedDate)}',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                editNameController.dispose();
                editCiController.dispose();
                Navigator.of(ctx).pop();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editFormKey.currentState!.validate()) {
                  try {
                    final updatedDevice = Device(
                      id: device.id,
                      name: editNameController.text,
                      fillDate: editSelectedDate,
                      initialCiValue: double.parse(editCiController.text),
                      sourceType: editSelectedSource,
                    );

                    // Navigator'ı önce kapat
                    Navigator.of(ctx).pop();

                    // Cleanup controllers
                    editNameController.dispose();
                    editCiController.dispose();

                    // Provider güncellemesini dialog kapatıldıktan sonra yap
                    await deviceProvider.updateDevice(updatedDevice);

                    // Mounted kontrolü ile güvenli SnackBar gösterimi
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cihaz başarıyla güncellendi')),
                      );
                    }

                    // Analytics tracking
                    AnalyticsService.logFeatureUsed(
                      featureName: 'device_updated',
                      additionalParams: {
                        'device_name': updatedDevice.name,
                        'source_type': updatedDevice.sourceType.displayName,
                      },
                    );
                  } catch (e) {
                    // Hata durumunda cleanup
                    editNameController.dispose();
                    editCiController.dispose();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hata: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, String deviceId, String deviceName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cihazı Sil'),
        content:
            Text('"$deviceName" cihazını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Navigator'ı önce kapat
                Navigator.of(ctx).pop();

                // Cihazı sil
                await Provider.of<DeviceProvider>(context, listen: false)
                    .removeDevice(deviceId);

                // Mounted kontrolü ile güvenli SnackBar gösterimi
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"$deviceName" cihazı silindi')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Silme hatası: $e')),
                  );
                }
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the modal
void showDeviceManagementModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: const DeviceManagementModal(),
      ),
    ),
  );
}
