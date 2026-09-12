num _parseNum(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val;
  if (val is String) return num.tryParse(val) ?? 0;
  return 0;
}

class InvoiceModel {
  final String consultationId;
  final String invoiceNumber;
  final String date;
  final String invoiceDate;
  final String? duration;
  final String? billableMinutes;
  final num perMinuteRate;
  final num subtotal;
  final num platformFee;
  final num totalAmount;
  final String status;
  final String paymentMethod;
  final String transactionId;
  final InvoiceUser? user;
  final InvoiceConsultant? consultant;

  InvoiceModel({
    required this.consultationId,
    required this.invoiceNumber,
    required this.date,
    required this.invoiceDate,
    this.duration,
    this.billableMinutes,
    required this.perMinuteRate,
    required this.subtotal,
    required this.platformFee,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.transactionId,
    this.user,
    this.consultant,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      consultationId: json['consultationId']?.toString() ?? json['_id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString() ?? json['invoiceNo']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      invoiceDate: json['invoiceDate']?.toString() ?? json['createdAt']?.toString() ?? '',
      duration: json['duration']?.toString(),
      billableMinutes: json['billableMinutes']?.toString() ?? json['duration']?.toString(),
      perMinuteRate: _parseNum(json['perMinuteRate']),
      subtotal: _parseNum(json['subtotal']),
      platformFee: _parseNum(json['platformFee']),
      totalAmount: _parseNum(json['totalAmount']),
      status: json['status']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      transactionId: json['transactionId']?.toString() ?? '',
      user: json['user'] != null && json['user'] is Map
          ? InvoiceUser.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
      consultant: json['consultant'] != null && json['consultant'] is Map
          ? InvoiceConsultant.fromJson(Map<String, dynamic>.from(json['consultant']))
          : null,
    );
  }
}

class InvoiceUser {
  final String id;
  final String name;
  final String email;

  InvoiceUser({required this.id, required this.name, required this.email});

  factory InvoiceUser.fromJson(Map<String, dynamic> json) {
    return InvoiceUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class InvoiceConsultant {
  final String id;
  final String name;
  final String? type;

  InvoiceConsultant({required this.id, required this.name, this.type});

  factory InvoiceConsultant.fromJson(Map<String, dynamic> json) {
    return InvoiceConsultant(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString(),
    );
  }
}
