import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apms/providers/farm_provider.dart';
import 'package:apms/widgets/monitoring_chart.dart';
import 'package:apms/widgets/monitoring_card.dart';

class MonitoringTab extends StatefulWidget {
  const MonitoringTab({Key? key}) : super(key: key);

  @override
  State<MonitoringTab> createState() => _MonitoringTabState();
}

class _MonitoringTabState extends State<MonitoringTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 7; // Default to 7 days

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadHistoricalData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoricalData() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    await farmProvider.fetchHistoricalData(days: _selectedPeriod);
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Temperature'),
            Tab(text: 'Humidity'),
            Tab(text: 'Feed'),
            Tab(text: 'Water'),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Time Period:'),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: _selectedPeriod,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 Day')),
                  DropdownMenuItem(value: 7, child: Text('7 Days')),
                  DropdownMenuItem(value: 30, child: Text('30 Days')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                  farmProvider.fetchHistoricalData(days: _selectedPeriod);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child:
              farmProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : farmProvider.historicalData.isEmpty
                  ? const Center(child: Text('No historical data available'))
                  : TabBarView(
                    controller: _tabController,
                    children: [
                      // Temperature Tab
                      _buildTemperatureTab(farmProvider),

                      // Humidity Tab
                      _buildHumidityTab(farmProvider),

                      // Feed Tab
                      _buildFeedTab(farmProvider),

                      // Water Tab
                      _buildWaterTab(farmProvider),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildTemperatureTab(FarmProvider farmProvider) {
    final data = farmProvider.historicalData;
    final currentData = farmProvider.currentData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentData != null)
            MonitoringCard(
              title: 'Current Temperature',
              value: '${currentData.temperature.toStringAsFixed(1)}°C',
              icon: Icons.thermostat,
              color: _getTemperatureColor(currentData.temperature),
              description: _getTemperatureDescription(currentData.temperature),
            ),
          const SizedBox(height: 24),
          const Text(
            'Temperature History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: MonitoringChart(
              data: data,
              dataKey: 'temperature',
              unit: '°C',
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Temperature Guidelines',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildGuidelineCard(
            title: 'Optimal Temperature',
            content:
                'For broilers, the optimal temperature range is 21-27°C for adult birds.',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          _buildGuidelineCard(
            title: 'Temperature Warning',
            content:
                'Temperatures below 20°C or above 30°C can stress the birds and affect productivity.',
            icon: Icons.warning,
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          _buildGuidelineCard(
            title: 'Temperature Danger',
            content:
                'Temperatures below 15°C or above 35°C can be dangerous and lead to increased mortality.',
            icon: Icons.dangerous,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityTab(FarmProvider farmProvider) {
    final data = farmProvider.historicalData;
    final currentData = farmProvider.currentData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentData != null)
            MonitoringCard(
              title: 'Current Humidity',
              value: '${currentData.humidity.toStringAsFixed(1)}%',
              icon: Icons.water_drop,
              color: _getHumidityColor(currentData.humidity),
              description: _getHumidityDescription(currentData.humidity),
            ),
          const SizedBox(height: 24),
          const Text(
            'Humidity History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: MonitoringChart(
              data: data,
              dataKey: 'humidity',
              unit: '%',
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Humidity Guidelines',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildGuidelineCard(
            title: 'Optimal Humidity',
            content: 'For broilers, the optimal humidity range is 50-70%.',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          _buildGuidelineCard(
            title: 'Humidity Warning',
            content:
                'Humidity below 40% can lead to respiratory issues. Humidity above 80% can lead to wet litter and foot problems.',
            icon: Icons.warning,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedTab(FarmProvider farmProvider) {
    final data = farmProvider.historicalData;
    final currentData = farmProvider.currentData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentData != null)
            MonitoringCard(
              title: 'Current Feed Level',
              value: '${currentData.feedLevel.toStringAsFixed(1)}%',
              icon: Icons.restaurant,
              color: _getFeedLevelColor(currentData.feedLevel),
              description: _getFeedLevelDescription(currentData.feedLevel),
            ),
          const SizedBox(height: 24),
          const Text(
            'Feed Level History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: MonitoringChart(
              data: data,
              dataKey: 'feedLevel',
              unit: '%',
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Feed Guidelines',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildGuidelineCard(
            title: 'Feed Monitoring',
            content:
                'Regular monitoring of feed levels ensures birds have constant access to feed.',
            icon: Icons.info,
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildGuidelineCard(
            title: 'Low Feed Warning',
            content:
                'Feed levels below 20% require immediate refilling to prevent feed shortages.',
            icon: Icons.warning,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTab(FarmProvider farmProvider) {
    final data = farmProvider.historicalData;
    final currentData = farmProvider.currentData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentData != null)
            MonitoringCard(
              title: 'Current Water Level',
              value: '${currentData.waterLevel.toStringAsFixed(1)}%',
              icon: Icons.local_drink,
              color: _getWaterLevelColor(currentData.waterLevel),
              description: _getWaterLevelDescription(currentData.waterLevel),
            ),
          const SizedBox(height: 24),
          const Text(
            'Water Level History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: MonitoringChart(
              data: data,
              dataKey: 'waterLevel',
              unit: '%',
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Water Guidelines',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildGuidelineCard(
            title: 'Water Monitoring',
            content:
                'Regular monitoring of water levels ensures birds have constant access to clean water.',
            icon: Icons.info,
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildGuidelineCard(
            title: 'Low Water Warning',
            content:
                'Water levels below 20% require immediate refilling to prevent dehydration.',
            icon: Icons.warning,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(content),
                ],
              ),
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

  String _getTemperatureDescription(double temperature) {
    if (temperature < 20) {
      return 'Too cold for optimal growth';
    } else if (temperature > 30) {
      return 'Too hot, may cause heat stress';
    } else {
      return 'Optimal temperature range';
    }
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 40) {
      return Colors.orange;
    } else if (humidity > 80) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getHumidityDescription(double humidity) {
    if (humidity < 40) {
      return 'Too dry, may cause respiratory issues';
    } else if (humidity > 80) {
      return 'Too humid, may cause wet litter';
    } else {
      return 'Optimal humidity range';
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

  String _getFeedLevelDescription(double level) {
    if (level < 20) {
      return 'Critical: Feed needs immediate refill';
    } else if (level < 50) {
      return 'Warning: Feed level is getting low';
    } else {
      return 'Good: Feed level is adequate';
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

  String _getWaterLevelDescription(double level) {
    if (level < 20) {
      return 'Critical: Water needs immediate refill';
    } else if (level < 50) {
      return 'Warning: Water level is getting low';
    } else {
      return 'Good: Water level is adequate';
    }
  }
}
