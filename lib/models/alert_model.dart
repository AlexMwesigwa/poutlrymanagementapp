enum AlertType {
  temperature,
  humidity,
  feed,
  water,
  security,
}

class AlertModel {
  final String id;
  final AlertType type;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  
  AlertModel({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
  
  factory AlertModel.fromMap(Map<String, dynamic> map, String docId) {
    return AlertModel(
      id: docId,
      type: _stringToAlertType(map['type'] ?? 'temperature'),
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as dynamic).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'type': _alertTypeToString(type),
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
  
  AlertModel copyWith({
    String? id,
    AlertType? type,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AlertModel(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
  
  static AlertType _stringToAlertType(String type) {
    switch (type) {
      case 'temperature':
        return AlertType.temperature;
      case 'humidity':
        return AlertType.humidity;
      case 'feed':
        return AlertType.feed;
      case 'water':
        return AlertType.water;
      case 'security':
        return AlertType.security;
      default:
        return AlertType.temperature;
    }
  }
  
  static String _alertTypeToString(AlertType type) {
    switch (type) {
      case AlertType.temperature:
        return 'temperature';
      case AlertType.humidity:
        return 'humidity';
      case AlertType.feed:
        return 'feed';
      case AlertType.water:
        return 'water';
      case AlertType.security:
        return 'security';
    }
  }
}
