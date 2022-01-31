#' Clean SIDs
#'
#' Use this function to remove SIDs that may have extra spaces or hyphens in them.
#'
#' @param data Any dataframe or list object contains sids
#' @param check_length Return a column that indicates whether an sid is the correct lenght, 9 characters.
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
#'   name = c("Batman", "Supergirl", "Flash", "Aquaman")
#'   )
#'
#' clean_sids(messy_sids)
#'
#' messy_sids %>%
#'   clean_sids()
#'
#'
clean_sids <- function(data, check_length = FALSE) {
  message("Column names were set to snake case")

  output <- data %>%
    janitor::clean_names() %>%
    mutate(clean_sid = stringr::str_remove_all(stringr::str_trim(sid), "[-|\\s]"))


  if(check_length == TRUE) {

    error_sid <- output %>%
      mutate(pot_sid_error = if_else(!str_length(clean_sid) != 9, "no", 'yes'))

    return(error_sid)

  }


  return(output)

}
