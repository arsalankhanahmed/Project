-- Monson University - DDL --

-- =======================================================================
-- Database:     Monson University1
-- Author:       FunctionX
-- CreationDate: Wednesday 13 June 2012
-- Modified:     Thursday 03 November 2012, 10:15
-- =======================================================================

USE master
GO

-- Drop the database if it already exists
IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'MonsonUniversity1'
)
DROP DATABASE MonsonUniversity1;
GO
CREATE DATABASE MonsonUniversity1;
GO

USE MonsonUniversity1;
GO

CREATE SCHEMA Academics;
GO
CREATE SCHEMA Admissions;
GO
CREATE SCHEMA Administration;
GO
CREATE SCHEMA Catalogs;
GO

-- We will not use these sequences. I was only testing something
CREATE SEQUENCE Academics.SeqSchedules
	AS Int
    START WITH   10101
    INCREMENT BY 1;
GO

/* Instead of specified a deterministic date of birth, we will supply 
   a number of days to this function and, based on day this script is 
   run, the function will subtract the number of days from that date.
   That's how we will get the date of birth of a student. */

CREATE FUNCTION Administration.SetDateOfBirth(@days int)
RETURNS Date
AS
BEGIN
	RETURN DATEADD(d, @days, SYSDATETIME());
END
GO

CREATE TABLE Administration.Genders
(
    GenderLetter nvarchar(5) not null,
    GenderName nvarchar(50),
    Constraint PK_Genders Primary Key(GenderLetter)
);
GO

CREATE TABLE Academics.CourseDeliveryTypes
(
    CourseDeliveryTypeCode nvarchar(1) not null,
    CourseDeliveryType nvarchar(25),
    Notes nvarchar(max),
    Constraint PK_CourseDeliveryTypes Primary Key(CourseDeliveryTypeCode)
);
GO

CREATE TABLE Academics.TeachersStatus
(
    TeacherStatusCode nvarchar(5) not null,
    TeacherStatus nvarchar(25),
    Notes nvarchar(max),
    Constraint PK_TeacherStatus Primary Key(TeacherStatusCode)
);
GO
    
CREATE TABLE Academics.PassesFailsStatus
(
    PassFailStatus nvarchar(20) not null,
    Notes nvarchar(max),
    Constraint PK_PassesFailsStatus Primary Key(PassFailStatus)
);
GO

CREATE TABLE Academics.Semesters
(
    SemesterID int identity(101, 1) not null,
    Semester nvarchar(40),
    SemesterStart Date,
    SemesterEnd Date,
    Session1Start Date,
    Session1End Date,
    Session2Start Date,
    Session2End Date,
    OnlineStart Date,
    OnlineEnd Date,
    Constraint PK_Semesters Primary Key(SemesterID)
);
GO

CREATE TABLE Academics.GradingScales
(
    LetterGrade nvarchar(5) not null,
    Minimum smallint,
    Maximum smallint,
    Mark nvarchar(30),
    [Description] nvarchar(max),
    Constraint PK_GradingScales Primary Key(LetterGrade)
);
GO

CREATE TABLE Administration.Locations
(
    LocationCode nvarchar(5) not null,
    LocationName nvarchar(50) not null,
    Notes nvarchar(max),
    Constraint PK_Locations Primary Key(LocationCode)
);
GO

CREATE TABLE Administration.Departments
(
    DepartmentCode nvarchar(4) not null,
    DepartmentName nvarchar(50) default N'N/A',
    Notes nvarchar(max),
    Constraint PK_Departments Primary Key(DepartmentCode)
);
GO
CREATE TABLE Administration.EmploymentsCategories
(
    EmploymentCategory nvarchar(20) not null,
    CategoryDecsription nvarchar(max),
    Constraint PK_EmploymentsCategories Primary Key(EmploymentCategory)
);
GO
CREATE TABLE Administration.Employees
(
    EmployeeNumber nvarchar(8) not null,
    FirstName	   nvarchar(20),
    MiddleName	   nvarchar(20),
    LastName	   nvarchar(20) not null,
    DepartmentCode nvarchar(4),
    Title		   nvarchar(100),
    EmploymentCategory		nvarchar(20),
    Gender		   nvarchar(5),
	Anniversary	   nvarchar(25) null,
	CommunityCollegeDegrees nvarchar(25) null,
	UndergraduateDegrees	nvarchar(25) null,
	GraduateDegrees			nvarchar(25) null,
	DoctorateDegrees		nvarchar(25) null,
	[Certificates]			nvarchar(25),
	YearlySalary   money null,
    EmailAddress   nvarchar(50),
    Username	   nvarchar(15),
    [Password]	   nvarchar(20) default N'Password1',
    Notes nvarchar(max),
    Constraint PK_Employees Primary Key(EmployeeNumber),
    Constraint FK_Departments Foreign Key(DepartmentCode)
		References Administration.Departments(DepartmentCode),
    Constraint FK_EmployeesGender Foreign Key(Gender)
		References Administration.Genders(GenderLetter),
    Constraint FK_EmploymentsCategories Foreign Key(EmploymentCategory)
		References Administration.EmploymentsCategories(EmploymentCategory)
);
GO

CREATE TABLE Academics.UndergraduateMajors
(
    MajorID int identity(1001, 1) not null,
    Major nvarchar(60) unique,
    Dean nvarchar(8) not null,
    Notes nvarchar(max),
    Constraint PK_UndergraduateMajors Primary Key(MajorID),
    Constraint FK_Deans Foreign Key(Dean)
		References Administration.Employees(EmployeeNumber)
);
GO

CREATE TABLE Academics.Minors
(
    MinorID int identity(1001, 1) not null,
    Minor nvarchar(60) unique,
    Notes nvarchar(max),
    Constraint PK_Minors Primary Key(MinorID)
);
GO

CREATE TABLE Administration.Teachers
(
    TeacherID int identity(1, 1),
    TeacherNumber nvarchar(10) not null,
    FirstName nvarchar(25),
    MiddleName nvarchar(25),
    LastName nvarchar(25) not null,
    [Degrees] nvarchar(200) null,
    DepartmentCode nvarchar(4) default N'N/A',
    TeacherStatusCode nvarchar(5) default N'N/A',
    EmailAddress nvarchar(50),
    Gender nvarchar(5) default N'N/A',
    Username nvarchar(15),
    [Password] nvarchar(20) default N'Password1',
    Notes nvarchar(max),
    Constraint PK_Teachers Primary Key(TeacherNumber),
    Constraint FK_TeachersDepartments Foreign Key(DepartmentCode)
		References Administration.Departments(DepartmentCode),
    Constraint FK_TeachersStatus Foreign Key(TeacherStatusCode)
		References Academics.TeachersStatus(TeacherStatusCode),
    Constraint FK_TeachersGenders Foreign Key(Gender)
		References Administration.Genders(GenderLetter)
);
GO

CREATE TABLE Catalogs.UndergraduateCourses
(
    CourseCode nvarchar(8) not null,
    CourseName nvarchar(100),
    Credits integer not null,
    CourseDescription nvarchar(max),
    Prerequisites nvarchar(100),
    Notes nvarchar(max),
    Constraint PK_UndergraduateCourses Primary Key(CourseCode)
);
GO

CREATE TABLE Administration.UndergraduateCoursesTaught
(
    CourseTaughtID int identity(1, 1) not null,
    TeacherNumber nvarchar(10),
    CourseCode nvarchar(8),
    Notes nvarchar(max),
    Constraint PK_UndergraduateCoursesTaught Primary Key(CourseTaughtID),
    Constraint FK_TeachersCoursesTaught Foreign Key(TeacherNumber)
		References Administration.Teachers(TeacherNumber),
    Constraint FK_UndergraduateCoursesTaught Foreign Key(CourseCode)
		References Catalogs.UndergraduateCourses(CourseCode)
);
GO
CREATE TABLE Admissions.UndergraduateStudents
(
    StudentID int identity(1, 1),
    StudentNumber nvarchar(8) not null,
    FirstName nvarchar(20),
    MiddleName nvarchar(20),
    LastName nvarchar(20),
    BirthDate date,
    Gender nvarchar(5) default N'N/A',
    EmailAddress nvarchar(50),
    MajorID int not null,
    MinorID int not null,
    Username nvarchar(15),
    [Password] nvarchar(20) default N'Password1',
    Notes nvarchar(max),
    Constraint PK_UndergraduateStudents Primary Key(StudentNumber),
    Constraint FK_StudentsMajors Foreign Key(MajorID)
		References Academics.UndergraduateMajors(MajorID),
    Constraint FK_StudentsMinors Foreign Key(MinorID)
		References Academics.Minors(MinorID),
    Constraint FK_StudentsGenders Foreign Key(Gender)
		References Administration.Genders(GenderLetter)
);
GO
CREATE TABLE Catalogs.UndergraduateSchedules
(
    UndergraduateScheduleID int not null,
    SemesterID 	  int,
    StartDate  	  date,
    EndDate       date, -- CHECK(EndDate >= StartDate),
    StartTime  	  time,
    EndTime 	  time, -- CHECK(EndTime > StartTime),
    Weekdays 	  nvarchar(32),
    TeacherNumber nvarchar(10),
    TANumber 	  nvarchar(10),
    CourseCode 	  nvarchar(8),
    CourseDeliveryTypeCode nvarchar(1),
    LocationCode  nvarchar(5) not null,
    RoomNumber    nvarchar(40),
    Constraint PK_UndergraduateSchedules Primary Key(UndergraduateScheduleID),
    Constraint FK_UndergradSemSchedule Foreign Key(SemesterID) 
		References Academics.Semesters(SemesterID),
    Constraint FK_UndergraduateMainTeachers Foreign Key(TeacherNumber) 
		References Administration.Teachers(TeacherNumber),
    Constraint FK_UndergraduateTeacherAssistants Foreign Key(TeacherNumber) 
		References Administration.Teachers(TeacherNumber),
    Constraint FK_UndergraduateCourses Foreign Key(CourseCode) 
		References Catalogs.UndergraduateCourses(CourseCode),
    Constraint FK_UndergraduateDeliveryTypes Foreign Key(CourseDeliveryTypeCode) 
		References Academics.CourseDeliveryTypes(CourseDeliveryTypeCode),
    Constraint FK_Locations Foreign Key(LocationCode) 
		References Administration.Locations(LocationCode)
);
GO
    
CREATE TABLE Admissions.UndergraduateRegistrations
(
    RegistrationID int identity(1, 1) not null,
    RegistrationDate date,
    StudentNumber nvarchar(8),
    UndergraduateScheduleID int,
    Notes nvarchar(max),
    Constraint PK_UndergraduateRegistrations Primary Key(RegistrationID),
    Constraint FK_UndergraduateRegistrations Foreign Key(StudentNumber) 
		References Admissions.UndergraduateStudents(StudentNumber),
    Constraint FK_UndergraduateSchedules Foreign Key(UndergraduateScheduleID) 
		References Catalogs.UndergraduateSchedules(UndergraduateScheduleID)
);
GO
    
CREATE TABLE Academics.UndergraduateGrades
(
    UndergraduateGradeID int identity(1, 1) not null,
    DateGradePosted date,
    TeacherNumber nvarchar(10) not null,
    RegistrationID int,
    LetterGrade nvarchar(5),
    PassFailStatus nvarchar(20),
    CreditReceived integer,
    CurrentGPA decimal(6, 2),
    TotalStudentCredits integer,
    RemainingCredits integer,
    Notes nvarchar(max),
    Constraint PK_UndergraduateGrades Primary Key(UndergraduateGradeID),
    Constraint FK_TeachersPostingGrades Foreign Key(TeacherNumber) 
		References Administration.Teachers(TeacherNumber),
    Constraint FK_CoursesForGrades Foreign Key(RegistrationID) 
		References Admissions.UndergraduateRegistrations(RegistrationID),
    Constraint FK_GradingScalesLetters Foreign Key(LetterGrade) 
		References Academics.GradingScales(LetterGrade),
    Constraint FK_PassesFailsStatus Foreign Key(PassFailStatus) 
		References Academics.PassesFailsStatus(PassFailStatus)
);
GO