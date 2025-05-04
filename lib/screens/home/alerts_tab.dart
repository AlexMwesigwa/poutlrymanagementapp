import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apms/providers/farm_provider.dart';
import 'package:apms/models/alert_model.dart';
import 'package:intl/intl.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({Key? key}) : super(key: key);

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    await farmProvider.fetchAlerts(limit: 50);
  }

  List<AlertModel> _getFilteredAlerts(List<AlertModel> alerts) {
    if (_selectedFilter == 'All') {
      return alerts;
    } else {
      final alertType = _stringToAlertType(_selectedFilter);
      return alerts.where((alert) => alert.type == alertType).toList();
    }
  }

  AlertType _stringToAlertType(String type) {
    switch (type) {
      case 'Temperature':
        return AlertType.temperature;
      case 'Humidity':
        return AlertType.humidity;
      case 'Feed':
        return AlertType.feed;
      case 'Water':
        return AlertType.water;
      case 'Security':
        return AlertType.security;
      default:
        return AlertType.temperature;
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);
    final filteredAlerts = _getFilteredAlerts(farmProvider.alerts);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Filter by:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Temperature'),
                      _buildFilterChip('Humidity'),
                      _buildFilterChip('Feed'),
                      _buildFilterChip('Water'),
                      _buildFilterChip('Security'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAlerts,
            child:
                farmProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredAlerts.isEmpty
                    ? const Center(child: Text('No alerts found'))
                    : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredAlerts.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final alert = filteredAlerts[index];
                        return _buildAlertItem(alert);
                      },
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
      ),
    );
  }

  Widget _buildAlertItem(AlertModel alert) {
    return InkWell(
      onTap: () {
        if (!alert.isRead) {
          Provider.of<FarmProvider>(
            context,
            listen: false,
          ).markAlertAsRead(alert.id);
        }

        _showAlertDetailsDialog(alert);
      },
      child: Container(
        decoration: BoxDecoration(
          color: alert.isRead ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getAlertColor(alert.type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _getAlertIcon(alert.type),
                color: _getAlertColor(alert.type),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getAlertColor(alert.type).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getAlertTypeString(alert.type),
                          style: TextStyle(
                            color: _getAlertColor(alert.type),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(alert.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (!alert.isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert.message,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertDetailsDialog(AlertModel alert) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  _getAlertIcon(alert.type),
                  color: _getAlertColor(alert.type),
                ),
                const SizedBox(width: 8),
                Text(_getAlertTypeString(alert.type)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.message, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text(
                  'Time: ${DateFormat('MMM dd, yyyy - hh:mm a').format(alert.timestamp)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  _getAlertRecommendation(alert.type),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.temperature:
        return Icons.thermostat;
      case AlertType.humidity:
        return Icons.water_drop;
      case AlertType.feed:
        return Icons.restaurant;
      case AlertType.water:
        return Icons.local_drink;
      case AlertType.security:
        return Icons.security;
    }
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.temperature:
        return Colors.red;
      case AlertType.humidity:
        return Colors.blue;
      case AlertType.feed:
        return Colors.orange;
      case AlertType.water:
        return Colors.lightBlue;
      case AlertType.security:
        return Colors.purple;
    }
  }

  String _getAlertTypeString(AlertType type) {
    switch (type) {
      case AlertType.temperature:
        return 'Temperature';
      case AlertType.humidity:
        return 'Humidity';
      case AlertType.feed:
        return 'Feed';
      case AlertType.water:
        return 'Water';
      case AlertType.security:
        return 'Security';
    }
  }

  String _getAlertRecommendation(AlertType type) {
    switch (type) {
      case AlertType.temperature:
        return 'Recommendation: Adjust the temperature control system to maintain optimal temperature between 21-27°C.';
      case AlertType.humidity:
        return 'Recommendation: Adjust ventilation to maintain optimal humidity between 50-70%.';
      case AlertType.feed:
        return 'Recommendation: Refill the feed containers as soon as possible to ensure continuous feeding.';
      case AlertType.water:
        return 'Recommendation: Check water supply and refill water containers to prevent dehydration.';
      case AlertType.security:
        return 'Recommendation: Check the farm immediately and ensure all security measures are in place.';
    }
  }
}
