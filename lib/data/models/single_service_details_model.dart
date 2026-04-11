class StoreServiceDetailsResponseModel {
  final bool? success;
  final String? message;
  final StoreServiceDetailsData? data;

  StoreServiceDetailsResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory StoreServiceDetailsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StoreServiceDetailsResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? StoreServiceDetailsData.fromJson(json['data'])
          : null,
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

class StoreServiceDetailsData {
  final String? id;
  final String? storeId;
  final String? serviceId;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final StoreServiceService? service;
  final List<ReviewModel>? reviews;
  final ReviewCountModel? count;
  final StoreModel? store;

  StoreServiceDetailsData({
    this.id,
    this.storeId,
    this.serviceId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.service,
    this.reviews,
    this.count,
    this.store,
  });

  factory StoreServiceDetailsData.fromJson(Map<String, dynamic> json) {
    return StoreServiceDetailsData(
      id: json['id'],
      storeId: json['storeId'],
      serviceId: json['serviceId'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      service: json['service'] != null
          ? StoreServiceService.fromJson(json['service'])
          : null,
      reviews: json['reviews'] != null
          ? List<ReviewModel>.from(
              json['reviews'].map((x) => ReviewModel.fromJson(x)),
            )
          : [],
      count: json['_count'] != null
          ? ReviewCountModel.fromJson(json['_count'])
          : null,
      store: json['store'] != null ? StoreModel.fromJson(json['store']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'serviceId': serviceId,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'service': service?.toJson(),
      'reviews': reviews?.map((x) => x.toJson()).toList(),
      '_count': count?.toJson(),
      'store': store?.toJson(),
    };
  }
}

class StoreServiceService {
  final String? id;
  final String? operatorId;
  final String? categoryId;
  final String? name;
  final String? basePrice;
  final String? description;
  final String? image;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final CategoryModel? category;
  final List<ServiceAddonModel>? serviceAddons;
  final List<StoreServiceLinkModel>? storeServices;
  final OperatorModel? operator;

  StoreServiceService({
    this.id,
    this.operatorId,
    this.categoryId,
    this.name,
    this.basePrice,
    this.description,
    this.image,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.serviceAddons,
    this.storeServices,
    this.operator,
  });

  factory StoreServiceService.fromJson(Map<String, dynamic> json) {
    return StoreServiceService(
      id: json['id'],
      operatorId: json['operatorId'],
      categoryId: json['categoryId'],
      name: json['name'],
      basePrice: json['basePrice'],
      description: json['description'],
      image: json['image'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      serviceAddons: json['serviceAddons'] != null
          ? List<ServiceAddonModel>.from(
              json['serviceAddons'].map((x) => ServiceAddonModel.fromJson(x)),
            )
          : [],
      storeServices: json['storeServices'] != null
          ? List<StoreServiceLinkModel>.from(
              json['storeServices'].map(
                (x) => StoreServiceLinkModel.fromJson(x),
              ),
            )
          : [],
      operator: json['operator'] != null
          ? OperatorModel.fromJson(json['operator'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operatorId': operatorId,
      'categoryId': categoryId,
      'name': name,
      'basePrice': basePrice,
      'description': description,
      'image': image,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'category': category?.toJson(),
      'serviceAddons': serviceAddons?.map((x) => x.toJson()).toList(),
      'storeServices': storeServices?.map((x) => x.toJson()).toList(),
      'operator': operator?.toJson(),
    };
  }
}

class CategoryModel {
  final String? id;
  final String? name;
  final String? description;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  CategoryModel({
    this.id,
    this.name,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ServiceAddonModel {
  final String? id;
  final String? serviceId;
  final String? addonId;
  final String? createdAt;
  final String? updatedAt;
  final AddonModel? addon;

  ServiceAddonModel({
    this.id,
    this.serviceId,
    this.addonId,
    this.createdAt,
    this.updatedAt,
    this.addon,
  });

  factory ServiceAddonModel.fromJson(Map<String, dynamic> json) {
    return ServiceAddonModel(
      id: json['id'],
      serviceId: json['serviceId'],
      addonId: json['addonId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      addon:
          json['addon'] != null ? AddonModel.fromJson(json['addon']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'addonId': addonId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'addon': addon?.toJson(),
    };
  }
}

class AddonModel {
  final String? id;
  final String? operatorId;
  final String? name;
  final String? description;
  final String? price;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  AddonModel({
    this.id,
    this.operatorId,
    this.name,
    this.description,
    this.price,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      id: json['id'],
      operatorId: json['operatorId'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operatorId': operatorId,
      'name': name,
      'description': description,
      'price': price,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class StoreServiceLinkModel {
  final String? id;
  final String? storeId;
  final String? serviceId;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  StoreServiceLinkModel({
    this.id,
    this.storeId,
    this.serviceId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreServiceLinkModel.fromJson(Map<String, dynamic> json) {
    return StoreServiceLinkModel(
      id: json['id'],
      storeId: json['storeId'],
      serviceId: json['serviceId'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'serviceId': serviceId,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class OperatorModel {
  final String? id;
  final String? operatorId;
  final String? userId;
  final String? approvalStatus;
  final String? status;
  final String? stripeAccountId;
  final String? stripeAccountStatus;
  final String? createdAt;
  final String? updatedAt;

  OperatorModel({
    this.id,
    this.operatorId,
    this.userId,
    this.approvalStatus,
    this.status,
    this.stripeAccountId,
    this.stripeAccountStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      id: json['id'],
      operatorId: json['operatorId'],
      userId: json['userId'],
      approvalStatus: json['approvalStatus'],
      status: json['status'],
      stripeAccountId: json['stripeAccountId'],
      stripeAccountStatus: json['stripeAccountStatus'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operatorId': operatorId,
      'userId': userId,
      'approvalStatus': approvalStatus,
      'status': status,
      'stripeAccountId': stripeAccountId,
      'stripeAccountStatus': stripeAccountStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ReviewModel {
  final String? id;
  final String? reviewNumber;
  final String? userId;
  final String? storeServiceId;
  final String? storeBundleId;
  final int? rating;
  final String? comment;
  final String? operatorReply;
  final String? createdAt;
  final String? updatedAt;

  ReviewModel({
    this.id,
    this.reviewNumber,
    this.userId,
    this.storeServiceId,
    this.storeBundleId,
    this.rating,
    this.comment,
    this.operatorReply,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      reviewNumber: json['reviewNumber'],
      userId: json['userId'],
      storeServiceId: json['storeServiceId'],
      storeBundleId: json['storeBundleId'],
      rating: json['rating'],
      comment: json['comment'],
      operatorReply: json['operatorReply'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewNumber': reviewNumber,
      'userId': userId,
      'storeServiceId': storeServiceId,
      'storeBundleId': storeBundleId,
      'rating': rating,
      'comment': comment,
      'operatorReply': operatorReply,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ReviewCountModel {
  final int? reviews;

  ReviewCountModel({
    this.reviews,
  });

  factory ReviewCountModel.fromJson(Map<String, dynamic> json) {
    return ReviewCountModel(
      reviews: json['reviews'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviews': reviews,
    };
  }
}

class StoreModel {
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

  StoreModel({
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
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
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
    };
  }
}