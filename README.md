
# `{bbccIR}` 0.1.4.9000

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

The `bbccIR` package is a collection of functions that will aid the
department of [Institutional Research and
Planning](https://www.bigbend.edu/information-center/institutional-research-planning/)
in conducting analysis for the college.

To install the `bbccIR` package run the following code:

``` r
devtools::install_github("Edgar-Zamora/bbccIR")
```

# Data Warehouse Tables

The following sections detail transformations, visualizations, and/or
calculations that can be made to the tables that are found within our
data warehouse (e.g. transcripts, class, student, etc.). For the
functions to work you have to retrieve and store the table as a R
object.

# Class Table

### `state_fte`

The `state_fte` function will calculate and disintegrate state FTE by
student intent for a given year quarter. This function is accessing data
from the local ods and will change daily when viewing current quarter
state FTEs. As for previous years the FTEs will be static and will not
change. To view a more complete picture of all state FTEs over years you
can visit the Tableau dashboard found on the IR [protal
page](https://port.bigbend.edu/employee/Institutional%20Research%20%20Planning/Forms/AllItems.aspx).

There are two different ways to use the `clean_dw_transcript` function.
The first method is by passing the data object that contains the class
table directly into the function as so:

``` r
state_fte(class, "C012")
```

``` r
class %>% 
  state_fte("C012")
```

# Transcript Table

### `clean_dw_transcript`

The `clean_dw_transcript` function will remove those courses that are
not necessary when looking at course level data. This function will be
important when producing course success rates.

There are two different ways to use the `clean_dw_transcript` function.
The first method is by passing the data object that contains the
transcript table directly into the function as so:

``` r
clean_dw_transcript(transcript_tbl)
```

The second method is using the pipe (%\>%) as so:

``` r
transcript_tbl %>% 
  clean_dw_transcript()
```

### `course_success_rate`

Using the `course_success_rate` will generate an output that calculates
the pass rate for every course taught at BBCC. To do so you will need to
have the entire transcript table saved as an object in R.

There are two methods to use the `course_success_rate`, both equal in
their output. The first method is by passing the data object that
contains the transcript table directly into the function as so:

``` r
course_success_rate(transcript_tbl) %>%
  filter(year > "B89")
```

The second method is using the pipe (%\>%) as so:

``` r
transcript_tbl %>% 
  course_success_rate() %>% 
  filter(total_stu >= 5, 
         year == "B90")
```

There are additional parameters that can be given to the
`course_success_rate` that will change the level of analysis of the
output. By default, the courses success rates are reported in their raw
format containing the number of withdrawals, failures, fails and total
students.

## `course_success_rate_publ`

Building off the previous function, `course_success_rate`, the
`course_success_rate_publ` function will output a date frame that is
ready for publication either for the portal or to be distributed to
various stakeholders. All that is required is for the user to designate
which academic year they would like to look at. Additionally, the user
can use the `map` functions from the `purrr` package to retrieve the
courses success rates for all academic years, of which are available.
Running the following line of code will output the data frame.

``` r
course_success_rates_publ("B90")
```

# Student Table

The following set of functions are executed using the Student table
found in the Data Warehouse tables provided by the WA State Board. In
addition to having access to the tables you will also will have to have
created a odbc connection on your machine while using the `odbc` package
to make the connection in R. For a walkthrough on how to do that you can
visit is this [page](https://db.rstudio.com/odbc/). After binding the
database to an object in R. The following is an example of what your
code should look like:

``` r
connection <- dbConnect(odbc::odbc(), "R Data")

student_tbl <- tbl(con, "STUDENT") %>% #in parenthesis is the name of table as given by SBCTC
  collect() %>% #binds the object to the student_tbl name
  clean_names() %>% #turns names into snake_case
  filter(year %in% c("B78", "B89")) %>% 
  .....
```

This format of making connections to and storing data will apply to any
other tables you would like to incorporate into R. You can also use the
“Connections” tab that is part of the *Environment, History, and
Connections* pane if you prefer that method.

## Dual Enrollment

This section details functions that can be used for either Running Start
or College in the High School students. To be able to use any of the
functions you will have had created a connection to the DW tables,
specifically the Student table.

#### Running Start Students

##### `rs_fte_contribution()`

To calculate how many or what percentage of BBCC’s FTEs come from
running start students one can run the following function.

``` r
student_tbl %>% 
  rs_fte_contribution() %>% 
  filter(str_detect(yrq, "B[6-9][0-9][2-4]"))
```

##### `rs_demographics()`

Running the following function will provide a breakout of Running
Students for each year. Additionally if desired, one can choose a
specific high school to breakout by. In choosing the school you can pass
the entire name or you can guess (i.e Ep instead of Ephrata High
School).

``` r
student_tbl %>% 
  rs_demographics()

rs_demographics(student_tbl, high_school_name = 'Eph')

student_tbl %>%
  rs_demographic(high_school_name = "Ephrata") %>%
  filter(year == "B78")
```

#### College In The High School

The `ciHS_demographics()` function is the same as the
`rs_demographics()` function except that the former focuses on College
In The High School students.

``` r
student_tbl %>% 
  ciHS_demographics(high_school_name = "Eph") %>%
  filter(year >= "B23")
```

## Yearly Infographic

Every year Institutional Resesrach is tasked with updating the
infographic found the onthe Institutional Research and Planning
[webpage](https://www.bigbend.edu/information-center/institutional-research-planning/).
Running the `infographic()` function will return a `gt` table that can
be exported using the `gtsave()` from `gt` package to turn the table
into a pdf which is than sent the head of communication. There are two
arguments that are necessary to include. The first is the academic year
in the form of “\[B-C\]…\]” and then the district population of Adams
and Grant County which is retrieved from the [Census Fact Finder
site](https://www.census.gov/quickfacts/fact/table/grantcountywashington,adamscountywashington,US/PST045219).

``` r
infographic("B90", "117,716")
```

# Other

## Dealing With SIDs

From time to time there may be extra characters (spaces or hyphen)
within an students sid that may hinder one from joining to other tables.
To correct such issues, use the `clean_sids()` function. Doing so will
remove any extra spaces of hyphens found within an sid. Currently those
are the two most common characters found in an sid, but certainly more
characters can be added. For the `clean_sid()` function to work proper,
the field must be named *sid*.

These are **NOT** real sids.

``` r
messy_sids <- tibble(
  sid = c("123456789", "987654321", "273859371", "848- 34-7859", "274-05-9031  ", "562058276",
          "495-09-9624", "902-48-2957"))

dashed_ids %>% 
  clean_sids()
```

## Student Enrolled In This Quarter

This function stems from a request we get asking to give a list of
students who are registered in a given and determining whether they are
enrolled in the subsquent quarter. More often than not it is between
Fall and Winter quarter but the way in which this function is written it
cann apply to any quarters. There are two arguments in this function,
one being the current quarter and the other being the target quarter.
Including them (yrq formate) will return a list of students who meet the
criteria as seen below.

``` r
stu_not_registred_nxt_qtr("C012", "C013")
```

Note that you do not have to provide this function any data since the
date source is being connected to form within the function.
