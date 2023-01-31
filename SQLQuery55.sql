-- cleaning data in sql

SELECT *
FROM project.dbo.National_housing


--CONVERT DATE FORMART

SELECT SaleDateCONVERTED, CONVERT(Date,SaleDate)
FROM project.dbo.National_housing

UPDATE National_housing
SET  SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE National_housing
ADD SaleDateConverted Date;

UPDATE National_housing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--POPULATE PROPERTY ADDRESS DATA


SELECT *
FROM project.dbo.National_housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress,B.ParcelID,B.PropertyAddress, isnull(A.PropertyAddress,B.PropertyAddress)
FROM project.dbo.National_housing A
JOIN project.dbo.National_housing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = isnull(A.PropertyAddress,B.PropertyAddress)
FROM project.dbo.National_housing A
JOIN project.dbo.National_housing B
ON A.ParcelID =  B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null


--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS

SELECT PropertyAddress
FROM project.dbo.National_housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM project.dbo.National_housing

ALTER TABLE National_housing
ADD PropertySplitAddress NvarChar(255);

UPDATE National_housing
SET PropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE  National_housing
ADD PropertySplitCity NvarChar(255);

UPDATE National_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))




SELECT *
FROM project.dbo.National_housing



SELECT OwnerAddress
FROM project.dbo.National_housing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', ',' ) , 3),
PARSENAME(REPLACE(OwnerAddress, ',', ',') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', ',' ) , 1)
FROM project.dbo.National_housing


ALTER TABLE National_housing 
ADD  OwnerSplitAddress NvarChar(225);


UPDATE National_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', ',') ,3)


ALTER TABLE National_housing
ADD OwnerSplitCity NvarChar(225);

UPDATE National_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', ',') ,2)


ALTER TABLE National_housing
ADD OwnerSplitState NvarChar(255);


UPDATE National_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', ',') ,1)


SELECT *
FROM project.dbo.National_housing

--CHANGE Y AND N TO TES AND NO IN SOLD AS VACANT COLUMN

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
 FROM project.dbo.National_housing
 GROUP BY SoldAsVacant
 ORDER BY 2


 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant ='N' THEN 'No'
 ELSE SoldAsVacant
 END
 FROM project.dbo.National_housing


 UPDATE National_housing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END


 --REMOVE DUPLICATES

 WITH RowNumCTE AS(
 SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
 PropertyAddress,
 SalePrice,
 SaleDate,
 LegalReference
 ORDER BY
 UniqueID) row_num
 FROM project.dbo.National_housing
 --ORDER BY ParcelID
 )
 --to delete replace select* below with Delete function
 DELETE
 FROM RowNumCTE
 WHERE row_num > 1
 --ORDER BY PropertyAddress



 SELECT *
 FROM project.dbo.National_housing


 ALTER TABLE project.dbo.National_housing
 DROP COLUMN TaxDistrict,PropertyAddress