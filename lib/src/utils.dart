import 'dart:collection';

import 'package:teno_datetime/teno_datetime.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/standalone.dart';

Location getTimeLocation(DateTime dateTime) {
  if (dateTime is TZDateTime) {
    return dateTime.location;
  }

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

/// teno_datetime only works on DateTime, so it does not know about TZDateTime
/// unfortunately TZDateTime does not handle copyWith properly, so
DateTime locationAwarenessAddDays(DateTime instance, int days) {
  if (instance is TZDateTime) {
    final dt = instance.addUnit(days: days);
    return TZDateTime(instance.location, dt.year, dt.month, dt.day, dt.hour,
        dt.minute, dt.second, dt.millisecond, dt.microsecond);
  }
  return instance.addUnit(days: days);
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
  } else if (dateTime.isUtc) {
    return DateTime.utc(
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

extension FlatMap<T> on Iterable<T> {
  Iterable<U> flatMap<U>(Iterable<U> Function(T element) mapper) {
    return _FlatMapIterable<T, U>(this, mapper);
  }
}

class _FlatMapIterable<T, U> with IterableBase<U> {
  final Iterable<T> source;
  final Iterable<U> Function(T element) mapper;

  const _FlatMapIterable(this.source, this.mapper);

  @override
  Iterator<U> get iterator => _FlatMapIterator(source, mapper);
}

class _FlatMapIterator<T, U> implements Iterator<U> {
  final Iterable<T> source;
  final Iterable<U> Function(T element) mapper;

  late Iterator<T> sourceIterator;
  Iterator<U>? currentIterator;

  _FlatMapIterator(this.source, this.mapper) {
    sourceIterator = this.source.iterator;
  }

  @override
  U get current => currentIterator!.current;

  @override
  bool moveNext() {
    if (currentIterator == null) {
      if (!sourceIterator.moveNext()) {
        return false;
      }
      currentIterator = mapper(sourceIterator.current).iterator;
    }
    while (!currentIterator!.moveNext()) {
      if (!sourceIterator.moveNext()) {
        return false;
      }
      currentIterator = mapper(sourceIterator.current).iterator;
    }
    return true;
  }
}

bool isNotEmpty(Iterable? iterable) {
  return iterable != null && iterable.isNotEmpty;
}

bool isEmpty(Iterable? iterable) {
  return iterable == null || iterable.isEmpty;
}
