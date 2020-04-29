#' Clean DW Transcript Table
#'
#'Used to clean the transcript table by removing non-credit course, community courses, or any other not applicable.
#'
#' @param data name of object where the transcript data is stored from data warehouse
#'
#'
#' @return A dataframe with a cleaned transcript table
#' @export
#'
#' @examples
#' \donotrun{
#' transcript_tbl %>%
#'   clean_dw_transcript()
#'
#' }
#'
#'
clean_dw_transcript <- function(data) {

  {{data}} %>%
    filter(!dept_div %in% c("NSO", "DVS", "FIR", "COM", "JST", "CPT", "HSC", "OPD"),
           !str_detect(dept_div, "BDC[A-Z]"),
           course_num >= "090",
           cr > 0,
           item != "XOXO",
           !sect %in% c("A#P", "C#P", "OCW", "PLC", "T#P", "ACE", "HSP", "HSC", "CBE", "CLG", "CHP", "CRT", "I#B"))
}
