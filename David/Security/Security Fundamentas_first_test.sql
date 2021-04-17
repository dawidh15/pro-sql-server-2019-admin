
USE [first_test]
GO

-- Database ROLES
-- seniorETL: Can run ETL in test AND production
-- testETL: Can run ETL only in test environment

-- Logins (for roles, not users)
/*
	Logins are used at the instance level.
	They can be used for users (people) or roles (functions).
	They can be used with Windows Authentication or with 2nd level autentication (SQL SERVER Password)
*/

-- seniorETL, pass  seniorETLpassword1
/*
 Senior ETL can perform ETLs on this instance (SERVER ROLE bulkadmin)
 Senior ETL can backup database (db_backupoperator role).
 Senior ETL can read from database (db_datareader role)
 Senior ETL can write to ANY table in the database, i.e. has DML rights (db_datawriter role)
 */
USE [master]
GO
CREATE LOGIN [seniorETL] WITH PASSWORD=N'seniorETLpassword1' 
	-- MUST_CHANGE -- Change password after first login
	, DEFAULT_DATABASE=[master]
	, CHECK_EXPIRATION=ON
	, CHECK_POLICY=ON
GO
ALTER SERVER ROLE [bulkadmin] ADD MEMBER [seniorETL]
GO
USE [first_test]
GO
CREATE USER [seniorETL] FOR LOGIN [seniorETL]
GO
USE [first_test]
GO
ALTER USER [seniorETL] WITH DEFAULT_SCHEMA=[t]
GO
USE [first_test]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [seniorETL]
GO
USE [first_test]
GO
ALTER ROLE [db_datareader] ADD MEMBER [seniorETL]
GO
USE [first_test]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [seniorETL]
GO


-- testETL, pass  testETLpassword1

/*
	Test ETL can only write and read tables from the test schema (t)
	on the first_test database.

	First create role tester on first_test db
	Second, Grant DML to t schema
	Third, Create Login for testerETL
	Fourth, Create User testerELTuser
	Fifth, Add testerETLuser as member of tester role
*/

USE [first_test]
GO

CREATE ROLE first_test_ETL_tester AUTHORIZATION dbo;
GO

GRANT SELECT ON SCHEMA::t TO first_test_ETL_tester;
GRANT INSERT ON SCHEMA::t TO first_test_ETL_tester;
GRANT DELETE ON SCHEMA::t TO first_test_ETL_tester;
GRANT UPDATE ON SCHEMA::t TO first_test_ETL_tester;

GO

USE [master]
GO
CREATE LOGIN [testerETL] WITH PASSWORD=N'testerETLpassword1' 
	-- MUST_CHANGE -- Change password after first login
	, DEFAULT_DATABASE=[master]
	, CHECK_EXPIRATION=ON
	, CHECK_POLICY=ON
GO

USE [first_test]
GO
CREATE USER [testerETLuser] FOR LOGIN [testerETL]
GO

USE [first_test]
GO
ALTER ROLE [first_test_ETL_tester] ADD MEMBER [testerETLuser]
GO

-- NOTE
-- When login, use the login name if asked for Login.
-- Use the user name if asked for it.


-- SCHEMAS
-- w: work or production schema
-- t: test schema

-- Create a production schema
CREATE SCHEMA w;
GO

-- Transfer customer and sales from dbo to w schema
ALTER SCHEMA w TRANSFER [dbo].[customer];
ALTER SCHEMA w TRANSFER [dbo].[sales];
GO

-- Create a test schema
CREATE SCHEMA t;
GO

CREATE TABLE [t].[customer](
	[custno] [int] IDENTITY(1,1) NOT NULL,
	[custname] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_customer] PRIMARY KEY CLUSTERED ([custno] ASC)
) 


CREATE TABLE [t].[sales](
	[salesno] [int] IDENTITY(1,1) NOT NULL,
	[custno] [int] NULL,
	[sales] [decimal](10, 2) NOT NULL,
 CONSTRAINT [PK_sales] PRIMARY KEY CLUSTERED ( [salesno] ASC )
) 
GO

ALTER TABLE [t].[sales]  WITH CHECK ADD  CONSTRAINT [FK_sales_cust] FOREIGN KEY([custno])
REFERENCES [t].[customer] ([custno])
ON UPDATE CASCADE
ON DELETE SET NULL
GO

ALTER TABLE [t].[sales] CHECK CONSTRAINT [FK_sales_cust]
GO

ALTER TABLE [t].[sales]  WITH CHECK ADD  CONSTRAINT [CK_sales] CHECK  (([sales]>(0)))
GO

ALTER TABLE [t].[sales] CHECK CONSTRAINT [CK_sales]
GO

