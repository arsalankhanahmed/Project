-- Lambda Properties Management --

USE master
GO

-- Drop the database if it already exists
IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'LambdaPropertiesManagement1'
)
DROP DATABASE LambdaPropertiesManagement1;
GO

CREATE DATABASE LambdaPropertiesManagement1;
GO

USE LambdaPropertiesManagement1;
GO
CREATE SCHEMA Personnel;
GO
CREATE SCHEMA Management;
GO
CREATE SCHEMA Rentals;
GO
CREATE SCHEMA Listing;
GO

CREATE SEQUENCE Management.SeqEmployees
    AS Int
    START WITH   10000
    INCREMENT BY 10;
GO

CREATE TABLE Rentals.OccupanciesStatus
(
	OccupancyStatus	  nvarchar(20) not null,
	StatusDescription nvarchar(max),
	Constraint PK_OccupanciesStatus Primary Key(OccupancyStatus)
);
GO
CREATE TABLE Management.MaritalsStatus
(
	MaritalStatus	  nvarchar(20) not null,
	StatusDescription nvarchar(max),
	Constraint PK_MaritalsStatus Primary Key(MaritalStatus)
);
GO
CREATE TABLE Rentals.PropertiesTypes
(
	PropertyType	  nvarchar(20) not null,
	TypeDescription nvarchar(max),
	Constraint PK_PropertiesTypes Primary Key(PropertyType)
);
GO
CREATE TABLE Personnel.Employees
(
	EmployeeNumber int not null unique default (NEXT VALUE FOR Management.SeqEmployees),
	FirstName      nvarchar(25),
	LastName       nvarchar(25),
	Title	       nvarchar(50),
	HourlySalary   money,
	Constraint PK_Employees Primary Key(EmployeeNumber)
);
GO
CREATE TABLE Listing.Properties
(
	PropertyNumber  nvarchar(10) not null unique,
	PropertyType    nvarchar(20),
	[Address]   	nvarchar(50),
	UnitNumber      nvarchar(6),
	City	        nvarchar(40),
	[State]	        nvarchar(40),
	ZIPCode	        nvarchar(20),
	Bedrooms    	smallint,
	Bathrooms   	float,
	MonthlyRate     money,
	SecurityDeposit	money,
	OccupancyStatus	nvarchar(20),
	Constraint PK_Properties Primary Key(PropertyNumber),
	Constraint FK_PropertiesTypes Foreign Key(PropertyType)
		References Rentals.PropertiesTypes(PropertyType),
	Constraint FK_PropertiesOccupancies Foreign Key(OccupancyStatus)
		References Rentals.OccupanciesStatus(OccupancyStatus)
);
GO
CREATE TABLE Rentals.Tenants
(
	TenantCode   	 nvarchar(10) not null,
	DateCreated      date,
	FirstName	     nvarchar(25),
	LastName    	 nvarchar(25),
	MaritalStatus	 nvarchar(20),
	NumberOfChildren smallint,
	PhoneNumber	     nvarchar(20), 
	EmailAddress	 nvarchar(50),
	EmergencyName    nvarchar(40),
	EmergencyPhone   nvarchar(20),
	Constraint PK_Tenants Primary Key(TenantCode),
	Constraint FK_TenantsMaritalsStatus Foreign Key(MaritalStatus)
		References Management.MaritalsStatus(MaritalStatus)
);
GO
CREATE TABLE Rentals.Registrations
(
	RegistrationNumber int identity(1, 1) not null,
	RegistrationDate   Date,
	EmployeeNumber     int, -- Processed By
	TenantCode         nvarchar(10), -- Processed For
	PropertyNumber     nvarchar(10) not null,
	RentStartDate      date,
	CONSTRAINT PK_Registrations PRIMARY KEY(RegistrationNumber),
	CONSTRAINT FK_Clerks FOREIGN KEY(EmployeeNumber)
		REFERENCES Personnel.Employees(EmployeeNumber),
	CONSTRAINT FK_Tenants FOREIGN KEY(TenantCode)
		REFERENCES Rentals.Tenants(TenantCode),
	CONSTRAINT FK_PropertiesNumbers FOREIGN KEY(PropertyNumber)
		REFERENCES Listing.Properties(PropertyNumber)
);
GO
CREATE TABLE Management.PaymentsReasons
(
	PaymentReason nvarchar(25) not null,
	[Description] nvarchar(max),
	Constraint PK_PaymentsReasons Primary Key(PaymentReason)
);
GO
CREATE TABLE Rentals.Payments
(
	ReceiptNumber      int identity(10001, 1) not null,
	PaymentDate  	   date,
	EmployeeNumber     int, -- Processed By
	RegistrationNumber int,
	PaymentReason      nvarchar(25),
	AmountPaid         money,
	Notes              nvarchar(max),
	CONSTRAINT PK_Payments PRIMARY KEY(ReceiptNumber),
	CONSTRAINT FK_PaymentReceiver FOREIGN KEY(EmployeeNumber)
		REFERENCES Personnel.Employees(EmployeeNumber),
	CONSTRAINT FK_Registrations FOREIGN KEY(RegistrationNumber)
		REFERENCES Rentals.Registrations(RegistrationNumber),
	CONSTRAINT FK_PaymentsReasons FOREIGN KEY(PaymentReason)
		REFERENCES Management.PaymentsReasons(PaymentReason)
);
GO

INSERT INTO Rentals.OccupanciesStatus(OccupancyStatus, StatusDescription)
VALUES(N'Available', N'The apartment is ready for rent. It has passed internal and external inspections.'),
      (N'Occupied', N'The apartment is currently used by another tenant and it is not available'),
      (N'Not Ready', N'For any reason, the apartment cannot be occupied at this time. It could be due to need repair or a failed inspection.'),
      (N'Needs Repair', N'The property cannot be rented at this time because work is needed in it.'),
      (N'Other', N'The status of this property is not clearly determined.');
GO
INSERT INTO Rentals.PropertiesTypes(PropertyType, TypeDescription)
VALUES(N'Apartment', N'An apartment is a property located in a building made of one or more (2, 3, 5, 6, 10, 20, or even more) levels. The whole building is made of apartments and units used for management.'),
      (N'Condominium', N'A comdominium (also called a condo) primarily follows the description of an aprtment. The small difference is that, in most cases, only one company manages all the apartments in the building. In the case of a condo, different independent companies may be in charge of different units. Some other condos in the same building be occupied by people who are currently purchasing, as opposed to renting, them.'),
      (N'Townhouse', N'A townhouse is a house that is attached to at least one other house. In most cases, townhouse has 1, 2, or 3 levels (not more, based on the construction). In some cases, a townhouse may be built under or above another townhouse.'),
      (N'Single Family', N'A single family is a house that stands by itself and is occupied by one or more people who live as family members or acquaintances.'),
      (N'Other', N'The property fits none of the other descriptions');
GO
INSERT INTO Management.MaritalsStatus(MaritalStatus, StatusDescription)
VALUES(N'Single', N'The tenant has never been married.'),
      (N'Married', N'The tenant is currently (legally) married, whether living with the spouse or not.'),
      (N'Separated', N'The tenant and the official spouse are not living together and are not expected to share the apartment'),
      (N'Divorced', N'At one time, the tenant was married but has legally divorced.'),
      (N'Widow', N'At one time, the tenant was married but the spouse passed away.'),
      (N'Unspecified', N'The marital status is not specified or is not clear.');
GO
INSERT INTO  Personnel.Employees(FirstName, LastName, Title)
VALUES(N'Justine', N'Sandt', N'Rent Manager');
GO
INSERT INTO  Personnel.Employees(FirstName, LastName)
VALUES(N'Raymond', N'Wilkinson');
GO
INSERT INTO  Personnel.Employees(FirstName, LastName, Title)
VALUES(N'Mark',    N'Reason',    N'Maintenance Technician'),
      (N'Marc',    N'Knights',   N'Rent Associate'),
      (N'Jane',    N'Proctor',   N'Human Resources Manager'),
      (N'Leonard', N'Goulet',    N'Owner - General Manager'),
      (N'Thomas',  N'Wilkens',   N'Bookeeper'),
      (N'Nancy',   N'Longhorn',  N'Rent Associate'),
      (N'Horace',  N'Taylor',    N'Maintenance Technician'),
      (N'Martin',  N'Schroeder', N'Rent Associate');
GO
 
INSERT INTO Listing.Properties(PropertyNumber, PropertyType, [Address], UnitNumber, City, [State], ZIPCode,
							   Bedrooms, Bathrooms, MonthlyRate, SecurityDeposit, OccupancyStatus)
VALUES(N'7283-0884', N'Condominium',   N'4606 Canterbury Ave',     N'804',  N'Bethesda',      N'MD', N'20814', 2,   2, 1475, 1000, N'Available'),
      (N'8241-0600', N'Apartment',     N'6802 Gulf Branch Ave',    N'102',  N'Rockville',     N'MD', N'20850', 1,   1,  895,  250, N'Other'),
      (N'2729-3971', N'Apartment',     N'6802 Gulf Branch Ave',    N'103',  N'Rockville',     N'MD', N'20850', 1,   1,  925,  275, N'Available'),
      (N'6200-8048', N'Apartment',     N'6802 Gulf Branch Ave',    N'104',  N'Rockville',     N'MD', N'20850', 2,   1, 1100,  500, N'Occupied'),
      (N'3840-0002', N'Apartment',     N'10314 Springster Rd #2D', N'2D',   N'Alexandria',    N'VA', N'22312', 3,   2, 1450,  600, N'Available'),
      (N'4927-5396', N'Apartment',     N'6802 Gulf Branch Ave',    N'106',  N'Rockville',     N'MD', N'20850', 3,   2, 1350,  425, N'Available'),
      (N'3006-6088', N'Apartment',     N'10316 Springster Rd #1A', N'1A',   N'Alexandria',    N'VA', N'22312', 1,   1, 1100,  600, N'Occupied'),
      (N'5927-5940', N'Apartment',     N'6802 Gulf Branch Ave',    N'108',  N'Rockville',     N'MD', N'20850', 0,   1,  865,  225, N'Available'),
      (N'1397-0492', N'Apartment',     N'6802 Gulf Branch Ave',    N'109',  N'Rockville',     N'MD', N'20850', 2,   1, 1050,  350, N'Available'),
      (N'3692-9404', N'Apartment',     N'6802 Gulf Branch Ave',    N'110',  N'Rockville',     N'MD', N'20850', 1,   1,  895,  250, N'Other'),
      (N'5020-8114', N'Apartment',     N'6802 Gulf Branch Ave',    N'111',  N'Rockville',     N'MD', N'20850', 1,   1,  895,  250, N'Other'),
      (N'6286-6408', N'Apartment',     N'6802 Gulf Branch Ave',    N'112',  N'Rockville',     N'MD', N'20850', 0,   1,  950,  450, N'Available'),
      (N'2927-1539', N'Apartment',     N'6802 Gulf Branch Ave',    N'201',  N'Rockville',     N'MD', N'20850', 0,   1,  825,  200, N'Available'),
      (N'4855-5702', N'Townhouse',     N'6812 Jerry Woods Ave',    NULL,    N'Silver Spring', N'MD', N'20906', 3, 2.5, 1580, 1200, N'Available'),
      (N'9359-9502', N'Condominium',   N'3139 Orchard Ridge Ave',  N'E2',   N'Baltimore',     N'MD', N'21201', 1,   1,  760,  500, N'Available'),
      (N'3840-0683', N'Apartment',     N'6802 Gulf Branch Ave',    N'204',  N'Rockville',     N'MD', N'20850', 2,   2, 1150,  650, N'Occupied'),
      (N'8044-1850', N'Apartment',     N'6802 Gulf Branch Ave',    N'205',  N'Rockville',     N'MD', N'20850', 1,   1, 1100,  500, N'Occupied'),
      (N'6248-8502', N'Apartment',     N'10314 Springster Rd #1C', N'1C',   N'Alexandria',    N'VA', N'22312', 2,   2, 1425, 1200, N'Available'),
      (N'2949-2240', N'Apartment',     N'6802 Gulf Branch Ave',    N'207',  N'Rockville',     N'MD', N'20850', 1,   1,  895,  250, N'Other'),
      (N'6020-4181', N'Apartment',     N'6802 Gulf Branch Ave',    N'208',  N'Rockville',     N'MD', N'20850', 0,   1,  815,  200, N'Available'),
      (N'4960-7550', N'Apartment',     N'6802 Gulf Branch Ave',    N'210',  N'Rockville',     N'MD', N'20850', 1,   1,  895,  350, N'Available'),
      (N'3840-0600', N'Apartment',     N'10316 Springster Rd #2D', N'2D',   N'Alexandria',    N'VA', N'22312', 2,   1, 1150,  700, N'Occupied'),
      (N'3840-8262', N'Apartment',     N'6802 Gulf Branch Ave',    N'212',  N'Rockville',     N'MD', N'20850', 3,   2, 1450,  850, N'Occupied'),
      (N'2937-9284', N'Single Family', N'10224 Hansen Drv',        NULL,    N'College Park',  N'MD', N'20707', 5, 3.5, 1650, 1200, N'Available'),
	  (N'3974-9318', N'Apartment',     N'6802 Gulf Branch Ave',    N'301',  N'Rockville',     N'MD', N'20850', 0,   1,  845,  200, N'Other'),
	  (N'6259-4816', N'Apartment',     N'6802 Gulf Branch Ave',    N'302',  N'Rockville',     N'MD', N'20850', 1,   1,  925,  250, N'Other'),
	  (N'4049-5077', N'Apartment',     N'6802 Gulf Branch Ave',    N'303',  N'Rockville',     N'MD', N'20850', 2,   1,  985,  275, N'Available'),
	  (N'3048-2062', N'Apartment',     N'6802 Gulf Branch Ave',    N'304',  N'Rockville',     N'MD', N'20850', 2,   2, 1250,  300, N'Other'),
	  (N'8250-2082', N'Townhouse',     N'688 Larrington St NW',    NULL,    N'Washington',    N'DC', N'20012', 3, 2.5, 1450,  850, N'Available'),
	  (N'5963-0599', N'Apartment',     N'6802 Gulf Branch Ave',    N'306',  N'Rockville',     N'MD', N'20850', 3,   2, 1450,  850, N'Available'),
	  (N'1380-4408', N'Apartment',     N'6802 Gulf Branch Ave',    N'307',  N'Rockville',     N'MD', N'20850', 2,   2, 1285,  400, N'Other'),
	  (N'2864-4816', N'Townhouse',     N'10344 Dunfield Drv',      NULL,    N'Columbia',      N'MD', N'21045', 3, 2.5, 1850, 1200, N'Available'),
	  (N'2972-9705', N'Apartment',     N'6802 Gulf Branch Ave',    N'309',  N'Rockville',     N'MD', N'20850', 2,   1, 1150,  550, N'Available'),
	  (N'2057-0794', N'Single Family', N'8249 North Plum Ave',     NULL,    N'Bethesda',      N'MD', N'20814', 5, 3.5, 2880, 1500, N'Available'),
	  (N'3502-9405', N'Apartment',     N'6802 Gulf Branch Ave',    N'311',  N'Rockville',     N'MD', N'20850', 3,   2, 1325,  500, N'Other'),
	  (N'3042-8505', N'Apartment',     N'6802 Gulf Branch Ave',    N'312',  N'Rockville',     N'MD', N'20850', 0,   1,  825,  200, N'Available'),
	  (N'1702-5947', N'Apartment',     N'10314 Springster Rd #1D', N'1D',   N'Alexandria',    N'VA', N'22312', 3,   2, 1650, 1400, N'Available'),
	  (N'5975-0530', N'Condominium',   N'4606 Canterbury Ave',     N'1011', N'Bethesda',      N'MD', N'20814', 2,   2, 1475, 1000, N'Available'),
	  (N'2682-2048', N'Apartment',     N'10314 Springster Rd #2B', N'2B',   N'Alexandria',    N'VA', N'22312', 2,   1, 1375, 1000, N'Available'),
	  (N'9462-7394', N'Apartment',     N'10314 Springster Rd #2C', N'2C',   N'Alexandria',    N'VA', N'22312', 2,   2, 1425, 1200, N'Available'),
	  (N'6200-0008', N'Apartment',     N'10314 Springster Rd #3A', N'3A',   N'Alexandria',    N'VA', N'22312', 1,   1, 1100,  600, N'Occupied'),
      (N'2495-1808', N'Townhouse',     N'6814 Jerry Woods Ave',    NULL,    N'Silver Spring', N'MD', N'20906', 3, 2.5, 1600, 1200, N'Available'),
	  (N'1797-0530', N'Apartment',     N'10314 Springster Rd #3B', N'3B',   N'Alexandria',    N'VA', N'22312', 2,   1, 1375, 1000, N'Available'),
	  (N'2297-2970', N'Apartment',     N'10314 Springster Rd #3C', N'3C',   N'Alexandria',    N'VA', N'22312', 2,   2, 1425, 1200, N'Available'),
	  (N'6469-5596', N'Apartment',     N'10314 Springster Rd #3D', N'3D',   N'Alexandria',    N'VA', N'22312', 3,   2, 1650, 1400, N'Available'),
	  (N'6286-0008', N'Apartment',     N'10316 Springster Rd #3A', N'3A',   N'Alexandria',    N'VA', N'22312', 1,   1, 1150,  600, N'Available'),
	  (N'4002-9362', N'Apartment',     N'10316 Springster Rd #3B', N'3B',   N'Alexandria',    N'VA', N'22312', 1,   1, 1100,  600, N'Available'),
	  (N'9736-6181', N'Single Family', N'681 Jane Mood St',        NULL,    N'Alexandria',    N'VA', N'22312', 3, 2.5, 1650, 1200, N'Available'),
	  (N'6304-0796', N'Apartment',     N'10316 Springster Rd #3D', N'3D',   N'Alexandria',    N'VA', N'22312', 2,   1, 1500, 1000, N'Available'),
	  (N'6029-7570', N'Condominium',   N'3139 Orchard Ridge Ave',  N'B4',   N'Baltimore',     N'MD', N'21201', 1,   1,  820,  500, N'Available'),
	  (N'9255-7497', N'Condominium',   N'4606 Canterbury Ave',     N'606',  N'Bethesda',      N'MD', N'20814', 2,   2, 1475, 1000, N'Available'),
	  (N'2930-8048', N'Condominium',   N'4606 Canterbury Ave',     N'605',  N'Bethesda',      N'MD', N'20814', 1,   1, 1265,  850, N'Available'),
	  (N'6209-2252', N'Condominium',   N'4606 Canterbury Ave',     N'802',  N'Bethesda',      N'MD', N'20814', 1,   1, 1265,  850, N'Available'),
	  (N'3730-1637', N'Single Family', N'7114 West Janitor Str',   NULL,    N'Rockville',     N'MD', N'20854', 5, 2.5, 2650, 1500, N'Available'),
	  (N'7950-8807', N'Apartment',     N'10316 Springster Rd #1C', N'1C',   N'Alexandria',    N'VA', N'22312', 2,   2, 1600, 1400, N'Available'),
	  (N'6082-0406', N'Apartment',     N'10316 Springster Rd #1D', N'1D',   N'Alexandria',    N'VA', N'22312', 2,   1, 1500, 1200, N'Available'),
	  (N'1409-4961', N'Condominium',   N'4606 Canterbury Ave',     N'1012', N'Bethesda',      N'MD', N'20814', 1,   1, 1265,  850, N'Available'),
	  (N'4639-4496', N'Apartment',     N'10316 Springster Rd #2B', N'2B',   N'Alexandria',    N'VA', N'22312', 2,   1, 1450, 1200, N'Available'),
	  (N'3940-4680', N'Apartment',     N'10316 Springster Rd #2C', N'2C',   N'Alexandria',    N'VA', N'22312', 2,   2, 1600, 1400, N'Available'),
	  (N'2680-2846', N'Condominium',   N'3139 Orchard Ridge Ave',  N'B1',   N'Baltimore',     N'MD', N'21201', 3,   2, 1480, 1000, N'Available'),
	  (N'6281-5085', N'Condominium',   N'3139 Orchard Ridge Ave',  N'W4',   N'Baltimore',     N'MD', N'21201', 1,   1,  740,  500, N'Not Ready'),
	  (N'8020-4827', N'Single Family', N'8115 Range Parkers Ave',  NULL,    N'Alexandria',    N'VA', N'22310', 5, 3.5, 2250, 1400, N'Available'),
	  (N'6020-4058', N'Single Family', N'8121 Range Parkers Ave',  NULL,    N'Alexandria',    N'VA', N'22310', 5, 3.5, 2400, 1400, N'Available'),
	  (N'2947-2085', N'Condominium',   N'4606 Canterbury Ave',     N'808',  N'Bethesda',      N'MD', N'20814', 2,   2, 1475, 1000, N'Available'),
	  (N'2040-0860', N'Condominium',   N'3139 Orchard Ridge Ave',  N'D2',   N'Baltimore',     N'MD', N'21201', 1,   1,  760,  500, N'Available'),
	  (N'1883-3184', N'Townhouse',     N'1406 Great Rossy Ave',    NULL,   N'Columbia',       N'MD', N'21045', 3, 2.5, 1665, 1200, N'Available'),
	  (N'4068-0502', N'Condominium',   N'3139 Orchard Ridge Ave',  N'E4',   N'Baltimore',     N'MD', N'21201', 3,   2, 1480, 1000, N'Available'),
	  (N'7046-6860', N'Condominium',   N'4606 Canterbury Ave',     N'1015', N'Bethesda',      N'MD', N'20814', 1,   1, 1265,  850, N'Available'),
	  (N'6207-2048', N'Apartment',     N'10314 Springster Rd #1A', N'1A',   N'Alexandria',    N'VA', N'22312', 1,   1, 1100,  600, N'Available'),
	  (N'2940-0859', N'Condominium',   N'4606 Canterbury Ave',     N'1014', N'Bethesda',      N'MD', N'20814', 1,   1, 1265,  850, N'Available'),
	  (N'2802-4495', N'Single Family', N'12304 Donaldson Rd',      NULL,    N'College Park',  N'MD', N'20740', 5, 3.5, 2500, 1000, N'Not Ready'),
	  (N'6320-8409', N'Single Family', N'7002 War Fair Drv',       NULL,    N'Arlington',     N'VA', N'22201', 5, 3.5, 3200, 1500, N'Available'),
	  (N'9280-6028', N'Townhouse',     N'2410 Jerridan Str NW',    NULL,    N'Washington',    N'DC', N'20008', 5, 2.5, 2650, 1250, N'Available'),
	  (N'8841-5804', N'Single Family', N'8602 Jorham Drv',         NULL,    N'Silver Spring', N'MD', N'20906', 5, 3.5, 2880, 1000, N'Available'),
	  (N'2042-4058', N'Single Family', N'426 Zimmers Rd',          NULL,    N'Silver Spring', N'MD', N'20901', 5, 2.5, 2650, 1000, N'Available'),
	  (N'8280-2479', N'Single Family', N'9910 East Rolling Rd',    NULL,    N'Silver Spring', N'MD', N'20910', 5, 3.5, 2485, 1200, N'Available'),
	  (N'5924-0739', N'Townhouse',     N'8114 Parlance Rd',        NULL,    N'Silver Spring', N'MD', N'20902', 3, 2.5, 1580, 1250, N'Needs Repair'),
	  (N'4086-0486', N'Townhouse',     N'1408 Great Rossy Ave',    NULL,    N'Columbia',      N'MD', N'21045', 3, 2.5, 1200,  800, N'Available'),
	  (N'2027-5840', N'Single Family', N'929 Carnage Crt',         NULL,    N'Gaithersburg',  N'MD', N'20877', 3, 2.5, 1500, 1200, N'Available'),
	  (N'2404-8051', N'Townhouse',     N'1877 Charley Rd',         NULL,    N'Arlington',     N'VA', N'22202', 3, 1.5, 1575, 1200, N'Available'),
	  (N'7202-6385', N'Single Family', N'664 Vast Armey Way',      NULL,    N'Alexandria',    N'VA', N'22312', 5, 3.5, 2425, 1500, N'Not Ready'),
	  (N'6082-2408', N'Townhouse',     N'1410 Great Rossy Ave',    NULL,    N'Columbia',      N'MD', N'21045', 3, 2.5, 2475, 1500, N'Available'),
	  (N'7240-9384', N'Single Family', N'2214 East Jonathan Crt',  NULL,    N'Silver Spring', N'MD', N'20901', 3, 1.5, 1575, 1200, N'Available'),
	  (N'6222-0494', N'Single Family', N'8288 Prophesia Way',      NULL,    N'Annapolis',     N'MD', N'20404', 5, 2.5, 1250, 1000, N'Needs Repair'),
	  (N'7242-2085', N'Townhouse',     N'2505 Renaissance Ln',     NULL,    N'Silver Spring', N'MD', N'20904', 3, 2.5, 1885, 1200, N'Available'),
	  (N'1850-2839', N'Townhouse',     N'10708 Silver Stone Str',  NULL,    N'Arlington',     N'VA', N'22201', 3, 2.5, 1885, 1200, N'Available'),
	  (N'9292-6375', N'Single Family', N'1505 Leamington Rd',      NULL,    N'College Park',  N'MD', N'20740', 5, 2.5, 2600, 1500, N'Needs Repair'),
	  (N'3803-1685', N'Single Family', N'375 Reisters Way',        NULL,    N'Arlington',     N'VA', N'22203', 5, 2.5, 3250, 1500, N'Needs Repair'),
	  (N'5936-2739', N'Townhouse',     N'10224 Pleasntry Ave',     NULL,    N'College Park',  N'MD', N'20740', 3, 2.5, 1450, 1000, N'Available'),
	  (N'9317-9475', N'Townhouse',     N'1044 Connors Rd NW',      NULL,    N'Washington',    N'DC', N'20004', 3, 2.5, 1775, 1200, N'Available'),
	  (N'2927-9405', N'Single Family', N'206 Checker Ct',          NULL,    N'Silver Spring', N'MD', N'20901', 5, 3.5, 2750, 1500, N'Not Ready'),
	  (N'9294-0075', N'Townhouse',     N'1412 Great Rossy Ave',    NULL,    N'Columbia',      N'MD', N'21045', 3, 1.5, 1750, 1200, N'Available'),
	  (N'2950-2948', N'Single Family', N'771 Glentley Rd',         NULL,    N'Alexandria',    N'VA', N'22312', 3,   2, 2200, 1400, N'Needs Repair'),
	  (N'4937-9595', N'Townhouse',     N'1844 Willow Woodson Rd',  NULL,    N'Rockville',     N'MD', N'20854', 3, 1.5, 1885, 1200, N'Available');
GO
INSERT INTO Rentals.Tenants(TenantCode, FirstName, LastName, MaritalStatus, NumberOfChildren, PhoneNumber, EmailAddress)
VALUES(N'927407', N'Ann',       N'Sanders',  N'Married',   1, N'(240) 524-2831', N'annsanders@emailcity.com'),
      (N'295804', N'Mahty',     N'Shaoul',   N'Married',   2, N'202-729-1574',   N'mshaoulman@gmail.com'),
      (N'624050', N'Frank',     N'Ulm',      N'Single',    0, N'(301) 882-0704', N'fulm112244@yaho.com'),
      (N'385974', N'Elise',     N'Provoski', N'Separated', 1, N'(443) 974-9631', N'eprevalence@yahoo.com'),
      (N'824857', N'Grace',     N'Curryan',  N'Married',   1, N'(240) 927-0993', N'gcarrier@gmail.com'),
      (N'495294', N'Tracy',     N'Warrens',  N'Divorced',  2, N'202-793-6924',   N'twarrior12@hotmail.coom'),
      (N'292475', N'James',     N'Thomason', N'Married',   3, N'(410-792-7045',  N'pyamo@hr.umd.edu'),
      (N'524794', N'Nancy',     N'Shermann', N'Single',    1, N'(703) 338-2973', N'nsherre@emailcity.com'),
      (N'293759', N'Michael',   N'Tiernan',  N'Single',    0, N'301-274-9285',   N'resdev.globelan.net'),
      (N'839405', N'Phillippe', N'Anderson', N'Single',    0, N'202-729-1574',   N'philanders@gmail.com');
GO

INSERT INTO Rentals.Tenants(TenantCode, DateCreated, LastName, FirstName, PhoneNumber, EmailAddress, MaritalStatus, NumberOfChildren, EmergencyName, EmergencyPhone)
VALUES(N'295800', N'20120615', N'Weaks', N'David', N'703.920.3974', N'dweaks@gmail.com', N'Married', 3, N'Jane Thomas', N'202.229.0447');
GO
INSERT INTO Rentals.Tenants(TenantCode, DateCreated, LastName, FirstName, PhoneNumber, EmailAddress, MaritalStatus, EmergencyName) 
VALUES(N'824850', N'20120723', N'Flores', N'Grace', N'202.183.2574', N'cfloor1920@yahoo.com', N'Married', N'Carlos Flores');
GO
INSERT INTO Rentals.Tenants(TenantCode, DateCreated, LastName, FirstName, PhoneNumber, NumberOfChildren, EmergencyPhone) 
VALUES(N'204059', N'20121007', N'Haffaz', N'Reyza', N'240.922.9374', 3, N'301.739.4075');
GO
INSERT INTO Rentals.Tenants(TenantCode, DateCreated, LastName, FirstName, MaritalStatus, EmergencyPhone) 
VALUES(N'292470', N'20120801', N'Thomason', N'James', N'Single', N'718.249.4608');
GO
INSERT INTO Rentals.Tenants(TenantCode, DateCreated, LastName, FirstName, PhoneNumber, EmailAddress, MaritalStatus, NumberOfChildren, EmergencyName, EmergencyPhone)
VALUES(N'524790', N'20120922', N'Shermann', N'Christopher', N'410.601.3204', N'chrischris42@hotmail.com', N'Married', 2, N'Emmanuelle Richards', N'443.317.2937');
GO
INSERT INTO Rentals.Tenants(TenantCode, DateCreated, LastName, FirstName, PhoneNumber, EmailAddress, EmergencyPhone) 
VALUES(N'293750', N'20120305', N'Woodson', N'Diana', N'301.429.3874', N'diana.woodson@gmail.com', N'240.480.7151');
GO
INSERT INTO Rentals.Registrations(RegistrationDate, EmployeeNumber, TenantCode, PropertyNumber, RentStartDate) 
VALUES(N'20120612', 10030, 927407, N'1397-0492', N'20120701'),
      (N'20120615', 10070, 295804, N'3840-8262', N'20120801'),
      (N'20120622', 10000, 624050, N'2729-3971', N'20120701'),
      (N'20120622', 10090, 385974, N'8044-1850', N'20120801'),
      (N'20120723', 10090, 824857, N'6200-8048', N'20120901'),
      (N'20120725', 10000, 495294, N'4927-5396', N'20120801'),
      (N'20120801', 10030, 292475, N'3840-0683', N'20121001'),
      (N'20120810', 10000, 524794, N'5927-5940', N'20120901'),
      (N'20120912', 10080, 293759, N'6286-6408', N'20121101'),
      (N'20121005', 10030, 839405, N'4960-7550', N'20121101');
GO
INSERT INTO Rentals.Registrations(PropertyNumber, RegistrationDate, RentStartDate, TenantCode) 
VALUES(N'3840-0002', N'20120615', N'20120801', N'295804'),
      (N'6200-0008', N'20120723', N'20120901', N'824857'),
      (N'3840-0600', N'20120912', N'20121001', N'292475'),
      (N'6286-0008', N'20120915', N'20121101', N'293759'),
      (N'6304-0796', N'20120922', N'20121001', N'524794'),
      (N'9736-6181', N'20121007', N'20121201', N'204059');
GO
INSERT INTO Management.PaymentsReasons
VALUES(N'Security Deposit', N'This fee must be paid to acquire a property. The customer can pay it when the rental contract is being made or sometime before occupying the property.'),
      (N'Monthly Payment', N'This is the amount a tenant must pay at the end of each month.'),
      (N'Fee', N'There are various types of fee for different reasons. For example, if no payment has been received by the 6th of the month for a certain property, the tenant is charged $100 to $150. As another example, if the tenant of a residential neighborhood (townhouse or single family) leaves trash out on the wrong day and management has to remove it, the tenant is charged a fee.');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid, Notes) 
VALUES(N'20120622', 10030, 1, N'Security Deposit', 450, N'This is the payment for the security deposit.'),
      (N'20120625', 10080, 2, N'Security Deposit', 600, N'Payment for security deposit'),
      (N'20120702', 10000, 3, N'Security Deposit', 350, N'Security Deposit');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid) 
VALUES(N'20120725', 10030, 1, N'Monthly Payment', 1150),
      (N'20120726', 10090, 3, N'Monthly Payment', 925);
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid, Notes) 
VALUES(N'20120801', 10000, 6, N'Security Deposit', 500, N'This was payment for the security deposit.'),
      (N'20120808', 10000, 8, N'Security Deposit', 300, N'The customer payd the security deposit.'),
      (N'20120808', 10000, 7, N'Security Deposit', 650, N'security deposit payment'),
      (N'20120813', 10000, 4, N'Security Deposit', 500, N'This was the payment for a security deposit.'),
      (N'20120827', 10000, 2, N'Monthly Payment', 1450, N'August 2012 Rent');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid) 
VALUES(N'20120828', 10080, 4, N'Monthly Payment', 1100), (N'20120828', 10030, 1, N'Monthly Payment', 1150),
      (N'20120830', 10090, 3, N'Monthly Payment',  925), (N'20120830', 10090, 6, N'Monthly Payment', 1350);
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid, Notes) 
VALUES(N'20120917', 10000, 9, N'Security Deposit', 450, N'This was the payment for the security deposit.'),
      (N'20120918', 10080, 5, N'Security Deposit', 500, N'This was payment for security deposit.');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid) 
VALUES(N'20120925', 10080, 4, N'Monthly Payment', 1100), (N'20120925', 10080, 8, N'Monthly Payment',  885),
      (N'20120925', 10080, 6, N'Monthly Payment', 1350), (N'20120927', 10080, 1, N'Monthly Payment', 1150),
      (N'20120928', 10000, 2, N'Monthly Payment', 1450), (N'20120928', 10000, 5, N'Monthly Payment', 1100),
      (N'20121001', 10030, 3, N'Monthly Payment',  925);
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid, Notes) 
VALUES(N'20121008', 10000, 10, N'Security Deposit', 300, N'This was payment for security deposit.');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid) 
VALUES(N'20121024', 10080, 4, N'Monthly Payment', 1100), (N'20121024', 10080, 5, N'Monthly Payment', 1100),
      (N'20121025', 10000, 6, N'Monthly Payment', 1350), (N'20121025', 10000, 7, N'Monthly Payment', 1150),
      (N'20121026', 10080, 3, N'Monthly Payment',  925), (N'20121029', 10050, 1, N'Monthly Payment', 1150),
      (N'20121029', 10050, 8, N'Monthly Payment',  885);
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid, Notes) 
VALUES(N'20121030', 10000, 2, N'Monthly Payment', 1450, N'October 2012 Rent Payment');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid) 
VALUES(N'20121126', 10080, 8, N'Monthly Payment', 885);
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid, Notes) 
VALUES(N'20121202', 10030, 2, N'Monthly Payment', 1450, N'November 2012 Rent');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid) 
VALUES(N'20121127', 10030, 6, N'Monthly Payment', 1350), (N'20121128', 10050,  1, N'Monthly Payment', 1150),
      (N'20121128', 10090, 4, N'Monthly Payment', 1100), (N'20121128', 10080,  5, N'Monthly Payment', 1100),
      (N'20121128', 10080, 7, N'Monthly Payment', 1150), (N'20121130', 10090,  9, N'Monthly Payment',  950),
      (N'20121130', 10030, 3, N'Monthly Payment',  925), (N'20121130', 10070, 10, N'Monthly Payment',  895),
      (N'20121225', 10080, 6, N'Monthly Payment', 1350), (N'20121226', 10030,  7, N'Monthly Payment', 1150);
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid, Notes) 
VALUES(N'20121226', 10030, 2, N'Monthly Payment', 1450, N'December 2012 Rent Payment');
GO
INSERT INTO Rentals.Payments(PaymentDate, EmployeeNumber, RegistrationNumber, PaymentReason, AmountPaid) 
VALUES(N'20121226', 10050,  1, N'Monthly Payment', 1150), (N'20121227', 10090,  9, N'Monthly Payment', 950),
      (N'20121228', 10070,  5, N'Monthly Payment', 1100), (N'20121228', 10030, 10, N'Monthly Payment', 895),
      (N'20121228', 10090,  4, N'Monthly Payment', 1100), (N'20121228', 10080,  3, N'Monthly Payment', 925),
      (N'20121231', 10090,  8, N'Monthly Payment',  885);
GO

INSERT INTO Rentals.Payments(PaymentReason, AmountPaid, RegistrationNumber, PaymentDate, Notes) 
VALUES(N'Security Deposit', 700, 13, N'20120808', N'This is the security deposit payment for new rental contract.'),
      (N'Security Deposit', 850, 11, N'20120827', N'This payment is the customer security deposit '),
      (N'Monthly Payment', 1450, 11, N'20120827', N'This is the payment of rent for the first month: August 2012.'),
      (N'Monthly Payment',  750, 12, N'20120920', N'This rent for September 2012 payment was made on behalf of the customer.'),
      (N'Monthly Payment', 1450, 11, N'20120928', N'This is payment for the month of October 2012'),
      (N'Monthly Payment', 1100, 12, N'20120928', N'Rent Payment for September 2012'),
      (N'Monthly Payment', 1100, 12, N'20121024', N'Rent Payment for October 2012'),
      (N'Monthly Payment', 1150, 13, N'20121025', N'Apartment 2D rent payment - October 2012.'),
      (N'Monthly Payment', 1450, 11, N'20121030', N'Payment for November 2012'),
      (N'Monthly Payment', 1100, 12, N'20121128', N'Rent Payment for November 2012'),
      (N'Monthly Payment', 1150, 13, N'20121128', N'Rent Payment for November 2012'),
      (N'Monthly Payment',  950, 14, N'20121130', N'This is payment for November 2012 rent.'),
      (N'Monthly Payment', 1150, 13, N'20121226', N'Rent Payment for December 2012'),
      (N'Monthly Payment',  950, 14, N'20121227', N'This is payment for December 2012 rent.'),
      (N'Monthly Payment', 1100, 12, N'20121228', N'Rent Payment for December 2012'),
      (N'Monthly Payment', 1450, 11, N'20130112', N'This is payment for December 2012 rent'),
      (N'Fee',              150, 11, N'20130112', N'This is a fee for late payment of rent for December 2012'),
      (N'Monthly Payment', 1150, 13, N'20130126', N'Rent Payment for January 2013'),
      (N'Monthly Payment', 1250, 15, N'20130126', N'Rent payment for January 2013.'),
      (N'Monthly Payment', 1450, 11, N'20130205', N'January 2012 payment'),
      (N'Monthly Payment', 1650, 16, N'20130205', N'Rent payment for January 2013'),
      (N'Monthly Payment', 1150, 13, N'20130226', N'Rent Payment for February 2013'),
      (N'Monthly Payment', 1250, 15, N'20130227', N'This was payment for 2013 February.'),
      (N'Monthly Payment', 1100, 12, N'20130228', N'Rent Payment for February 2013'),
      (N'Monthly Payment', 1650, 16, N'20130305', N'This was payment for 2013 February.'),
      (N'Monthly Payment', 1450, 11, N'20130308', N'Payment for February 2013'),
      (N'Fee',              150, 11, N'20130308', N'This is a fee for late payment of rent for February 2013'),
      (N'Monthly Payment', 1250, 15, N'20130326', N'Payment for March 2013 rent.'),
      (N'Monthly Payment', 1450, 11, N'20130327', N'March 2013 payment'),
      (N'Monthly Payment', 1150, 13, N'20130327', N'Rent Payment for March 2013'),
      (N'Monthly Payment', 1100, 12, N'20130331', N'Rent Payment for March 2013'),
      (N'Monthly Payment',  950, 14, N'20130428', N'Payment for April 2013.'),
      (N'Monthly Payment', 1450, 11, N'20130430', N'Payment for April 2013.'),
      (N'Monthly Payment', 1100, 12, N'20130510', N'This was rent payment for April 2013'),
      (N'Fee',              100, 12, N'20130510', N'This is a $100 fee that was applied for late payment'),
      (N'Monthly Payment', 1450, 11, N'20130529', N'May 2013 Rent Payment'),
      (N'Monthly Payment',  950, 14, N'20130530', N'Rent payment for May 2013 rent.'),
      (N'Monthly Payment', 1100, 12, N'20130605', N'Rent payment: May 2013'),
      (N'Monthly Payment', 1450, 11, N'20130627', N'Jun-13 payment'),
      (N'Monthly Payment', 1200, 12, N'20130708', N'Rent late payment - June 2013. a 100 fee was applied.'),
      (N'Monthly Payment', 1450, 11, N'20130815', N'Rent for July 2013'),
      (N'Fee',              150, 11, N'20130815', N'This is a $100 fee applied for late rent payment.'),
      (N'Monthly Payment', 1100, 11, N'20130824', N'August 2013 Rent Payment'),
      (N'Security Deposit', 600, 14, N'20130915', N'This is payment for the security deposit.'),
      (N'Monthly Payment', 1250, 15, N'20120922', N'This payment is the rent for the first month.'),
      (N'Security Deposit', 800, 15, N'20120922', N'This payment is the security deposit.'),
      (N'Monthly Payment', 1595, 11, N'20130930', N'This was rent payment for September 2013. The rent was increased by 145.'),
      (N'Monthly Payment', 1200, 16, N'20121025', N'Payment for security deposit'),
      (N'Monthly Payment', 1595, 11, N'20131030', N'This is payment for the month of April 2013.'),
      (N'Monthly Payment', 1250, 15, N'20121125', N'Rent payment for November 2013.'),
      (N'Monthly Payment', 1650, 16, N'20121202', N'Rent payment for November 2012.'),
      (N'Monthly Payment', 1595, 11, N'20131210', N'This is rent payment for November 2013.'),
      (N'Fee',              150, 11, N'20131210', N'This is rent payment for November 2013.'),
      (N'Monthly Payment', 1250, 15, N'20121224', N'Rent payment for December 2012.'),
      (N'Monthly Payment', 1650, 16, N'20121231', N'Rent payment for December 2013');
GO