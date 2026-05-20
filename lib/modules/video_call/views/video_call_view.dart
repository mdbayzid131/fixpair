import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
        // Show consultant in full screen
        if (controller.remoteUid.value != 0) {
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
            'Waiting for consultant to join...',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Timing & charging will start when they join',
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
      color: const Color(0xFF0F172A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130.w,
                height: 130.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.2),
                    width: 4,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 54.r,
                backgroundColor: const Color(0xFF1E293B),
                child: Text(
                  'YOU',
                  style: GoogleFonts.manrope(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.videocam_off_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'Your camera is turned off',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteVideoMutedPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0F172A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130.w,
                height: 130.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.2),
                    width: 4,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 54.r,
                backgroundColor: const Color(0xFF1E293B),
                backgroundImage:
                    controller.booking.consultant?.avatar != null &&
                        controller.booking.consultant!.avatar!.isNotEmpty
                    ? NetworkImage(controller.booking.consultant!.avatar!)
                    : null,
                child:
                    controller.booking.consultant?.avatar == null ||
                        controller.booking.consultant!.avatar!.isEmpty
                    ? Text(
                        controller.booking.consultant?.name
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'C',
                        style: GoogleFonts.manrope(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF94A3B8),
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.videocam_off_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            '${controller.booking.consultant?.name ?? 'Consultant'} turned camera off',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Audio is still active',
            style: GoogleFonts.manrope(
              color: const Color(0xFF94A3B8),
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
                  waiting ? "PAUSED" : controller.formattedTime,
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
        Column(
          children: [
            Text(
              controller.booking.consultant?.name ?? 'Consultant',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              controller.booking.consultant?.tags?.toUpperCase() ??
                  'CONSULTATION',
              style: GoogleFonts.manrope(
                color: Colors.white54,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),

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
    return controller.isCameraOn.value
        ? AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: controller.engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          )
        : Container(
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
                  'Camera off',
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
    if (controller.remoteUid.value == 0) {
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
                  'Cam Off',
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

  Widget _buildBottomControls() {
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

        // Camera Toggle
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


        // Switch Camera (Flip)
        _buildStaticControlButton(
          icon: Icons.flip_camera_ios_rounded,
          onTap: () => controller.switchCamera(),
        ),
      ],
    );
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
