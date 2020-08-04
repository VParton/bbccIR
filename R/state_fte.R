#' state_fte
#'
#' @param data Will be the dbo class table saved as an R object
#' @param yrq The desired year quarter.
#'
#' @return returns a tibble.
#' @export
#'
#' @examples
#'
#' class %>%
#'    state_fte("C012)
#'
#'


state_fte <- function(data, yrq){
  {{data}} %>%
    filter(year_quarter_id == {{yrq}} & funding_source_id == 1) %>%
    select(class_id, institutional_intent_id, credit_equivalent, funding_source_id, enrollment_census_total, department) %>%
    mutate(
      course_fte = (credit_equivalent * enrollment_census_total)/15,
      department = str_trim(department),
      fte_type = case_when(
        institutional_intent_id %in% c("21", "22", "23") ~ "voc_fte",
        institutional_intent_id %in% c("11", "12", "13", "14", "15") & str_detect(department, "DVS") ~ "abe_ftes",
        institutional_intent_id %in% c("11", "12", "13", "14", "15")  ~ "acad_ftes",
        TRUE ~ "remove")) %>%
    filter(fte_type != "remove") %>%
    group_by(fte_type) %>%
    summarise(
      type_fte = sum(course_fte)) %>%
    mutate(total_fte = sum(type_fte))
}
