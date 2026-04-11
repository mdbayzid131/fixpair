class OperatorCategoryResponseModel {
  final bool? success;
  final String? message;
  final OperatorCategoryMeta? meta;
  final List<OperatorCategoryData>? data;

  OperatorCategoryResponseModel({
    this.success,
    this.message,
    this.meta,
    this.data,
  });

  factory OperatorCategoryResponseModel.fromJson(
      Map<String, dynamic> json) {
    return OperatorCategoryResponseModel(
      success: json['success'],
      message: json['message'],
      meta: json['meta'] != null
          ? OperatorCategoryMeta.fromJson(json['meta'])
          : null,
      data: json['data'] != null
          ? List<OperatorCategoryData>.from(
              json['data'].map((x) => OperatorCategoryData.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'meta': meta?.toJson(),
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class OperatorCategoryMeta {
  final int? total;
  final int? totalPage;
  final int? page;
  final int? limit;

  OperatorCategoryMeta({
    this.total,
    this.totalPage,
    this.page,
    this.limit,
  });

  factory OperatorCategoryMeta.fromJson(Map<String, dynamic> json) {
    return OperatorCategoryMeta(
      total: json['total'],
      totalPage: json['totalPage'],
      page: json['page'],
      limit: json['limit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'totalPage': totalPage,
      'page': page,
      'limit': limit,
    };
  }
}

class OperatorCategoryData {
  final String? id;
  final String? operatorId;
  final String? categoryId;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final CategoryModel? category;

  OperatorCategoryData({
    this.id,
    this.operatorId,
    this.categoryId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  factory OperatorCategoryData.fromJson(Map<String, dynamic> json) {
    return OperatorCategoryData(
      id: json['id'],
      operatorId: json['operatorId'],
      categoryId: json['categoryId'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operatorId': operatorId,
      'categoryId': categoryId,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'category': category?.toJson(),
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

