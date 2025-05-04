import 'package:flutter/material.dart';
import 'package:apms/models/alert_model.dart';
import 'package:intl/intl.dart';

class RecentAlertsCard extends StatelessWidget {
  final List<AlertModel> alerts;
  final VoidCallback? onViewAll;

  const RecentAlertsCard({Key? key, required this.alerts, this.onViewAll})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Alerts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (alerts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No recent alerts',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return _buildAlertItem(alert);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(AlertModel alert) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getAlertColor(alert.type).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getAlertIcon(alert.type),
            color: _getAlertColor(alert.type),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(alert.timestamp),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        if (!alert.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
      ],
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
}
