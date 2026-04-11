class StoreDetailsResponseModel {
  final bool? success;
  final String? message;
  final StoreDetailsData? data;

  StoreDetailsResponseModel({this.success, this.message, this.data});

  factory StoreDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreDetailsResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? StoreDetailsData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class StoreDetailsData {
  final String? id;
  final String? operatorId;
  final String? name;
  final String? logo;
  final String? banner;
  final String? address;
  final String? country;
  final String? state;
  final String? city;
  final String? postalCode;
  final double? lat;
  final double? lng;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final StoreOperatorWrapper? operator;
  final StoreCountModel? count;
  final double? distanceMile;

  StoreDetailsData({
    this.id,
    this.operatorId,
    this.name,
    this.logo,
    this.banner,
    this.address,
    this.country,
    this.state,
    this.city,
    this.postalCode,
    this.lat,
    this.lng,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.operator,
    this.count,
    this.distanceMile,
  });

  factory StoreDetailsData.fromJson(Map<String, dynamic> json) {
    return StoreDetailsData(
      id: json['id'],
      operatorId: json['operatorId'],
      name: json['name'],
      logo: json['logo'],
      banner: json['banner'],
      address: json['address'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      postalCode: json['postalCode'],
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      operator: json['operator'] != null
          ? StoreOperatorWrapper.fromJson(json['operator'])
          : null,
      count: json['_count'] != null
          ? StoreCountModel.fromJson(json['_count'])
          : null,
      distanceMile: json['distanceMile'] != null
          ? double.tryParse(json['distanceMile'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operatorId': operatorId,
      'name': name,
      'logo': logo,
      'banner': banner,
      'address': address,
      'country': country,
      'state': state,
      'city': city,
      'postalCode': postalCode,
      'lat': lat,
      'lng': lng,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'operator': operator?.toJson(),
      '_count': count?.toJson(),
    };
  }
}

class StoreOperatorWrapper {
  final StoreUser? user;

  StoreOperatorWrapper({this.user});

  factory StoreOperatorWrapper.fromJson(Map<String, dynamic> json) {
    return StoreOperatorWrapper(
      user: json['user'] != null ? StoreUser.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user?.toJson()};
  }
}

class StoreUser {
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;

  StoreUser({this.name, this.email, this.phone, this.avatar});

  factory StoreUser.fromJson(Map<String, dynamic> json) {
    return StoreUser(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone': phone, 'avatar': avatar};
  }
}

class StoreCountModel {
  final int? storeServices;
  final int? storeBundles;
  final int? bundleServices;
  final int? cartItems;
  final int? operatorOrders;

  StoreCountModel({
    this.storeServices,
    this.storeBundles,
    this.bundleServices,
    this.cartItems,
    this.operatorOrders,
  });

  factory StoreCountModel.fromJson(Map<String, dynamic> json) {
    return StoreCountModel(
      storeServices: json['storeServices'],
      storeBundles: json['storeBundles'],
      bundleServices: json['bundleServices'],
      cartItems: json['cartItems'],
      operatorOrders: json['operatorOrders'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeServices': storeServices,
      'storeBundles': storeBundles,
      'bundleServices': bundleServices,
      'cartItems': cartItems,
      'operatorOrders': operatorOrders,
    };
  }
}
