class FarmData {
  final String id;
  final double temperature;
  final double humidity;
  final double feedLevel;
  final double waterLevel;
  final bool securityStatus;
  final DateTime timestamp;
  
  FarmData({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.feedLevel,
    required this.waterLevel,
    required this.securityStatus,
    required this.timestamp,
  });
  
  factory FarmData.fromMap(Map<String, dynamic> map, String docId) {
    return FarmData(
      id: docId,
      temperature: (map['temperature'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      feedLevel: (map['feedLevel'] as num).toDouble(),
      waterLevel: (map['waterLevel'] as num).toDouble(),
      securityStatus: map['securityStatus'] ?? true,
      timestamp: (map['timestamp'] as dynamic).toDate(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'feedLevel': feedLevel,
      'waterLevel': waterLevel,
      'securityStatus': securityStatus,
      'timestamp': timestamp,
    };
  }
}
