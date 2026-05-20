class TranscriptMessage {
  final String speakerName;
  final String speakerRole;
  final String text;
  final bool isFinal;
  final DateTime timestamp;

  TranscriptMessage({
    required this.speakerName,
    required this.speakerRole,
    required this.text,
    required this.isFinal,
    required this.timestamp,
  });

  factory TranscriptMessage.fromJson(
    Map<String, dynamic> json,
    String defaultUser,
    String defaultConsultant,
  ) {
    final role = json['speakerRole']?.toString() ?? '';
    String name = '';
    if (role == 'consultant') {
      name = defaultConsultant;
    } else if (role == 'user') {
      name = defaultUser;
    } else {
      name = json['speakerUid']?.toString() ?? 'Unknown';
    }

    return TranscriptMessage(
      speakerName: name,
      speakerRole: role,
      text: json['text']?.toString() ?? '',
      isFinal: json['isFinal'] == true,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speakerName': speakerName,
      'speakerRole': speakerRole,
      'text': text,
      'isFinal': isFinal,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TranscriptMessage.fromDirectJson(Map<String, dynamic> json) {
    return TranscriptMessage(
      speakerName: json['speakerName']?.toString() ?? '',
      speakerRole: json['speakerRole']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      isFinal: json['isFinal'] == true,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
