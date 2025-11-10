// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/src/shared/utils.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  group('isSameDay() tests:', () {
    test('Same day, different time', () {
      final dateA = DateTime(2020, 5, 10, 4, 32, 16);
      final dateB = DateTime(2020, 5, 10, 8, 21, 44);

      expect(isSameDay(dateA, dateB), true);
    });

    test('Different day, same time', () {
      final dateA = DateTime(2020, 5, 10, 4, 32, 16);
      final dateB = DateTime(2020, 5, 11, 4, 32, 16);

      expect(isSameDay(dateA, dateB), false);
    });

    test('UTC and local time zone', () {
      final dateA = DateTime.utc(2020, 5, 10);
      final dateB = DateTime(2020, 5, 10);

      expect(isSameDay(dateA, dateB), true);
    });
  });

  group('normalizeDate() tests:', () {
    test('Local time zone gets converted to UTC', () {
      final dateA = DateTime(2020, 5, 10, 4, 32, 16);
      final dateB = normalizeDate(dateA);

      expect(dateB.isUtc, true);
    });

    test('Date is unchanged', () {
      final dateA = DateTime(2020, 5, 10, 4, 32, 16);
      final dateB = normalizeDate(dateA);

      expect(dateB.year, 2020);
      expect(dateB.month, 5);
      expect(dateB.day, 10);
    });

    test('Time gets trimmed', () {
      final dateA = DateTime(2020, 5, 10, 4, 32, 16);
      final dateB = normalizeDate(dateA);

      expect(dateB.hour, 0);
      expect(dateB.minute, 0);
      expect(dateB.second, 0);
      expect(dateB.millisecond, 0);
      expect(dateB.microsecond, 0);
    });

    test('Returns TZDateTime when provided location', () {
      final location = tz.getLocation('America/New_York');
      final source = DateTime.utc(2020, 3, 8, 5, 45); // 00:45 local before DST

      final normalized = normalizeDate(source, location: location);

      expect(normalized, isA<tz.TZDateTime>());
      expect((normalized as tz.TZDateTime).location, location);
      expect(normalized.hour, 0);
      expect(normalized.minute, 0);
    });

    test('Preserves TZDateTime location without explicit location', () {
      final location = tz.getLocation('Asia/Tokyo');
      final source = tz.TZDateTime(location, 2021, 12, 31, 22, 15);

      final normalized = normalizeDate(source);

      expect(normalized, isA<tz.TZDateTime>());
      expect((normalized as tz.TZDateTime).location, location);
      expect(normalized.hour, 0);
      expect(normalized.minute, 0);
    });
  });

  group('getWeekdayNumber() tests:', () {
    test('Monday returns number 1', () {
      expect(getWeekdayNumber(StartingDayOfWeek.monday), 1);
    });

    test('Sunday returns number 7', () {
      expect(getWeekdayNumber(StartingDayOfWeek.sunday), 7);
    });
  });
}
