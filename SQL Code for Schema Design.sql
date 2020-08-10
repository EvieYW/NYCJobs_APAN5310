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
        posting_type	char(8),
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
    	title_id 			 integer,
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
        id                integer,
        job_id            integer,
        business_title_id integer,
		category_id       integer,
        job_description   varchar,
        work_location_1   varchar(200),
        requirement_id    integer,
        salary_id         integer,
        division_id       integer,
        title_id     	  integer,
        career_level_id   integer,
        agency_id         integer,
        apply_id		  integer,
        recruitment_contact varchar(50),
        number_of_positions integer,
        post_id             integer,
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

