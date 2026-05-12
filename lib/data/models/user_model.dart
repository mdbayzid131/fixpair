import 'package:flutter/foundation.dart';

class UserProfileResponseModel {
  final bool? success;
  final String? message;
  final UserData? data;

  UserProfileResponseModel({this.success, this.message, this.data});

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class ConsultantResponseModel {
  final bool? success;
  final String? message;
  final PaginationModel? pagination;
  final List<UserData>? data;

  ConsultantResponseModel({
    this.success,
    this.message,
    this.pagination,
    this.data,
  });

  factory ConsultantResponseModel.fromJson(Map<String, dynamic> json) {
    return ConsultantResponseModel(
      success: json['success'],
      message: json['message'],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => UserData.fromJson(i)).toList()
          : null,
    );
  }
}

class PaginationModel {
  final int? total;
  final int? limit;
  final int? page;
  final int? totalPage;

  PaginationModel({this.total, this.limit, this.page, this.totalPage});

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'],
      limit: json['limit'],
      page: json['page'],
      totalPage: json['totalPage'],
    );
  }
}

class ConsultantStats {
  final String? id;
  final double? avgRating;
  final int? totalReviews;

  ConsultantStats({this.id, this.avgRating, this.totalReviews});

  factory ConsultantStats.fromJson(Map<String, dynamic> json) {
    return ConsultantStats(
      id: json['_id'],
      avgRating: json['avgRating'] != null
          ? double.tryParse(json['avgRating'].toString())
          : 0.0,
      totalReviews: json['totalReviews'] != null
          ? int.tryParse(json['totalReviews'].toString())
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'avgRating': avgRating, 'totalReviews': totalReviews};
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
  final String? expertise;
  final int? visitFee;
  final int? perMinuteRate;
  final bool? activeStatus;
  final String? stripeCustomerId;
  final String? paypalPayerId;
  final List<dynamic>? paymentMethods;
  final String? createdAt;
  final String? updatedAt;
  final String? tags;
  final ConsultantStats? stats;

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
    this.tags,
    this.stats,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    try {
      return UserData(
        authentication: json['authentication'] != null
            ? AuthenticationModel.fromJson(json['authentication'])
            : null,
        id: json['_id']?.toString(),
        name: json['name']?.toString(),
        firstName: json['firstName']?.toString(),
        lastName: json['lastName']?.toString(),
        role: json['role']?.toString(),
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        image: json['image']?.toString(),
        avatar: json['avatar']?.toString(),
        status: json['status']?.toString(),
        verified: json['verified'] == true,
        provider: json['provider']?.toString(),
        providerId: json['providerId']?.toString(),
        consultancyType: json['consultancyType']?.toString(),
        experience: json['experience']?.toString(),
        languages: json['languages'] is List ? json['languages'] : [],
        expertise: json['expertise']?.toString(),
        visitFee: int.tryParse(json['visitFee']?.toString() ?? '0') ?? 0,
        perMinuteRate:
            int.tryParse(json['perMinuteRate']?.toString() ?? '0') ?? 0,
        activeStatus: json['activeStatus'] == true,
        stripeCustomerId: json['stripeCustomerId']?.toString(),
        paypalPayerId: json['paypalPayerId']?.toString(),
        paymentMethods: json['paymentMethods'] is List
            ? json['paymentMethods']
            : [],
        createdAt: json['createdAt']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
        tags: json['tags']?.toString(),
        stats: json['stats'] != null
            ? ConsultantStats.fromJson(json['stats'])
            : null,
      );
    } catch (e) {
      debugPrint('UserData Parsing Error: $e');
      return UserData(id: json['_id']?.toString(), name: 'Error Parsing');
    }
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
      'tags': tags,
      'stats': stats?.toJson(),
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
