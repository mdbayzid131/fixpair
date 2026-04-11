class StoreBundleResponseModel {
  final bool? success;
  final String? message;
  final List<StoreBundleData>? data;

  StoreBundleResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory StoreBundleResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreBundleResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<StoreBundleData>.from(
              json['data'].map((x) => StoreBundleData.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class StoreBundleData {
  final String? id;
  final String? storeId;
  final String? bundleId;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  final BundleModel? bundle;
  final StoreModel? store;

  StoreBundleData({
    this.id,
    this.storeId,
    this.bundleId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.bundle,
    this.store,
  });

  factory StoreBundleData.fromJson(Map<String, dynamic> json) {
    return StoreBundleData(
      id: json['id'],
      storeId: json['storeId'],
      bundleId: json['bundleId'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      bundle:
          json['bundle'] != null ? BundleModel.fromJson(json['bundle']) : null,
      store: json['store'] != null ? StoreModel.fromJson(json['store']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'bundleId': bundleId,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'bundle': bundle?.toJson(),
      'store': store?.toJson(),
    };
  }
}

class BundleModel {
  final String? id;
  final String? operatorId;
  final String? name;
  final String? description;
  final String? image;
  final String? bundlePrice;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  BundleModel({
    this.id,
    this.operatorId,
    this.name,
    this.description,
    this.image,
    this.bundlePrice,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory BundleModel.fromJson(Map<String, dynamic> json) {
    return BundleModel(
      id: json['id'],
      operatorId: json['operatorId'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      bundlePrice: json['bundlePrice'],
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
      'image': image,
      'bundlePrice': bundlePrice,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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