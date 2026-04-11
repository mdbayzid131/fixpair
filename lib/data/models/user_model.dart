class UserProfileResponseModel {
  final bool? success;
  final String? message;
  final UserData? data;

  UserProfileResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
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

class UserData {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? avatar;
  final String? status;
  final bool? isVerified;
  final bool? isDeleted;
  final double? lat;
  final double? lng;
  final bool? isTwoFactorEnabled;
  final List<dynamic>? userSubscriptions;
  final String? stripeCustomerId;
  final bool? isSubscribed;
  final String? internalUserId;
  final String? createdAt;
  final String? updatedAt;
  final List<UserAddress>? addresses;
  final List<dynamic>? orders;
  final List<dynamic>? reviews;
  final CountModel? count;

  UserData({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.avatar,
    this.status,
    this.isVerified,
    this.isDeleted,
    this.lat,
    this.lng,
    this.isTwoFactorEnabled,
    this.userSubscriptions,
    this.stripeCustomerId,
    this.isSubscribed,
    this.internalUserId,
    this.createdAt,
    this.updatedAt,
    this.addresses,
    this.orders,
    this.reviews,
    this.count,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      avatar: json['avatar'],
      status: json['status'],
      isVerified: json['isVerified'],
      isDeleted: json['isDeleted'],
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
      isTwoFactorEnabled: json['isTwoFactorEnabled'],
      userSubscriptions: json['userSubscriptions'] ?? [],
      stripeCustomerId: json['stripeCustomerId'],
      isSubscribed: json['isSubscribed'],
      internalUserId: json['userId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      addresses: json['addresses'] != null
          ? List<UserAddress>.from(
              json['addresses'].map((x) => UserAddress.fromJson(x)),
            )
          : [],
      orders: json['orders'] ?? [],
      reviews: json['reviews'] ?? [],
      count: json['_count'] != null ? CountModel.fromJson(json['_count']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar': avatar,
      'status': status,
      'isVerified': isVerified,
      'isDeleted': isDeleted,
      'lat': lat,
      'lng': lng,
      'isTwoFactorEnabled': isTwoFactorEnabled,
      'userSubscriptions': userSubscriptions,
      'stripeCustomerId': stripeCustomerId,
      'isSubscribed': isSubscribed,
      'userId': internalUserId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'addresses': addresses?.map((x) => x.toJson()).toList(),
      'orders': orders,
      'reviews': reviews,
      '_count': count?.toJson(),
    };
  }
}

class UserAddress {
  final String? id;
  final String? userId;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final bool? isDefault;
  final String? createdAt;
  final String? updatedAt;

  UserAddress({
    this.id,
    this.userId,
    this.streetAddress,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'],
      userId: json['userId'],
      streetAddress: json['streetAddress'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      isDefault: json['isDefault'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'isDefault': isDefault,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}


class CountModel {
  final int? orders;
  final int? reviews;
  final int? supportTickets;
  final int? ticketMessages;
  final int? paymentCards;
  final int? favoriteServices;
  final int? notifications;
  final int? userSubscriptions;
  final int? userAddresses;
  final int? wallets;
  final int? payouts;
  final int? transactions;
  final int? chatParticipants;
  final int? chatMessages;

  CountModel({
    this.orders,
    this.reviews,
    this.supportTickets,
    this.ticketMessages,
    this.paymentCards,
    this.favoriteServices,
    this.notifications,
    this.userSubscriptions,
    this.userAddresses,
    this.wallets,
    this.payouts,
    this.transactions,
    this.chatParticipants,
    this.chatMessages,
  });

  factory CountModel.fromJson(Map<String, dynamic> json) {
    return CountModel(
      orders: json['orders'],
      reviews: json['reviews'],
      supportTickets: json['supportTickets'],
      ticketMessages: json['ticketMessages'],
      paymentCards: json['paymentCards'],
      favoriteServices: json['favoriteServices'],
      notifications: json['notifications'],
      userSubscriptions: json['userSubscriptions'],
      userAddresses: json['userAddresses'],
      wallets: json['wallets'],
      payouts: json['payouts'],
      transactions: json['transactions'],
      chatParticipants: json['chatParticipants'],
      chatMessages: json['chatMessages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders,
      'reviews': reviews,
      'supportTickets': supportTickets,
      'ticketMessages': ticketMessages,
      'paymentCards': paymentCards,
      'favoriteServices': favoriteServices,
      'notifications': notifications,
      'userSubscriptions': userSubscriptions,
      'userAddresses': userAddresses,
      'wallets': wallets,
      'payouts': payouts,
      'transactions': transactions,
      'chatParticipants': chatParticipants,
      'chatMessages': chatMessages,
    };
  }
}