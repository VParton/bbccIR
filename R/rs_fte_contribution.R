#' Calculate RS FTE contribution
#'
#' @description Calculate the amount of ftes that running start students contribute to the colleges overall fte count for each quarter.
#' @param data A dataframe of the student table
#' @param no_summer Determine whether to exclude summer quarter as part of the output. By default it is set to FALSE
#' @export
#' @import dplyr
#'
#' @return A tibble will be returned

#' @examples
#' \dontrun{
#'
#' student_tbl %>%
#'   rs_fte_contribution(no_summer = TRUE)
#'
#' }
#'
#'
rs_fte_contribution <- function(data, no_summer = FALSE) {

  rs_ftes <- {{data}} %>%
    select(sid, yrq, ftes_total, running_start_status) %>%
    filter(!yrq %in% c("+", "19"),
           !is.na(yrq)) %>%
    mutate(rs_status = case_when(
      running_start_status == "1" ~ "rs_students",
      TRUE ~ "other")) %>%
    group_by(yrq,rs_status) %>%
    summarise(total_ftes = round(sum(ftes_total)/3, 0),
              num_students = n()) %>%
    ungroup() %>%
    group_by(yrq) %>%
    mutate(percent_rs = round(total_ftes/sum(total_ftes) * 100, 0)) %>%
    ungroup()

  if(no_summer == TRUE) {
    rs_ftes <- rs_ftes %>%
      filter(str_detect(yrq, "[A-Z][1-9][0-9][2-4]"))
  }

  return(rs_ftes)
}
