#' Clean IDs
#'
#' Use this function to remove SIDs or Emplids that may have extra spaces or hyphens in them.
#'
#' @param data Any dataframe or list object contains sids
#' @param check_errors Returns a column indicating whether there are errors for a given sid or emplid. Errors
#' are deemed as not having the right character length (9) or containing lettters in them.
#'
#'
#' @import dplyr
#' @importFrom magrittr "%>%"
#' @importFrom tibble tibble
#' @importFrom stringr str_remove_all
#' @importFrom stringr str_trim
#' @importFrom janitor clean_names
#'
#' @return Returns a dataframe or list with clean sids.
#' @export
#'
#' @examples
#' library(magrittr)
#' library(dplyr)
#'
#' messy_sids <- tibble(
#'   SID = c("123456789", "123-456-789", " 1234-56789", "12345"),
#'   Emplid = c("777777777", "8888-8989", " d34df8878", "77777"),
#'   name = c("Batman", "Supergirl", "Flash", "Aquaman")
#' )
#'
#' clean_ids(messy_sids)
#'
#' messy_sids %>%
#'   clean_ids(check_errors = TRUE)
#'
#'
clean_ids <- function(data, check_errors = FALSE) {
  message("Column names were set to snake case")

  output <- data %>%
    janitor::clean_names() %>%
    mutate(across(c(sid, emplid), ~stringr::str_remove_all(stringr::str_trim(.), "[-|\\s]")))


  if(check_errors == TRUE) {

    error_sid <- output %>%
      mutate(         across(c(emplid, sid), ~case_when(!str_detect(., "^[:digit:]+$") |
                                                          str_length(.) != "9" ~ "yes",
                                                        TRUE ~ 'no'),
                             .names = "pot_error_{col}"))

    return(error_sid)

  }


  return(output)

}
