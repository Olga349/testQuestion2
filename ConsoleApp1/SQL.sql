USE [Apteka]
GO

/****** Object:  Table [dbo].[merchandises]    Script Date: 03.07.2023 16:46:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[merchandises](
	[merchandise_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_merchandises] PRIMARY KEY CLUSTERED 
(
	[merchandise_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[dragstores](
	[drugstore_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](150) NOT NULL,
	[adress] [nvarchar](250) NULL,
	[telephone] [nvarchar](50) NULL,
 CONSTRAINT [PK_dragstores] PRIMARY KEY CLUSTERED 
(
	[drugstore_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[stores](
	[store_id] [int] IDENTITY(1,1) NOT NULL,
	[dragstore_id] [int] NOT NULL,
	[name] [nvarchar](150) NULL,
 CONSTRAINT [PK_stores] PRIMARY KEY CLUSTERED 
(
	[store_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[stores]  WITH CHECK ADD  CONSTRAINT [FK_stores_dragstores] FOREIGN KEY([dragstore_id])
REFERENCES [dbo].[dragstores] ([drugstore_id])
GO

ALTER TABLE [dbo].[stores] CHECK CONSTRAINT [FK_stores_dragstores]
GO

CREATE TABLE [dbo].[shipments](
	[shipment_id] [int] IDENTITY(1,1) NOT NULL,
	[merchandise_id] [int] NOT NULL,
	[store_id] [int] NOT NULL,
	[quantity] [int] NOT NULL,
 CONSTRAINT [PK_shipments] PRIMARY KEY CLUSTERED 
(
	[shipment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[shipments]  WITH CHECK ADD  CONSTRAINT [FK_shipments_merchandises] FOREIGN KEY([merchandise_id])
REFERENCES [dbo].[merchandises] ([merchandise_id])
GO

ALTER TABLE [dbo].[shipments] CHECK CONSTRAINT [FK_shipments_merchandises]
GO

ALTER TABLE [dbo].[shipments]  WITH CHECK ADD  CONSTRAINT [FK_shipments_stores] FOREIGN KEY([store_id])
REFERENCES [dbo].[stores] ([store_id])
GO

ALTER TABLE [dbo].[shipments] CHECK CONSTRAINT [FK_shipments_stores]
GO

CREATE PROCEDURE [dbo].[AddDrugstory]
	-- Add the parameters for the stored procedure here
	@name nvarchar(150),
	@adress nvarchar(250),
	@telephone nvarchar(50),
	@drugstory_id int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	insert into [dbo].[drugstores] (name, adress, telephone)
	values (@name, @adress, @telephone)

	SET @drugstory_id = @@IDENTITY
END
GO

GO

CREATE PROCEDURE [dbo].[DrugstoreDelete] 
	-- Add the parameters for the stored procedure here
	@drugstore_id Int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		-- interfering with SELECT statements.
	DELETE FROM [dbo].[shipments] WHERE store_id in (SELECT store_id FROM [dbo].[stores] where [drugstore_id] = @drugstore_id)
	DELETE FROM  [dbo].[stores] where [drugstore_id] = @drugstore_id
	DELETE FROM [dbo].[drugstores] WHERE [drugstore_id] = @drugstore_id
END

GO

CREATE PROCEDURE dbo.StoresAdd
	@drugstore_id int,
	@name nvarchar(50),
	@store_id int output
AS
BEGIN
	insert into dbo.stores (drugstore_id, name)
	values(@drugstore_id, @name)
	SET @store_id = @@IDENTITY
END
GO
CREATE PROCEDURE dbo.StoresDelete 
	@store_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	delete from [dbo].[shipments] Where Store_id = @store_id
	DELETE FROM [dbo].[stores] WHERE store_id = @store_id
END
GO
CREATE PROCEDURE  [dbo].[MerchandisesAdd]
	@name nvarchar(150),
	@merchandise_id int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	INSERT INTO  [dbo].[merchandises] (name)
	VALUES (@name)

	SET @merchandise_id = @@IDENTITY
END
GO
CREATE PROCEDURE dbo.MerchandisesDelete 
	@merchandise_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM [dbo].[shipments] WHERE [merchandise_id]= @merchandise_id
	DELETE FROM [dbo].[merchandises] WHERE [merchandise_id] = @merchandise_id
END
GO

CREATE PROCEDURE dbo.shipmentsAdd 
	@merchandise_id int,
	@store_id int,
	@quantity int,
	@shipment_id int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[shipments] ([merchandise_id], [store_id], [quantity])
	VALUES (@merchandise_id, @store_id, @quantity)

	SET @shipment_id = @@IDENTITY
END
GO
CREATE PROCEDURE dbo.ShipmentDelete 
	@shipment_Id int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DELETE FROM [dbo].[shipments] WHERE [shipment_id] = @shipment_Id
END
GO
//Запрос кол-во товара во всех складах аптеки
DECLARE @drugstoreID INT = 1


SELECT M.name, S.[merchandise_id], SUM([quantity])
FROM  [dbo].[shipments] S
INNER JOIN [dbo].[merchandises] M ON S.merchandise_id = M.merchandise_id
INNER JOIN [dbo].[stores] T ON S.store_id = T.store_id
WHERE T.drugstore_id = @drugstoreID
GROUP BY M.name, S.[merchandise_id],   T.drugstore_id