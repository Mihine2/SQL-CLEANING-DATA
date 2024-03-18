--SQL PROJECT CLEANING DATA 
SELECT *
FROM Portfolio.dbo.NashvilleHousing

--Standardize Sale Price
SELECT SalePrice
FROM Portfolio.dbo.NashvilleHousing
WHERE SalePrice LIKE '%$%'

SELECT SalePrice, REPLACE(SalePrice, '$', '') as SalePriceFixed
FROM Portfolio.dbo.NashvilleHousing
WHERE SalePrice LIKE '%$%'

UPDATE NashvilleHousing
SET SalePrice = REPLACE(SalePrice, '$', '') 

UPDATE NashvilleHousing
SET SalePrice = REPLACE(SalePrice, ',', '')

SELECT SalePriceConverted, CONVERT(INT,SalePrice)
FROM Portfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SalePriceConverted INT

UPDATE NashvilleHousing
SET SalePriceConverted = CONVERT(INT,SalePrice)

--Populate Property Data
SELECT *
FROM Portfolio.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio.dbo.NashvilleHousing a
JOIN Portfolio.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
WHERE a.UniqueID <> b.UniqueID
AND a.PropertyAddress IS NULL 

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio.dbo.NashvilleHousing a
JOIN Portfolio.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
WHERE a.UniqueID <> b.UniqueID
AND a.PropertyAddress IS NULL 

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM Portfolio.dbo.NashvilleHousing

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Portfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Address NVARCHAR(50)

UPDATE NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD City NVARCHAR(50)

UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT Address, City
FROM Portfolio.dbo.NashvilleHousing

SELECT OwnerAddress
FROM Portfolio.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.' ), 3) AS OwnerAddresss,
PARSENAME(REPLACE(OwnerAddress,',','.' ), 2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress,',','.' ), 1) AS OwnerState 
FROM Portfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddresss NVARCHAR(50)

UPDATE NashvilleHousing
SET OwnerAddresss = PARSENAME(REPLACE(OwnerAddress,',','.' ), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR(50)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.' ), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState NVARCHAR(50)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.' ), 1)

SELECT OwnerAddresss, OwnerCity, OwnerState
FROM Portfolio.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM Portfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM Portfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END

-- Remove Duplicates
WITH CTEROW_NUM
AS
(
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference 
    ORDER BY 
    UniqueID
    ) row_num
FROM Portfolio.dbo.NashvilleHousing
)
SELECT *
FROM CTEROW_NUM
WHERE row_num > 1

--REMOVE DUPLICATE
SELECT *
FROM Portfolio.dbo.NashvilleHousing

ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SalePrice

