/*
	Cleaning data in SQL Queries
*/

SELECT *
FROM PortfolioProjects..NashvilleHousing
--FROM PortfolioProjects.dbo.NashvilleHousing
;

--Standardize date format

SELECT SaleDateConverted, CONVERT(Date,SaleDate) AS New_SaleDate
FROM NashvilleHousing;

UPDATE NashvilleHousing   --Command not working
SET SaleDate = CONVERT(Date,SaleDate);

--So we will ALTER the table
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(Date,SaleDate);


-- Populate property address

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
;

--Breaking out Address into Individual Columns (Address, City, State)

--For Property Address

SELECT PropertyAddress
FROM NashvilleHousing
;

SELECT
SUBSTRING(PropertyAddress , 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing
;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1, CHARINDEX(',',PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress));

SELECT *
FROM NashvilleHousing;

--For Owner Address

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing
;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT *
FROM NashvilleHousing;

--Change Y and N to Yes and No in "SoldAsVacant" Column

Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing
;

UPDATE NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing
;

Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

--Remove Duplicates
/* Find Duplicate first */

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference
		ORDER BY 
			UniqueID
			) row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
--WHERE row_num > 1
ORDER BY PropertyAddress
;

/* Remove Duplicate */
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference
		ORDER BY 
			UniqueID
			) row_num
FROM NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
;

--Delete Unused Columns

SELECT *
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict
;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
;
