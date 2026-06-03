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
  final RxMap<String, List<SlotModel>> slotsByDate =
      <String, List<SlotModel>>{}.obs;

  final RxList<Map<String, String>> dates = <Map<String, String>>[].obs;
  final RxList<String> times = <String>[].obs;

  final isRescheduling = false.obs;
  String? bookingId;

  // New variables for flexible durations
  final selectedStartTime = ''.obs;
  final selectedDurationMinutes = 30.obs;
  final durationOptions = <Map<String, dynamic>>[].obs;

  final Map<String, List<SlotModel>> _unavailableByDate = {};
  final Map<String, List<SlotModel>> _bookedByDate = {};

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
      final dateStr = DateFormat('yyyy-MM-dd').format(focusedDate.value);
      final response = await _userRepository.getAvailableSlots(
        expert.value!.id!,
        date: dateStr,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = response.data['data'] ?? {};
        final List<dynamic> unavailableData = dataMap['unavailableSlots'] ?? [];
        final List<dynamic> bookedData = dataMap['bookedSlots'] ?? [];

        final List<SlotModel> unavailableSlots = unavailableData
            .map((e) => SlotModel.fromJson(e))
            .toList();
        final List<SlotModel> bookedSlots = bookedData
            .map((e) => SlotModel.fromJson(e))
            .toList();

        _generateAndOrganizeSlots(dateStr, unavailableSlots, bookedSlots);
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching slots: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool _isOverlapping(String start1, String end1, String start2, String end2) {
    if (start1.isEmpty || end1.isEmpty || start2.isEmpty || end2.isEmpty) {
      return false;
    }
    final s1 = _parseTime(start1);
    final e1 = _parseTime(end1);
    final s2 = _parseTime(start2);
    final e2 = _parseTime(end2);
    if (s1 == null || e1 == null || s2 == null || e2 == null) return false;
    return s1.isBefore(e2) && s2.isBefore(e1);
  }

  DateTime? _parseTime(String timeStr) {
    try {
      final cleanTime = timeStr.trim();
      final parts = cleanTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].split(' ')[0]);
      return DateTime(2000, 1, 1, hour, minute);
    } catch (e) {
      return null;
    }
  }

  String addMinutesToTime(String timeStr, int minutes) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final time = DateTime(
      2000,
      1,
      1,
      hour,
      minute,
    ).add(Duration(minutes: minutes));
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _generateAndOrganizeSlots(
    String queryDateKey,
    List<SlotModel> unavailableSlots,
    List<SlotModel> bookedSlots,
  ) {
    slotsByDate.clear();

    _unavailableByDate.clear();
    _unavailableByDate[queryDateKey] = unavailableSlots;

    _bookedByDate.clear();
    for (var b in bookedSlots) {
      if (b.date != null) {
        final bDateKey = DateFormat('yyyy-MM-dd').format(b.date!.toLocal());
        _bookedByDate.putIfAbsent(bDateKey, () => []).add(b);
      }
    }

    final year = focusedDate.value.year;
    final month = focusedDate.value.month;
    final totalDays = DateTime(year, month + 1, 0).day;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final List<String> possibleTimes = [
      '08:00',
      '08:30',
      '09:00',
      '09:30',
      '10:00',
      '10:30',
      '11:00',
      '11:30',
      '12:00',
      '12:30',
      '13:00',
      '13:30',
      '14:00',
      '14:30',
      '15:00',
      '15:30',
      '16:00',
      '16:30',
      '17:00',
      '17:30',
      '18:00',
      '18:30',
      '19:00',
      '19:30',
    ];

    for (var day = 1; day <= totalDays; day++) {
      final currentDate = DateTime(year, month, day);
      final currentDayStart = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      if (currentDayStart.isBefore(todayStart)) continue;

      final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
      final isToday = dateKey == DateFormat('yyyy-MM-dd').format(today);

      final dayUnavailable = _unavailableByDate[dateKey] ?? [];
      final dayBooked = _bookedByDate[dateKey] ?? [];

      final List<SlotModel> daySlots = [];

      for (var startTime in possibleTimes) {
        final endTime = addMinutesToTime(startTime, 30);

        if (isToday) {
          final parsedSlotStart = _parseTime(startTime);
          if (parsedSlotStart != null) {
            final currentSlotTime = DateTime(
              2000,
              1,
              1,
              parsedSlotStart.hour,
              parsedSlotStart.minute,
            );
            final currentNowTime = DateTime(
              2000,
              1,
              1,
              today.hour,
              today.minute,
            );
            if (currentSlotTime.isBefore(currentNowTime)) continue;
          }
        }

        final isUnavailable = dayUnavailable.any(
          (u) => _isOverlapping(
            startTime,
            endTime,
            u.startTime ?? '',
            u.endTime ?? '',
          ),
        );
        if (isUnavailable) continue;

        final isBooked = dayBooked.any(
          (b) => _isOverlapping(
            startTime,
            endTime,
            b.startTime ?? '',
            b.endTime ?? '',
          ),
        );
 
        daySlots.add(
          SlotModel(
            date: currentDate,
            startTime: startTime,
            endTime: endTime,
            isBooked: isBooked,
          ),
        );
      }

      if (daySlots.isNotEmpty) {
        slotsByDate[dateKey] = daySlots;
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
    selectedStartTime.value = '';
    selectedDurationMinutes.value = 30;
    durationOptions.clear();

    if (dates.isEmpty) return;

    final selectedDateKey = dates[selectedDateIndex.value]['fullDate'];
    final slots = slotsByDate[selectedDateKey] ?? [];

    times.value = slots.map((s) => s.startTime ?? '').toList();
  }

  void selectDate(int index) {
    selectedDateIndex.value = index;
    if (dates.isNotEmpty && index >= 0 && index < dates.length) {
      final selectedDateKey = dates[index]['fullDate']!;
      fetchSlotsForDate(selectedDateKey);
    } else {
      _updateTimesForSelectedDate();
    }
  }

  Future<void> fetchSlotsForDate(String dateKey) async {
    if (expert.value == null) return;

    try {
      isLoading.value = true;
      final response = await _userRepository.getAvailableSlots(
        expert.value!.id!,
        date: dateKey,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = response.data['data'] ?? {};
        final List<dynamic> unavailableData = dataMap['unavailableSlots'] ?? [];
        final List<dynamic> bookedData = dataMap['bookedSlots'] ?? [];

        final List<SlotModel> unavailableSlots = unavailableData
            .map((e) => SlotModel.fromJson(e))
            .toList();
        final List<SlotModel> bookedSlots = bookedData
            .map((e) => SlotModel.fromJson(e))
            .toList();

        _updateSlotsForDate(dateKey, unavailableSlots, bookedSlots);
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching slots for date $dateKey: $e');
    } finally {
      isLoading.value = false;
      _updateTimesForSelectedDate();
    }
  }

  void _updateSlotsForDate(
    String dateKey,
    List<SlotModel> unavailableSlots,
    List<SlotModel> bookedSlots,
  ) {
    final currentDate = DateTime.parse(dateKey);
    final today = DateTime.now();
    final isToday = dateKey == DateFormat('yyyy-MM-dd').format(today);

    final List<String> possibleTimes = [
      '08:00',
      '08:30',
      '09:00',
      '09:30',
      '10:00',
      '10:30',
      '11:00',
      '11:30',
      '12:00',
      '12:30',
      '13:00',
      '13:30',
      '14:00',
      '14:30',
      '15:00',
      '15:30',
      '16:00',
      '16:30',
      '17:00',
      '17:30',
      '18:00',
      '18:30',
      '19:00',
      '19:30',
    ];

    final List<SlotModel> dayUnavailable = unavailableSlots;

    final List<SlotModel> dayBooked = [];
    for (var b in bookedSlots) {
      if (b.date != null) {
        final bDateLocal = DateFormat('yyyy-MM-dd').format(b.date!.toLocal());
        if (bDateLocal == dateKey) {
          dayBooked.add(b);
        }
      }
    }

    final List<SlotModel> daySlots = [];

    for (var startTime in possibleTimes) {
      final endTime = addMinutesToTime(startTime, 30);

      if (isToday) {
        final parsedSlotStart = _parseTime(startTime);
        if (parsedSlotStart != null) {
          final currentSlotTime = DateTime(
            2000,
            1,
            1,
            parsedSlotStart.hour,
            parsedSlotStart.minute,
          );
          final currentNowTime = DateTime(2000, 1, 1, today.hour, today.minute);
          if (currentSlotTime.isBefore(currentNowTime)) continue;
        }
      }

      final isUnavailable = dayUnavailable.any(
        (u) => _isOverlapping(
          startTime,
          endTime,
          u.startTime ?? '',
          u.endTime ?? '',
        ),
      );
      if (isUnavailable) continue;

      final isBooked = dayBooked.any(
        (b) => _isOverlapping(
          startTime,
          endTime,
          b.startTime ?? '',
          b.endTime ?? '',
        ),
      );

      daySlots.add(
        SlotModel(
          date: currentDate,
          startTime: startTime,
          endTime: endTime,
          isBooked: isBooked,
        ),
      );
    }

    slotsByDate[dateKey] = daySlots;
  }

  void selectStartTime(int index) {
    if (dates.isEmpty) return;
    final selectedDateKey = dates[selectedDateIndex.value]['fullDate'];
    final slots = slotsByDate[selectedDateKey] ?? [];
    if (index >= 0 && index < slots.length) {
      final slot = slots[index];
      if (slot.isBooked == true) {
        Helpers.showWarning('This time slot is already booked.');
        return;
      }
      selectedTimeIndex.value = index;
      selectedStartTime.value = slot.startTime ?? '';
      _updateDurationOptions(selectedDateKey!, slot.startTime ?? '');
    }
  }

  void _updateDurationOptions(String dateKey, String startTime) {
    durationOptions.clear();

    final List<int> durations = [30, 60, 90, 120];

    final dayUnavailable = _unavailableByDate[dateKey] ?? [];
    final dayBooked = _bookedByDate[dateKey] ?? [];

    for (var duration in durations) {
      final endTime = addMinutesToTime(startTime, duration);

      final isUnavailable = dayUnavailable.any(
        (u) => _isOverlapping(
          startTime,
          endTime,
          u.startTime ?? '',
          u.endTime ?? '',
        ),
      );

      final isBooked = dayBooked.any(
        (b) => _isOverlapping(
          startTime,
          endTime,
          b.startTime ?? '',
          b.endTime ?? '',
        ),
      );

      final parsedEnd = _parseTime(endTime);
      final parsedMax = _parseTime('20:00');
      final isExceeding =
          parsedEnd != null &&
          parsedMax != null &&
          parsedEnd.isAfter(parsedMax);

      final isEnabled = !isUnavailable && !isBooked && !isExceeding;

      String label = '';
      if (duration == 30) label = '30 Min';
      if (duration == 60) label = '1 Hour';
      if (duration == 90) label = '1.5 Hours';
      if (duration == 120) label = '2 Hours';

      durationOptions.add({
        'duration': duration,
        'label': label,
        'isEnabled': isEnabled,
        'endTime': endTime,
      });
    }

    final firstEnabled = durationOptions.firstWhere(
      (d) => d['isEnabled'] == true,
      orElse: () => {},
    );
    if (firstEnabled.isNotEmpty) {
      selectedDurationMinutes.value = firstEnabled['duration'];
    } else {
      selectedDurationMinutes.value = 30;
    }
  }

  double get totalPrice {
    if (selectedStartTime.isEmpty) return 0.0;
    final rate = expert.value?.perMinuteRate ?? 0;
    return (selectedDurationMinutes.value * rate).toDouble();
  }

  void nextMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
      1,
    );
    fetchSlots();
  }

  void previousMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month - 1,
      1,
    );
    fetchSlots();
  }

  Future<void> bookScheduled() async {
    if (expert.value == null ||
        selectedDateIndex.value == -1 ||
        selectedStartTime.isEmpty) {
      Helpers.showWarning('Please select a date, start time, and duration');
      return;
    }

    final selectedDateKey = dates[selectedDateIndex.value]['fullDate'];
    final endTime = addMinutesToTime(
      selectedStartTime.value,
      selectedDurationMinutes.value,
    );

    try {
      isLoading.value = true;
      if (isRescheduling.value && bookingId != null) {
        final response = await _userRepository.rescheduleBooking(
          id: bookingId!,
          date: selectedDateKey!,
          startTime: selectedStartTime.value,
          endTime: endTime,
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
          "date": selectedDateKey,
          "startTime": selectedStartTime.value,
          "endTime": endTime,
          "notes": "Scheduled Booking",
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
