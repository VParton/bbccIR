#' Clean DW Transcript Table
#'
#' Used to clean the transcript table by removing non-credit course, community courses, or any other not applicable courses.
#'
#' @param data Name of R object that contains the TRANSCRIPT data.
#'
#' @import dplyr
#'
#' @return A dataframe with a cleaned transcript table
#' @export
#'
#' @examples
#'
#' library(tibble)
#' library(magrittr)
#'
#' df <- tibble(
#'         dept_div = c("NSO", "DVS", "CHEM&", "ENGL", "BDC"),
#'         course_num = c("100", "098", "121", "099", "121"),
#'         cr = c(NA, NA, 5, 5, 2),
#'         item = c("XOXO", "1", "2", "3", "4"),
#'         sect = c("A#P", "HY", "OL1", NA, "OL3"),
#'         class_size = c(500, 20, 25, 25, 25)
#'         )
#'
#'  df
#'
#'
#'# Piping clean_dw_transcripts will return those courses that should
#'# be excluded from course success.
#'
#'  df %>%
#'    clean_dw_transcript()
#'
#'
#'
clean_dw_transcript <- function(data) {

  data %>%
    filter(!dept_div %in% c("NSO", "DVS", "FIR", "COM", "JST", "CPT", "HSC", "OPD"),
           course_num >= '090',
           cr > 0,
           !item %in% 'XOXO',
           !sect %in% c("A#P", "C#P", "OCW", "PLC", "T#P", "ACE", "HSP", "HSC", "CBE",
                        "CLG", "CHP", "CRT", "I#B"),
           !str_detect(dept_div, "BDC[A-Z]"))
}
