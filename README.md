[![Build Status](https://github.com/hnvcam/teno_rrule/actions/workflows/ci.yaml/badge.svg)](https://github.com/hnvcam/teno_rrule)
[![codecov](https://codecov.io/gh/hnvcam/teno_rrule/graph/badge.svg?token=FCRWMFYD3O)](https://codecov.io/gh/hnvcam/teno_rrule)
[![Pub Package](https://img.shields.io/pub/v/teno_rrule)](https://pub.dev/packages/teno_rrule)

## Dart Recurrence Rule implements RFC5545 (iCalendar)
This library is designed to support what are defined in [RFC5545 - Recurrence Rule](https://datatracker.ietf.org/doc/html/rfc5545#section-3.8.5.3).

## What is to choose between this library (teno_rrule) vs [rrule](https://pub.dev/packages/rrule)
| **If you are looking for**                 | Ideal choice  |
|--------------------------------------------|---------------|
| Stable with many usages                    | rrule         |
| Features like WKST, Timezone, Exdates, ... | teno-rrule    |
| Both above                                 | You will made |

## Getting started

This library utilizes [timezone](https://pub.dev/packages/timezone) to support timezone-based DateTime (TZDateTime),
so make sure you follow the instruction their for initializing the location database. For short:
```dart
import 'package:timezone/data/latest_10y.dart';
...
initializeTimeZones();
```
By default, the library will using the standard alone version of the library.

Add this library to your pubspec.yaml
```shell
dart pub add teno-rrule
```
And you are good to go! 

## Usage

#### Create Recurrence Rule instance from code:
```dart
final rrule = RecurrenceRule(
    frequency: Frequency.weekly,
    startDate: DateTime(1997, 9, 2, 9, 0, 0),
    byWeekDays: {WeekDay.monday, WeekDay.wednesday, WeekDay.friday});
```

#### Get its recurrence by
```dart
final instances = rrule.between(DateTime(1997, 9, 2, 9), DateTime(1997, 10, 2, 9));
// gets: 1997-09-03 09:00:00.000, 1997-09-05 09:00:00.000, ... 1997-10-01 09:00:00.000
```
end range is exclusive.

#### Parse from string
```dart
final rruleString = 'DTSTART;TZID=America/New_York:19970902T090000\n'
    'RRULE:FREQ=DAILY;INTERVAL=2';
final rrule = RecurrenceRule.from(rruleString);
```
> You need to initialize the Location database before parsing from string with TZID, otherwise it will throw exception!

#### To use with timezone, you first need to initialize location database at getting start section
```dart
final rrule = RecurrenceRule(
    frequency: Frequency.daily,
    count: 10,
    isLocal: false,
    startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9));
```
By default, isLocal = true, means it won't care about the timezone in startDate and treats everything as local time. 
To use with timezone, please set this flag to **false**.

#### To specify the first day of week
```dart
final rrule = RecurrenceRule(
          frequency: Frequency.weekly,
          count: 10,
          weekStart: DateTime.sunday,
          byWeekDays: {WeekDay.tuesday, WeekDay.thursday},
          startDate: DateTime(1997, 9, 2, 9));
```
by default, WKST will take the value of **firstDayOfWeek** from [teno_datetime](https://pub.dev/packages/teno_datetime), so you can:
1. Override the WKST by setting value to property weekStart
2. Override globally by setting value to **firstDayOfWeek**, for ex:
```dart
firstDayOfWeek = DateTime.saturday;
```

#### To select the n occurrence of day
```dart
final rrule = RecurrenceRule(
    frequency: Frequency.monthly,
    interval: 2,
    count: 10,
    byWeekDays: {
        WeekDay.sunday.withOccurrence(1),  // or WeekDay(DateTime.sunday, 1)
        WeekDay.sunday.withOccurrence(-1)  // or WeekDay(DateTime.sunday, -1)
    },
    isLocal: false,
    startDate:
    TZDateTime(getLocation('America/New_York'), 1997, 09, 07, 9));
```
#### copyWith
```dart
final anotherRRule = rrule.copyWith(interval: 5, count: 5);
```

## Additional information
This library has been tested with all examples from RFC5545 - section 3.8.5.3. You can have a look at:
[test/conversions_test.dart](test/conversions_test.dart)
[test/query_test.dart](test/conversions_test.dart)

You can refer to the current progress at: [TODO.md](TODO.md)

## If you found a bug, issue, or have a request.
Please submit an issue at https://github.com/hnvcam/teno_rrule/issues. And give me sometime to take a look on it.
I won't promise to take the action soon, but I will reply you my plan.

---
<div style="text-align: center;">
<h4>If you find this library is useful</h4>
[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/hnvcam)
</div>