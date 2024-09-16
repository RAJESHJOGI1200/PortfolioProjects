/*

Cleaning Data in SQL Queries

*/


Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardizing SaleDate into proper DATE format in MySQL
-- First, converting SaleDate to DATE format
	
UPDATE NashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate, '%Y-%m-%d');

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

-- 1. Select records, ordered by ParcelID
SELECT *
FROM NashvilleHousing
ORDER BY ParcelID;

-- 2. Select records where PropertyAddress is null and perform join
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
       COALESCE(a.PropertyAddress, b.PropertyAddress) AS FilledPropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b 
    ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- 3. Update records where PropertyAddress is null with non-null values from join
UPDATE NashvilleHousing a
JOIN NashvilleHousing b 
    ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;




--------------------------------------------------------------------------------------------------------------------------
-- Breaking Out Address into Individual Columns (Address, City, State)

-- 1. Select PropertyAddress to view the original data
SELECT PropertyAddress
FROM NashvilleHousing;

-- 2. Split PropertyAddress into Address and City
SELECT
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS PropertySplitAddress,  -- First part before the first comma
    SUBSTRING_INDEX(PropertyAddress, ',', -1) AS PropertySplitCity     -- Last part after the last comma
FROM NashvilleHousing;

-- 3. Add new columns for the split address and city
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

-- 4. Update the new columns with the split values from PropertyAddress
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1),
    PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

-- 5. Select the OwnerAddress to view the original data
SELECT OwnerAddress
FROM NashvilleHousing;

-- 6. Split OwnerAddress into Address, City, and State using PARSENAME logic
SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM NashvilleHousing;

-- 7. Add new columns for the split OwnerAddress, City, and State
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

-- 8. Update the new columns with the split values from OwnerAddress
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- 9. Verify the updated table with all columns
SELECT *





--------------------------------------------------------------------------------------------------------------------------


-- Changing 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant field

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
	
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

Select *
From NashvilleHousing;




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From NashvilleHousing;


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- Method 1:
-- To export cleaned data from MySQL to Excel, you can use several approaches. Here's a common method:

-- 1. Using MySQL Workbench:
-- MySQL Workbench allows you to export query results to CSV, which can then be opened in Excel.
-- Steps:

-- Run your query to retrieve the cleaned data, for example:

SELECT * FROM NashvilleHousing;

-- Right-click on the result grid.
-- Choose "Export result set".
-- Select CSV as the file format.
-- Save the file and open it in Excel.

-- Method 2:
-- Using MySQL SELECT INTO OUTFILE:
-- You can directly export the data from MySQL to a CSV file that can be opened in Excel:


SELECT * 
INTO OUTFILE '/path_to_your_file/nashville_cleaned_data.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM NashvilleHousing;






