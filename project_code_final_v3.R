# SQL group project

#load data
getwd()
library(data.table)
df<-fread("kpav-sd4t.csv",encoding = "UTF-8")
df <- as.data.frame(df)
str(df)
nrow(df)


### ------------------------- create table in database ----------------------------------
#install packages
require('RPostgreSQL')
library(dplyr)

# Load the PostgreSQL driver
drv <- dbDriver('PostgreSQL')

# Create a connection
con <- dbConnect(drv, dbname = 'NYC_job',
                 host = 'localhost', port = 5432,
                 user = 'postgres', password = '123')

stmt <- "
      CREATE TABLE agency(
        agency_id     integer,
        agency        varchar(150),
        work_location varchar(150),
        PRIMARY KEY(agency_id)
    );

    CREATE TABLE posting(
        post_id         integer,
        posting_updated date,
        posting_date    date,
        post_until      date,
        posting_type    char(8),
        PRIMARY KEY(post_id)
    );

    CREATE TABLE salary(
        salary_id         integer,
        salary_range_from numeric(12,4),
        salary_range_to   numeric(12,4),
        salary_frequency  varchar(10),
        PRIMARY KEY(salary_id)
    );

    CREATE TABLE requirement(
        requirement_id            integer,
        additional_information    varchar,
        preferred_skills          varchar,
        minimum_qual_requirements varchar,
        residency_requirement     varchar,
        PRIMARY KEY(requirement_id)
    );

    CREATE TABLE title(
        title_id             integer,
        title_code_no        char(5),
        civil_service_title  varchar(50),
        title_classification varchar(30),
        level                varchar(2),
        PRIMARY KEY(title_id)
    );

    CREATE TABLE job_category(
        category_id  integer,
        job_category varchar(150),
        PRIMARY KEY(category_id)
    );

    CREATE TABLE business_title(
        business_title_id integer,
        business_title    varchar(200),
        PRIMARY KEY(business_title_id)
    );

    CREATE TABLE application(
        apply_id integer,
        to_apply varchar,
        PRIMARY KEY(apply_id)
    );

    CREATE TABLE career(
        career_level_id integer,
        career_level    varchar(50),
        PRIMARY KEY(career_level_id)
    );

    CREATE TABLE division(
        division_id        integer,
        division_work_unit varchar(100),
        PRIMARY KEY(division_id)
    );

    CREATE TABLE job_info(
        id                            integer,
        job_id                        integer,
        business_title_id             integer,
        category_id                   integer,
        job_description               varchar,
        work_location                 varchar(200),
        requirement_id                integer,
        salary_id                     integer,
        division_id                   integer,
        title_id                      integer,
        career_level_id               integer,
        agency_id                     integer,
        apply_id                      integer,
        recruitment_contact           varchar(50),
        number_of_positions           integer,
        post_id                       integer,
        full_time_part_time_indicator char(1),
        hours_shift                   varchar(300),
        PRIMARY KEY(id),
        CHECK (full_time_part_time_indicator IN ('P','F')),
        FOREIGN KEY(business_title_id) REFERENCES business_title(business_title_id),
        FOREIGN KEY(category_id) REFERENCES job_category(category_id),
        FOREIGN KEY(requirement_id) REFERENCES requirement(requirement_id),
        FOREIGN KEY(salary_id) REFERENCES salary(salary_id),
        FOREIGN KEY(division_id) REFERENCES division(division_id),
        FOREIGN KEY(title_id) REFERENCES title(title_id),
        FOREIGN KEY(career_level_id) REFERENCES career(career_level_id),
        FOREIGN KEY(agency_id) REFERENCES agency(agency_id),
        FOREIGN KEY(apply_id) REFERENCES application(apply_id),
        FOREIGN KEY(post_id) REFERENCES posting(post_id)
    );

"

# Execute the statement to create tables
dbGetQuery(con, stmt)


### ------------------------- cleaning, formatting data ---------------------------------
# remove and check duplicates
df <- df[!duplicated(df), ]
nrow(distinct(df['job_id']))

# count na in dataframe
att_names <- names(df)
count_na <- c()
count_notna <- c()
for (i in 1:ncol(df)) {
  count_na <- c(count_na, sum(is.na(df[, i])))
  count_notna <- c(count_notna, sum(!is.na(df[, i])))
}
length(count_na)
length(count_notna)
na_summary <- cbind(data.frame(att_names), data.frame(count_na), data.frame(count_notna))
na_summary

# count empty cells in dataframe
count_empty <- c()
count_notempty <- c()
str(att_names)
for (i in 1:ncol(df)) {
  count_empty <- c(count_empty, sum(df[, i] == ""))
  count_notempty <- c(count_notempty, sum(df[, i] != ""))
}
empty_summary <- cbind(data.frame(att_names), data.frame(count_empty), data.frame(count_notempty))
empty_summary

str(df)

# change factors to characters
df <- df %>% mutate_if(is.factor, as.character)


### ------------------------- creating table --------------------------------------------
# create table agency
temp_agency_df <- df[c('agency','work_location')]
temp_agency_df <- temp_agency_df %>% distinct(agency, .keep_all = TRUE)
temp_agency_df$agency_id <- 1:nrow(temp_agency_df)
temp_agency_df <- temp_agency_df[c('agency_id','agency','work_location')]

# create table posting
posting_df <- df[c('posting_updated','posting_date','post_until','posting_type')]
posting_df <- unique(posting_df)
posting_df$post_id <- 1:nrow(posting_df)
posting_df <- posting_df[c('post_id','posting_updated','posting_date','post_until','posting_type')]

# create table salary
salary_df <- df[c('salary_range_to','salary_range_from','salary_frequency')]
salary_df <- unique(salary_df)
salary_df$salary_id <- 1:nrow(salary_df)
salary_df <- salary_df[c('salary_id','salary_range_to','salary_range_from','salary_frequency')]

# create table requirement
requirement_df <- df[c('additional_information','preferred_skills','minimum_qual_requirements','residency_requirement')]
requirement_df <- unique(requirement_df)
requirement_df$requirement_id <- 1:nrow(requirement_df)
requirement_df <- requirement_df[c('requirement_id','additional_information','preferred_skills','minimum_qual_requirements','residency_requirement')]

# create table title
title_df <- df[c('title_code_no', 'civil_service_title', 'title_classification', 'level')]
title_df <- unique(title_df)
title_df$title_id <- 1:nrow(title_df)
title_df <- title_df[c('title_id','title_code_no', 'civil_service_title', 'title_classification', 'level')]

# create table job_category
job_category_df <- df[c('job_category')]
job_category_df <- unique(job_category_df)
job_category_df$category_id <- 1:nrow(job_category_df)
job_category_df <- job_category_df[c('category_id','job_category')]

# create table business_title
business_title_df <- df[c('business_title')]
business_title_df <- unique(business_title_df)
business_title_df$business_title_id <- 1:nrow(business_title_df)

# create table application
application_df <- df[c('to_apply')]
application_df <- unique(application_df)
application_df$apply_id <- 1:nrow(application_df)

# create table career
career_df <- df[c('career_level')]
career_df <- unique(career_df)
career_df$career_level_id <- 1:nrow(career_df)

# create table division
division_df <- df[c('division_work_unit')]
division_df <- unique(division_df)
division_df$division_id <- 1:nrow(division_df)
division_df <- division_df[c('division_id','division_work_unit')]

# create table job_info
df2 <- df

# add business_title_id
business_title_id_list <- sapply(df2$business_title, 
                          function(x) business_title_df$business_title_id[business_title_df$business_title == x])
df2$business_title_id <- business_title_id_list

# add category_id
job_category_id_list <- sapply(df2$job_category, function(x) job_category_df$category_id[job_category_df$job_category == x])
df2$category_id <- job_category_id_list

# add requirement_id
requirement_id_list <- 
mapply(function(x, y, z, k) requirement_df$requirement_id[requirement_df$additional_information == x &
                                                          requirement_df$preferred_skills == y & 
                                                          requirement_df$minimum_qual_requirements == z &
                                                          requirement_df$residency_requirement == k], 
                              df2$additional_information, 
                              df2$preferred_skills, 
                              df2$minimum_qual_requirements,
                              df2$residency_requirement)
df2$requirement_id <- requirement_id_list

# add salary_id 
salary_id_list <- mapply(function(x, y, z) salary_df$salary_id[salary_df$salary_range_from == x &
                                                               salary_df$salary_range_to == y &
                                                               salary_df$salary_frequency == z], 
                         df2$salary_range_from, 
                         df2$salary_range_to, 
                         df2$salary_frequency)
df2$salary_id <- salary_id_list

# add division_id
division_id_list <- sapply(df2$division_work_unit, 
                           function(x) division_df$division_id[division_df$division_work_unit == x])
df2$division_id <- division_id_list


# add title_id
title_id_list <- mapply(function(x, y, z, a) title_df$title_id[title_df$title_code_no == x &
                                                                 title_df$civil_service_title == y &
                                                                 title_df$title_classification == z&
                                                                 title_df$level == a], 
                         df2$title_code_no, 
                         df2$civil_service_title, 
                         df2$title_classification,
                         df2$level)
df2$title_id <- title_id_list

# add career_level_id
career_level_list <- sapply(df2$career_level,
                            function(x) career_df$career_level_id[career_df$career_level == x])
df2$career_level_id <- career_level_list

# add agency_id
agency_id_list <- sapply(df2$agency,
                            function(x) temp_agency_df$agency_id[temp_agency_df$agency == x])

df2$agency_id <- agency_id_list

# add apply_id
apply_id_list <- sapply(df2$to_apply, 
                        function(x) application_df$apply_id[application_df$to_apply == x])
df2$apply_id <- apply_id_list

# add post_id
post_id_list <- mapply(function(x, y, z, a) posting_df$post_id[posting_df$posting_updated == x &
                                                                 posting_df$posting_date == y &
                                                                 posting_df$post_until == z&
                                                                 posting_df$posting_type== a], 
                       df2$posting_updated,
                       df2$posting_date,
                       df2$post_until,
                       df2$posting_type)
df2$post_id <- post_id_list

df2 <- unique(df2)
df2$id <- 1:nrow(df2)

job_info_df <- df2[c('id','job_id','business_title_id','job_description','work_location','requirement_id','salary_id',
'division_id','title_id','category_id','career_level_id','agency_id','apply_id','recruitment_contact','number_of_positions', 
'post_id','full_time_part_time_indicator','hours_shift')]

job_info_df <- unique(job_info_df)


### ------------------------- converting blank cell to NA -------------------------------
temp_agency_df[temp_agency_df==""]<-NA
posting_df[posting_df==""]<-NA
salary_df[salary_df==""]<-NA
requirement_df[requirement_df==""]<-NA
title_df[title_df==""]<-NA
job_category_df[job_category_df==""]<-NA
business_title_df[business_title_df==""]<-NA
application_df[application_df==""]<-NA
career_df[career_df==""]<-NA
division_df[division_df==""]<-NA
job_info_df[job_info_df==""]<-NA


### ------------------------- push data into database -----------------------------------
#push the agency data to the database
dbWriteTable(con, name="agency", value=temp_agency_df, row.names=FALSE, append=TRUE)

#push the posting data to the database
dbWriteTable(con, name="posting", value=posting_df, row.names=FALSE, append=TRUE)

#push the salary data to the database
dbWriteTable(con, name="salary", value=salary_df, row.names=FALSE, append=TRUE)

#push the requirement data to the database
dbWriteTable(con, name="requirement", value=requirement_df, row.names=FALSE, append=TRUE)

#push the requirement data to the database
dbWriteTable(con, name="title", value=title_df, row.names=FALSE, append=TRUE)

#push the job_category data to the database
dbWriteTable(con, name="job_category", value=job_category_df, row.names=FALSE, append=TRUE)

#push the business_title data to the database
dbWriteTable(con, name="business_title", value=business_title_df, row.names=FALSE, append=TRUE)

#push the application data to the database
dbWriteTable(con, name="application", value=application_df, row.names=FALSE, append=TRUE)

#push the career data to the database
dbWriteTable(con, name="career", value=career_df, row.names=FALSE, append=TRUE)

#push the division data to the database
dbWriteTable(con, name="division", value=division_df, row.names=FALSE, append=TRUE)

# push the job_info data to the database
dbWriteTable(con, name="job_info", value=job_info_df, row.names=FALSE, append=TRUE)
