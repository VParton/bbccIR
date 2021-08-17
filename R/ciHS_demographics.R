#' Determine the demographic breakout of College In The High School students by High School
#'
#' @param data The student table saved as an object
#' @param high_school_name You can write out the entire name of the high school or match based on given name.
#'
#' @return A tibble will be returned
#'
#' @importFrom odbc odbc
#' @import dplyr
#' @importFrom stringi stri_isempty
#' @importFrom DBI dbConnect
#' @importFrom stringr str_trim
#' @importFrom stringr str_to_title
#' @importFrom stringr str_detect
#'
#' @export
#'

ciHS_demographics <- function(data, high_school_name = '') {

  con <- dbConnect(odbc::odbc(), "R Data")

  high_school_lu <- tbl(con, "dbo_HighSchool") %>%
    select(HighSchoolID, HighSchoolName) %>%
    collect() %>%
    clean_names() %>%
    mutate(high_school_id = str_trim(high_school_id),
           high_school_name = str_to_title(high_school_name))

  all_rs_data <- {{data}} %>%
    select(sid, year, dual_enroll, race_ethnic_code, hi_schl) %>%
    left_join(high_school_lu, by = c("hi_schl" = "high_school_id")) %>%
    filter(dual_enroll %in% c("2")) %>%
    distinct_all() %>%
    mutate(race_ethnic_code = case_when(race_ethnic_code %in% c("1", "6") ~ "A/W",
                                        is.na(race_ethnic_code) ~ "Unknown",
                                        TRUE ~ "HUG")) %>%
    count(year, race_ethnic_code, high_school_name)


  if(stri_isempty(high_school_name)) {

    all_rs_data

  } else {

    all_rs_data %>%
      filter(str_detect(high_school_name, {{high_school_name}}))
  }

}
