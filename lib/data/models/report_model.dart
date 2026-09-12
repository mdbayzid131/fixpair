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
      id: json['id']?.toString() ?? json['_id']?.toString(),
      sId: json['_id']?.toString(),
      aiSummary: json['aiSummary'] != null && json['aiSummary'] is Map<String, dynamic>
          ? AiSummaryModel.fromJson(json['aiSummary'] as Map<String, dynamic>)
          : null,
      consultation: json['consultation'] != null && json['consultation'] is Map<String, dynamic>
          ? ReportConsultationInfo.fromJson(json['consultation'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserData.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      consultant: json['consultant'] != null && json['consultant'] is Map<String, dynamic>
          ? UserData.fromJson(json['consultant'] as Map<String, dynamic>)
          : null,
      summary: json['summary']?.toString(),
      keyPoints: json['keyPoints'] != null && json['keyPoints'] is List
          ? List<String>.from((json['keyPoints'] as List).map((x) => x.toString()))
          : [],
      stepsTaken: json['stepsTaken'] != null && json['stepsTaken'] is List
          ? List<String>.from((json['stepsTaken'] as List).map((x) => x.toString()))
          : [],
      recommendedProducts: json['recommendedProducts'] != null &&
              json['recommendedProducts'] is List
          ? List<RecommendedProductModel>.from(
              (json['recommendedProducts'] as List)
                  .where((x) => x is Map<String, dynamic>)
                  .map(
                    (x) => RecommendedProductModel.fromJson(
                      x as Map<String, dynamic>,
                    ),
                  ),
            )
          : [],
      conversation: json['conversation']?.toString(),
      duration: json['duration'] is num
          ? json['duration'] as num
          : (json['duration'] != null
              ? num.tryParse(json['duration'].toString())
              : null),
      notes: json['notes']?.toString(),
      images: json['images'] != null && json['images'] is List
          ? List<String>.from((json['images'] as List).map((x) => x.toString()))
          : [],
      links: json['links'] != null && json['links'] is List
          ? List<String>.from((json['links'] as List).map((x) => x.toString()))
          : [],
      pdfUrl: json['pdfUrl']?.toString(),
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
      overview: json['overview']?.toString(),
      keyPoints: json['keyPoints'] != null && json['keyPoints'] is List
          ? List<String>.from((json['keyPoints'] as List).map((x) => x.toString()))
          : [],
      actionItems: json['actionItems'] != null && json['actionItems'] is List
          ? List<String>.from((json['actionItems'] as List).map((x) => x.toString()))
          : [],
      recommendations: json['recommendations'] != null &&
              json['recommendations'] is List
          ? List<String>.from((json['recommendations'] as List).map((x) => x.toString()))
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
      id: json['id']?.toString() ?? json['_id']?.toString(),
      bookingType: json['bookingType']?.toString(),
      perMinuteRate: json['perMinuteRate'] is num
          ? json['perMinuteRate'] as num
          : (json['perMinuteRate'] != null
              ? num.tryParse(json['perMinuteRate'].toString())
              : null),
      status: json['status']?.toString(),
    );
  }
}

class RecommendedProductModel {
  final String? id;
  final String? name;
  final String? image;
  final dynamic price;
  final String? link;

  RecommendedProductModel({
    this.id,
    this.name,
    this.image,
    this.price,
    this.link,
  });

  factory RecommendedProductModel.fromJson(Map<String, dynamic> json) {
    return RecommendedProductModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name']?.toString() ?? json['title']?.toString(),
      image: json['image']?.toString() ?? json['imageUrl']?.toString(),
      price: json['price'],
      link: json['link']?.toString() ??
          json['buyLink']?.toString() ??
          json['buyUrl']?.toString(),
    );
  }

  String get formattedPrice {
    if (price == null || price.toString().trim().isEmpty) return '';
    final str = price.toString().trim();
    final parsed = num.tryParse(str);
    if (parsed != null) {
      return '€${parsed.toStringAsFixed(2)}';
    }
    if (str.startsWith('€') || str.startsWith('\$') || str.startsWith('£')) {
      return str;
    }
    return '€$str';
  }
}
