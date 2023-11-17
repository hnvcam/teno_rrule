enum Frequency {
  secondly('SECONDLY'),
  minutely('MINUTELY'),
  hourly('HOURLY'),
  daily('DAILY'),
  weekly('WEEKLY'),
  monthly('MONTHLY'),
  yearly('YEARLY');

  final String value;
  const Frequency(this.value);

  @override
  String toString() {
    return value;
  }
}
