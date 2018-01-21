DROP TABLE IF EXISTS Company;
CREATE TABLE Company(
    Id integer PRIMARY KEY AUTOINCREMENT NOT NULL,
    [Name] nvarchar (128) NOT NULL,
    Address1 nvarchar (255) NOT NULL, 
    Address2 nvarchar (255) NOT NULL,  
    City nvarchar (128) NOT NULL,  
    State nvarchar (128) NOT NULL,  
    ZipCode nvarchar (128) NOT NULL,  
    PhoneNumber nvarchar (128) NOT NULL,  
    FaxNumber nvarchar (128) NOT NULL,  
    CategoryId integer NOT NULL,
    FOREIGN KEY(CategoryId) REFERENCES Category(Id)
);

DROP TABLE IF EXISTS Category;
CREATE TABLE Category(
    Id integer PRIMARY KEY AUTOINCREMENT NOT NULL,
    [Name] nvarchar (128) NOT NULL
)