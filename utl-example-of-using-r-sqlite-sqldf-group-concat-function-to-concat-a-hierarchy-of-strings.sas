%let pgm=utl-example-of-using-r-sqlite-sqldf-group-concat-function-to-concat-a-hierarchy-of-strings;

%stop_submission;

Example of using r sqlite sqldf group concat function to concat a hierarchy of strings

github
https://tinyurl.com/2sbbxj7u
https://github.com/rogerjdeangelis/utl-example-of-using-r-sqlite-sqldf-group-concat-function-to-concat-a-hierarchy-of-strings

related repo
https://tinyurl.com/37kr8jcn
https://github.com/rogerjdeangelis/utl-example-of-sqlite-group_concat-and-associated-sas-datastep-solution

communities.sas.com
https://tinyurl.com/yu6f7t2m
https://communities.sas.com/t5/SAS-Procedures/new-variable-from-conditional-concatenation-of-observations-from/m-p/772510#M81075

/**************************************************************************************************************************/
/*    INPUT                         |       PROCESS                               |          OUTPUT                       */
/* Obs    LTR    HIER    COUNTRY    |  For later = A (selfexplanatory sql)        |  R                                    */
/*                                  |                                             |    LTR                grpcat          */
/*  1      A      123    Berlin     |  1 Concat country by ltr and hier > 122     |                                       */
/*  2      A       12    Germany    |                                             |  1   A                Berlin          */
/*  3      A        1    Europe     |     A     Berlin                            |  2   A        Berlin,Germany          */
/*  4      B      123    Lyon       |                                             |  3   A Berlin,Germany,Europe          */
/*  5      B       12    Nice       |  2 Concat country by ltr and hier > 11      |  4   B                  Lyon          */
/*  6      B        1    France     |                                             |  5   B             Lyon,Nice          */
/*                                  |     A     Berlin,Germany                    |  6   B      Lyon,Nice,France          */
/* options validvarname=upcase;     |                                             |                                       */
/* libname sd1 "d:/sd1";            |  3  Concat country by ltr and hier > 0      |                                       */
/* data sd1.have;                   |                                             |  SAS                                  */
/*       input ltr$ hier country$;  |     A     Berlin,Germany,Europe             |                                       */
/* cards4;                          |                                             |  LTR    GRPCAT                        */
/* A 123 Berlin                     |                                             |                                       */
/* A 12 Germany                     |  %utl_rbeginx;                              |   A     Berlin                        */
/* A 1 Europe                       |  parmcards4;                                |   A     Berlin,Germany                */
/* B 123 Lyon                       |  library(haven)                             |   A     Berlin,Germany,Europe         */
/* B 12 Nice                        |  library(sqldf)                             |   B     Lyon                          */
/* B 1 France                       |  source("c:/oto/fn_tosas9x.R")              |   B     Lyon,Nice                     */
/* ;;;;                             |  options(sqldf.dll = "d:/dll/sqlean.dll")   |   B     Lyon,Nice,France              */
/* run;quit;                        |  have<-read_sas("d:/sd1/have.sas7bdat")     |                                       */
/*                                  |  print(have)                                |                                       */
/*                                  |  want<-sqldf('                              |                                       */
/*                                  |    select                                   |                                       */
/*                                  |       ltr                                   |                                       */
/*                                  |      ,group_concat(country) as grpcat       |                                       */
/*                                  |    from                                     |                                       */
/*                                  |       have                                  |                                       */
/*                                  |    where                                    |                                       */
/*                                  |       hier > 122                            |                                       */
/*                                  |    group                                    |                                       */
/*                                  |       by ltr                                |                                       */
/*                                  |    union                                    |                                       */
/*                                  |    select                                   |                                       */
/*                                  |       ltr                                   |                                       */
/*                                  |      ,group_concat(country) as grpcat       |                                       */
/*                                  |    from                                     |                                       */
/*                                  |       have                                  |                                       */
/*                                  |    where                                    |                                       */
/*                                  |       hier > 11                             |                                       */
/*                                  |    group                                    |                                       */
/*                                  |       by ltr                                |                                       */
/*                                  |    union                                    |                                       */
/*                                  |    select                                   |                                       */
/*                                  |       ltr                                   |                                       */
/*                                  |      ,group_concat(country) as grpcat       |                                       */
/*                                  |    from                                     |                                       */
/*                                  |       have                                  |                                       */
/*                                  |    where                                    |                                       */
/*                                  |       hier > 0                              |                                       */
/*                                  |    group                                    |                                       */
/*                                  |       by ltr                                |                                       */
/*                                  |    order                                    |                                       */
/*                                  |       by ltr, grpcat                        |                                       */
/*                                  |    ')                                       |                                       */
/*                                  |  want                                       |                                       */
/*                                  |  fn_tosas9x(                                |                                       */
/*                                  |        inp    = want                        |                                       */
/*                                  |       ,outlib ="d:/sd1/"                    |                                       */
/*                                  |       ,outdsn ="want"                       |                                       */
/*                                  |       )                                     |                                       */
/*                                  |  ;;;;                                       |                                       */
/*                                  |  %utl_rendx;                                |                                       */
/*                                  |                                             |                                       */
/*                                  |  proc print data=sd1.want;                  |                                       */
/*                                  |  run;quit;                                  |                                       */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
      input ltr$ hier country$;
cards4;
A 123 Berlin
A 12 Germany
A 1 Europe
B 123 Lyon
B 12 Nice
B 1 France
;;;;
run;quit;

/**************************************************************************************************************************/
/* Obs    LTR    HIER    COUNTRY                                                                                          */
/*                                                                                                                        */
/*  1      A      123    Berlin                                                                                           */
/*  2      A       12    Germany                                                                                          */
/*  3      A        1    Europe                                                                                           */
/*  4      B      123    Lyon                                                                                             */
/*  5      B       12    Nice                                                                                             */
/*  6      B        1    France                                                                                           */
/**************************************************************************************************************************/

%utl_rbeginx;
parmcards4;
library(haven)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
options(sqldf.dll = "d:/dll/sqlean.dll")
have<-read_sas("d:/sd1/have.sas7bdat")
print(have)
want<-sqldf('
  select
     ltr
    ,group_concat(country) as grpcat
  from
     have
  where
     hier > 122
  group
     by ltr
  union
  select
     ltr
    ,group_concat(country) as grpcat
  from
     have
  where
     hier > 11
  group
     by ltr
  union
  select
     ltr
    ,group_concat(country) as grpcat
  from
     have
  where
     hier > 0
  group
     by ltr
  order
     by ltr, grpcat
  ')
want
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )
;;;;
%utl_rendx;

proc print data=sd1.want;
run;quit;

/**************************************************************************************************************************/
/*  R                            |   SAS                                                                                  */
/*    LTR                grpcat  |   LTR    GRPCAT                                                                        */
/*                               |                                                                                        */
/*  1   A                Berlin  |    A     Berlin                                                                        */
/*  2   A        Berlin,Germany  |    A     Berlin,Germany                                                                */
/*  3   A Berlin,Germany,Europe  |    A     Berlin,Germany,Europe                                                         */
/*  4   B                  Lyon  |    B     Lyon                                                                          */
/*  5   B             Lyon,Nice  |    B     Lyon,Nice                                                                     */
/*  6   B      Lyon,Nice,France  |    B     Lyon,Nice,France                                                              */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
