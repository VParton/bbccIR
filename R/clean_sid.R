#' Clean SIDs
#'
#' Use this function to remove SIDs that may have extra spaces or hyphens in them.
#'
#' @param data Any dataframe object containing a column named 'sid'
#'
#' @return A dataframe containing a new column, 'clean_sid', with cleaned sid numbers.
#' @export
#'
#' @examples
#'
#' df %>%
#'   clean_sids()
#'
#'
#' df %>%
#'   select(sid) %>%
#'   clean_sids()
#'
clean_sids <- function(data) {

  {{data}} %>%
    mutate(sid = str_remove_all(str_trim(sid), "[-|\\s]"))
}
