### Define Recurrence Rule model
[x] Recurrence Rule, Frequency
### Parse and serialize RRule
[x] Serialize to rfc5545 string
[x] Parse from rfc5545 string
### Generate Recurrences
[x] Handle FREQ rule
[x] Handle interval rule
[x] Handle constrains of start date, end date
[x] Handle rules of by month, by weeks, ...
### Support for Exclusion
[x] EXDATE
[ ] Multiple exdates and rrules of a rruleset (this won't be a case of RFC5545?)
### Support timezone
[x] TZDateTime
[x] Start date and exdate has same time zone.
[ ] Different time zones of start date, exdate and rrules. (Check if this is a case of rfc5545)
### Limit instances
[x] Handle count & until
[x] No limit?
### Enhanced support
[x] ByNWeekDays
[x] Negative By...
### Complex test scenarios
[ ] Import from Google calendar
[ ] Import from Apple calendar
### Document and release
[x] Basic usage
[ ] Considerations
[ ] tenolife.com page