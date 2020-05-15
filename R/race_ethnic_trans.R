#'  Allows the user to convert numberical codes for racial/ethnic codes into A/W or HUG grouping for BBCC.
#'
#' @param data A dataframe containing desired data
#'
#' @return A new column containing recoded data
#' @export
#'
#' @examples
#'
#' df %>%
#'   race_ethnic_trans()
#'
#'
race_ethnic_trans <- function(data) {
  {{data}} %>%
    mutate(race_ethnic_grps = case_when(race_code %in% c("1", "6") ~ "A/W",
                                        is.na(race_code) ~ "Unknown",
                                        TRUE ~ "HUG"))
}

