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
      consultationId: json['consultationId']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      invoiceDate: json['invoiceDate']?.toString() ?? '',
      duration: json['duration']?.toString(),
      billableMinutes: json['billableMinutes']?.toString(),
      perMinuteRate: json['perMinuteRate'] is num
          ? json['perMinuteRate'] as num
          : (num.tryParse(json['perMinuteRate']?.toString() ?? '0') ?? 0),
      subtotal: json['subtotal'] is num
          ? json['subtotal'] as num
          : (num.tryParse(json['subtotal']?.toString() ?? '0') ?? 0),
      platformFee: json['platformFee'] is num
          ? json['platformFee'] as num
          : (num.tryParse(json['platformFee']?.toString() ?? '0') ?? 0),
      totalAmount: json['totalAmount'] is num
          ? json['totalAmount'] as num
          : (num.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0),
      status: json['status']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      transactionId: json['transactionId']?.toString() ?? '',
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? InvoiceUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      consultant: json['consultant'] != null && json['consultant'] is Map<String, dynamic>
          ? InvoiceConsultant.fromJson(json['consultant'] as Map<String, dynamic>)
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type']?.toString(),
    );
  }
}
