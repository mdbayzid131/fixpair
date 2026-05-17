import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/services/api_checker.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ScheduleBookingController extends GetxController {
  final UserRepository _userRepository = Get.find();

  final selectedDateIndex = 0.obs;
  final selectedTimeIndex = (-1).obs;
  final focusedDate = DateTime.now().obs;
  final isLoading = false.obs;

  final Rxn<UserData> expert = Rxn<UserData>();
  final RxList<SlotModel> allSlots = <SlotModel>[].obs;
  final RxMap<String, List<SlotModel>> slotsByDate =
      <String, List<SlotModel>>{}.obs;

  final RxList<Map<String, String>> dates = <Map<String, String>>[].obs;
  final RxList<String> times = <String>[].obs;

  final isRescheduling = false.obs;
  String? bookingId;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is UserData) {
      expert.value = Get.arguments as UserData;
      fetchSlots();
    } else if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      expert.value = args['expert'];
      isRescheduling.value = args['isRescheduling'] ?? false;
      bookingId = args['bookingId'];
      if (expert.value != null) {
        fetchSlots();
      }
    }
  }

  Future<void> fetchSlots() async {
    if (expert.value == null) return;

    try {
      isLoading.value = true;
      final response = await _userRepository.getAvailableSlots(
        expert.value!.id!,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        allSlots.value = data.map((e) => SlotModel.fromJson(e)).toList();
        _organizeSlots();
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching slots: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _organizeSlots() {
    slotsByDate.clear();
    for (var slot in allSlots) {
      if (slot.isBooked == true) continue;
      if (slot.date != null) {
        final dateKey = DateFormat('yyyy-MM-dd').format(slot.date!);
        if (!slotsByDate.containsKey(dateKey)) {
          slotsByDate[dateKey] = [];
        }
        slotsByDate[dateKey]!.add(slot);
      }
    }
    _generateDates();
  }

  void _generateDates() {
    dates.clear();
    final sortedDateKeys = slotsByDate.keys.toList()..sort();

    for (var key in sortedDateKeys) {
      final date = DateTime.parse(key);
      dates.add({
        'day': DateFormat('EEE').format(date).toUpperCase(),
        'date': date.day.toString().padLeft(2, '0'),
        'fullDate': key,
        'isPast': 'false',
      });
    }

    if (dates.isNotEmpty) {
      selectedDateIndex.value = 0;
      focusedDate.value = DateTime.parse(dates[0]['fullDate']!);
      _updateTimesForSelectedDate();
    }
  }

  void _updateTimesForSelectedDate() {
    times.clear();
    selectedTimeIndex.value = -1;

    if (dates.isEmpty) return;

    final selectedDateKey = dates[selectedDateIndex.value]['fullDate'];
    final slots = slotsByDate[selectedDateKey] ?? [];

    times.value = slots.map((s) {
      if (s.startTime != null && s.endTime != null) {
        return '${s.startTime} - ${s.endTime}';
      }
      return s.startTime ?? '';
    }).toList();
  }

  void selectDate(int index) {
    selectedDateIndex.value = index;
    _updateTimesForSelectedDate();
  }

  void selectTime(int index) => selectedTimeIndex.value = index;

  double get totalPrice {
    if (selectedDateIndex.value == -1 || selectedTimeIndex.value == -1) {
      return 0.0;
    }
    if (dates.isEmpty || times.isEmpty) return 0.0;

    final selectedDateKey = dates[selectedDateIndex.value]['fullDate'];
    final slots = slotsByDate[selectedDateKey] ?? [];
    if (selectedTimeIndex.value >= slots.length) return 0.0;

    final slot = slots[selectedTimeIndex.value];

    if (slot.startTime == null || slot.endTime == null) return 0.0;

    final start = DateFormat('HH:mm').parse(slot.startTime!);
    final end = DateFormat('HH:mm').parse(slot.endTime!);
    int duration = end.difference(start).inMinutes;
    if (duration < 0) duration += 24 * 60; // Handle overnight slots if any

    return (duration * (expert.value?.perMinuteRate ?? 0)).toDouble();
  }

  void nextMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
      1,
    );
  }

  void previousMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month - 1,
      1,
    );
  }

  Future<void> bookScheduled() async {
    if (expert.value == null ||
        selectedDateIndex.value == -1 ||
        selectedTimeIndex.value == -1) {
      Helpers.showWarning('Please select a date and time');
      return;
    }

    final selectedDateKey = dates[selectedDateIndex.value]['fullDate'];
    final slots = slotsByDate[selectedDateKey] ?? [];
    final slot = slots[selectedTimeIndex.value];

    try {
      isLoading.value = true;
      if (isRescheduling.value && bookingId != null) {
        final response = await _userRepository.rescheduleBooking(
          bookingId!,
          slot.id!,
        );
        if (response.statusCode == 200) {
          Helpers.showSuccess(
            'Booking rescheduled successfully. Waiting for consultant approval.',
          );
          Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR, arguments: 2);
        } else {
          Helpers.showError(
            response.data['message'] ?? 'Failed to reschedule booking',
          );
        }
      } else {
        final body = {
          "consultantId": expert.value!.id,
          "bookingType": "scheduled",
          "slotId": slot.id,
        };

        final response = await _userRepository.bookConsultation(body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          Helpers.showBookingSuccess();
          Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR, arguments: 2);
        }
        ApiChecker.checkWriteApi(response);
      }
    } catch (e) {
      Helpers.showDebugLog('Booking error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
