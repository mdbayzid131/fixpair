import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/data/models/review_model.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SeeAllReviewsView extends StatefulWidget {
  final String consultantId;

  const SeeAllReviewsView({super.key, required this.consultantId});

  @override
  State<SeeAllReviewsView> createState() => _SeeAllReviewsViewState();
}

class _SeeAllReviewsViewState extends State<SeeAllReviewsView> {
  final UserRepository _userRepository = Get.find();
  final ScrollController _scrollController = ScrollController();

  final List<ReviewModel> _reviewsList = [];
  ConsultantStats? _stats;
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _fetchReviews();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_hasMore && !_isLoadingMore && !_isLoading) {
          _fetchReviews(isLoadMore: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await _userRepository.getConsultantStats(widget.consultantId);
      if (response.statusCode == 200) {
        setState(() {
          _stats = ConsultantStats.fromJson(response.data['data']);
        });
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching stats in reviews view: $e');
    }
  }

  Future<void> _fetchReviews({bool isLoadMore = false}) async {
    try {
      if (isLoadMore) {
        setState(() => _isLoadingMore = true);
        _currentPage++;
      } else {
        setState(() {
          _isLoading = true;
          _reviewsList.clear();
          _currentPage = 1;
          _hasMore = true;
        });
      }

      final response = await _userRepository.getConsultantReviews(
        widget.consultantId,
        page: _currentPage,
        limit: 10,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<ReviewModel> fetchedReviews =
            data.map((e) => ReviewModel.fromJson(e)).toList();

        setState(() {
          _reviewsList.addAll(fetchedReviews);
          
          if (response.data['pagination'] != null) {
            final pagination = response.data['pagination'];
            final totalPage = pagination['totalPage'] ?? 1;
            _hasMore = _currentPage < totalPage;
          } else {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching reviews: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1D293D)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Reviews & Ratings',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchStats();
          await _fetchReviews();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Rating breakdown card header
            SliverToBoxAdapter(
              child: _buildBreakdownHeader(),
            ),
            
            // List of reviews
            if (_isLoading && _reviewsList.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_reviewsList.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 64.sp,
                        color: const Color(0x8094A3B8),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No reviews yet',
                        style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _reviewsList.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }
                      final review = _reviewsList[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: _buildReviewItem(review),
                      );
                    },
                    childCount: _reviewsList.length + (_isLoadingMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownHeader() {
    final double avgRating = _stats?.avgRating ?? 0.0;
    final int totalReviews = _stats?.totalReviews ?? 0;

    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: GoogleFonts.manrope(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D293D),
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star_rounded,
                      color: index < avgRating.round() ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                      size: 18.sp,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '$totalReviews ${totalReviews == 1 ? 'Review' : 'Reviews'}',
                  style: GoogleFonts.manrope(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 80.h,
            width: 1.w,
            color: const Color(0xFFE2E8F0),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildRatingBar(5, avgRating >= 4.5 ? 1.0 : (avgRating >= 4.0 ? 0.8 : 0.2)),
                SizedBox(height: 4.h),
                _buildRatingBar(4, avgRating >= 3.5 && avgRating < 4.5 ? 0.7 : 0.1),
                SizedBox(height: 4.h),
                _buildRatingBar(3, 0.05),
                SizedBox(height: 4.h),
                _buildRatingBar(2, 0.0),
                SizedBox(height: 4.h),
                _buildRatingBar(1, 0.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double value) {
    return Row(
      children: [
        Text(
          '$star',
          style: GoogleFonts.manrope(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
        SizedBox(width: 4.w),
        Icon(Icons.star_rounded, color: const Color(0xFFF59E0B), size: 12.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    final imageUrl = ApiConstants.getImageUrl(review.user?.image);
    final ratingCount = (review.rating ?? 5.0).toInt();

    String timeStr = 'Some time ago';
    if (review.createdAt != null) {
      final difference = DateTime.now().difference(review.createdAt!);
      if (difference.inDays == 0) {
        timeStr = 'Today';
      } else if (difference.inDays == 1) {
        timeStr = '1 day ago';
      } else if (difference.inDays < 7) {
        timeStr = '${difference.inDays} days ago';
      } else {
        timeStr = DateFormat('MMM dd, yyyy').format(review.createdAt!);
      }
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty ? const Icon(Icons.person, color: Color(0xFF64748B)) : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user?.name ?? 'Anonymous User',
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D293D),
                      ),
                    ),
                    Text(
                      timeStr,
                      style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    color: index < ratingCount ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            review.comment ?? 'No comment provided.',
            style: GoogleFonts.manrope(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
