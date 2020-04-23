clean_dw_transcript <- function(data) {
  {{data}} %>%
    filter(!dept_div %in% c("NSO", "DVS", "FIR", "COM", "JST", "CPT", "HSC", "OPD"),
           !str_detect(dept_div, "BDC[A-Z]"),
           course_num >= "090",
           cr > 0,
           item != "XOXO",
           !sect %in% c("A#P", "C#P", "OCW", "PLC", "T#P", "ACE", "HSP", "HSC", "CBE", "CLG", "CHP", "CRT", "I#B"))
}
