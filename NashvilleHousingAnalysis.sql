
/* 
Cleaning data in SQL queries
*/
Select * FROM NashvilleHousingAnalysis.dbo.NashvilleHousing;


-- (1->)Standarize the Data formates

SELECT SaleDateConverted, CONVERT(Date, SaleDate) as Date
FROM dbo.NashvilleHousing;

UPDATE NashvilleHousing    --udpate not working every time
SET SaleDate = CONVERT(DATE, SaleDate);

-- Create the column for dates format
ALTER TABLE NashvilleHousing 
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);


-- (2) Populated Property Address Data

Select * 
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID


-- doubt: jo self join mariae to kem  nulll aek column ma aave ne bija ma nai aavtu ? self j join chhe to banne nu null j hy ne

Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)   -- I can change b.PropertyAddress to "NO ADDRESS" also
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing a
JOIN NashvilleHousingAnalysis.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE b.PropertyAddress is NULL

UPDATE a   -- i want to update any one Alias that is why here is a, If I write tablename then it shows me ambigous bcz I created instance of it
 SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM NashvilleHousingAnalysis.dbo.NashvilleHousing a 
 JOIN NashvilleHousingAnalysis.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID  -- NOT EQUAL
WHERE a.PropertyAddress is NULL;


-- (2)  Breaking Address into format of ADDRESS, COLUMN, CITY

SELECT PropertyAddress
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing;

-- now add two column into databse
ALTER TABLE NashvilleHousingAnalysis.dbo.NashvilleHousing
ADD StreetName VARCHAR(250)

UPDATE NashvilleHousingAnalysis.dbo.NashvilleHousing
SET StreetName = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousingAnalysis.dbo.NashvilleHousing
ADD CityName VARCHAR(250)

UPDATE NashvilleHousingAnalysis.dbo.NashvilleHousing
SET CityName = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertyAddress,StreetName, CityName
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing;

-- Owener's Address
SELECT OwnerAddress
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)     -- Ex:- PARSENAME('first.second.third', 2) ==> it will return second 
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2) 
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1) 
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing;

-- adding into table

ALTER TABLE NashvilleHousingAnalysis.dbo.NashvilleHousing
ADD OwnerStreet VARCHAR(250)

UPDATE NashvilleHousingAnalysis.dbo.NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


ALTER TABLE NashvilleHousingAnalysis.dbo.NashvilleHousing
ADD OwnerCity VARCHAR(250)

UPDATE NashvilleHousingAnalysis.dbo.NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousingAnalysis.dbo.NashvilleHousing
ADD OwnerState VARCHAR(250)

UPDATE NashvilleHousingAnalysis.dbo.NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT OwnerStreet, OwnerCity, OwnerState
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing;


-- (4) COnvert YES and NO from Y and N

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


Select SoldAsVacant,  
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
End 
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing

UPDATE NashvilleHousingAnalysis.dbo.NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing


-- Remove Duplicates


SELECT * 
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing
-- CTE usage
WITH RowNumCTE as(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,	
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
	) row_num
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing
-- ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress;

 
-- delete the some columns that are not usable
ALTER TABLE NashvilleHousingAnalysis.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT * 
FROM NashvilleHousingAnalysis.dbo.NashvilleHousing