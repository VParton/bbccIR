#' Clean SIDs
#'
#' Use this function to remove SIDs that may have extra spaces or hyphens in them.
#'
#' @param data Any dataframe or list object contains sids
#' @import dplyr
#' @importFrom magrittr "%>%"
#' @importFrom stringr str_remove_all
#' @importFrom tibble tibble
#'
#' @return Returns a dataframe or list with clean sids.
#' @export
#'
#' @examples
#' library(magrittr)
#' library(dplyr)
#'
#' messy_sid <- c("1234", "123-4", " 1234-5")
#'
#' clean_sids(messy_sid)
#'

#'
#' tibble(messy_sid) %>%
#'    mutate(sid = clean_sids(messy_sid))
#'
#'
clean_sids <- function(data) {

  str_remove_all(str_trim(data), "[-|\\s]")
}
