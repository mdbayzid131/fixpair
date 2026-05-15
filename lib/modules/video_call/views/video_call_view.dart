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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Consultant Video (Background)
          _buildConsultantVideo(),

          // 2. Top Bar (Timer, Info, Cost)
          Positioned(
            top: 50.h,
            left: 20.w,
            right: 20.w,
            child: _buildTopOverlay(),
          ),

          // 3. User Video (PiP)
          Positioned(
            bottom: 120.h,
            right: 20.w,
            child: _buildUserPiP(),
          ),

          // 4. Bottom Controls
          Positioned(
            bottom: 40.h,
            left: 20.w,
            right: 20.w,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultantVideo() {
    return Obx(() {
      if (controller.remoteUid.value != 0) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: controller.engine,
            canvas: VideoCanvas(uid: controller.remoteUid.value),
            connection: RtcConnection(channelId: controller.channelName),
          ),
        );
      } else {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20.h),
              Text(
                'Waiting for consultant...',
                style: GoogleFonts.manrope(color: Colors.white70, fontSize: 16.sp),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildTopOverlay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Timer
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Obx(() => Text(
                controller.formattedTime,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              )),
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
            Text(
              controller.booking.consultant?.tags?.toUpperCase() ?? 'TAX CONSULTATION',
              style: GoogleFonts.manrope(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),

        // Cost Indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B00), Color(0xFFFF8A00)],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B00).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Obx(() => Text(
                    '${controller.currentCost.value.toStringAsFixed(2)}€',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserPiP() {
    return Obx(() {
      if (controller.isJoined.value) {
        return Container(
          width: 100.w,
          height: 140.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: controller.engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.mic_rounded,
          onTap: () => controller.toggleMic(),
          isToggled: controller.isMicOn,
        ),
        _buildControlButton(
          icon: Icons.videocam_rounded,
          onTap: () => controller.toggleCamera(),
          isToggled: controller.isCameraOn,
        ),
        // Hang up button
        GestureDetector(
          onTap: () => controller.endCall(),
          child: Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3B30).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.call_end_rounded, color: Colors.white, size: 32.sp),
          ),
        ),
        _buildControlButton(
          icon: Icons.more_vert_rounded,
          onTap: () {},
          isToggled: true.obs, // Always on style for this
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required RxBool isToggled,
  }) {
    return Obx(() => GestureDetector(
          onTap: onTap,
          child: Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: isToggled.value 
                  ? Colors.white.withOpacity(0.15) 
                  : Colors.white.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26.sp,
            ),
          ),
        ));
  }
}
