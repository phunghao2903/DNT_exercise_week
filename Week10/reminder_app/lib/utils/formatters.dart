String dateLong(DateTime dateTime) {
  final String month = _monthNames[dateTime.month - 1];
  final String day = _twoDigits(dateTime.day);
  return '$day $month ${dateTime.year}';
}

String timeHM(DateTime dateTime) {
  final String hour = _twoDigits(dateTime.hour);
  final String minute = _twoDigits(dateTime.minute);
  return '$hour:$minute';
}

String dateTimeReadable(DateTime dateTime) {
  return '${dateLong(dateTime)}, ${timeHM(dateTime)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

const List<String> _monthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
