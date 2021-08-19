#' Generate infographic information
#'
#' @description Providing numbers of information that is used for the infographic found on the Institutional Research and Planning webpage.
#'
#' @param year Choose which year to pull
#' @param district_pop Insert the district population of Adams and Grant county that is obtained from the Census factfind webpag
#'
#' @import gt
#' @importFrom janitor clean_names
#' @importFrom glue glue
#' @importFrom stats median
#' @import dplyr
#' @importFrom tibble add_row
#' @importFrom purrr pluck
#' @importFrom odbc odbc
#' @importFrom DBI dbConnect
#'
#'
#' @return Returns a gt tbl that can be saved as pdf or png.
#' @export
#'
#' @examples
#' \dontrun{
#'
#' infogrpahic("C01", 50,000)
#'
#' }
infographic <- function(year, district_pop) {

  con <- dbConnect(odbc::odbc(), "R Data")

  year_title <- tbl(con, "YRQ LU") %>%
    dplyr::collect() %>%
    janitor::clean_names() %>%
    filter(yr == {{year}}) %>%
    distinct(year_long) %>%
    pull(year_long)

  infogrpahic <- tbl(con, "STUDENT") %>%
    dplyr::collect() %>%
    janitor::clean_names() %>%
    filter(year == {{year}}) %>%
    select(sid, intent, race_ethnic_code, sex, age, ftes_total, yrq, dual_enroll, credits_total, econ_disad_ind) %>%
    distinct_all()

  #------------------------------------------

  total_headcount <- infogrpahic %>%
    distinct(sid) %>%
    count() %>%
    pull()

  #------------------------------------------

  fte <- infogrpahic %>%
    summarise(ftes_total = as.character(round(sum(ftes_total)/3, 0))) %>%
    pull()

  #------------------------------------------

  ethnicity <- infogrpahic %>%
    filter(!is.na(race_ethnic_code),
           intent %in% c("A", "B", "F", "G", "M", "X", "D")) %>%
    distinct(sid, race_ethnic_code) %>%
    mutate(value = case_when(race_ethnic_code %in% c("7", "1") ~ "Asian/Pacific Islander",
                             race_ethnic_code == "2" ~ "African American",
                             race_ethnic_code == "3" ~ "Alaskan Native/Native American/American Indian",
                             race_ethnic_code == "4" ~ "Hispanic",
                             race_ethnic_code == "5" ~ "Two or more races",
                             TRUE ~ "White/Caucasian")) %>%
    count(value) %>%
    mutate(percentage = paste0(round(n/sum(n) * 100, 0), "%")) %>%
    select(-n)

  #------------------------------------------

  intent_j_l <- tbl(con, "TRANSCRIPTS") %>%
    dplyr::collect() %>%
    janitor::clean_names() %>%
    filter(dept_div %in% c("OPD", "HSC", "DVS") & year == {{year}}) %>%
    inner_join(infogrpahic, by = c("yrq", "sid")) %>%
    filter(intent %in% c("D", "L")) %>%
    distinct(sid)


  student_intent <- infogrpahic %>%
    filter(intent %in% c("A", "B", "F", "M", "J")) %>%
    distinct(sid, intent) %>%
    mutate(value = case_when(intent %in% c("F", "M") ~ "Workforce",
                             intent == "J" ~ "Industry Training",
                             TRUE ~ "Academic")) %>%
    count(value) %>%
    tibble::add_row(value = "Developmental", n = 612) %>%
    mutate(percentage = paste0(round(n/sum(n) * 100, 0), "%")) %>%
    select(-n)

  #------------------------------------------
  sex_ratio <- infogrpahic %>%
    distinct(sid, sex, yrq) %>%
    count(sex) %>%
    filter(!is.na(sex)) %>%
    mutate(percentage = paste0(round(n/sum(n) * 100, 0), "%")) %>%
    rename(value = sex) %>%
    select(-n)

  #------------------------------------------
  age <- infogrpahic %>%
    filter(intent %in% c("A", "B", "F", "G",
                         "M", "X", "D")) %>%
    distinct(sid, age)


  #------------------------------------------
  #retrieved from https://www.census.gov/quickfacts/fact/table/grantcountywashington,adamscountywashington,US/PST045219
  district_population <- tibble(
    value = "",
    percentage = {{district_pop}}
  )

  #------------------------------------------

  need_based_aid <- infogrpahic %>%
    select(sid, econ_disad_ind, dual_enroll, intent, credits_total) %>%
    filter(credits_total > 5.5,
           intent %in% c("A", "B", "J", "M"),
           !dual_enroll %in% c("1", "2") | is.na(dual_enroll)) %>%
    distinct(sid, econ_disad_ind) %>%
    count(econ_disad_ind) %>%
    mutate(percentage = paste0(round(n/sum(n) * 100, 0), "%")) %>%
    purrr::pluck("percentage", 1)

  #------------------------------------------

  infographic_tbl <- ethnicity %>%
    bind_rows(student_intent, sex_ratio, district_population) %>%
    add_row(value = "", percentage = as.character(total_headcount)) %>%
    add_row(value = "", percentage = as.character(fte)) %>%
    add_row(value = "", percentage = as.character(round(median(age$age, na.rm = T), 0))) %>%
    add_row(value = "", percentage = need_based_aid) %>%

    # Building tab with gt package
    gt() %>%
    tab_header(
      title = glue('{year_title} Infographic Information')
    ) %>%
    tab_row_group(
      group = "Ethnicity",
      rows = 1:6
    ) %>%
    tab_row_group(
      group = "Student Intent",
      rows = 7:10
    ) %>%
    tab_row_group(
      group = "Headcount",
      rows = 14
    ) %>%
    tab_row_group(
      group = "Female/Male Ratio",
      rows = 11:12
    ) %>%
    tab_row_group(
      group = "Full-time equivalent students",
      rows = 15
    ) %>%
    tab_row_group(
      group = "District Population",
      rows = 13
    ) %>%
    tab_row_group(
      group = "Median Age",
      rows = 16
    ) %>%
    tab_row_group(
      group = "Need-based aid",
      rows = 17
    ) %>%
    cols_label(
      value = "",
      percentage = " "
    ) %>%
    tab_options(
      row_group.background.color = "#c7c7c7"
    )

  return(infographic_tbl)

}
