#' Calculate course success rates
#'
#'
#' @param data Complete transcrpt table from data warehouse
#' @param rate Determine the output type. Default is the raw output but can be changed to 'percent' to get
#'             pass rate as a percentage
#' @param graded Determine whether to view average gpa by individual course. By default graded is set to FALSE but can be
#'             changed by making graded equal to TRUE
#'
#' @import dplyr
#' @importFrom tidyr pivot_wider
#'
#' @return A dataframe of all the key metrics for course success rates
#' @export
#'
#' @examples
#' \dontrun{
#'
#' transcript_tbl %>%
#'   course_succces_rate(rate = 'percent')
#'
#'
#' transcript_tbl %>%
#'   course_success_rate(graded = TRUE)
#'
#' }
#'
#'
course_success_rate <- function(data, rate = 'raw', graded = FALSE) {

  transcripts <- {{data}} %>%
    clean_dw_transcript() %>%
    mutate(outcome = case_when(
      gr == "W" ~ "withdraw",
      gr == "N" ~ "noncomplete",
      gr == "P" ~ "passed",
      gr_dec > 1.9 ~ "passed",
      TRUE ~ "failed")) %>%
    filter(!gr %in% c("*", "N", "Y")) %>%
    select(year, quarter, item, dept_div, course_num, course_title, cr, dist_ed, item, sect, outcome, gr_dec)

  if(rate %in% c('raw', 'percent')){

    raw_data <- transcripts %>%
      select(-c(quarter, gr_dec)) %>%
      group_by_all() %>%
      summarise(count = n()) %>%
      pivot_wider(names_from = outcome, values_from = count) %>%
      ungroup() %>%
      mutate_at(vars("withdraw", "failed", "passed"),
                ~if_else(is.na(.), 0, as.double(.))) %>%
      mutate(total_stu = withdraw + passed + failed) %>%
      select(year, dept_div, course_num, item, course_title, cr, dist_ed, withdraw, passed, failed, total_stu)

    if(rate == 'percent'){
      results_data <- raw_data %>%
        mutate(pass_rate = round(passed/total_stu * 100, 1)) %>%
        select(year, dept_div, course_num, item, course_title, cr, dist_ed, withdraw, passed, failed, total_stu, pass_rate)
    } else{
      results_data <- raw_data
    }
  }

  if(graded == TRUE){
    results_data <- transcripts %>%
      group_by(year, quarter, dept_div, course_num, sect, item, course_title) %>%
      summarise(total_stud = n(),
                withdrawls = sum(outcome == "withdraw"),
                failed = sum(outcome == "failed"),
                passed = sum(outcome == "passed"),
                graded_stud = total_stud - withdrawls,
                avg_grd = mean(gr_dec[outcome != "withdraw"])) %>%
      ungroup() %>%
      select(year, quarter, dept_div, course_num, sect, item, course_title, withdrawls, failed, passed, graded_stud, total_stud, avg_grd)
  }

  return(results_data)

}




#' Publication ready course success rates
#'
#' @param academic_year Designate academic year using codes.
#'
#' @import dplyr
#' @importFrom janitor clean_names
#' @importFrom glue glue
#'
#' @return A tibble containing course success rates in a summarized fashion.
#' @export
#'
#' @examples
#' \dontrun{
#'
#' course_success_rates_publ("C01")
#'
#' course_success_rates_publ("B56")
#'
#' }
#'
course_success_rates_publ <- function(academic_year) {

  con <- dbConnect(odbc(), "R Data")

  transcript <- tbl(con, "TRANSCRIPTS") %>%
    collect() %>%
    clean_names() %>%
    filter(year == {{academic_year}}) %>%
    course_success_rate()


  year_lu <- tbl(con, "YRQ LU") %>%
    collect() %>%
    clean_names() %>%
    select(yr, year_long)



  # Each year has the potential for new courses.
  year <- {academic_year}

  tbl_name <- glue("Course and Division LU {year}")


  dept_dvision_lu <- tbl(con, tbl_name) %>%
    collect() %>%
    clean_names() %>%
    select(-year)



  course_success_pub <- transcript %>%
    select(-item) %>%
    group_by(year, dept_div, course_num, course_title) %>%
    summarise(
      withdraws = sum(withdraw),
      passed = sum(passed),
      failed = sum(failed),
      total_stu = sum(total_stu),
      percent_pass = paste0(round(passed/total_stu * 100, 0), "%")) %>%
    ungroup() %>%
    left_join(year_lu, by = c("year" = "yr")) %>%
    left_join(dept_dvision_lu, by = c("dept_div", "course_num")) %>%
    distinct_all() %>%
    select(year_long, division, department, dept_div, course_num, course_title,
           withdraws, failed, passed, total_stu, percent_pass) %>%
    rename(
      `Academic Year` = year_long,
      Division = division,
      Department = department,
      Dept = dept_div,
      `Course Number` = course_num,
      Title = course_title,
      Withdraws = withdraws,
      `Unsucessful Students` = failed,
      `Successful Students` = passed,
      `Total Enrolled` = total_stu,
      `Percent Successful` = percent_pass
    ) %>%
    group_by(Division) %>%
    arrange(Division)

  return(course_success_pub)

}


