bbccIR 0.1.1.9000
=================

[Edgar Zamora \| Twitter:
`@Edgar_Zamora_`](https://twitter.com/Edgar_Zamora_)
<img src="bbccIR_logo.png" align="right" style="width:200px;height:200x;">

The `bbccIR` package is a collection of functions that will aid the
department of Institutional Research and Planning in conducting analysis
for the college. Functions range from themes in `ggplot` to shaping the
data stored in our data warehouse.

To install the `bbccIR` package run the following code:

``` r
devtools::install_github("Edgar-Zamora/bbccIR")
```

Data Warehouse Tables
=====================

The following sections detail transformations, visualations, and/or
calculations that can be made to the tables that are found within our
data warehouse (e.g. transcripts, class, student, etc.). For the
functions to work you have to retrieve and store the table as a R
object.

Transcript Table
================

### `clean_dw_transcript`

The `clean_dw_transcript` function will remove those courses that are
not neccessary when looking at course level data. This function will be
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
format containing the number of withdrawls, failfures, fails and total
students.

Student Table
=============

Running Start Students
----------------------

### `rs_fte_contribution()`

To calculate how many or what percentage of BBCC’s FTEs come from
running start students one can run the following function.

``` r
student_tbl %>% 
  rs_fte_contribution() %>% 
  filter(str_detect(yrq, "B[6-9][0-9][2-4]"))
```

Creating Race/Ethnic groups
---------------------------

### `race_ethnic_trans()`

Allows the recoding of the the *race\_ethnic\_code* variable in to the
ethnic/racial groups that are commonly used when reporting our data.
Running the `race_ethnic_trans()` will result in a new column named
**race\_ethnic\_grps** that will contain the following values: A/W
(Asian and White), HUG (Historically Underrepresented groups), and
Unknown.

``` r
student_tbl %>% 
  race_ethnic_trans()
```
