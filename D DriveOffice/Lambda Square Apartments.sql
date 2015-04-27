-- Lambda Square Apartments --
USE master
GO

-- Drop the database if it already exists
IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'LambdaSquareApartments1'
)
DROP DATABASE LambdaSquareApartments1;
GO

CREATE DATABASE LambdaSquareApartments1;
GO

USE LambdaSquareApartments1;
GO

CREATE SCHEMA Presentation;
GO
CREATE SCHEMA Rentals;
GO
CREATE SCHEMA Personnel;
GO

CREATE TABLE Personnel.Employees
(
	EmployeeNumber nchar(5) not null,
	FirstName nvarchar(24),
	LastName nvarchar(24) not null,
	EmployeeName AS LastName + N', ' + FirstName,
	Title nvarchar(50),
	EmailAddress nvarchar(50),
	CONSTRAINT PK_Employees PRIMARY KEY(EmployeeNumber)
);
GO
CREATE TABLE Rentals.OccupanciesStatus
(	
	OccupancyStatus nvarchar(20) not null,
	StatusDescription nvarchar(max),
	CONSTRAINT PK_OccupanciesStatus PRIMARY KEY(OccupancyStatus)
);
GO
CREATE TABLE Presentation.Units
(
	UnitNumber int not null,
	Bedrooms int not null,
	Bathrooms real not null,
	MonthlyRate money not null,
	SecurityDeposit money not null,
	OccupancyStatus nvarchar(20) not null,
	Notes nvarchar(max),
	CONSTRAINT PK_Units PRIMARY KEY(UnitNumber),
	CONSTRAINT FK_OccupanciesStatus FOREIGN KEY(OccupancyStatus)
		REFERENCES Rentals.OccupanciesStatus(OccupancyStatus)
);
GO
CREATE TABLE Rentals.MaritalsStatus
(
	MaritalStatus nvarchar(20) not null,
	StatusDescription nvarchar(max),
	CONSTRAINT PK_MaritalsStatus PRIMARY KEY(MaritalStatus)
);
GO
CREATE TABLE Rentals.Tenants
(
	TenantCode nvarchar(6) not null,
	FirstName nvarchar(24),
	LastName nvarchar(24),
	TenantName AS LastName + N', ' + FirstName,
	MaritalStatus nvarchar(20),
	NumberOfChildren tinyint,
	PhoneNumber nvarchar(20),
	EmailAddress nvarchar(40),
	Notes nvarchar(max),
	CONSTRAINT PK_Tenants PRIMARY KEY(TenantCode),
	CONSTRAINT FK_MaritalsStatus FOREIGN KEY(MaritalStatus)
		REFERENCES Rentals.MaritalsStatus(MaritalStatus)
);
GO
CREATE TABLE Rentals.Registrations
(
	RegistrationID int identity(1001, 1) not null,
	RegistrationDate Date,
	EmployeeNumber nchar(5), -- Processed By
	TenantCode nvarchar(6), -- Processed For
	UnitNumber int not null,
	RentStartDate date,
	Notes nvarchar(max),
	CONSTRAINT PK_Registrations PRIMARY KEY(RegistrationID),
	CONSTRAINT FK_Registrants FOREIGN KEY(EmployeeNumber)
		REFERENCES Personnel.Employees(EmployeeNumber),
	CONSTRAINT FK_Tenants FOREIGN KEY(TenantCode)
		REFERENCES Rentals.Tenants(TenantCode),
	CONSTRAINT FK_Units FOREIGN KEY(UnitNumber)
		REFERENCES Presentation.Units(UnitNumber)
);
GO
CREATE TABLE Rentals.Payments
(
	ReceiptNumber int identity(100001, 1) not null,
	PaymentDate date,
	EmployeeNumber nchar(5),
	RegistrationID int,
	AmountPaid money,
	Notes nvarchar(max),
	CONSTRAINT PK_Payments PRIMARY KEY(ReceiptNumber),
	CONSTRAINT FK_PaymentReceiver FOREIGN KEY(EmployeeNumber)
		REFERENCES Personnel.Employees(EmployeeNumber),
	CONSTRAINT FK_Registrations FOREIGN KEY(RegistrationID)
		REFERENCES Rentals.Registrations(RegistrationID)
);
GO

INSERT INTO  Personnel.Employees(EmployeeNumber, FirstName, LastName, Title, EmailAddress)
VALUES(N'27495', N'Justine', N'Sandt', N'Rent Manager', N'jsandt2008@gmail.com');
GO
INSERT INTO  Personnel.Employees(EmployeeNumber, FirstName, LastName, EmailAddress)
VALUES(N'28404', N'Raymond', N'Wilkinson', N'rwilkinson@centralsquare.com');
GO
INSERT INTO  Personnel.Employees(EmployeeNumber, FirstName, LastName, Title, EmailAddress)
VALUES(N'30529', N'Mark', N'Reason', N'Maintenance Technician', N'mreason@centralsquare.com'),
      (N'38047', N'Marc', N'Knights', N'Rent Associate', N'mknights@centralsquare.com'),
      (N'40995', N'Jane', N'Proctor', N'Human Resources Manager', N'jproctor@centralsquare.com'),
      (N'62797', N'Leonard', N'Goulet', N'Owner - General Manager', N'lgoulet@centralsquare.com'),
      (N'72088', N'Thomas', N'Wilkens', N'Bookeeper', N'twilkens@centralsquare.com'),
      (N'92748', N'Nancy', N'Longhorn', N'Rent Associate', N'nlonghorn@centralsquare.com'),
      (N'92749', N'Horace', N'Taylor', N'Maintenance Technician', N'htaylor@centralsquare.com'),
      (N'94008', N'Martin', N'Schroeder', N'Rent Associate', N'mschroeder@centralsquare.com');
GO

INSERT INTO Rentals.OccupanciesStatus(OccupancyStatus, StatusDescription)
VALUES(N'Available', N'The apartment is ready for rent. It has passed internal and external inspections.');
GO
INSERT INTO Rentals.OccupanciesStatus(OccupancyStatus) VALUES(N'Needs Repair');
GO
INSERT INTO Rentals.OccupanciesStatus(OccupancyStatus, StatusDescription)
VALUES(N'Not Ready', N'For any reason, the apartment cannot be occupied at this time. It could be due to need repair or a failed inspection.'),
      (N'Occupied', N'The apartment is currently used by another tenant and it is not available');
INSERT INTO Rentals.OccupanciesStatus(OccupancyStatus) VALUES(N'Other');
GO

INSERT INTO Presentation.Units(UnitNumber, Bedrooms, Bathrooms, MonthlyRate, SecurityDeposit, OccupancyStatus)
VALUES(N'101', 2, 2, 1150, 450, N'Available'),
      (N'102', 1, 1,  950, 350, N'Needs Repair'),
      (N'103', 1, 1,  925, 350, N'Available'),
      (N'104', 3, 2, 1350, 500, N'Available'),
      (N'105', 2, 1, 1150, 400, N'Available'),
      (N'106', 3, 2, 1350, 500, N'Available'),
      (N'107', 3, 2, 1285, 500, N'Not Ready'),
      (N'108', 1, 1,  885, 300, N'Available'),
      (N'109', 2, 2, 1150, 450, N'Available'),
      (N'110', 1, 1,  895, 300, N'Available'),
      (N'111', 2, 2, 1145, 450, N'Available'),
      (N'112', 2, 1, 1085, 400, N'Available'),
      (N'201', 2, 1, 1185, 400, N'Available'),
      (N'202', 1, 1,  895, 300, N'Available'),
      (N'203', 1, 1,  925, 350, N'Available'),
      (N'204', 3, 2, 1250, 500, N'Available'),
      (N'205', 2, 1, 1100, 400, N'Available'),
      (N'206', 3, 2, 1300, 500, N'Available'),
      (N'207', 3, 2, 1350, 500, N'Available'),
      (N'208', 1, 1,  920, 350, N'Available'),
      (N'209', 2, 2, 1150, 450, N'Available'),
      (N'210', 1, 1,  895, 300, N'Available'),
      (N'211', 2, 2, 1175, 450, N'Available'),
      (N'212', 2, 1, 1075, 400, N'Available'),
      (N'301', 2, 2, 1175, 450, N'Available'),
      (N'302', 1, 1,  950, 350, N'Available'),
      (N'303', 1, 1,  925, 350, N'Available'),
      (N'304', 3, 2, 1250, 500, N'Available'),
      (N'305', 2, 1, 1100, 400, N'Needs Repair'),
      (N'306', 3, 2, 1300, 500, N'Available'),
      (N'307', 3, 2, 1350, 500, N'Available'),
      (N'308', 1, 1,  920, 350, N'Available'),
      (N'309', 2, 2, 1150, 450, N'Available'),
      (N'310', 1, 1,  935, 350, N'Available'),
      (N'311', 2, 2, 1175, 450, N'Available'),
      (N'312', 2, 1, 1075, 400, N'Available');
GO

INSERT INTO Rentals.MaritalsStatus(MaritalStatus, StatusDescription)
VALUES(N'Single', N'The tenant has never been married.'),
      (N'Married', N'The tenant is currently (legally) married, whether living with the spouse or not.'),
      (N'Separated', N'The tenant and the official spouse are not living together and are not expected to share the apartment'),
      (N'Divorced', N'At one time, the tenant was married but has legally divorced.'),
      (N'Widow', N'At one time, the tenant was married but the spouse passed away.');
GO
INSERT INTO Rentals.MaritalsStatus(MaritalStatus) VALUES(N'Unspecified');
GO

INSERT INTO Rentals.Tenants(TenantCode, FirstName, LastName, MaritalStatus, NumberOfChildren, PhoneNumber, EmailAddress)
VALUES(N'928411', N'Ann', N'Sanders', N'Married', 1, N'(240) 524 -2831', N'annsanders@emailcity.com'),
      (N'279475', N'Mahty', N'Shaoul', N'Married', 2, N'202-729-1574', N'mshaoulman@gmail.com'),
      (N'920074', N'Frank', N'Ulm', N'Single', 0, N'(301) 882-0704', N'fulm112244@yaho.com'),
      (N'804085', N'Elise', N'Provoski', N'Separated', 1, N'(443) 974-9631', N'eprevalence@yahoo.com'),
      (N'920948', N'Grace', N'Curryan', N'Married', 1, N'(240) 927-0993', N'gcarrier@gmail.com'),
      (N'603848', N'Tracy', N'Warrens', N'Divorced', 2, N'202-793-6924', N'twarrior12@hotmail.coom'),
      (N'824922', N'Paul', N'Yamo', N'Married', 3, N'(410-792-7045', N'pyamo@hr.umd.edu'),
      (N'300409', N'Nancy', N'Shermann', N'Single', 1, N'(703) 338-2973', N'nsherre@emailcity.com'),
      (N'248506', N'Michael', N'Tiernan', N'Single', 0, N'301-274-9285', N'resdev.globelan.net'),
      (N'208081', N'Phillippe', N'Anderson', N'Single', 0, N'202-729-1574', N'philanders@gmail.com');
GO

INSERT INTO Rentals.Registrations(RegistrationDate, EmployeeNumber, TenantCode, UnitNumber, RentStartDate)
VALUES(N'20120612', N'38047', N'928411', N'109', N'20120701'),
      (N'20120615', N'92748', N'279475', N'104', N'20120801'),
      (N'20120622', N'27495', N'920074', N'103', N'20120701'),
      (N'20120622', N'94008', N'804085', N'305', N'20120801'),
      (N'20120723', N'94008', N'920948', N'105', N'20120901'),
      (N'20120725', N'27495', N'603848', N'106', N'20120801'),
      (N'20120801', N'38047', N'824922', N'204', N'20121001'),
      (N'20120810', N'27495', N'300409', N'108', N'20120901'),
      (N'20120912', N'92749', N'248506', N'209', N'20121101'),
      (N'20121005', N'38047', N'208081', N'202', N'20121101');
GO

INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationID, AmountPaid, Notes)
VALUES(N'20120622', N'38047', 1001, 450, N'This is the payment for the security deposit.'),
      (N'20120625', N'92749', 1002, 500, N'Payment for security deposit'),
      (N'20120702', N'27495', 1003, 350, N'Security Deposit');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationID, AmountPaid)
VALUES(N'20120725', N'38047', 1001, 1150),
      (N'20120726', N'94008', 1003,  925);
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationID, AmountPaid, Notes)
VALUES(N'20120801', N'27495', 1006, 500, N'Security Deposit'),
      (N'20120808', N'27495', 1008, 300, N'Security Deposit'),
      (N'20120808', N'27495', 1007, 500, N'Security Deposit'),
      (N'20120813', N'27495', 1004, 400, N'Security Deposit');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationID, AmountPaid)
VALUES(N'20120827', N'27495', 1004, 1100),
      (N'20120828', N'92749', 1002, 1350),
      (N'20120828', N'38047', 1001, 1150),
      (N'20120830', N'94008', 1003,  925),
      (N'20120830', N'94008', 1006, 1350);
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationID, AmountPaid, Notes)
VALUES(N'20120917', N'27495', 1009, 450, N'Security Deposit'),
      (N'20120918', N'92749', 1005, 400, N'Security Deposit');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationID, AmountPaid)
VALUES(N'20120925', N'92749', 1004, 1100),
      (N'20120925', N'92749', 1008,  885),
      (N'20120925', N'92749', 1006, 1350),
      (N'20120927', N'92749', 1001, 1150),
      (N'20120928', N'27495', 1002, 1350),
      (N'20120928', N'27495', 1005, 1150),
      (N'20121001', N'38047', 1003,  925);
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationID, AmountPaid, Notes)
VALUES(N'20121008', N'27495', 1010, 300, N'Security Deposit');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationID, AmountPaid)
VALUES(N'20121024', N'92749', 1004, 1100),
      (N'20121024', N'92749', 1005, 1150),
      (N'20121025', N'27495', 1006, 1350),
      (N'20121025', N'27495', 1007, 1250),
      (N'20121026', N'92749', 1002, 1350),
      (N'20121029', N'62797', 1001, 1150),
      (N'20121029', N'62797', 1008,  885),
      (N'20121030', N'27495', 1003,  925),
      (N'20121126', N'92749', 1008,  885),
      (N'20121126', N'38047', 1002, 1350),
      (N'20121127', N'38047', 1006, 1350),
      (N'20121128', N'62797', 1001, 1150),
      (N'20121128', N'94008', 1004, 1100),
      (N'20121128', N'92749', 1005, 1150),
      (N'20121128', N'92749', 1007, 1250),
      (N'20121130', N'94008', 1009, 1150),
      (N'20121130', N'38047', 1003,  925),
      (N'20121130', N'92748', 1010,  895),
      (N'20121202', N'92749', 1002, 1350),
      (N'20121225', N'38047', 1006, 1350),
      (N'20121225', N'38047', 1007, 1250),
      (N'20121226', N'62797', 1002, 1350),
      (N'20121226', N'94008', 1001, 1150),
      (N'20121227', N'92748', 1009, 1150),
      (N'20121228', N'38047', 1005, 1150),
      (N'20121228', N'94008', 1010,  895),
      (N'20121228', N'92749', 1004, 1100),
      (N'20121228', N'94008', 1003,  925),
      (N'20121231', N'92749', 1008,  885);
GO