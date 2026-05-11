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
  final AuthenticationModel? authentication;
  final String? id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? email;
  final String? phone;
  final String? image;
  final String? avatar;
  final String? status;
  final bool? verified;
  final String? provider;
  final String? providerId;
  final String? consultancyType;
  final String? experience;
  final List<dynamic>? languages;
  final List<dynamic>? expertise;
  final int? visitFee;
  final int? perMinuteRate;
  final String? activeStatus;
  final String? stripeCustomerId;
  final String? paypalPayerId;
  final List<dynamic>? paymentMethods;
  final String? createdAt;
  final String? updatedAt;

  UserData({
    this.authentication,
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.role,
    this.email,
    this.phone,
    this.image,
    this.avatar,
    this.status,
    this.verified,
    this.provider,
    this.providerId,
    this.consultancyType,
    this.experience,
    this.languages,
    this.expertise,
    this.visitFee,
    this.perMinuteRate,
    this.activeStatus,
    this.stripeCustomerId,
    this.paypalPayerId,
    this.paymentMethods,
    this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      authentication: json['authentication'] != null
          ? AuthenticationModel.fromJson(json['authentication'])
          : null,
      id: json['_id'],
      name: json['name'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
      avatar: json['avatar'],
      status: json['status'],
      verified: json['verified'],
      provider: json['provider'],
      providerId: json['providerId'],
      consultancyType: json['consultancyType'],
      experience: json['experience'],
      languages: json['languages'] ?? [],
      expertise: json['expertise'] ?? [],
      visitFee: json['visitFee'] != null ? int.tryParse(json['visitFee'].toString()) : 0,
      perMinuteRate: json['perMinuteRate'] != null ? int.tryParse(json['perMinuteRate'].toString()) : 0,
      activeStatus: json['activeStatus'],
      stripeCustomerId: json['stripeCustomerId'],
      paypalPayerId: json['paypalPayerId'],
      paymentMethods: json['paymentMethods'] ?? [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authentication': authentication?.toJson(),
      '_id': id,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'email': email,
      'phone': phone,
      'image': image,
      'avatar': avatar,
      'status': status,
      'verified': verified,
      'provider': provider,
      'providerId': providerId,
      'consultancyType': consultancyType,
      'experience': experience,
      'languages': languages,
      'expertise': expertise,
      'visitFee': visitFee,
      'perMinuteRate': perMinuteRate,
      'activeStatus': activeStatus,
      'stripeCustomerId': stripeCustomerId,
      'paypalPayerId': paypalPayerId,
      'paymentMethods': paymentMethods,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class AuthenticationModel {
  final bool? isResetPassword;
  final dynamic oneTimeCode;
  final dynamic expireAt;
  final int? otpRequestCount;
  final dynamic lastOtpRequestTime;

  AuthenticationModel({
    this.isResetPassword,
    this.oneTimeCode,
    this.expireAt,
    this.otpRequestCount,
    this.lastOtpRequestTime,
  });

  factory AuthenticationModel.fromJson(Map<String, dynamic> json) {
    return AuthenticationModel(
      isResetPassword: json['isResetPassword'],
      oneTimeCode: json['oneTimeCode'],
      expireAt: json['expireAt'],
      otpRequestCount: json['otpRequestCount'],
      lastOtpRequestTime: json['lastOtpRequestTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isResetPassword': isResetPassword,
      'oneTimeCode': oneTimeCode,
      'expireAt': expireAt,
      'otpRequestCount': otpRequestCount,
      'lastOtpRequestTime': lastOtpRequestTime,
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