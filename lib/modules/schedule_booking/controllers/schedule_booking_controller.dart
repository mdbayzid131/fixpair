import 'package:get/get.dart';

class ScheduleBookingController extends GetxController {
  final selectedDateIndex = 0.obs;
  final selectedTimeIndex = (-1).obs;
  final focusedDate = DateTime.now().obs;

  final RxList<Map<String, String>> dates = <Map<String, String>>[].obs;

  final times = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
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
  ];

  @override
  void onInit() {
    super.onInit();
    _generateDates();
  }

  void _generateDates() {
    dates.clear();
    final year = focusedDate.value.year;
    final month = focusedDate.value.month;

    // Get number of days in the month
    final lastDay = DateTime(year, month + 1, 0).day;

    final List<String> weekDays = [
      'SUN',
      'MON',
      'TUE',
      'WED',
      'THU',
      'FRI',
      'SAT',
    ];
    final today = DateTime.now();
    final todayZero = DateTime(today.year, today.month, today.day);

    for (int i = 1; i <= lastDay; i++) {
      final current = DateTime(year, month, i);
      final isPast = current.isBefore(todayZero);
      dates.add({
        'day': weekDays[current.weekday % 7],
        'date': i.toString().padLeft(2, '0'),
        'isPast': isPast.toString(),
      });
    }

    // Find the first non-past date index and select it
    int firstAvailable = dates.indexWhere((d) => d['isPast'] == 'false');
    if (firstAvailable != -1) {
      selectedDateIndex.value = firstAvailable;
    } else {
      selectedDateIndex.value = 0;
    }
  }

  void selectDate(int index) => selectedDateIndex.value = index;
  void selectTime(int index) => selectedTimeIndex.value = index;

  void updateFocusedDate(DateTime date) {
    focusedDate.value = date;
    _generateDates();
  }

  void nextMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
      1,
    );
    _generateDates();
  }

  void previousMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month - 1,
      1,
    );
    _generateDates();
  }
}
