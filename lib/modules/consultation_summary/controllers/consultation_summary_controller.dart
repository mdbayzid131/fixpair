import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/models/invoice_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/config/routes/app_pages.dart';

class ConsultationSummaryController extends GetxController {
  final UserRepository _userRepository = Get.find();

  final rating = 0.obs;
  final reviewController = TextEditingController();

  BookingModel? booking;
  final consultantName = ''.obs;
  final date = ''.obs;
  final duration = ''.obs;
  final rate = ''.obs;
  final subtotal = ''.obs;
  final platformFee = ''.obs;
  final vat = ''.obs;
  final totalCharged = ''.obs;
  final invoiceNo = ''.obs;

  final isLoadingInvoice = false.obs;
  final isSubmittingReview = false.obs;
  final invoiceData = Rxn<InvoiceModel>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      final bookingArg = args['booking'];
      if (bookingArg != null && bookingArg is BookingModel) {
        booking = bookingArg;
        consultantName.value = booking?.consultant?.name ?? 'Consultant';
        if (booking?.id != null) {
          fetchInvoice(booking!.id!);
        }
      }
    }
  }

  Future<void> fetchInvoice(String consultationId) async {
    try {
      isLoadingInvoice.value = true;
      final response = await _userRepository.getInvoice(consultationId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data != null) {
          final invoice = InvoiceModel.fromJson(data);
          invoiceData.value = invoice;

          // Update display values
          invoiceNo.value = invoice.invoiceNumber;
          date.value = invoice.invoiceDate.isNotEmpty
              ? DateFormat('dd.MM.yyyy').format(
                  DateTime.tryParse(invoice.invoiceDate) ?? DateTime.now(),
                )
              : DateFormat('dd.MM.yyyy').format(DateTime.now());

          duration.value = invoice.billableMinutes != null
              ? '${invoice.billableMinutes} min'
              : '0 min';

          rate.value = '€${invoice.perMinuteRate.toStringAsFixed(2)} / min';
          subtotal.value = '€${invoice.subtotal.toStringAsFixed(2)}';
          platformFee.value = '€${invoice.platformFee.toStringAsFixed(2)}';

          final num calculatedVat =
              invoice.totalAmount - (invoice.subtotal + invoice.platformFee);
          vat.value = '€${calculatedVat.toStringAsFixed(2)}';
          totalCharged.value = '€${invoice.totalAmount.toStringAsFixed(2)}';
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching invoice: $e');
    } finally {
      isLoadingInvoice.value = false;
    }
  }

  void setRating(int value) => rating.value = value;

  Future<void> submitReview() async {
    if (booking == null || booking!.id == null) {
      Helpers.showCustomSnackBar(
        'Invalid booking details',
        type: SnackBarType.error,
        useGetxSnackbar: false,
      );
      return;
    }
    if (rating.value == 0) {
      Helpers.showCustomSnackBar(
        'Please select a star rating first',
        type: SnackBarType.warning,
        useGetxSnackbar: false,
      );
      return;
    }

    try {
      isSubmittingReview.value = true;
      Helpers.showLoadingDialog(message: 'Submitting review...');

      final response = await _userRepository.postReview(
        consultationId: booking!.id!,
        rating: rating.value.toDouble(),
        comment: reviewController.text,
      );

      Helpers.hideLoadingDialog();
      if (response.statusCode == 200 || response.statusCode == 201) {
        Helpers.showCustomSnackBar(
          'Thank you for your feedback!',
          type: SnackBarType.success,
          useGetxSnackbar: false,
        );
        Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
      }
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showDebugLog('Error submitting review: $e');
      Helpers.showCustomSnackBar(
        'Failed to submit review',
        type: SnackBarType.error,
        useGetxSnackbar: false,
      );
    } finally {
      isSubmittingReview.value = false;
    }
  }

  Future<void> downloadPdfInvoice() async {
    final invoice = invoiceData.value;
    if (invoice == null) {
      Helpers.showCustomSnackBar(
        'Invoice details not loaded yet',
        type: SnackBarType.error,
        useGetxSnackbar: false,
      );
      return;
    }

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final num calculatedVat =
              invoice.totalAmount - (invoice.subtotal + invoice.platformFee);
          final formattedDate = invoice.invoiceDate.isNotEmpty
              ? DateFormat('dd.MM.yyyy HH:mm').format(
                  DateTime.tryParse(invoice.invoiceDate) ?? DateTime.now(),
                )
              : DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());

          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'FIXPAIR INVOICE',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Invoice No: ${invoice.invoiceNumber}'),
                        pw.Text('Date: $formattedDate'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Fixpair Ltd.',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('support@fixpair.com'),
                        pw.Text('www.fixpair.com'),
                      ],
                    ),
                  ],
                ),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 24),

                // Bill to / Bill from
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Client Details:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(invoice.user?.name ?? 'Client'),
                          pw.Text(invoice.user?.email ?? ''),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Consultant Details:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(invoice.consultant?.name ?? 'Consultant'),
                          pw.Text(invoice.consultant?.type ?? 'Expert'),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 32),

                // Invoice Table
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.symmetric(
                    inside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                  ),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blue900,
                  ),
                  headers: ['Description', 'Rate', 'Duration', 'Amount'],
                  data: [
                    [
                      'Consultation Session',
                      '${invoice.perMinuteRate.toStringAsFixed(2)} EUR / min',
                      '${invoice.billableMinutes ?? '0'} min',
                      '${invoice.subtotal.toStringAsFixed(2)} EUR',
                    ],
                    [
                      'Platform Service Fee',
                      '-',
                      '-',
                      '${invoice.platformFee.toStringAsFixed(2)} EUR',
                    ],
                  ],
                ),
                pw.SizedBox(height: 24),

                // Total Summary
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 220,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:'),
                            pw.Text('${invoice.subtotal.toStringAsFixed(2)} EUR'),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Platform Fee:'),
                            pw.Text('${invoice.platformFee.toStringAsFixed(2)} EUR'),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('VAT (19%):'),
                            pw.Text('${calculatedVat.toStringAsFixed(2)} EUR'),
                          ],
                        ),
                        pw.Divider(thickness: 1),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total Amount:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                                color: PdfColors.blue900,
                              ),
                            ),
                            pw.Text(
                              '${invoice.totalAmount.toStringAsFixed(2)} EUR',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                                color: PdfColors.blue900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                pw.Spacer(),

                // Footer
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Thank you for using Fixpair!',
                    style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'invoice_${invoice.invoiceNumber}.pdf',
      );
    } catch (e) {
      Helpers.showCustomSnackBar(
        'Failed to generate PDF invoice preview',
        type: SnackBarType.error,
        useGetxSnackbar: false,
      );
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
