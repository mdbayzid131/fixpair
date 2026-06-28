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
      consultationId: json['consultationId'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      date: json['date'] ?? '',
      invoiceDate: json['invoiceDate'] ?? '',
      duration: json['duration']?.toString(),
      billableMinutes: json['billableMinutes']?.toString(),
      perMinuteRate: json['perMinuteRate'] ?? 0,
      subtotal: json['subtotal'] ?? 0,
      platformFee: json['platformFee'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      transactionId: json['transactionId'] ?? '',
      user: json['user'] != null ? InvoiceUser.fromJson(json['user']) : null,
      consultant: json['consultant'] != null
          ? InvoiceConsultant.fromJson(json['consultant'])
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
