class MyOrderResponseModel {
  final bool? success;
  final String? message;
  final Meta? meta;
  final List<Order>? data;

  MyOrderResponseModel({this.success, this.message, this.meta, this.data});

  factory MyOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return MyOrderResponseModel(
      success: json['success'],
      message: json['message'],
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data: json['data'] != null
          ? List<Order>.from(json['data'].map((x) => Order.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "meta": meta?.toJson(),
    "data": data?.map((e) => e.toJson()).toList(),
  };
}

class Meta {
  final int? total;
  final int? totalPage;
  final int? page;
  final int? limit;

  Meta({this.total, this.totalPage, this.page, this.limit});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'],
      totalPage: json['totalPage'],
      page: json['page'],
      limit: json['limit'],
    );
  }

  Map<String, dynamic> toJson() => {
    "total": total,
    "totalPage": totalPage,
    "page": page,
    "limit": limit,
  };
}

class Order {
  final String? id;
  final String? orderNumber;
  final String? userId;
  final String? status;
  final String? paymentStatus;
  final String? subtotal;
  final String? pickupAndDeliveryFee;
  final String? platformFee;
  final String? fixedTransactionFee;
  final String? totalAmount;
  final String? actualPickupAndDeliveryFee;
  final bool? isSubscription;
  final String? scheduledDate;
  final String? stripePaymentIntentId;
  final String? stripeTransferGroup;
  final String? paymentUrl;
  final String? createdAt;
  final String? updatedAt;

  final User? user;
  final Address? pickupAddress;
  final Address? deliveryAddress;
  final List<OrderItem>? orderItems;
  final List<OperatorOrder>? operatorOrders;
  final Payment? payment;

  Order({
    this.id,
    this.orderNumber,
    this.userId,
    this.status,
    this.paymentStatus,
    this.subtotal,
    this.pickupAndDeliveryFee,
    this.platformFee,
    this.fixedTransactionFee,
    this.totalAmount,
    this.actualPickupAndDeliveryFee,
    this.isSubscription,
    this.scheduledDate,
    this.stripePaymentIntentId,
    this.stripeTransferGroup,
    this.paymentUrl,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.pickupAddress,
    this.deliveryAddress,
    this.orderItems,
    this.operatorOrders,
    this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'],
      userId: json['userId'],
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      subtotal: json['subtotal'],
      pickupAndDeliveryFee: json['pickupAndDeliveryFee'],
      platformFee: json['platformFee'],
      fixedTransactionFee: json['fixedTransactionFee'],
      totalAmount: json['totalAmount'],
      actualPickupAndDeliveryFee: json['actualPickupAndDeliveryFee'],
      isSubscription: json['isSubscription'],
      scheduledDate: json['scheduledDate'],
      stripePaymentIntentId: json['stripePaymentIntentId'],
      stripeTransferGroup: json['stripeTransferGroup'],
      paymentUrl: json['paymentUrl'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      pickupAddress: json['pickupAddress'] != null
          ? Address.fromJson(json['pickupAddress'])
          : null,
      deliveryAddress: json['deliveryAddress'] != null
          ? Address.fromJson(json['deliveryAddress'])
          : null,
      orderItems: json['orderItems'] != null
          ? List<OrderItem>.from(
              json['orderItems'].map((x) => OrderItem.fromJson(x)),
            )
          : [],
      operatorOrders: json['operatorOrders'] != null
          ? List<OperatorOrder>.from(
              json['operatorOrders'].map((x) => OperatorOrder.fromJson(x)),
            )
          : [],
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {};
}

class User {
  final String? name;
  final String? email;

  User({this.name, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(name: json['name'], email: json['email']);
  }

  Map<String, dynamic> toJson() => {"name": name, "email": email};
}

class Address {
  final String? id;
  final String? orderId;
  final String? pickupTime;
  final String? pickupDate;
  final String? deliveryTime;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  Address({
    this.id,
    this.orderId,
    this.pickupTime,
    this.pickupDate,
    this.deliveryTime,
    this.streetAddress,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      orderId: json['orderId'],
      pickupTime: json['pickupTime'],
      pickupDate: json['pickupDate'],
      deliveryTime: json['deliveryTime'],
      streetAddress: json['streetAddress'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() => {};
}

class OrderItem {
  final String? id;
  final String? orderId;
  final String? operatorOrderId;
  final String? serviceName;
  final int? quantity;
  final String? price;
  final String? serviceId;
  final String? bundleId;
  final String? createdAt;

  OrderItem({
    this.id,
    this.orderId,
    this.operatorOrderId,
    this.serviceName,
    this.quantity,
    this.price,
    this.serviceId,
    this.bundleId,
    this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      operatorOrderId: json['operatorOrderId'],
      serviceName: json['serviceName'],
      quantity: json['quantity'],
      price: json['price'],
      serviceId: json['serviceId'],
      bundleId: json['bundleId'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {};
}

class OperatorOrder {
  final String? id;
  final String? orderId;
  final String? operatorId;
  final String? storeId;
  final String? subtotal;
  final String? transferAmount;
  final String? transferStatus;
  final String? stripeTransferId;
  final String? createdAt;
  final Store? store;

  OperatorOrder({
    this.id,
    this.orderId,
    this.operatorId,
    this.storeId,
    this.subtotal,
    this.transferAmount,
    this.transferStatus,
    this.stripeTransferId,
    this.createdAt,
    this.store,
  });

  factory OperatorOrder.fromJson(Map<String, dynamic> json) {
    return OperatorOrder(
      id: json['id'],
      orderId: json['orderId'],
      operatorId: json['operatorId'],
      storeId: json['storeId'],
      subtotal: json['subtotal'],
      transferAmount: json['transferAmount'],
      transferStatus: json['transferStatus'],
      stripeTransferId: json['stripeTransferId'],
      createdAt: json['createdAt'],
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
    );
  }
}

class Store {
  final String? id;
  final String? name;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double? lat;
  final double? lng;

  Store({
    this.id,
    this.name,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.lat,
    this.lng,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}

class Payment {
  final String? id;
  final String? orderId;
  final String? amount;
  final String? currency;
  final String? status;
  final String? paymentUrl;
  final String? paidAt;

  Payment({
    this.id,
    this.orderId,
    this.amount,
    this.currency,
    this.status,
    this.paymentUrl,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      orderId: json['orderId'],
      amount: json['amount'],
      currency: json['currency'],
      status: json['status'],
      paymentUrl: json['paymentUrl'],
      paidAt: json['paidAt'],
    );
  }
}
