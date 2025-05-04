import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apms/providers/farm_provider.dart';
import 'package:apms/widgets/dashboard_card.dart';
import 'package:apms/widgets/recent_alerts_card.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);
    final currentData = farmProvider.currentData;

    return RefreshIndicator(
      onRefresh: () async {
        await farmProvider.fetchCurrentData();
        await farmProvider.fetchAlerts();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Biyizika Poultry Farm',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor your poultry farm in real-time',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (farmProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (currentData == null)
              const Center(
                child: Text('No data available. Pull down to refresh.'),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Farm Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DashboardCard(
                        title: 'Temperature',
                        value:
                            '${currentData.temperature.toStringAsFixed(1)}°C',
                        icon: Icons.thermostat,
                        color: _getTemperatureColor(currentData.temperature),
                      ),
                      DashboardCard(
                        title: 'Humidity',
                        value: '${currentData.humidity.toStringAsFixed(1)}%',
                        icon: Icons.water_drop,
                        color: Colors.blue,
                      ),
                      DashboardCard(
                        title: 'Feed Level',
                        value: '${currentData.feedLevel.toStringAsFixed(1)}%',
                        icon: Icons.restaurant,
                        color: _getFeedLevelColor(currentData.feedLevel),
                      ),
                      DashboardCard(
                        title: 'Water Level',
                        value: '${currentData.waterLevel.toStringAsFixed(1)}%',
                        icon: Icons.local_drink,
                        color: _getWaterLevelColor(currentData.waterLevel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'Security Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              currentData.securityStatus
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          currentData.securityStatus ? 'Secure' : 'Alert',
                          style: TextStyle(
                            color:
                                currentData.securityStatus
                                    ? Colors.green
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  currentData.securityStatus
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              currentData.securityStatus
                                  ? Icons.security
                                  : Icons.security_update_warning,
                              color:
                                  currentData.securityStatus
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentData.securityStatus
                                      ? 'Farm is secure'
                                      : 'Security alert detected',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentData.securityStatus
                                      ? 'No security issues detected'
                                      : 'Check the farm immediately',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Alerts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  RecentAlertsCard(
                    alerts: farmProvider.alerts.take(3).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature < 20) {
      return Colors.blue;
    } else if (temperature > 30) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  Color _getFeedLevelColor(double level) {
    if (level < 20) {
      return Colors.red;
    } else if (level < 50) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Color _getWaterLevelColor(double level) {
    if (level < 20) {
      return Colors.red;
    } else if (level < 50) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
