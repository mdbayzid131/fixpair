import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/routes/app_pages.dart';
import '../controllers/payment_controller.dart';

class PaymentMethodsView extends GetView<PaymentController> {
  const PaymentMethodsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Payment Methods',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.paymentMethods.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF2563EB),
          onRefresh: controller.fetchPaymentMethods,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            children: [
              // Header Wallet Banner
              _buildWalletHeaderBanner(),

              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Saved Cards',
                    style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${controller.paymentMethods.length} Saved',
                      style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              if (controller.paymentMethods.isEmpty)
                _buildEmptyState()
              else
                ...controller.paymentMethods.map(
                  (method) => _buildRealisticCreditCard(method),
                ),

              SizedBox(height: 24.h),

              _buildAddCardButton(),

              SizedBox(height: 32.h),

              // Supported Payment Partners Footer
              _buildSupportedNetworksFooter(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWalletHeaderBanner() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: const Color(0xFF38BDF8),
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Payment Wallet',
                  style: GoogleFonts.manrope(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      size: 13.sp,
                      color: const Color(0xFF34D399),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'PCI-DSS Compliant & Encrypted',
                      style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealisticCreditCard(dynamic method) {
    final String last4 = (method['last4'] ?? '****').toString();
    final String rawBrand = (method['brand'] ?? 'card').toString().toLowerCase();
    final bool isDefault = method['isDefault'] ?? false;
    final String id = method['methodId'] ?? '';
    final String expMonth = (method['expMonth'] ?? '••').toString().padLeft(2, '0');
    final String expYear = (method['expYear'] ?? '••').toString().length > 2
        ? (method['expYear'] ?? '••').toString().substring(2)
        : (method['expYear'] ?? '••').toString();

    final cardTheme = _getCardTheme(rawBrand);

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: AspectRatio(
        aspectRatio: 1.586, // Standard Physical Credit Card Ratio (85.6mm x 53.98mm)
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: cardTheme.backgroundGradient,
            boxShadow: [
              BoxShadow(
                color: cardTheme.shadowColor.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Stack(
              children: [
                // 1. Glossy Sheen Overlay (Diagonal Glare)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0.05),
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.1),
                        ],
                        stops: const [0.0, 0.35, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),

                // 2. Decorative Watermark Circles / Wave Lines
                Positioned(
                  right: -40.w,
                  bottom: -40.h,
                  child: Container(
                    width: 180.w,
                    height: 180.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),

                // 3. Card Content
                Padding(
                  padding: EdgeInsets.all(22.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: EMV Chip + Contactless Icon & Hologram / Brand Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Realistic Detailed EMV Micro-Chip
                              _buildRealisticEMVChip(),
                              SizedBox(width: 10.w),

                              // Contactless Icon
                              Icon(
                                Icons.wifi_tethering_rounded,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 22.sp,
                              ),
                            ],
                          ),

                          // Brand Official Badge & Holographic Sticker
                          Row(
                            children: [
                              // Holographic Foil Seal
                              Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const SweepGradient(
                                    colors: [
                                      Colors.red,
                                      Colors.yellow,
                                      Colors.green,
                                      Colors.cyan,
                                      Colors.blue,
                                      Colors.purple,
                                      Colors.red,
                                    ],
                                  ),
                                  border: Border.all(color: Colors.white38, width: 1),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              _buildBrandOfficialLogo(rawBrand),
                            ],
                          ),
                        ],
                      ),

                      // Card Masked Number with 3D Embossed Font Effect
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildEmbossedText('••••'),
                          _buildEmbossedText('••••'),
                          _buildEmbossedText('••••'),
                          _buildEmbossedText(last4),
                        ],
                      ),

                      // Bottom Row: Expiry, Default Badge / Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CARD HOLDER',
                                    style: GoogleFonts.manrope(
                                      fontSize: 8.sp,
                                      color: Colors.white54,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'VALUED CUSTOMER',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 20.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'VALID THRU',
                                    style: GoogleFonts.manrope(
                                      fontSize: 8.sp,
                                      color: Colors.white54,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '$expMonth/$expYear',
                                    style: GoogleFonts.shareTechMono(
                                      fontSize: 12.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Default Status Badge or Set Default Action Button
                          if (isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'DEFAULT',
                                    style: GoogleFonts.manrope(
                                      fontSize: 10.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            InkWell(
                              onTap: () => controller.setDefaultCard(id),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: Colors.white38),
                                ),
                                child: Text(
                                  'Set as Default',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Realistic EMV Gold Micro-Chip Widget
  Widget _buildRealisticEMVChip() {
    return Container(
      width: 42.w,
      height: 30.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF6D365),
            Color(0xFFFDA085),
            Color(0xFFD4AF37),
          ],
        ),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFB8860B), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Inner Micro-circuit Lines
          Positioned(
            top: 13.h,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.black38),
          ),
          Positioned(
            left: 14.w,
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: Colors.black38),
          ),
          Positioned(
            left: 28.w,
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: Colors.black38),
          ),
          Center(
            child: Container(
              width: 12.w,
              height: 10.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38, width: 0.8),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Embossed Letterpress Text Generator
  Widget _buildEmbossedText(String text) {
    return Text(
      text,
      style: GoogleFonts.shareTechMono(
        fontSize: 19.sp,
        color: Colors.white,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        shadows: const [
          Shadow(
            offset: Offset(1, 1),
            blurRadius: 1,
            color: Colors.black54,
          ),
          Shadow(
            offset: Offset(-0.5, -0.5),
            blurRadius: 1,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  // Authentic Brand Logo Widgets
  Widget _buildBrandOfficialLogo(String brand) {
    switch (brand) {
      case 'visa':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            'VISA',
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF1A1F71),
              letterSpacing: 1.2,
            ),
          ),
        );

      case 'mastercard':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 26.w,
                height: 16.h,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 16.w,
                        height: 16.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEB001B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 16.w,
                        height: 16.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF79E1B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                'mastercard',
                style: GoogleFonts.manrope(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );

      case 'american_express':
      case 'amex':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: const Color(0xFF006FCF),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: Colors.white),
          ),
          child: Text(
            'AMEX',
            style: GoogleFonts.orbitron(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        );

      case 'discover':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE65100),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            'DISCOVER',
            style: GoogleFonts.manrope(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        );

      default:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.credit_card_rounded, color: Colors.white, size: 14),
              SizedBox(width: 4.w),
              Text(
                brand.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
    }
  }

  _CardTheme _getCardTheme(String brand) {
    switch (brand) {
      case 'visa':
        return _CardTheme(
          backgroundGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A192F),
              Color(0xFF112240),
              Color(0xFF1E3A8A),
              Color(0xFF0F172A),
            ],
          ),
          shadowColor: const Color(0xFF1E3A8A),
        );
      case 'mastercard':
        return _CardTheme(
          backgroundGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F2937),
              Color(0xFF111827),
              Color(0xFF374151),
              Color(0xFF030712),
            ],
          ),
          shadowColor: const Color(0xFF1F2937),
        );
      case 'american_express':
      case 'amex':
        return _CardTheme(
          backgroundGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0284C7),
              Color(0xFF0369A1),
              Color(0xFF075985),
              Color(0xFF0C4A6E),
            ],
          ),
          shadowColor: const Color(0xFF0284C7),
        );
      case 'discover':
        return _CardTheme(
          backgroundGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEA580C),
              Color(0xFFC2410C),
              Color(0xFF9A3412),
              Color(0xFF1F2937),
            ],
          ),
          shadowColor: const Color(0xFFEA580C),
        );
      default:
        return _CardTheme(
          backgroundGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
              Color(0xFF1E40AF),
              Color(0xFF0F172A),
            ],
          ),
          shadowColor: const Color(0xFF2563EB),
        );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.credit_card_off_rounded,
              size: 48.sp,
              color: const Color(0xFF2563EB),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Payment Cards Saved',
            style: GoogleFonts.manrope(
              fontSize: 17.sp,
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Add your credit or debit card to make fast & seamless bookings.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.ADD_CARD),
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_card_rounded, color: Colors.white),
              SizedBox(width: 10.w),
              Text(
                'Add Credit Card',
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportedNetworksFooter() {
    return Column(
      children: [
        Text(
          'ACCEPTED CREDIT CARDS',
          style: GoogleFonts.manrope(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMiniBadge('VISA', const Color(0xFF1A1F71)),
            SizedBox(width: 8.w),
            _buildMiniBadge('MASTERCARD', const Color(0xFFEB001B)),
            SizedBox(width: 8.w),
            _buildMiniBadge('AMEX', const Color(0xFF006FCF)),
            SizedBox(width: 8.w),
            _buildMiniBadge('DISCOVER', const Color(0xFFE65100)),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _CardTheme {
  final LinearGradient backgroundGradient;
  final Color shadowColor;

  _CardTheme({
    required this.backgroundGradient,
    required this.shadowColor,
  });
}
