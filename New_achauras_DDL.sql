--Note: putting '--' before a line (such as this one) turns it into a comment line
/* Begin sections of comments with /* and end the comment section with: */
/* This method is universal as it can be used for one line. */
--The '--' method is just simpler to type.
--BEGIN PRACTICUM COMMENTS. See main pdf document for directions.

/*
The drop table statements below remove the current copies of these tables so they can be re-created.
If you do not remove previous versions the new CREATE TABLE statement will give you a 'name is already used' type error.

IMPORTANT - These statements will give you an error if run in your database before the tables are created in your database. 
Just ignore these 'table does not exist' errors(arising from these statements only).

They do no damage and will stop when you finish your script by inserting the missing create table statements. When you are FINISHED, this script should
run with no errors - but not until you are finished. */

/*
If you run this script before creating any tables it will not create any tables.
These will run AFTER you have created at least the Employee and Admin tables correctly and implemented in your account. */

/*
The drop table and create table statements are in the order they need to be to drop and create properly.
If you change the order then errors may occur because dropping or creating in a different order may have foreign key errors arise. */
DROP TABLE admin CASCADE CONSTRAINTS PURGE;
DROP TABLE benefit CASCADE CONSTRAINTS PURGE;
DROP TABLE certification CASCADE CONSTRAINTS PURGE;
DROP TABLE district CASCADE CONSTRAINTS PURGE;
DROP TABLE employee CASCADE CONSTRAINTS PURGE;
DROP TABLE ot_pay CASCADE CONSTRAINTS PURGE;
DROP TABLE other_emp CASCADE CONSTRAINTS PURGE;
DROP TABLE pab_item CASCADE CONSTRAINTS PURGE;
DROP TABLE pab_lineitem CASCADE CONSTRAINTS PURGE;
DROP TABLE reg_pay CASCADE CONSTRAINTS PURGE;
DROP TABLE teacher CASCADE CONSTRAINTS PURGE;
DROP TABLE teacher_cert_int CASCADE CONSTRAINTS PURGE;
DROP TABLE total_pab CASCADE CONSTRAINTS PURGE;

/* I suggest to create the table EMPLOYEE first. You should create the table
first with NO foreign keys. There are two foreign keys that should be added in
using ALTER TABLE after all tables are created. This is because the tables all
reference each other in a way that you must remove the foreign keys temporarily
so that the tables can be created.

If you take my suggestion above and place your CREATE TABLE statements in this
script in the same order as the place marked below, you should not run into
problems with foreign keys restricting the creation of your tables. You can
include the other table's FKs in the single CREATE TABLE statements without
problem if you implement in the correct order.

Do not forget to add those FK's to the emplyee table at the end.
*/

-- 1 

CREATE TABLE EMPLOYEE (
   DISTRICT_ID CHAR(5 BYTE) NOT NULL,
   EMP_ID CHAR(5 BYTE) NOT NULL,
   EMP_FNAME CHAR(50 BYTE),
   EMP_LNAME CHAR(50 BYTE) NOT NULL,
   ZIPCODE CHAR(5 BYTE),
   HIREDATE DATE DEFAULT SYSDATE,
   PREVIOUS_EXPERIENCE_YEARS NUMBER(3, 1) DEFAULT 0, 
   HIGHEST_EARNED_DEGREE CHAR(11 BYTE) DEFAULT 'Bachelor',
   DIRECT_ADMIN_ID CHAR(5 BYTE),
   IS_ADMIN CHAR(1 BYTE) DEFAULT 'N' NOT NULL,
   IS_TEACHER CHAR(1 BYTE) DEFAULT 'Y' NOT NULL,
   EDU_EMAIL VARCHAR2(20 BYTE) NOT NULL,
   CONSTRAINT EMPLOYEE_UK1 UNIQUE (EDU_EMAIL),
   CONSTRAINT EMPLOYEE_PK PRIMARY KEY (EMP_ID));


-- 2
CREATE TABLE ADMIN(
    A_EMP_ID CHAR (5 BYTE) NOT NULL,
    ADMIN_START_DATE DATE DEFAULT SYSDATE NOT NULL,
    ADMIN_END_DATE DATE,
    DIVERSITY_TRAINING_CERT CHAR (1 BYTE) DEFAULT 'N' NOT NULL,
    ADMIN_TITLE CHAR (40 BYTE),
    CONSTRAINT ADMIN_PK PRIMARY KEY (A_EMP_ID),
    CONSTRAINT ADMIN_FK1 FOREIGN KEY (A_EMP_ID)
    REFERENCES EMPLOYEE (EMP_ID))
    ;
    
--- 3.
CREATE TABLE TEACHER(
T_EMP_ID CHAR(5 BYTE) NOT NULL,
IS_FULLTIME CHAR(1 BYTE) DEFAULT 'Y' NOT NULL,
GRADE_OR_SPECIAL CHAR(1 BYTE) DEFAULT 'G' NOT NULL,
CONSTRAINT TEACHER_PK PRIMARY KEY(T_EMP_ID),
CONSTRAINT TEACHER_FK1 FOREIGN KEY (T_EMP_ID)
REFERENCES Employee (EMP_ID));

--- 4.
CREATE TABLE OTHER_EMP(
O_EMP_ID CHAR(5 BYTE) NOT NULL,
TYPE CHAR(30 BYTE) NOT NULL,
TITLE CHAR(50 BYTE),
CONSTRAINT OTHER_EMP_PK PRIMARY KEY(O_EMP_ID),
CONSTRAINT OTHER_EMP_FK1 FOREIGN KEY (O_EMP_ID)
REFERENCES employee (EMP_ID));

---5.
CREATE TABLE CERTIFICATION(
CERT_ID CHAR(5 BYTE) NOT NULL,
STATE_CERT_CODE CHAR(10 BYTE) NOT NULL,
CERT_DESC VARCHAR2(100 BYTE),
CONSTRAINT CERTIFICATION_UK1 UNIQUE (STATE_CERT_CODE),
CONSTRAINT CERTIFICATION_PK PRIMARY KEY (CERT_ID)
);

---6.
CREATE TABLE TEACHER_CERT_INT(
T_EMP_ID CHAR(5 BYTE) NOT NULL,
CERT_ID CHAR(5 BYTE) NOT NULL,
DATE_EFFECTIVE DATE NOT NULL,
DATE_EXPIRES DATE,
CONSTRAINT TEACHER_CERT_INT_PK PRIMARY KEY (T_EMP_ID,CERT_ID,DATE_EFFECTIVE),
CONSTRAINT TEACHER_CERT_INT_FK1 FOREIGN KEY (T_EMP_ID)
REFERENCES TEACHER (T_EMP_ID),
CONSTRAINT TEACHER_CERT_INT_FK2 FOREIGN KEY (CERT_ID)
REFERENCES CERTIFICATION (CERT_ID));


---7.
CREATE TABLE DISTRICT(
DISTRICT_ID CHAR(5 BYTE) NOT NULL,
DISTRICT_NAME VARCHAR2(100 BYTE) NOT NULL,
SUPERINTENDENT_ID CHAR(5 BYTE),
CONSTRAINT DISTRICT_UK1 UNIQUE(SUPERINTENDENT_ID), 
CONSTRAINT DISTRICT_PK PRIMARY KEY(DISTRICT_ID),
CONSTRAINT DISTRICT_FK1 FOREIGN KEY (SUPERINTENDENT_ID)
REFERENCES admin (A_EMP_ID)
);
   
CREATE TABLE total_pab (
emp_id CHAR(5) NOT NULL,
tax_year NUMBER(4, 0) NOT NULL,
reg_pay NUMBER(7, 0) NULL,
overtime_pay NUMBER(7, 0) NULL,
other_pay NUMBER(7, 0) NULL,
total_benefits NUMBER(7, 0) NULL,
date_last_calc DATE NULL,
pab_id CHAR(5) NOT NULL,
review_admin_id CHAR(5) NULL,
CONSTRAINT total_pab_uk1 UNIQUE ( emp_id, tax_year ),
CONSTRAINT total_pab_pk1 PRIMARY KEY ( pab_id ),
CONSTRAINT total_pab_fk1 FOREIGN KEY ( emp_id )
REFERENCES employee ( emp_id ),
CONSTRAINT total_pab_fk2 FOREIGN KEY ( review_admin_id )
REFERENCES admin ( a_emp_id )
);
CREATE TABLE pab_item (
pab_item_id CHAR(5) NOT NULL,
type CHAR(15) NOT NULL,
item_desc VARCHAR2(100) NOT NULL,
CONSTRAINT pab_item_pk PRIMARY KEY ( pab_item_id ),
CONSTRAINT pab_item_type_check CHECK ( type IN ( 'REGULAR PAY', 'OVERTIME PAY',
'OTHER PAY', 'BENEFIT' ) )
);
CREATE TABLE benefit (
pab_item_id CHAR(5) NOT NULL,
taxable_code_id CHAR(10) NOT NULL,
CONSTRAINT benefit_pk PRIMARY KEY ( pab_item_id ),
CONSTRAINT benefit_fk1 FOREIGN KEY ( pab_item_id )
REFERENCES pab_item ( pab_item_id )
);
CREATE TABLE ot_pay (
pab_item_id CHAR(5) NOT NULL,
holiday_multiplier NUMBER(4, 2) NOT NULL,
CONSTRAINT ot_pay_pk PRIMARY KEY ( pab_item_id ),
CONSTRAINT ot_pay_fk1 FOREIGN KEY ( pab_item_id )
REFERENCES pab_item ( pab_item_id ),
CONSTRAINT holiday_multiplier_check CHECK ( holiday_multiplier BETWEEN ( 1.00 )
AND ( 3.50 ) )
);
CREATE TABLE reg_pay (
pab_item_id CHAR(5) NOT NULL,
collective_bargaining_sect CHAR(15) NOT NULL,
CONSTRAINT reg_pay_pk PRIMARY KEY ( pab_item_id ),
CONSTRAINT reg_pay_fk1 FOREIGN KEY ( pab_item_id )
REFERENCES pab_item ( pab_item_id )
);
CREATE TABLE pab_lineitem (
pab_id CHAR(5) NOT NULL,
pab_item_id CHAR(5) NOT NULL,
beg_date DATE NOT NULL,
end_date DATE NOT NULL,
amount_posted NUMBER(9, 2) DEFAULT 0 NOT NULL,
posted_timestamp TIMESTAMP(6) DEFAULT sysdate NOT NULL,
CONSTRAINT pab_lineitem_pk PRIMARY KEY ( pab_item_id,
pab_id,
beg_date,
end_date ),
CONSTRAINT pab_lineitem_fk FOREIGN KEY ( pab_id )
REFERENCES total_pab ( pab_id ),
CONSTRAINT pab_lineitem_fk1 FOREIGN KEY ( pab_item_id )
REFERENCES pab_item ( pab_item_id )
); 


ALTER TABLE employee
ADD CONSTRAINT EMPLOYEE_FK
FOREIGN KEY (DISTRICT_ID)
REFERENCES  DISTRICT (DISTRICT_ID);


ALTER TABLE employee
ADD CONSTRAINT EMPLOYEE_FK1 
FOREIGN KEY (DIRECT_ADMIN_ID)
REFERENCES  admin (A_EMP_ID) ;

--- 1. Add a constraint to reject any inserted value for the ADMIN.ADMIN_DIVERSITY_CERT attribute other than ‘Y’ and ‘N’.
ALTER TABLE ADMIN
ADD CONSTRAINT CO_DIVERSITY_TRAINING_CERT
CHECK (DIVERSITY_TRAINING_CERT IN ('Y', 'N'));

--- 2. Add a constraint to make sure that the ADMIN.ADMIN_END_DATE date is the same date or later than the ADMIN.ADMIN_START_DATE date.
ALTER TABLE ADMIN
ADD CONSTRAINT CO_ADMIN_END_DATE
CHECK (ADMIN_END_DATE >= ADMIN_START_DATE);

/* 3. [Since this constraint is a bit more involved, it will be scored equal to 2 constraints. In other words, this one
counts double.] Add a constraint to check for the appearance of a valid email address (it won’t check if the
email is truly valid, just that it seems to be a properly formatted email address). The constraint should check
to make sure all email addresses entered into EMPLOYEE.EDU_EMAIL are of the form
[Anytext]@[Anytext].edu. Wherever you see [Anytext] this means that there must be at least two characters
in that spot to be a valid input. The .edu at the end must be those exact letters but can use any capitalization
pattern. If the rest of the email address is valid having the last four characters as ‘.edu’, ‘.EDU’, ‘.EdU’, ‘.edU’,
etc., these should all be accepted. To make this case insensitive do not string together a bunch of ‘OR’s to test
for every combination. Consider how this could be done more easily using the UPPER() function. Therefore,
‘me@hh.edu’, ‘abrandyb@kent.eDu’, ‘xx@xx.EDU’ would all be valid inputs. However, your constraint should
reject these entries: ‘@.’, ‘me at hh.com’, ‘me.com@hh’, ‘test@test@edu’, ‘x@x.edu’, ‘a@kent.edu’ (and any
other examples that do not meet the stated criteria). */
ALTER TABLE EMPLOYEE 
ADD CONSTRAINT EMPLOYEE_EDU_EMAIL_CHK CHECK(UPPER (EDU_EMAIL) LIKE '%__@%__.EDU');

---4. Constrain EMPLOYEE.HIGHEST_EARNED_DEGREE to the following values: 'GRE', 'High School', 'Associate','Bachelor', 'Master', and 'Doctorate'. All other entries should be rejected.
ALTER TABLE EMPLOYEE
ADD CONSTRAINT HIGHEST_EARNED_DEGREE_CHECK
CHECK (HIGHEST_EARNED_DEGREE IN ('GRE', 'High School', 'Associate', 'Bachelor', 'Master', 'Doctorate'));

---5. Constrain EMPLOYEE.HIREDATE to be January 1, 1950 or later (this would reject some ‘impossible’ entries, helping data integrity)
--ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YY';

ALTER TABLE EMPLOYEE
ADD CONSTRAINT CO_HIREDATE 
CHECK (HIREDATE >= TO_DATE('1950-01-01', 'YYYY-MM-DD'));

---6. Constrain OTHER_EMP.TYPE to the following values: 'CUSTODIAL', 'SECURITY', 'COUNSELING', 'CONTRACT', 'LANDSCAPING', and 'UNCATEGORIZED'. All other entries should be rejected.
ALTER TABLE OTHER_EMP
ADD CONSTRAINT CO_TYPE 
CHECK (TYPE IN ('CUSTODIAL', 'SECURITY', 'COUNSELING', 'CONTRACT', 'LANDSCAPING', 'UNCATEGORIZED'));

---7. Constrain PAB_ITEM.TYPE to the following values: 'REGULAR PAY', 'OVERTIME PAY', 'OTHER PAY', and 'BENEFIT'. All other entries should be rejected.
---already done by professor

---8. Constrain TEACHER.GRADE_OR_SPECIAL to the following values: 'G' and 'S'. All other entries should be rejected.
ALTER TABLE TEACHER
ADD CONSTRAINT CO_GRADE_OR_SPECIAL 
CHECK (GRADE_OR_SPECIAL IN ('G', 'S'));

---9. Constrain the value for OT_PAY.HOLIDAY_MULTIPLIER to be greater than or equal to 1.00 and less than or equal to 3.50.
---already done by professor
