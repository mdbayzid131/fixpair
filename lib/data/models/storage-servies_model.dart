class StoreServicesResponseModel {
  final bool? success;
  final String? message;
  final StoreServicesWrapper? data;

  StoreServicesResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory StoreServicesResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreServicesResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? StoreServicesWrapper.fromJson(json['data'])
          : null,
    );
  }
}

class StoreServicesWrapper {
  final Meta? meta;
  final List<StoreServiceItem>? data;

  StoreServicesWrapper({
    this.meta,
    this.data,
  });

  factory StoreServicesWrapper.fromJson(Map<String, dynamic> json) {
    return StoreServicesWrapper(
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data: json['data'] != null
          ? List<StoreServiceItem>.from(
              json['data'].map((x) => StoreServiceItem.fromJson(x)),
            )
          : [],
    );
  }
}

class Meta {
  final int? total;
  final int? totalPage;
  final int? page;
  final int? limit;

  Meta({
    this.total,
    this.totalPage,
    this.page,
    this.limit,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'],
      totalPage: json['totalPage'],
      page: json['page'],
      limit: json['limit'],
    );
  }
}

class StoreServiceItem {
  final String? id;
  final String? storeId;
  final String? serviceId;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  final Service? service;
  final Store? store;

  final List<Review>? reviews;
  final double? avgRating;
  final int? totalReviews;

  StoreServiceItem({
    this.id,
    this.storeId,
    this.serviceId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.service,
    this.store,
    this.reviews,
    this.avgRating,
    this.totalReviews,
  });

  factory StoreServiceItem.fromJson(Map<String, dynamic> json) {
    return StoreServiceItem(
      id: json['id'],
      storeId: json['storeId'],
      serviceId: json['serviceId'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      service:
          json['service'] != null ? Service.fromJson(json['service']) : null,
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      reviews: json['reviews'] != null
          ? List<Review>.from(
              json['reviews'].map((x) => Review.fromJson(x)),
            )
          : [],
      avgRating: json['avgRating'] != null
          ? double.tryParse(json['avgRating'].toString())
          : null,
      totalReviews: json['totalReviews'],
    );
  }
}

class Service {
  final String? id;
  final String? name;
  final String? basePrice;
  final String? description;
  final String? image;
  final String? categoryId;
  final bool? isActive;
  final String? operatorId;

  final Category? category;
  final List<ServiceAddon>? serviceAddons;
  final List<StoreServiceLink>? storeServices;
  final Operator? operator;

  final String? createdAt;
  final String? updatedAt;

  Service({
    this.id,
    this.name,
    this.basePrice,
    this.description,
    this.image,
    this.categoryId,
    this.isActive,
    this.operatorId,
    this.category,
    this.serviceAddons,
    this.storeServices,
    this.operator,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      basePrice: json['basePrice'],
      description: json['description'],
      image: json['image'],
      categoryId: json['categoryId'],
      isActive: json['isActive'],
      operatorId: json['operatorId'],
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      serviceAddons: json['serviceAddons'] != null
          ? List<ServiceAddon>.from(
              json['serviceAddons'].map(
                (x) => ServiceAddon.fromJson(x),
              ),
            )
          : [],
      storeServices: json['storeServices'] != null
          ? List<StoreServiceLink>.from(
              json['storeServices'].map(
                (x) => StoreServiceLink.fromJson(x),
              ),
            )
          : [],
      operator: json['operator'] != null
          ? Operator.fromJson(json['operator'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Category {
  final String? id;
  final String? name;
  final String? description;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  Category({
    this.id,
    this.name,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class ServiceAddon {
  final String? id;
  final String? serviceId;
  final String? addonId;
  final String? createdAt;
  final String? updatedAt;

  ServiceAddon({
    this.id,
    this.serviceId,
    this.addonId,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceAddon.fromJson(Map<String, dynamic> json) {
    return ServiceAddon(
      id: json['id'],
      serviceId: json['serviceId'],
      addonId: json['addonId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class StoreServiceLink {
  final String? id;
  final String? storeId;
  final String? serviceId;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  StoreServiceLink({
    this.id,
    this.storeId,
    this.serviceId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreServiceLink.fromJson(Map<String, dynamic> json) {
    return StoreServiceLink(
      id: json['id'],
      storeId: json['storeId'],
      serviceId: json['serviceId'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Operator {
  final String? id;
  final String? operatorId;
  final String? userId;
  final String? approvalStatus;
  final String? status;
  final String? stripeAccountId;
  final String? stripeAccountStatus;
  final String? createdAt;
  final String? updatedAt;

  Operator({
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

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
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
}

class Store {
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

  Store({
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

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
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
      lat: json['lat'] != null
          ? double.tryParse(json['lat'].toString())
          : null,
      lng: json['lng'] != null
          ? double.tryParse(json['lng'].toString())
          : null,
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Review {
  final String? id;
  final int? rating;
  final String? comment;
  final String? createdAt;

  Review({
    this.id,
    this.rating,
    this.comment,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['createdAt'],
    );
  }
}