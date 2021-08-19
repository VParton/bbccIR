#' Student Rention
#'
#' @description The resulting data set contains columns with information about a student
#' returning in subsquent quarters after their initial quater.
#'
#'
#' @param data A R object with the STUDENT table
#' @param cohort_yr The academic year of the starting cohort
#' @param nxt_yrq The following academic year after the cohort
#'
#' @family return
#' @return A data frame with demographics and retention for each student in the designated
#' starting cohort
#' @export
#'
#' @examples
#' \dontrun{
#'
#' student %>%
#'   retention('B90', 'C01')
#'
#' }
#'
#'
#'
retention <- function(data, cohort_yr, nxt_yr) {


  # Determining whether next qtrt data is available
  max_yrq <- data %>%
    distinct(yrq) %>%
    arrange(desc(yrq)) %>%
    slice(1) %>%
    pull()



  if(max_yrq < nxt_yrq){

    warning("Next Fall Quarter data may not be available yet")

  }



  # Storing quarter values
  cohort_yrq <- glue("{cohort_yr}2")
  winter <- glue("{cohort_yr}3")
  spring <- glue("{cohort_yr}4")
  nxt_fall <- glue("{nxt_yr}2")


  # Building incoming student cohort

  con <- dbConnect(odbc::odbc(), "R Data")

  og_cohort <- data %>%
    filter(yrq == cohort_yrq,
           intent %in% c("A", "B", "F", "G", "M"),
           source == "4") %>%
    select(yrq, sid, race_ethnic_ind, sex, dual_enroll, age, intent) %>%
    mutate(dual_enroll_status = case_when(dual_enroll %in% c("1", "2") ~ "Yes",
                                          TRUE ~ "No"),
           age_grp = case_when(age < 20.0 ~ "Under 20",
                                             age > 25.0 ~ "25 and older",
                                             is.na(age) ~ "Not Reported",
                                             TRUE ~ "20-25"),
         student_type = case_when(intent %in% c("A", "B")  ~ "Transfer",
                                  TRUE ~ "Workforce")) %>%
    left_join(tbl(con, "RACE_ETH LU") %>%
                collect() %>%
                clean_names(), by = c("race_ethnic_ind")) %>%
    distinct_all()




  retention_data <- og_cohort %>%
    left_join(student %>%
                filter(yrq == winter) %>%
                select(sid, yrq) %>%
                rename("winter" = yrq), by = "sid") %>%
    left_join(student %>%
                filter(yrq == spring) %>%
                select(sid, yrq) %>%
                rename("spring" = yrq), by = c("sid")) %>%
    left_join(student %>%
                filter(yrq == nxt_fall) %>%
                select(sid, yrq) %>%
                rename("nxt_fall" = yrq),  c("sid"))


  return(retention_data)

}




#' Summarized Student Retention
#'
#' @description The resulting data set is a summarized view of rention data.
#'
#' @param data A data set containing retention data
#' @param desired_qtr The quarter for which you want to get retention data for
#' @family retention
#'
#' @return
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' retention_data %>%
#'   retention_summarized(winter)
#'
#'
#'
#' student %>%
#'   retention('B90', 'C01') %>%
#'   retention_summarized(winter)
#'
#' }
#'
retention_summarized <- function(data, desired_qtr){


  # Calculating retention for each race/ethnicity group as well as the overall cohort
  race <- data %>%
    count(yrq, {{desired_qtr}}, race_ethn) %>%
    group_by(yrq, race_ethn) %>%
    mutate(return_rate = n/sum(n),
           group_total = sum(n)) %>%
    filter(!is.na({{desired_qtr}})) %>%
    rename(
      group = race_ethn,
      return_qtr = {{desired_qtr}}
    )


  overall <- data %>%
    count(yrq, {{desired_qtr}}) %>%
    group_by(yrq) %>%
    mutate(return_rate = n/sum(n),
           group_total = sum(n),
           group = "Overall") %>%
    filter(!is.na({{desired_qtr}})) %>%
    rename(
      return_qtr = {{desired_qtr}}
    )


  # Binding data together
  retention_data <- rbind(race, overall)


  return(retention_data)

}






