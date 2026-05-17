class ReviewModel {
  final String? id;
  final ReviewUser? user;
  final String? consultant;
  final String? consultation;
  final double? rating;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    this.id,
    this.user,
    this.consultant,
    this.consultation,
    this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? json['id'],
      user: json['user'] != null ? ReviewUser.fromJson(json['user']) : null,
      consultant: json['consultant']?.toString(),
      consultation: json['consultation']?.toString(),
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : 0.0,
      comment: json['comment']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user?.toJson(),
      'consultant': consultant,
      'consultation': consultation,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ReviewUser {
  final String? id;
  final String? name;
  final String? image;
  final String? avatar;

  ReviewUser({this.id, this.name, this.image, this.avatar});

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['_id'] ?? json['id'],
      name: json['name']?.toString(),
      image: json['image']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'avatar': avatar,
    };
  }
}
