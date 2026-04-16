import 'package:get/get.dart';

class ScheduleBookingController extends GetxController {
  final selectedDateIndex = 0.obs;
  final selectedTimeIndex = 0.obs;

  final dates = [
    {'day': 'THU', 'date': '02'},
    {'day': 'FRI', 'date': '03'},
    {'day': 'SAT', 'date': '04'},
    {'day': 'SUN', 'date': '05'},
    {'day': 'MON', 'date': '06'},
    {'day': 'TUE', 'date': '07'},
    {'day': 'WED', 'date': '08'},
    {'day': 'THU', 'date': '09'},
    {'day': 'FRI', 'date': '10'},
  ];

  final times = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30', '18:00', '18:30',
  ];

  void selectDate(int index) => selectedDateIndex.value = index;
  void selectTime(int index) => selectedTimeIndex.value = index;
}
