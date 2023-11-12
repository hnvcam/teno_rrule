import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/standalone.dart';

Location getTimeLocation(DateTime dateTime) {
  if (!timeZoneDatabase.isInitialized) {
    initializeTimeZones();
  }
  final timezoneOffsetInMilliseconds = dateTime.timeZoneOffset.inMilliseconds;
  return timeZoneDatabase.locations.values.firstWhere((loc) {
    for (TimeZone zone in loc.zones) {
      if (zone.offset == timezoneOffsetInMilliseconds) {
        return true;
      }
    }
    return false;
  });
}

String getTimezoneId(DateTime dateTime) {
  return getTimeLocation(dateTime).name;
}

String padZeroInt(int value) {
  return value.toString().padLeft(2, '0');
}

TZDateTime toTZDateTime(Location location, DateTime localDateTime) {
  return TZDateTime(
      location,
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
      localDateTime.hour,
      localDateTime.minute,
      localDateTime.second);
}

DateTime cloneWith(DateTime dateTime,
    {Location? location,
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second}) {
  final effectiveLocation =
      location ?? (dateTime is TZDateTime ? dateTime.location : null);
  if (effectiveLocation != null) {
    return TZDateTime(
        effectiveLocation,
        year ?? dateTime.year,
        month ?? dateTime.month,
        day ?? dateTime.day,
        hour ?? dateTime.hour,
        minute ?? dateTime.minute,
        second ?? dateTime.second);
  }
  return DateTime(
      year ?? dateTime.year,
      month ?? dateTime.month,
      day ?? dateTime.day,
      hour ?? dateTime.hour,
      minute ?? dateTime.minute,
      second ?? dateTime.second);
}
