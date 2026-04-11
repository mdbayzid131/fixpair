class StoreServiceResponseModel {
  final bool? success;
  final String? message;
  final Meta? meta;
  final List<StoreServiceData>? data;

  StoreServiceResponseModel({
    this.success,
    this.message,
    this.meta,
    this.data,
  });

  factory StoreServiceResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreServiceResponseModel(
      success: json['success'],
      message: json['message'],
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data: json['data'] != null
          ? List<StoreServiceData>.from(
              json['data'].map((x) => StoreServiceData.fromJson(x)),
            )
          : [],
    );
  }
}

class Meta {
  final int? total;
  final int? page;
  final int? limit;

  Meta({
    this.total,
    this.page,
    this.limit,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
    );
  }
}

class StoreServiceData {
  final String? id;
  final String? storeId;
  final String? serviceId;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  final Service? service;
  final Store? store;

  final double? distanceMeters;
  final double? distanceMile;

  StoreServiceData({
    this.id,
    this.storeId,
    this.serviceId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.service,
    this.store,
    this.distanceMeters,
    this.distanceMile,
  });

  factory StoreServiceData.fromJson(Map<String, dynamic> json) {
    return StoreServiceData(
      id: json['id'],
      storeId: json['storeId'],
      serviceId: json['serviceId'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      service: json['service'] != null
          ? Service.fromJson(json['service'])
          : null,
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      distanceMeters: json['distance_meters'] != null
          ? double.tryParse(json['distance_meters'].toString())
          : null,
      distanceMile: json['distanceMile'] != null
          ? double.tryParse(json['distanceMile'].toString())
          : null,
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
  final String? createdAt;
  final String? updatedAt;
  final bool? isActive;

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
    this.createdAt,
    this.updatedAt,
    this.isActive,
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
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isActive: json['isActive'],
    );
  }
}


class Service {
  final String? id;
  final String? serviceId;
  final String? operatorId;
  final String? categoryId;
  final String? name;
  final double? basePrice;
  final String? description;
  final String? image;
  final String? createdAt;
  final String? updatedAt;
  final bool? isActive;

  Service({
    this.id,
    this.serviceId,
    this.operatorId,
    this.categoryId,
    this.name,
    this.basePrice,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.isActive,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      serviceId: json['serviceId'],
      operatorId: json['operatorId'],
      categoryId: json['categoryId'],
      name: json['name'],
      basePrice: json['basePrice'] != null
          ? double.tryParse(json['basePrice'].toString())
          : null,
      description: json['description'],
      image: json['image'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isActive: json['isActive'],
    );
  }
}