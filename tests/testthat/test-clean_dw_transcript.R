test_that("cleaning for transcript is correct", {
  long_form <- transcript_tbl %>%
    filter(!dept_div %in% c("NSO", "DVS", "FIR", "COM", "JST", "CPT", "HSC", "OPD"),
           !str_detect(dept_div, "BDC[A-Z]"),
           course_num >= "090",
           cr > 0,
           item != "XOXO",
           !sect %in% c("A#P", "C#P", "OCW", "PLC", "T#P", "ACE", "HSP", "HSC", "CBE", "CLG", "CHP", "CRT", "I#B"))

  expect_equal(clean_dw_transcript(transcript_tbl), long_form)
  })
