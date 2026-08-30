import 'package:intl/intl.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/config/constants/api_constants.dart';

class ReportModel {
  final String? id;
  final String? sId;
  final AiSummaryModel? aiSummary;
  final ReportConsultationInfo? consultation;
  final UserData? user;
  final UserData? consultant;
  final String? summary;
  final List<String> keyPoints;
  final List<String> stepsTaken;
  final List<RecommendedProductModel> recommendedProducts;
  final String? conversation;
  final num? duration; // duration in seconds or minutes
  final String? notes;
  final List<String> images;
  final List<String> links;
  final String? pdfUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReportModel({
    this.id,
    this.sId,
    this.aiSummary,
    this.consultation,
    this.user,
    this.consultant,
    this.summary,
    this.keyPoints = const [],
    this.stepsTaken = const [],
    this.recommendedProducts = const [],
    this.conversation,
    this.duration,
    this.notes,
    this.images = const [],
    this.links = const [],
    this.pdfUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? json['_id'] as String?,
      sId: json['_id'] as String?,
      aiSummary: json['aiSummary'] != null
          ? AiSummaryModel.fromJson(json['aiSummary'])
          : null,
      consultation: json['consultation'] != null
          ? ReportConsultationInfo.fromJson(json['consultation'])
          : null,
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
      consultant: json['consultant'] != null
          ? UserData.fromJson(json['consultant'])
          : null,
      summary: json['summary'] as String?,
      keyPoints: json['keyPoints'] != null
          ? List<String>.from(json['keyPoints'].map((x) => x.toString()))
          : [],
      stepsTaken: json['stepsTaken'] != null
          ? List<String>.from(json['stepsTaken'].map((x) => x.toString()))
          : [],
      recommendedProducts: json['recommendedProducts'] != null
          ? List<RecommendedProductModel>.from(
              (json['recommendedProducts'] as List).map(
                (x) => RecommendedProductModel.fromJson(x),
              ),
            )
          : [],
      conversation: json['conversation'] as String?,
      duration: json['duration'] as num?,
      notes: json['notes'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'].map((x) => x.toString()))
          : [],
      links: json['links'] != null
          ? List<String>.from(json['links'].map((x) => x.toString()))
          : [],
      pdfUrl: json['pdfUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  String get formattedDate {
    if (createdAt == null) return 'N/A';
    return DateFormat('MMMM dd, yyyy').format(createdAt!);
  }

  String get formattedDuration {
    if (duration == null || duration == 0) return '0 min 0 sec';
    final int dur = duration!.toInt();
    if (dur >= 60) {
      final int min = dur ~/ 60;
      final int sec = dur % 60;
      return '$min min $sec sec';
    } else {
      return '0 min $dur sec';
    }
  }

  String get fullPdfUrl {
    if (pdfUrl == null || pdfUrl!.isEmpty) return '';
    return ApiConstants.getImageUrl(pdfUrl);
  }
}

class AiSummaryModel {
  final String? overview;
  final List<String> keyPoints;
  final List<String> actionItems;
  final List<String> recommendations;

  AiSummaryModel({
    this.overview,
    this.keyPoints = const [],
    this.actionItems = const [],
    this.recommendations = const [],
  });

  factory AiSummaryModel.fromJson(Map<String, dynamic> json) {
    return AiSummaryModel(
      overview: json['overview'] as String?,
      keyPoints: json['keyPoints'] != null
          ? List<String>.from(json['keyPoints'].map((x) => x.toString()))
          : [],
      actionItems: json['actionItems'] != null
          ? List<String>.from(json['actionItems'].map((x) => x.toString()))
          : [],
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'].map((x) => x.toString()))
          : [],
    );
  }
}

class ReportConsultationInfo {
  final String? id;
  final String? bookingType;
  final num? perMinuteRate;
  final String? status;

  ReportConsultationInfo({
    this.id,
    this.bookingType,
    this.perMinuteRate,
    this.status,
  });

  factory ReportConsultationInfo.fromJson(Map<String, dynamic> json) {
    return ReportConsultationInfo(
      id: json['id'] as String? ?? json['_id'] as String?,
      bookingType: json['bookingType'] as String?,
      perMinuteRate: json['perMinuteRate'] as num?,
      status: json['status'] as String?,
    );
  }
}

class RecommendedProductModel {
  final String? name;
  final String? image;
  final num? price;
  final String? link;

  RecommendedProductModel({
    this.name,
    this.image,
    this.price,
    this.link,
  });

  factory RecommendedProductModel.fromJson(Map<String, dynamic> json) {
    return RecommendedProductModel(
      name: json['name'] as String? ?? json['title'] as String?,
      image: json['image'] as String? ?? json['imageUrl'] as String?,
      price: json['price'] as num?,
      link: json['link'] as String? ?? json['buyUrl'] as String?,
    );
  }
}
