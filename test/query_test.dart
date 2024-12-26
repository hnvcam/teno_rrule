import 'package:teno_datetime/teno_datetime.dart';
import 'package:teno_rrule/teno_rrule.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/standalone.dart';

import 'testUtils.dart';

main() {
  initializeTimeZones();

  final testData = [
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=DAILY;COUNT=10',
      expected: [
        // ==> (1997 9:00 AM EDT) September 2-11
        for (int i = 0; i < 10; i++)
          newYorkDateTime(1997, 9, 2, 9).addUnit(days: i)
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=DAILY;UNTIL=19971224T000000Z',
      expected: [
        // ==> (1997 9:00 AM EDT) September 2-30;October 1-25
        //     (1997 9:00 AM EST) October 26-31;November 1-30;December 1-23
        for (DateTime date = newYorkDateTime(1997, 9, 2, 9);
            date.isBeforeUnit(DateTime.utc(1997, 12, 24), unit: Unit.second);
            date = date.addUnit(days: 1))
          toTZDateTime(getLocation('America/New_York'), date)
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=DAILY;INTERVAL=2',
      expected: [
        // ==> (1997 9:00 AM EDT) September 2,4,6,8...24,26,28,30;
        //                        October 2,4,6...20,22,24
        //     (1997 9:00 AM EST) October 26,28,30;
        //                        November 1,3,5,7...25,27,29;
        //                        December 1,3,...
        for (DateTime date = newYorkDateTime(1997, 9, 2, 9);
            date.isBeforeUnit(maxAllowedDate, unit: Unit.second);
            date = date.addUnit(days: 2))
          toTZDateTime(getLocation('America/New_York'), date)
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=DAILY;INTERVAL=10;COUNT=5',
      expected: [
        // ==> (1997 9:00 AM EDT) September 2,12,22;
        //                        October 2,12
        newYorkDateTime(1997, 9, 2, 9),
        newYorkDateTime(1997, 9, 12, 9),
        newYorkDateTime(1997, 9, 22, 9),
        newYorkDateTime(1997, 10, 2, 9),
        newYorkDateTime(1997, 10, 12, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19980101T090000\n'
          'RRULE:FREQ=YEARLY;UNTIL=20000131T140000Z;'
          'BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA',
      expected: [
        // => (1998 9:00 AM EST)January 1-31
        //    (1999 9:00 AM EST)January 1-31
        //    (2000 9:00 AM EST)January 1-31
        for (int i = 0; i < 3; i++)
          for (int j = 1; j <= 31; j++) newYorkDateTime(1998 + i, 1, j, 9)
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19980101T090000\n'
          'RRULE:FREQ=DAILY;UNTIL=20000131T140000Z;BYMONTH=1',
      expected: [
        // => (1998 9:00 AM EST)January 1-31
        //    (1999 9:00 AM EST)January 1-31
        //    (2000 9:00 AM EST)January 1-31
        for (int i = 0; i < 3; i++)
          for (int j = 1; j <= 31; j++) newYorkDateTime(1998 + i, 1, j, 9)
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=WEEKLY;COUNT=10',
      expected: [
        // ==> (1997 9:00 AM EDT) September 2,9,16,23,30;October 7,14,21
        //     (1997 9:00 AM EST) October 28;November 4
        for (var day in [2, 9, 16, 23, 30]) newYorkDateTime(1997, 9, day, 9),
        for (var day in [7, 14, 21, 28]) newYorkDateTime(1997, 10, day, 9),
        newYorkDateTime(1997, 11, 4, 9)
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z',
      expected: [
        // ==> (1997 9:00 AM EDT) September 2,9,16,23,30;
        //                        October 7,14,21
        //     (1997 9:00 AM EST) October 28;
        //                        November 4,11,18,25;
        //                        December 2,9,16,23
        for (var day in [2, 9, 16, 23, 30]) newYorkDateTime(1997, 9, day, 9),
        for (var day in [7, 14, 21, 28]) newYorkDateTime(1997, 10, day, 9),
        for (var day in [4, 11, 18, 25]) newYorkDateTime(1997, 11, day, 9),
        for (var day in [2, 9, 16, 23]) newYorkDateTime(1997, 12, day, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU',
      expected: [
        // ==> (1997 9:00 AM EDT) September 2,16,30;
        //                        October 14
        //     (1997 9:00 AM EST) October 28;
        //                        November 11,25;
        //                        December 9,23
        //     (1998 9:00 AM EST) January 6,20;
        //                        February 3, 17
        //     ...
        for (var date = newYorkDateTime(1997, 9, 2, 9);
            date.isBefore(maxAllowedDate);
            date = date.add(const Duration(days: 14)))
          date
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH',
      expected: [
        // ==> (1997 9:00 AM EDT) September 2,4,9,11,16,18,23,25,30;
        //                        October 2
        for (var day in [2, 4, 9, 11, 16, 18, 23, 25, 30])
          newYorkDateTime(1997, 9, day, 9),
        newYorkDateTime(1997, 10, 2, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970901T090000\n'
          'RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;'
          'BYDAY=MO,WE,FR',
      expected: [
        // ==> (1997 9:00 AM EDT) September 1,3,5,15,17,19,29;
        //                        October 1,3,13,15,17
        //     (1997 9:00 AM EST) October 27,29,31;
        //                        November 10,12,14,24,26,28;
        //                        December 8,10,12,22
        for (var day in [1, 3, 5, 15, 17, 19, 29])
          newYorkDateTime(1997, 9, day, 9),
        for (var day in [1, 3, 13, 15, 17, 27, 29, 31])
          newYorkDateTime(1997, 10, day, 9),
        for (var day in [10, 12, 14, 24, 26, 28])
          newYorkDateTime(1997, 11, day, 9),
        for (var day in [8, 10, 12, 22]) newYorkDateTime(1997, 12, day, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH',
      expected: [
        // ==> (1997 9:00 AM EDT) September 2,4,16,18,30;
        //                        October 2,14,16
        for (var day in [2, 4, 16, 18, 30]) newYorkDateTime(1997, 9, day, 9),
        for (var day in [2, 14, 16]) newYorkDateTime(1997, 10, day, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970905T090000\n'
          'RRULE:FREQ=MONTHLY;COUNT=10;BYDAY=1FR',
      expected: [
        // ==> (1997 9:00 AM EDT) September 5;October 3
        //     (1997 9:00 AM EST) November 7;December 5
        //     (1998 9:00 AM EST) January 2;February 6;March 6;April 3
        //     (1998 9:00 AM EDT) May 1;June 5'
        newYorkDateTime(1997, 9, 5, 9),
        newYorkDateTime(1997, 10, 3, 9),
        newYorkDateTime(1997, 11, 7, 9),
        newYorkDateTime(1997, 12, 5, 9),
        newYorkDateTime(1998, 1, 2, 9),
        newYorkDateTime(1998, 2, 6, 9),
        newYorkDateTime(1998, 3, 6, 9),
        newYorkDateTime(1998, 4, 3, 9),
        newYorkDateTime(1998, 5, 1, 9),
        newYorkDateTime(1998, 6, 5, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970905T090000\n'
          'RRULE:FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR',
      expected: [
        // ==> (1997 9:00 AM EDT) September 5; October 3
        //     (1997 9:00 AM EST) November 7; December 5
        newYorkDateTime(1997, 9, 5, 9),
        newYorkDateTime(1997, 10, 3, 9),
        newYorkDateTime(1997, 11, 7, 9),
        newYorkDateTime(1997, 12, 5, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970907T090000\n'
          'RRULE:FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU',
      expected: [
        // (1997 9:00 AM EDT) September 7,28
        // (1997 9:00 AM EST) November 2,30
        // (1998 9:00 AM EST) January 4,25;March 1,29
        // (1998 9:00 AM EDT) May 3,31
        newYorkDateTime(1997, 9, 7, 9),
        newYorkDateTime(1997, 9, 28, 9),
        newYorkDateTime(1997, 11, 2, 9),
        newYorkDateTime(1997, 11, 30, 9),
        newYorkDateTime(1998, 1, 4, 9),
        newYorkDateTime(1998, 1, 25, 9),
        newYorkDateTime(1998, 3, 1, 9),
        newYorkDateTime(1998, 3, 29, 9),
        newYorkDateTime(1998, 5, 3, 9),
        newYorkDateTime(1998, 5, 31, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970922T090000\n'
          'RRULE:FREQ=MONTHLY;COUNT=6;BYDAY=-2MO',
      expected: [
        // ==> (1997 9:00 AM EDT) September 22;October 20
        //     (1997 9:00 AM EST) November 17;December 22
        //     (1998 9:00 AM EST) January 19;February 16
        newYorkDateTime(1997, 9, 22, 9),
        newYorkDateTime(1997, 10, 20, 9),
        newYorkDateTime(1997, 11, 17, 9),
        newYorkDateTime(1997, 12, 22, 9),
        newYorkDateTime(1998, 1, 19, 9),
        newYorkDateTime(1998, 2, 16, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970928T090000\n'
          'RRULE:FREQ=MONTHLY;BYMONTHDAY=-3;COUNT=6', // Added COUNT=6, to easier to test
      expected: [
        // ==> (1997 9:00 AM EDT) September 28
        //     (1997 9:00 AM EST) October 29;November 28;December 29
        //     (1998 9:00 AM EST) January 29;February 26
        newYorkDateTime(1997, 9, 28, 9),
        newYorkDateTime(1997, 10, 29, 9),
        newYorkDateTime(1997, 11, 28, 9),
        newYorkDateTime(1997, 12, 29, 9),
        newYorkDateTime(1998, 1, 29, 9),
        newYorkDateTime(1998, 2, 26, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15',
      expected: [
        // ==> (1997 9:00 AM EDT) September 2,15;October 2,15
        //     (1997 9:00 AM EST) November 2,15;December 2,15
        //     (1998 9:00 AM EST) January 2,15
        newYorkDateTime(1997, 9, 2, 9),
        newYorkDateTime(1997, 9, 15, 9),
        newYorkDateTime(1997, 10, 2, 9),
        newYorkDateTime(1997, 10, 15, 9),
        newYorkDateTime(1997, 11, 2, 9),
        newYorkDateTime(1997, 11, 15, 9),
        newYorkDateTime(1997, 12, 2, 9),
        newYorkDateTime(1997, 12, 15, 9),
        newYorkDateTime(1998, 1, 2, 9),
        newYorkDateTime(1998, 1, 15, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970930T090000\n'
          'RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1',
      expected: [
        // ==> (1997 9:00 AM EDT) September 30;October 1
        //     (1997 9:00 AM EST) October 31;November 1,30;December 1,31
        //     (1998 9:00 AM EST) January 1,31;February 1
        newYorkDateTime(1997, 9, 30, 9),
        newYorkDateTime(1997, 10, 1, 9),
        newYorkDateTime(1997, 10, 31, 9),
        newYorkDateTime(1997, 11, 1, 9),
        newYorkDateTime(1997, 11, 30, 9),
        newYorkDateTime(1997, 12, 1, 9),
        newYorkDateTime(1997, 12, 31, 9),
        newYorkDateTime(1998, 1, 1, 9),
        newYorkDateTime(1998, 1, 31, 9),
        newYorkDateTime(1998, 2, 1, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970910T090000\n'
          'RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15',
      expected: [
        // ==> (1997 9:00 AM EDT) September 10,11,12,13,14,15
        //     (1999 9:00 AM EST) March 10,11,12,13
        for (int day in [10, 11, 12, 13, 14, 15])
          newYorkDateTime(1997, 9, day, 9),
        for (int day in [10, 11, 12, 13]) newYorkDateTime(1999, 3, day, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=MONTHLY;INTERVAL=2;BYDAY=TU;UNTIL=19980401T000000Z', // added UNTIL for easier to test
      expected: [
        // ==> (1997 9:00 AM EDT) September 2,9,16,23,30
        //     (1997 9:00 AM EST) November 4,11,18,25
        //     (1998 9:00 AM EST) January 6,13,20,27;March 3,10,17,24,31
        for (int day in [2, 9, 16, 23, 30]) newYorkDateTime(1997, 9, day, 9),
        for (int day in [4, 11, 18, 25]) newYorkDateTime(1997, 11, day, 9),
        for (int day in [6, 13, 20, 27]) newYorkDateTime(1998, 1, day, 9),
        for (int day in [3, 10, 17, 24, 31]) newYorkDateTime(1998, 3, day, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970610T090000\n'
          'RRULE:FREQ=YEARLY;COUNT=10;BYMONTH=6,7',
      expected: [
        // ==> (1997 9:00 AM EDT) June 10;July 10
        //     (1998 9:00 AM EDT) June 10;July 10
        //     (1999 9:00 AM EDT) June 10;July 10
        //     (2000 9:00 AM EDT) June 10;July 10
        //     (2001 9:00 AM EDT) June 10;July 10
        for (int year in [1997, 1998, 1999, 2000, 2001])
          for (int month in [6, 7]) newYorkDateTime(year, month, 10, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970310T090000\n'
          'RRULE:FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3',
      expected: [
        // ==> (1997 9:00 AM EST) March 10
        //     (1999 9:00 AM EST) January 10;February 10;March 10
        //     (2001 9:00 AM EST) January 10;February 10;March 10
        //     (2003 9:00 AM EST) January 10;February 10;March 10
        newYorkDateTime(1997, 3, 10, 9),
        for (int year in [1999, 2001, 2003])
          for (int month in [1, 2, 3]) newYorkDateTime(year, month, 10, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970101T090000\n'
          'RRULE:FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200',
      expected: [
        // ==> (1997 9:00 AM EST) January 1
        //     (1997 9:00 AM EDT) April 10;July 19
        //     (2000 9:00 AM EST) January 1
        //     (2000 9:00 AM EDT) April 9;July 18
        //     (2003 9:00 AM EST) January 1
        //     (2003 9:00 AM EDT) April 10;July 19
        //     (2006 9:00 AM EST) January 1'
        newYorkDateTime(1997, 1, 1, 9),
        newYorkDateTime(1997, 4, 10, 9),
        newYorkDateTime(1997, 7, 19, 9),
        newYorkDateTime(2000, 1, 1, 9),
        newYorkDateTime(2000, 4, 9, 9),
        newYorkDateTime(2000, 7, 18, 9),
        newYorkDateTime(2003, 1, 1, 9),
        newYorkDateTime(2003, 4, 10, 9),
        newYorkDateTime(2003, 7, 19, 9),
        newYorkDateTime(2006, 1, 1, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970519T090000\n'
          'RRULE:FREQ=YEARLY;BYDAY=20MO;COUNT=3', // Added COUNT=3 for easier testing
      expected: [
        // ==> (1997 9:00 AM EDT) May 19
        //     (1998 9:00 AM EDT) May 18
        //     (1999 9:00 AM EDT) May 17
        newYorkDateTime(1997, 5, 19, 9),
        newYorkDateTime(1998, 5, 18, 9),
        newYorkDateTime(1999, 5, 17, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970313T090000\n'
          'RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=TH;COUNT=11', // Added COUNT=11 for easier testing
      expected: [
        // ==> (1997 9:00 AM EST) March 13,20,27
        //     (1998 9:00 AM EST) March 5,12,19,26
        //     (1999 9:00 AM EST) March 4,11,18,25
        for (int day in [13, 20, 27]) newYorkDateTime(1997, 3, day, 9),
        for (int day in [5, 12, 19, 26]) newYorkDateTime(1998, 3, day, 9),
        for (int day in [4, 11, 18, 25]) newYorkDateTime(1999, 3, day, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970605T090000\n'
          'RRULE:FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8;UNTIL=19990831T000000Z', // Added UNTIL for easier testing
      expected: [
        // ==> (1997 9:00 AM EDT) June 5,12,19,26;July 3,10,17,24,31;
        //                        August 7,14,21,28
        //     (1998 9:00 AM EDT) June 4,11,18,25;July 2,9,16,23,30;
        //                        August 6,13,20,27
        //     (1999 9:00 AM EDT) June 3,10,17,24;July 1,8,15,22,29;
        //                        August 5,12,19,26
        for (int day in [5, 12, 19, 26]) newYorkDateTime(1997, 6, day, 9),
        for (int day in [3, 10, 17, 24, 31]) newYorkDateTime(1997, 7, day, 9),
        for (int day in [7, 14, 21, 28]) newYorkDateTime(1997, 8, day, 9),
        for (int day in [4, 11, 18, 25]) newYorkDateTime(1998, 6, day, 9),
        for (int day in [2, 9, 16, 23, 30]) newYorkDateTime(1998, 7, day, 9),
        for (int day in [6, 13, 20, 27]) newYorkDateTime(1998, 8, day, 9),
        for (int day in [3, 10, 17, 24]) newYorkDateTime(1999, 6, day, 9),
        for (int day in [1, 8, 15, 22, 29]) newYorkDateTime(1999, 7, day, 9),
        for (int day in [5, 12, 19, 26]) newYorkDateTime(1999, 8, day, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970913T090000\n'
          'RRULE:FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13;COUNT=10', // Added COUNT for easier testing
      expected: [
        // ==> (1997 9:00 AM EDT) September 13;October 11
        //     (1997 9:00 AM EST) November 8;December 13
        //     (1998 9:00 AM EST) January 10;February 7;March 7
        //     (1998 9:00 AM EDT) April 11;May 9;June 13...
        newYorkDateTime(1997, 9, 13, 9),
        newYorkDateTime(1997, 10, 11, 9),
        newYorkDateTime(1997, 11, 8, 9),
        newYorkDateTime(1997, 12, 13, 9),
        newYorkDateTime(1998, 1, 10, 9),
        newYorkDateTime(1998, 2, 7, 9),
        newYorkDateTime(1998, 3, 7, 9),
        newYorkDateTime(1998, 4, 11, 9),
        newYorkDateTime(1998, 5, 9, 9),
        newYorkDateTime(1998, 6, 13, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970904T090000\n'
          'RRULE:FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3',
      expected: [
        // ==> (1997 9:00 AM EDT) September 4;October 7
        //     (1997 9:00 AM EST) November 6
        newYorkDateTime(1997, 9, 4, 9),
        newYorkDateTime(1997, 10, 7, 9),
        newYorkDateTime(1997, 11, 6, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970929T090000\n'
          'RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2;COUNT=7', // added COUNT for easier testing
      expected: [
        // ==> (1997 9:00 AM EDT) September 29
        //     (1997 9:00 AM EST) October 30;November 27;December 30
        //     (1998 9:00 AM EST) January 29;February 26;March 30
        //     ...
        newYorkDateTime(1997, 9, 29, 9),
        newYorkDateTime(1997, 10, 30, 9),
        newYorkDateTime(1997, 11, 27, 9),
        newYorkDateTime(1997, 12, 30, 9),
        newYorkDateTime(1998, 1, 29, 9),
        newYorkDateTime(1998, 2, 26, 9),
        newYorkDateTime(1998, 3, 30, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=HOURLY;INTERVAL=3;UNTIL=19970902T170000Z',
      expected: [
        // ==> (September 2, 1997 EDT) 09:00,12:00,15:00
        newYorkDateTime(1997, 9, 2, 9),
        newYorkDateTime(1997, 9, 2, 12),
        newYorkDateTime(1997, 9, 2, 15),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=MINUTELY;INTERVAL=15;COUNT=6',
      expected: [
        // ==> (September 2, 1997 EDT) 09:00,09:15,09:30,09:45,10:00,10:15
        for (int i = 0; i < 6; i++)
          newYorkDateTime(1997, 9, 2, 9).addUnit(minutes: i * 15),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=MINUTELY;INTERVAL=90;COUNT=4',
      expected: [
        // ==> (September 2, 1997 EDT) 09:00,10:30;12:00;13:30
        for (int i = 0; i < 4; i++)
          newYorkDateTime(1997, 9, 2, 9).addUnit(minutes: i * 90),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=DAILY;BYHOUR=9,10,11,12,13,14,15,16;BYMINUTE=0,20,40;UNTIL=19970903T235959Z', // Added UNTIL for easier testing
      expected: [
        // ==> (September 2, 1997 EDT) 9:00,9:20,9:40,10:00,10:20,
        //                             ... 16:00,16:20,16:40
        //     (September 3, 1997 EDT) 9:00,9:20,9:40,10:00,10:20,
        //                             ...16:00,16:20,16:40
        //     ...
        for (int day = 2; day <= 3; day++)
          for (int hour in [9, 10, 11, 12, 13, 14, 15, 16])
            for (int minute in [0, 20, 40])
              newYorkDateTime(1997, 9, day, hour, minute),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=MINUTELY;INTERVAL=20;BYHOUR=9,10,11,12,13,14,15,16;UNTIL=19970903T235959Z', // Added UNTIL for easier testing
      expected: [
        // ==> (September 2, 1997 EDT) 9:00,9:20,9:40,10:00,10:20,
        //                             ... 16:00,16:20,16:40
        //     (September 3, 1997 EDT) 9:00,9:20,9:40,10:00,10:20,
        //                             ...16:00,16:20,16:40
        //     ...
        for (int day = 2; day <= 3; day++)
          for (int hour in [9, 10, 11, 12, 13, 14, 15, 16])
            for (int minute in [0, 20, 40])
              newYorkDateTime(1997, 9, day, hour, minute),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970805T090000\n'
          'RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=MO',
      expected: [
        // ==> (1997 EDT) August 5,10,19,24
        for (int day in [5, 10, 19, 24]) newYorkDateTime(1997, 8, day, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970805T090000\n'
          'RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU',
      expected: [
        // ==> (1997 EDT) August 5,17,19,31
        for (int day in [5, 17, 19, 31]) newYorkDateTime(1997, 8, day, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:20070115T090000\n'
          'RRULE:FREQ=MONTHLY;BYMONTHDAY=15,30;COUNT=5',
      expected: [
        // ==> (2007 EST) January 15,30
        //     (2007 EST) February 15
        //     (2007 EDT) March 15,30
        newYorkDateTime(2007, 1, 15, 9),
        newYorkDateTime(2007, 1, 30, 9),
        newYorkDateTime(2007, 2, 15, 9),
        newYorkDateTime(2007, 3, 15, 9),
        newYorkDateTime(2007, 3, 30, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970512T090000\n'
          'RRULE:FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO;COUNT=3', // Added COUNT for easier testing
      expected: [
        //  ==> (1997 9:00 AM EDT) May 12
        //      (1998 9:00 AM EDT) May 11
        //      (1999 9:00 AM EDT) May 17
        //      ...
        newYorkDateTime(1997, 5, 12, 9),
        newYorkDateTime(1998, 5, 11, 9),
        newYorkDateTime(1999, 5, 17, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'EXDATE;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13;COUNT=5', // Added COUNT for easier testing
      expected: [
        // ==> (1998 9:00 AM EST) February 13;March 13;November 13
        //     (1999 9:00 AM EDT) August 13
        //     (2000 9:00 AM EDT) October 13
        //            ...
        newYorkDateTime(1998, 2, 13, 9),
        newYorkDateTime(1998, 3, 13, 9),
        newYorkDateTime(1998, 11, 13, 9),
        newYorkDateTime(1999, 8, 13, 9),
        newYorkDateTime(2000, 10, 13, 9),
      ]
    ),
  ];

  for (var data in testData) {
    test("RRule: ${data.rruleString} has correct instances", () {
      final rrule = RecurrenceRule.from(data.rruleString);
      expect(rrule!.allInstances, data.expected);
    });
  }

  test('Single test, for debugging', skip: false, () {
    final data = (
      rruleString: 'DTSTART;TZID=America/New_York:19970512T090000\n'
          'RRULE:FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO;COUNT=3', // Added COUNT for easier testing
      expected: [
        //  ==> (1997 9:00 AM EDT) May 12
        //      (1998 9:00 AM EDT) May 11
        //      (1999 9:00 AM EDT) May 17
        //      ...
        newYorkDateTime(1997, 5, 12, 9),
        newYorkDateTime(1998, 5, 11, 9),
        newYorkDateTime(1999, 5, 17, 9),
      ]
    );

    final rrule = RecurrenceRule.from(data.rruleString);
    expect(rrule!.allInstances, data.expected);
  });
}
