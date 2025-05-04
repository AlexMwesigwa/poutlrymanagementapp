import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apms/providers/auth_provider.dart';
import 'package:apms/providers/farm_provider.dart';
import 'package:apms/widgets/custom_button.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  // Temperature threshold
  final _minTempController = TextEditingController(text: '20');
  final _maxTempController = TextEditingController(text: '30');

  // Humidity threshold
  final _minHumidityController = TextEditingController(text: '50');
  final _maxHumidityController = TextEditingController(text: '70');

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void dispose() {
    _minTempController.dispose();
    _maxTempController.dispose();
    _minHumidityController.dispose();
    _maxHumidityController.dispose();
    super.dispose();
  }

  Future<void> _saveTemperatureThresholds() async {
    try {
      final min = double.parse(_minTempController.text);
      final max = double.parse(_maxTempController.text);

      if (min >= max) {
        _showErrorSnackBar(
          'Minimum temperature must be less than maximum temperature',
        );
        return;
      }

      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      await farmProvider.updateTemperatureThreshold(min, max);

      if (!mounted) return;
      _showSuccessSnackBar('Temperature thresholds updated successfully');
    } catch (e) {
      _showErrorSnackBar('Invalid temperature values');
    }
  }

  Future<void> _saveHumidityThresholds() async {
    try {
      final min = double.parse(_minHumidityController.text);
      final max = double.parse(_maxHumidityController.text);

      if (min >= max) {
        _showErrorSnackBar(
          'Minimum humidity must be less than maximum humidity',
        );
        return;
      }

      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      await farmProvider.updateHumidityThreshold(min, max);

      if (!mounted) return;
      _showSuccessSnackBar('Humidity thresholds updated successfully');
    } catch (e) {
      _showErrorSnackBar('Invalid humidity values');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user?.role.toUpperCase() ?? 'WORKER',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Thresholds Section
          const Text(
            'Alert Thresholds',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Temperature Thresholds
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temperature Thresholds',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minTempController,
                          decoration: const InputDecoration(
                            labelText: 'Minimum (°C)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxTempController,
                          decoration: const InputDecoration(
                            labelText: 'Maximum (°C)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Save Temperature Thresholds',
                    onPressed: _saveTemperatureThresholds,
                    icon: Icons.save,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Humidity Thresholds
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Humidity Thresholds',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minHumidityController,
                          decoration: const InputDecoration(
                            labelText: 'Minimum (%)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxHumidityController,
                          decoration: const InputDecoration(
                            labelText: 'Maximum (%)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Save Humidity Thresholds',
                    onPressed: _saveHumidityThresholds,
                    icon: Icons.save,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text(
                      'Receive alerts about farm conditions',
                    ),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Temperature Alerts'),
                    value: _notificationsEnabled,
                    onChanged:
                        _notificationsEnabled
                            ? (value) {
                              // This is controlled by the main notification switch
                            }
                            : null,
                  ),
                  SwitchListTile(
                    title: const Text('Humidity Alerts'),
                    value: _notificationsEnabled,
                    onChanged:
                        _notificationsEnabled
                            ? (value) {
                              // This is controlled by the main notification switch
                            }
                            : null,
                  ),
                  SwitchListTile(
                    title: const Text('Feed Level Alerts'),
                    value: _notificationsEnabled,
                    onChanged:
                        _notificationsEnabled
                            ? (value) {
                              // This is controlled by the main notification switch
                            }
                            : null,
                  ),
                  SwitchListTile(
                    title: const Text('Water Level Alerts'),
                    value: _notificationsEnabled,
                    onChanged:
                        _notificationsEnabled
                            ? (value) {
                              // This is controlled by the main notification switch
                            }
                            : null,
                  ),
                  SwitchListTile(
                    title: const Text('Security Alerts'),
                    value: _notificationsEnabled,
                    onChanged:
                        _notificationsEnabled
                            ? (value) {
                              // This is controlled by the main notification switch
                            }
                            : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App Settings Section
          const Text(
            'App Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                      // TODO: Implement theme switching
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Language'),
                    subtitle: const Text('English'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implement language selection
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('About'),
                    subtitle: const Text('Version 1.0.0'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Show about dialog
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          CustomButton(
            text: 'Logout',
            onPressed: () {
              authProvider.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            backgroundColor: Colors.red,
            icon: Icons.logout,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
