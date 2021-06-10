#' Student Quarter Enrollment
#'
#' Running this function will allow one to find the last quarter in which a student is registered in. 
#'
#' @param current_qtr This is the last quarter in which a student attended.
#' @param summer Providing a field will allow for the inclusion of a summer quarter.
#'
#' @return
#' @export
#'
#' @examples
#'
#'
#' stu_not_registered_nxt_qtr("C014")
#' stu_not_registered_nxt_qtr("C014", "C121")
#'
#'
#'

stu_not_registered_nxt_qtr <- function(current_qtr, summer_qtr = NULL) {
  
  # Making database connection
  con <- dbConnect(odbc::odbc(), "R Data")
  
  output <- tbl(con, "dbo_Student") %>% 
    filter(StudentIntentID %in% c("A", "B", "F", "G", "M")) %>% 
    select(SID, FirstName, LastName, DaytimePhone, EveningPhone, Email, YRQLastAttended, StudentIntentID,
           EducationalProgramID, YRQTargetGrad, CollLevCREarned) %>% 
    collect() %>% 
    clean_names() %>% 
    filter(is.na(yrq_target_grad)) %>% 
    inner_join(tbl(con, "dbo_Enrollment") %>% 
                 filter(EnrolledCredits > 0) %>% 
                 select(SID, YearQuarterID) %>% 
                 collect() %>% 
                 clean_names(), by = c('sid', 'yrq_last_attended' = 'year_quarter_id')) %>% 
    distinct_all() %>% 
    left_join(tbl(con, "PROG CIP and NAME") %>% 
                collect() %>% 
                clean_names() %>% 
                select(program_code, program_title_general), by = c('educational_program_id' = 'program_code'))  %>% 
    left_join(tbl(con, "YRQ LU") %>% 
                collect() %>% 
                clean_names() %>% 
                select(yrq, year_qtr), by = c("yrq_last_attended" = "yrq")) %>% 
    distinct_all() %>% 
    arrange(sid)
  
  
  # Inclusion of summer quarter
  if(is.null(summer_qtr)){
    output %>% 
      filter(yrq_last_attended == {{current_qtr}})
  } else {
    output %>% 
      filter(yrq_last_attended == {{current_qtr}} | yrq_last_attended == {{summer_qtr}})
  }
}

