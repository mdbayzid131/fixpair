class CategoriesResponseModel {
  final bool? success;
  final String? message;
  final List<CategoryData>? data;

  CategoriesResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory CategoriesResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoriesResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<CategoryData>.from(
              json['data'].map((x) => CategoryData.fromJson(x)),
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

class CategoryData {
  final String? id;
  final String? name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  CategoryData({
    this.id,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}