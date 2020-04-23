test_that("test if course success rate works", {

  long_form <- transcript_tbl %>%
    clean_dw_transcript() %>%
    mutate(outcome = case_when(
      gr == "W" ~ "Withdraw",
      gr == "N" ~ "noncomplete",
      gr == "P" ~ "Passed",
      gr_dec > 1.9 ~ "Passed",
      TRUE ~ "Failed")) %>%
    select(year, quarter, item, dept_div, course_num, course_title, cr, dist_ed, item, sect, outcome) %>%
    arrange(year, dept_div, course_num) %>%
    group_by(year, dept_div, course_num, course_title, cr, dist_ed, item, sect, outcome) %>%
    summarise(count = n()) %>%
    pivot_wider(names_from = outcome, values_from = count) %>%
    ungroup() %>%
    select(-noncomplete) %>%
    mutate(withdraw = if_else(is.na(Withdraw), 0, as.numeric(Withdraw)),
           passed = if_else(is.na(Passed), 0, as.numeric(Passed)),
           failed = if_else(is.na(Failed), 0, as.numeric(Failed)),
           total_stu = withdraw + passed + failed,
           pass_rate = round(passed/total_stu * 100, 1)) %>%
    select(year, dept_div, course_num, course_title, withdraw, passed, failed, total_stu, pass_rate, cr, dist_ed)

  short_form <- transcript_tbl %>%
    course_success_rate()

  expect_equal(short_form, long_form)

})
