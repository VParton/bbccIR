bbccIR 0.1.2.9000 <img src="man/bbccIR_hex.png" align="right" style="width:200px;height:200x;">
===============================================================================================

[Edgar Zamora \| Twitter:
`@Edgar_Zamora_`](https://twitter.com/Edgar_Zamora_)

The `bbccIR` package is a collection of functions that will aid the
department of [Institutional Research and
Planning](https://www.bigbend.edu/information-center/institutional-research-planning/)
in conducting analysis for the college. Functions range from themes in
`ggplot` to shaping the data stored in our data warehouse.

To install the `bbccIR` package run the following code:

``` r
devtools::install_github("Edgar-Zamora/bbccIR")
```

Data Warehouse Tables
=====================

The following sections detail transformations, visualizations, and/or
calculations that can be made to the tables that are found within our
data warehouse (e.g. transcripts, class, student, etc.). For the
functions to work you have to retrieve and store the table as a R
object.

Class Table
===========

### `state_fte`

The `state_fte` function will calculate and disaggrate state FTE by
student intent for a given year quarter. This function is accessing data
from the local ods and will change daily when viewing current quarter
state FTEs. As for previous years the FTEs will be static and will not
change. To view a more complete picture of all state FTEs over years you
can visit the Tableau
[dashboard](https://tableau.sbctc.edu/t/BBCC/views/LiveClassCapacity/StateFTEDashboard?iframeSizedToWindow=true&%3Aembed=y&%3AshowAppBanner=false&%3Adisplay_count=no&%3AshowVizHome=no&%3Aorigin=viz_share_link)
found on the portal.

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

Transcript Table
================

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

The second method is using the pipe (%&gt;%) as so:

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

The second method is using the pipe (%&gt;%) as so:

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

Student Table
=============

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
other tables you would like to incoporate into R. You can also use the
“Connections” tab that is part of the *Enviornment, History, and
Connections* pane if you prefer that method.

Dual Enrollment
---------------

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
`rs_demographics()` function execept that the former focuses on College
In The High School students.

``` r
student_tbl %>% 
  ciHS_demographics(high_school_name = "Eph") %>%
  filter(year >= "B23")
```

Creating Race/Ethnic groups
---------------------------

### `race_ethnic_trans()`

Allows the recoding of the the *race\_ethnic\_code* variable into the
ethnic/racial groups that are commonly used when reporting our data.
Running the `race_ethnic_trans()` will result in a new column named
**race\_ethnic\_grps** that will contain the following values: A/W
(Asian and White), HUG (Historically Underrepresented groups), and
Unknown.

``` r
student_tbl %>% 
  race_ethnic_trans()
```

Dealing With SIDs
-----------------

From time to time there may be extra characters (spaces or hyphen)
within an students sid that may hinder one from joining to other tables.
To correct such issues, use the `clean_sids()` function. Doing so will
remove any extra spaces of hyphens found within an sid. Currently those
are the two most common characters found in an sid, but certainly more
characters can be added.

These are **NOT** real sids.

``` r
messy_sids <- tibble(
  sid = c("123456789", "987654321", "273859371", "848- 34-7859", "274-05-9031  ", "562058276",
          "495-09-9624", "902-48-2957"))

dashed_ids %>% 
  clean_sids()
```

Required Packages
=================

``` r
library(tidyverse)
library(odbc)
library(janitor)
library(dbplyr)
```

License
=======

All rights are reserved to Big Bend Community College regarding the
usage of their logo in the hex sticker.
