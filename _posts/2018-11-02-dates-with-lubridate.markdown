---
layout: post
title:  "R - Date objects using lubridate package"
date:   2018-11-02 12:02:03
categories: [r, dates, data science]
tags: [r, dates, data science]
---

Time series analysis in R requires a specific format of date objects. Lubridate is a package useful to create those objects.

## A. Date and Time Classes in R

Typically when raw data is loaded for time series analysis, it requires some reformatting to transform data into time series format.

R provides two types of date and time classes:

* __Date:__ This is a representation of a calendar date following the ISO 8601 international standard format using the YYYY-m-d date format. Each date object has a numeric value of the number of days since the origin point (1970–01–01)

* __POSIXct/POSIXlt:__ This are two POSIX date/time classes that represents the calendar date, the time of the day, and the time zone using the ISO 8601 international standard format of YYY-m-d H:M:S. The POSIXct class stores the values as the signed number of seconds since the origin point (1970–01–01, UTC time zone) as a numeric value. The POSIXlt class stores each one of the date and time elements as a list.
  
It makes sense to use a time object (POSIXct or POSIXlt objects) only if the series frequency is higher than daily.

A list of UTC zones can be found [here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). The complete database of time zones is maintained by the [IANA](https://www.iana.org/time-zones). Also the complete list of all time zone names can be seen with the function `OlsonNames()`.

## B. Creating date and time objects with lubridate package

### 1. From strings to date objects

To create time and data objects from character objects, we can use the following functions: `ymd_hms`, `ymd`, `mdy` and `dmy`

__ymd_hms__

```
ymd_hms("2019-06-04 12:00:00", tz = "America/Mexico_City")
#> [1] "2019-06-04 12:00:00 CDT"
```

__ymd__

```
ymd("20190604")
#> [1] "2019-06-04"
```

__mdy__

```
mdy("06-04-2019")
#> [1] "2019-06-04"
```

__dmy__

```
dmy("04/06/2019")
#> [1] "2019-06-04"
```

### 2. From individual components to date objects

__make_datetime__

```
year = 2019
month = 4
day = 10
hour = 13
minute = 45
make_datetime(year, month, day, hour, minute)
#> [1] "2019-04-10 13:45:00 UTC"
```

### 3. From numeric values to date objects

To convert numeric values to date object we use the `as_date` function.

```
as_datetime(today())
#> [1] "2019-01-08 UTC"
as_datetime(now())
#> [1] "2019-06-13 02:44:19 UTC"
as_date(now())
#> [1] "2019-06-13"
as_date(0)
#> [1] "1970-01-01"
```

## C. Helper functions

The lubridate package provides a set of functions for extraction and modifications of the elements of time and date of objects: `yday`, `qday`, `day`, `wday`, `hour`, `round_date`, `floor_date`, `ceiling_date`. Also simple functions to get and set components of a date-time, such as year, month, mday, hour, minute and second.

```
d <- now()  ## 2019-06-12 21:05:02 CST
yday(d)  ## day of year
#> [1] 163
qday(d)  ## day of quarter
#> [1] 163
day(d)         ## day of month
#> [1] 12
wday(d)       ## day of week 
#> [1] 4
hour(d)
#> [1] 21
round_date(d)
#> [1] "2019-06-12 21:05:03 CST"
floor_date(d)
#> [1] "2019-06-12 21:05:02 CST"
ceiling_date(d)
#> [1] "2019-06-12 21:05:03 CST"
```

Using time zones:

```
time <- ymd_hms("2010-12-13 15:30:30")
time 
#> [1] "2010-12-13 15:30:30 UTC" 
 
# Changes printing 
with_tz(time, "America/Chicago")
#> [1] "2010-12-13 09:30:30 CST" 
# Changes time
force_tz(time, "America/Chicago")
#> [1] "2010-12-13 15:30:30 CST"
```

## D. Durations, Intervals and Periods

Duration is a span of time measured in seconds. There is no start date. An Interval is also measured in seconds but has an associated start date, it measures elapsed seconds between two specific points in time. A Period records a time span in units larger than seconds, such as years or months.

```
# Declare start and end dates variables
start <- mdy_hm("3-11-2018 5:21", tz = "America/Mexico_City")
end <- mdy_hm("3-12-2018 5:21", tz = "America/Mexico_City")
```

We define an Interval using the `%--%` operator.

```
time.interval <- start %--% end
time.interval
#> [1] 2018-03-11 05:21:00 CST--2018-03-12 05:21:00 CST
```

To create a Duration between these two dates, we can use the `as.duration` function.

```
time.duration <- as.duration(time.interval)
time.duration
#> [1] "86400s (~1 days)"
```

We can create a Period from an Interval using the `as.period` function.

```
time.period <- as.period(time.interval)
time.period
#> [1] "1d 0H 0M 0S"
```
More information can be found at the [official web site](https://lubridate.tidyverse.org/index.html) for the lubridate package.

A cheat sheet for the lubridate packages can be found [here](https://rawgit.com/rstudio/cheatsheets/master/lubridate.pdf).
