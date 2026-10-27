const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// e.g. "12 Sep 2003"
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// e.g. "2003-09-12" (what Postgres `date` columns expect)
String toIsoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

int ageOn(DateTime dob, DateTime today) {
  var age = today.year - dob.year;
  if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
    age--;
  }
  return age;
}

/// e.g. "6 Oct"
String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

const _monthsLong = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _weekdaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String monthName(int month) => _monthsLong[month - 1];

/// e.g. "Wed, 16 September"
String formatLongDate(DateTime d) =>
    '${_weekdaysShort[d.weekday - 1]}, ${d.day} ${_monthsLong[d.month - 1]}';

/// e.g. 9, 0 -> "09:00 AM"
String formatTime12(int hour, int minute) {
  final h12 = hour % 12 == 0 ? 12 : hour % 12;
  final suffix = hour < 12 ? 'AM' : 'PM';
  return '${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $suffix';
}
