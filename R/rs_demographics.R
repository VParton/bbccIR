#' Determine the demographic breakout of RS by High School
#'
#' @description Determine the demographic breakout of Running Start Students by High School
#' @param data The student table saved as an object
#' @param high_school_name You can write out the entire name of the high school or match based on given name.
#' @param demographic Choose which demographic (sex or race/ethnicity) to breakout by.
#'
#' @importFrom DBI dbConnect
#' @importFrom odbc odbc
#' @import dplyr
#' @import stringr
#' @importFrom stringi stri_isempty
#'
#' @return Returns a tibble where each high school in a given year is broken out by the demographic choosen.
#' @export
#'
#'

rs_demographics <- function(data, demographic = NULL, high_school_name = '') {

  con <- dbConnect(odbc::odbc(), "R Data")

  high_school_lu <- tbl(con, "dbo_HighSchool") %>%
    select(HighSchoolID, HighSchoolName) %>%
    collect() %>%
    clean_names() %>%
    mutate(high_school_id = str_trim(high_school_id),
           high_school_name = str_to_title(high_school_name))

  rs_data <- {{data}} %>%
    select(sid, year, dual_enroll, sex, race_ethnic_code, hi_schl) %>%
    left_join(high_school_lu, by = c("hi_schl" = "high_school_id")) %>%
    filter(dual_enroll %in% c("1")) %>%
    mutate(race_ethnic_code = case_when(race_ethnic_code %in% c("1", "6") ~ "A/W",
                                        is.na(race_ethnic_code) ~ "Unknown",
                                        TRUE ~ "HUG")) %>%
    distinct_all() %>%
    count(year, {{demographic}}, high_school_name) %>%
    group_by(year, high_school_name) %>%
    mutate(percentage = round(n/sum(n), 2)) %>%
    rename(
      count = n
    ) %>%
    arrange(year, high_school_name, {{demographic}})



  # Accounting for if a user does not provide a high school
  if(stri_isempty(high_school_name)) {

    rs_data <- rs_data

  } else {

    rs_data <- rs_data %>%
      filter(str_detect(high_school_name, {{high_school_name}}))
  }


  return(rs_data)
}

