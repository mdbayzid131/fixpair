class CartResponseModel {
  final bool? success;
  final String? message;
  final CartData? data;

  CartResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? CartData.fromJson(json['data']) : null,
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

class CartData {
  final String? id;
  final String? userId;
  final String? createdAt;
  final String? updatedAt;
  final List<CartItemModel>? items;
  final String? pickupAndDeliveryFee;

  CartData({
    this.id,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.items,
    this.pickupAndDeliveryFee,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      id: json['id'],
      userId: json['userId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      items: json['items'] != null
          ? List<CartItemModel>.from(
              json['items'].map((x) => CartItemModel.fromJson(x)),
            )
          : [],
      pickupAndDeliveryFee: json['pickupAndDeliveryFee'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'items': items?.map((x) => x.toJson()).toList(),
    };
  }
}

class CartItemModel {
  final String? id;
  final String? cartId;
  final String? storeId;
  final String? operatorId;
  final String? serviceId;
  final String? bundleId;
  final int? quantity;
  final String? price;
  final String? createdAt;
  final String? updatedAt;
  final CartServiceModel? service;
  final CartBundleModel? bundle;
  final List<SelectedAddonModel>? selectedAddons;

  CartItemModel({
    this.id,
    this.cartId,
    this.storeId,
    this.operatorId,
    this.serviceId,
    this.bundleId,
    this.quantity,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.service,
    this.bundle,
    this.selectedAddons,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      cartId: json['cartId'],
      storeId: json['storeId'],
      operatorId: json['operatorId'],
      serviceId: json['serviceId'],
      bundleId: json['bundleId'],
      quantity: json['quantity'],
      price: json['price'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      service: json['service'] != null
          ? CartServiceModel.fromJson(json['service'])
          : null,
      bundle: json['bundle'] != null
          ? CartBundleModel.fromJson(json['bundle'])
          : null,
      selectedAddons: json['selectedAddons'] != null
          ? List<SelectedAddonModel>.from(
              json['selectedAddons'].map(
                (x) => SelectedAddonModel.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartId': cartId,
      'storeId': storeId,
      'operatorId': operatorId,
      'serviceId': serviceId,
      'bundleId': bundleId,
      'quantity': quantity,
      'price': price,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'service': service?.toJson(),
      'bundle': bundle?.toJson(),
      'selectedAddons': selectedAddons?.map((x) => x.toJson()).toList(),
    };
  }
}

class CartServiceModel {
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

  CartServiceModel({
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
  });

  factory CartServiceModel.fromJson(Map<String, dynamic> json) {
    return CartServiceModel(
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
    };
  }
}

class CartBundleModel {
  final String? id;
  final String? operatorId;
  final String? name;
  final String? description;
  final String? image;
  final String? bundlePrice;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  CartBundleModel({
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

  factory CartBundleModel.fromJson(Map<String, dynamic> json) {
    return CartBundleModel(
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

class SelectedAddonModel {
  final String? cartItemId;
  final String? addonId;
  final CartAddonModel? addon;

  SelectedAddonModel({
    this.cartItemId,
    this.addonId,
    this.addon,
  });

  factory SelectedAddonModel.fromJson(Map<String, dynamic> json) {
    return SelectedAddonModel(
      cartItemId: json['cartItemId'],
      addonId: json['addonId'],
      addon: json['addon'] != null
          ? CartAddonModel.fromJson(json['addon'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'addonId': addonId,
      'addon': addon?.toJson(),
    };
  }
}

class CartAddonModel {
  final String? id;
  final String? operatorId;
  final String? name;
  final String? description;
  final String? price;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  CartAddonModel({
    this.id,
    this.operatorId,
    this.name,
    this.description,
    this.price,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CartAddonModel.fromJson(Map<String, dynamic> json) {
    return CartAddonModel(
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