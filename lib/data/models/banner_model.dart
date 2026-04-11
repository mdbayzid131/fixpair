class BannerResponseModel {
  final bool? success;
  final String? message;
  final List<BannerData>? data;

  BannerResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory BannerResponseModel.fromJson(Map<String, dynamic> json) {
    return BannerResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<BannerData>.from(
              json['data'].map((x) => BannerData.fromJson(x)),
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

class BannerData {
  final String? id;
  final String? title;
  final String? description;
  final String? buttonText;
  final String? bannerType;
  final String? backgroundColor;
  final String? textColor;
  final bool? isActive;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  BannerData({
    this.id,
    this.title,
    this.description,
    this.buttonText,
    this.bannerType,
    this.backgroundColor,
    this.textColor,
    this.isActive,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      buttonText: json['buttonText'],
      bannerType: json['bannerType'],
      backgroundColor: json['backgroundColor'],
      textColor: json['textColor'],
      isActive: json['isActive'],
      image: json['image'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'buttonText': buttonText,
      'bannerType': bannerType,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'isActive': isActive,
      'image': image,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}