class CheckoutResponseModel {
  final bool? success;
  final String? message;
  final CheckoutData? data;

  CheckoutResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory CheckoutResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckoutResponseModel(
      success: json['success'],
      message: json['message'],
      data:
          json['data'] != null ? CheckoutData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}



class CheckoutData {
  final String? orderId;
  final String? paymentUrl;

  CheckoutData({
    this.orderId,
    this.paymentUrl,
  });

  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    return CheckoutData(
      orderId: json['orderId'],
      paymentUrl: json['paymentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'paymentUrl': paymentUrl,
    };
  }
}