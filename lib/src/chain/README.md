## Requirement
If multiple BYxxx rule parts are specified, then after evaluating
the specified FREQ and INTERVAL rule parts, the BYxxx rule parts
are applied to the current set of evaluated occurrences in the
following order: BYMONTH, BYWEEKNO, BYYEARDAY, BYMONTHDAY, BYDAY,
BYHOUR, BYMINUTE, BYSECOND and BYSETPOS; then COUNT and UNTIL are
evaluated.

+----------+--------+--------+-------+-------+------+-------+------+
|          |SECONDLY|MINUTELY|HOURLY |DAILY  |WEEKLY|MONTHLY|YEARLY|
+----------+--------+--------+-------+-------+------+-------+------+
|BYMONTH   |Limit   |Limit   |Limit  |Limit  |Limit |Limit  |Expand|
+----------+--------+--------+-------+-------+------+-------+------+
|BYWEEKNO  |N/A     |N/A     |N/A    |N/A    |N/A   |N/A    |Expand|
+----------+--------+--------+-------+-------+------+-------+------+
|BYYEARDAY |Limit   |Limit   |Limit  |N/A    |N/A   |N/A    |Expand|
+----------+--------+--------+-------+-------+------+-------+------+
|BYMONTHDAY|Limit   |Limit   |Limit  |Limit  |N/A   |Expand |Expand|
+----------+--------+--------+-------+-------+------+-------+------+
|BYDAY     |Limit   |Limit   |Limit  |Limit  |Expand|Note 1 |Note 2|
+----------+--------+--------+-------+-------+------+-------+------+
|BYHOUR    |Limit   |Limit   |Limit  |Expand |Expand|Expand |Expand|
+----------+--------+--------+-------+-------+------+-------+------+
|BYMINUTE  |Limit   |Limit   |Expand |Expand |Expand|Expand |Expand|
+----------+--------+--------+-------+-------+------+-------+------+
|BYSECOND  |Limit   |Expand  |Expand |Expand |Expand|Expand |Expand|
+----------+--------+--------+-------+-------+------+-------+------+
|BYSETPOS  |Limit   |Limit   |Limit  |Limit  |Limit |Limit  |Limit |
+----------+--------+--------+-------+-------+------+-------+------+

      Note 1:  Limit if BYMONTHDAY is present; otherwise, special expand
               for MONTHLY.

      Note 2:  Limit if BYYEARDAY or BYMONTHDAY is present; otherwise,
               special expand for WEEKLY if BYWEEKNO present; otherwise,
               special expand for MONTHLY if BYMONTH present; otherwise,
               special expand for YEARLY.

## Design
As the order is fixed and applied based on the table, so the Chain of Responsibility might be the
best option here. Remember that the expand or limit is applied based on the output of previous handler.