class NotificationModel {
  final String? id;
  final String? user;
  final String? title;
  final String? message;
  final String? type;
  final String? relatedBooking;
  final bool read;
  final NotificationMetadata? metadata;
  final String? createdAt;
  final String? updatedAt;

  NotificationModel({
    this.id,
    this.user,
    this.title,
    this.message,
    this.type,
    this.relatedBooking,
    this.read = false,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? json['_id'],
      user: json['user'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      relatedBooking: json['relatedBooking'],
      read: json['read'] ?? false,
      metadata: json['metadata'] != null
          ? NotificationMetadata.fromJson(json['metadata'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class NotificationMetadata {
  final String? consultantName;
  final String? status;
  final String? date;
  final String? time;

  NotificationMetadata({
    this.consultantName,
    this.status,
    this.date,
    this.time,
  });

  factory NotificationMetadata.fromJson(Map<String, dynamic> json) {
    return NotificationMetadata(
      consultantName: json['consultantName'],
      status: json['status'],
      date: json['date'],
      time: json['time'],
    );
  }
}

class NotificationResponseModel {
  final bool? success;
  final String? message;
  final List<NotificationModel>? data;
  final NotificationPagination? pagination;

  NotificationResponseModel({
    this.success,
    this.message,
    this.data,
    this.pagination,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<NotificationModel>.from(
              json['data'].map((x) => NotificationModel.fromJson(x)),
            )
          : null,
      pagination: json['pagination'] != null
          ? NotificationPagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class NotificationPagination {
  final int? total;
  final int? limit;
  final int? page;
  final int? totalPage;

  NotificationPagination({this.total, this.limit, this.page, this.totalPage});

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      total: json['total'],
      limit: json['limit'],
      page: json['page'],
      totalPage: json['totalPage'],
    );
  }
}
