USE [master]
GO
/****** Object:  Database [DataLakeStoreInfo]    Script Date: 27/03/2018 11:24:00 ******/
CREATE DATABASE [DataLakeStoreInfo]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DataLakeStore', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\DataLakeStore.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'DataLakeStore_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\DataLakeStore_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

USE [DataLakeStoreInfo]
GO
/****** Object:  Table [dbo].[StoreDetails]    Script Date: 27/03/2018 11:24:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StoreDetails](
	[AccountName] [varchar](128) NOT NULL,
	[FileId] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [varchar](500) NOT NULL,
	[FullPath] [varchar](max) NOT NULL,
	[Size] [float] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[ParentFolders]    Script Date: 27/03/2018 11:24:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ParentFolders]
AS

SELECT
	[AccountName],
	SUBSTRING([FullPath],2,CHARINDEX('/',SUBSTRING([FullPath],2,100))-1) AS 'RootFolders',
	SUM([Size])/1024 AS 'SizeGB',
	COUNT(0) AS 'FileCount'
FROM 
	[DataLakeStoreInfo].[dbo].[StoreDetails]
GROUP BY
	[AccountName],
	SUBSTRING([FullPath],2,CHARINDEX('/',SUBSTRING([FullPath],2,100))-1)


GO
/****** Object:  View [dbo].[StorageAcounts]    Script Date: 27/03/2018 11:24:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[StorageAcounts]
AS

SELECT DISTINCT
	[AccountName]
FROM
	[dbo].[StoreDetails]
GO
/****** Object:  StoredProcedure [dbo].[InsertADLStoreRecord]    Script Date: 27/03/2018 11:24:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertADLStoreRecord]
	(
	@AccountName VARCHAR(128),
	@FileName VARCHAR(500),
	@FullPath VARCHAR(MAX),
	@Size INT,
	@ModifiedDate DATETIME
	)
AS

BEGIN

	INSERT INTO [dbo].[StoreDetails]
		(
		[AccountName],
		[FileName],
		[FullPath],
		[Size],
		[ModifiedDate]
		)
	VALUES
		(
		@AccountName,
		@FileName,
		@FullPath,
		@Size,
		@ModifiedDate
		)

END
GO
USE [master]
GO
ALTER DATABASE [DataLakeStoreInfo] SET  READ_WRITE 
GO
