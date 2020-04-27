#' Calculating course success rates
#'
#' @param data
#' @param rate Determine the output type. Default is the raw output but can be changed to 'percent' to get
#'             pass rate as a percentage
#'
#' @return A dataframe of all the key metrics for course success rates
#' @export
#'
#' @examples
#' \donotrun{
#' transcript_tbl %>%
#'    course_success_rates()
#'
#' transcript_tbl %>%
#'    course_success_rates(rate = 'percent')
#'
#' }
#'
#'
course_success_rate <- function(data, rate = 'raw') {

  core_data <- {{data}} %>%
    clean_dw_transcript() %>%
    mutate(outcome = case_when(
      gr == "W" ~ "Withdraw",
      gr == "N" ~ "noncomplete",
      gr == "P" ~ "Passed",
      gr_dec > 1.9 ~ "Passed",
      TRUE ~ "Failed")) %>%
    select(year, quarter, item, dept_div, course_num, course_title, cr, dist_ed, item, sect, outcome) %>%
    arrange(year, dept_div, course_num) %>%
    group_by(year, dept_div, course_num, course_title, cr, dist_ed, item, sect, outcome) %>%
    summarise(count = n()) %>%
    pivot_wider(names_from = outcome, values_from = count) %>%
    ungroup() %>%
    select(-noncomplete) %>%
    mutate(withdraw = if_else(is.na(Withdraw), 0, as.numeric(Withdraw)),
           passed = if_else(is.na(Passed), 0, as.numeric(Passed)),
           failed = if_else(is.na(Failed), 0, as.numeric(Failed)),
           total_stu = withdraw + passed + failed) %>%
    select(year, dept_div, course_num, course_title, withdraw, passed, failed, total_stu, cr, dist_ed)


  if(rate == 'percent'){
    core_data <- core_data %>%
      mutate(pass_rate = round(passed/total_stu * 100, 1)) %>%
      select(year, dept_div, course_num, course_title, withdraw, passed, failed, pass_rate, total_stu, cr, dist_ed)
  }

  return(core_data)

}
