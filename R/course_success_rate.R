#' Calculating course success rates automatically. Note that the level of analysis will determine which parameters can be used.
#'
#'
#' @param data Complete transcrpt table from data warehouse
#' @param rate Determine the output type. Default is the raw output but can be changed to 'percent' to get
#'             pass rate as a percentage
#' @param graded Determine whether to view average gpa by individual course. By default graded is set to FALSE but can be
#'             changed by making graded equal to TRUE
#'
#' @return A dataframe of all the key metrics for course success rates
#' @export
#'
#' @examples
#' transcript_tbl %>%
#'    course_success_rates()
#'
#' transcript_tbl %>%
#'    course_success_rates(rate = 'percent')
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
