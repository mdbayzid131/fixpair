import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import '../controllers/video_call_controller.dart';

class VideoCallView extends GetView<VideoCallController> {
  const VideoCallView({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPipMode =
        mediaQuery.size.width < 280 || mediaQuery.size.height < 280;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.minimizeCall();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF090D16), // Premium dark theme
        body: Stack(
          children: [
            // 1. Full Screen Video (Background)
            _buildBackgroundVideo(),

            // 2. Top Bar (Timer, Info, Cost)
            if (!isPipMode)
              Positioned(
                top: 50.h,
                left: 20.w,
                right: 20.w,
                child: _buildTopOverlay(),
              ),

            // 3. User Video (PiP Window)
            if (!isPipMode) _buildUserPiP(),

            // 4. Bottom Controls
            if (!isPipMode)
              Positioned(
                bottom: 40.h,
                left: 20.w,
                right: 20.w,
                child: _buildBottomControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundVideo() {
    return Obx(() {
      if (!controller.isEngineInitialized.value) {
        return _buildWaitingPlaceholder();
      }
      final isLocalFull = controller.isLocalUserFullScreen.value;
      if (isLocalFull) {
        // Show client (local user) in full screen
        if (!controller.isCameraOn.value) {
          return _buildLocalVideoMutedBackgroundPlaceholder();
        }
        return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: controller.engine,
            canvas: const VideoCanvas(uid: 0),
          ),
        );
      } else {
        // Show consultant / remote user in full screen
        if (controller.remoteUid.value != 0) {
          if (controller.isConsultant.value) {
            // Consultant watching Customer's camera stream
            if (controller.isRemoteVideoMuted.value) {
              return _buildRemoteVideoMutedPlaceholder();
            }
            return AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: controller.engine,
                canvas: VideoCanvas(uid: controller.remoteUid.value),
                connection: RtcConnection(channelId: controller.channelName),
              ),
            );
          } else {
            // Customer viewing Consultant (Consultant camera is permanently OFF, show avatar)
            return _buildRemoteVideoMutedPlaceholder();
          }
        } else {
          return _buildWaitingPlaceholder();
        }
      }
    });
  }

  Widget _buildWaitingPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Beautiful animated-like glowing circle
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1.5,
              ),
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF22C55E),
              strokeWidth: 3.5,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Waiting for consultant to join...'.tr,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Timing & charging will start when they join'.tr,
            style: GoogleFonts.manrope(
              color: Colors.white54,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalVideoMutedBackgroundPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Obx(() {
        final localAvatarUrl = _getLocalUserAvatarUrl();
        final authService = Get.find<AuthService>();
        final userName = authService.user.value?.name ?? 'YOU'.tr;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 118.w,
                  height: 118.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: localAvatarUrl != null && localAvatarUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ApiConstants.getImageUrl(localAvatarUrl),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Text(
                                userName.substring(0, 1).toUpperCase(),
                                style: GoogleFonts.manrope(
                                  fontSize: 38.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              userName.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 38.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0F172A),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.videocam_off_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'Your camera is turned off'.tr,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRemoteVideoMutedPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Obx(() {
        final booking = controller.bookingRx.value ?? controller.booking;
        final consultantName =
            _getValidConsultantName(booking.consultant?.name);
        final avatarUrl = _getRemoteUserAvatarUrl();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF22C55E).withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 118.w,
                  height: 118.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ApiConstants.getImageUrl(avatarUrl),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Text(
                                consultantName.substring(0, 1).toUpperCase(),
                                style: GoogleFonts.manrope(
                                  fontSize: 38.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              consultantName.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 38.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0F172A),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              consultantName,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Audio active'.tr,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF94A3B8),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  String _getValidConsultantName(String? name) {
    if (name == null) return 'Consultant'.tr;
    final n = name.trim().toLowerCase();
    if (n.isEmpty ||
        n == 'a user' ||
        n == 'user' ||
        n == 'notification' ||
        n == 'null' ||
        n == 'undefined' ||
        n == 'fixpair') {
      return 'Consultant'.tr;
    }
    return name.trim();
  }

  String? _getUserAvatarUrl(UserData? user) {
    if (user == null) return null;
    if (user.image != null && user.image!.trim().isNotEmpty) {
      return user.image!.trim();
    }
    if (user.avatar != null && user.avatar!.trim().isNotEmpty) {
      return user.avatar!.trim();
    }
    return null;
  }

  String? _getLocalUserAvatarUrl() {
    try {
      final authService = Get.find<AuthService>();
      final currentUser = authService.user.value;
      final urlFromAuth = _getUserAvatarUrl(currentUser);
      if (urlFromAuth != null) return urlFromAuth;
    } catch (_) {}

    final booking = controller.bookingRx.value ?? controller.booking;
    if (controller.isConsultant.value) {
      return _getUserAvatarUrl(booking.consultant);
    } else {
      return _getUserAvatarUrl(booking.user);
    }
  }

  String? _getRemoteUserAvatarUrl() {
    final booking = controller.bookingRx.value ?? controller.booking;
    if (controller.isConsultant.value) {
      return _getUserAvatarUrl(booking.user);
    } else {
      return _getUserAvatarUrl(booking.consultant);
    }
  }

  Widget _buildTopOverlay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Minimize Button
        GestureDetector(
          onTap: () => controller.minimizeCall(),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.85),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ),

        // Timer with State indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.85),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: Obx(() {
            final waiting = controller.remoteUid.value == 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: waiting
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: waiting
                            ? const Color(0xFFEF4444).withOpacity(0.5)
                            : const Color(0xFF22C55E).withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  waiting ? "PAUSED".tr : controller.formattedTime,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: waiting ? 0.8 : 0.2,
                  ),
                ),
              ],
            );
          }),
        ),

        // Consultant Info
        Obx(() {
          final booking = controller.bookingRx.value ?? controller.booking;
          final consultantName = _getValidConsultantName(booking.consultant?.name);
          return Column(
            children: [
              Text(
                consultantName,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                booking.consultant?.tags?.toUpperCase() ??
                    'CONSULTATION',
                style: GoogleFonts.manrope(
                  color: Colors.white54,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          );
        }),

        // Cost Indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF22C55E), Color(0xFF15803D)],
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Obx(
            () => Text(
              '${controller.currentCost.value.toStringAsFixed(2)}€',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserPiP() {
    return Obx(() {
      if (controller.isJoined.value) {
        final isLocalFull = controller.isLocalUserFullScreen.value;
        return Positioned(
          left: controller.pipLeft.value,
          top: controller.pipTop.value,
          child: GestureDetector(
            onPanUpdate: (details) {
              controller.updatePipPosition(details.delta.dx, details.delta.dy);
            },
            onDoubleTap: () {
              controller.toggleFullScreenView();
            },
            child: Container(
              width: 95.w,
              height: 135.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: isLocalFull
                    ? _buildRemotePiPView()
                    : _buildLocalPiPView(),
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildLocalPiPView() {
    if (!controller.isEngineInitialized.value) {
      return Container(
        color: const Color(0xFF1E293B),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF22C55E),
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (controller.isCameraOn.value) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: controller.engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    }

    final localAvatarUrl = _getLocalUserAvatarUrl();
    final authService = Get.find<AuthService>();
    final userName = authService.user.value?.name ?? 'YOU';

    return Container(
      color: const Color(0xFF0F172A),
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFEF4444),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: localAvatarUrl != null && localAvatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ApiConstants.getImageUrl(localAvatarUrl),
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Center(
                        child: Text(
                          userName.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        userName.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.manrope(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Cam Off'.tr,
            style: GoogleFonts.manrope(
              color: Colors.white70,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemotePiPView() {
    if (!controller.isEngineInitialized.value || controller.remoteUid.value == 0) {
      return Container(
        color: const Color(0xFF0F172A),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(
                color: Color(0xFF22C55E),
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Connecting...'.tr,
              style: GoogleFonts.manrope(
                color: Colors.white70,
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.isConsultant.value) {
      return controller.isRemoteVideoMuted.value
          ? Container(
              color: const Color(0xFF1E293B),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_off_rounded,
                    color: const Color(0xFFEF4444),
                    size: 24.sp,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Cam Off'.tr,
                    style: GoogleFonts.manrope(
                      color: Colors.white70,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: controller.engine,
                canvas: VideoCanvas(uid: controller.remoteUid.value),
                connection: RtcConnection(channelId: controller.channelName),
              ),
            );
    }

    return Obx(() {
      final booking = controller.bookingRx.value ?? controller.booking;
      final consultantName =
          _getValidConsultantName(booking.consultant?.name);
      final avatarUrl = _getRemoteUserAvatarUrl();

      return Container(
        color: const Color(0xFF0F172A),
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF22C55E),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: ApiConstants.getImageUrl(avatarUrl),
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            consultantName.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.manrope(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          consultantName.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                consultantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mic_rounded,
                  color: const Color(0xFF22C55E),
                  size: 10.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Audio'.tr,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF94A3B8),
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomControls() {
    return Obx(() {
      final isConsultant = controller.isConsultant.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mic Toggle
          _buildToggleControlButton(
            activeIcon: Icons.mic_rounded,
            inactiveIcon: Icons.mic_off_rounded,
            onTap: () => controller.toggleMic(),
            isActive: controller.isMicOn,
          ),

          // Camera Toggle (Customer only)
          if (!isConsultant)
            _buildToggleControlButton(
              activeIcon: Icons.videocam_rounded,
              inactiveIcon: Icons.videocam_off_rounded,
              onTap: () => controller.toggleCamera(),
              isActive: controller.isCameraOn,
            ),

          // Hang up button
          GestureDetector(
            onTap: () => controller.endCall(),
            child: Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.35),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.call_end_rounded,
                color: Colors.white,
                size: 30.sp,
              ),
            ),
          ),

          // Switch Camera (Flip) (Customer only)
          if (!isConsultant)
            _buildStaticControlButton(
              icon: Icons.flip_camera_ios_rounded,
              onTap: () => controller.switchCamera(),
            ),
        ],
      );
    });
  }

  Widget _buildToggleControlButton({
    required IconData activeIcon,
    required IconData inactiveIcon,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    required RxBool isActive,
  }) {
    return Obx(() {
      final active = isActive.value;
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: 54.w,
          height: 54.w,
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withOpacity(0.12)
                : const Color(0xFFEF4444).withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: active
                  ? Colors.white.withOpacity(0.1)
                  : const Color(0xFFEF4444).withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Icon(
            active ? activeIcon : inactiveIcon,
            color: active ? Colors.white : const Color(0xFFEF4444),
            size: 24.sp,
          ),
        ),
      );
    });
  }

  Widget _buildStaticControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54.w,
        height: 54.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }
}
