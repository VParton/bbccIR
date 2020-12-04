#' Student Quarter Enrollment
#'
#' Running this function will allow one to see if a student is registered in designated quarter given the current quarter.
#'
#' @param current_qtr This is the quarter of which you want to start comparing.
#' @param nxt_qtr This is the quarter at which you want to see if a student is enrolled in.
#'
#' @return
#' @export
#'
#' @examples
#'
#' stu_not_registred_nxt_qtr("C012", "C013")
#'
#'
#'

stu_not_registred_nxt_qtr <- function(current_qtr, nxt_qtr) {

  # Making database connection
  con <- dbConnect(odbc::odbc(), "R Data")


  # Loading tables
  current_qtr <- tbl(con, "dbo_enrollment") %>%
    filter(YearQuarterID == {{current_qtr}},
           EnrolledCredits > 0) %>%
    select(SID, YearQuarterID) %>%
    collect() %>%
    clean_names() %>%
    distinct_all()


  desired_qtr <- tbl(con, "dbo_enrollment") %>%
    filter(YearQuarterID == {{nxt_qtr}},
           EnrolledCredits > 0) %>%
    select(SID) %>%
    collect() %>%
    clean_names() %>%
    mutate(nxt_qtr = "yes") %>%
    distinct_all()

  stu_not_registred <- current_qtr %>%
    anti_join(desired_qtr, by = "sid") %>%
    rename(
      current_qtr = year_quarter_id
    )  %>%
    left_join(tbl(con, "dbo_Student") %>%
                select(SID, FirstName, LastName, DaytimePhone, EveningPhone, Email,
                       NTUserName, EducationalProgramID, StudentIntentID) %>%
                collect() %>%
                clean_names(), by = "sid") %>%
    left_join(tbl(con, "PROGRAM NAME LU") %>%
                collect() %>%
                clean_names(), by = c("educational_program_id" = "program_code")) %>%
    filter(!str_detect(str_trim(nt_user_name), "\\.")) %>%
    mutate(bbcc_email = paste0(str_trim(nt_user_name), "@bigbend.edu")) %>%
    select(-nt_user_name) %>%
    distinct_all()

  return(stu_not_registred)

}
