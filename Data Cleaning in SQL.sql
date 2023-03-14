/* 
Cleaning Data in SQL Queries
*/  

Select * 
From [SQL Data Cleaning]..NashVilleHousing 

--Standardize Date Format 

Select SaleDateConverted, CONVERT(Date, SaleDate) 
From [SQL Data Cleaning]..NashVilleHousing 

Update NashVilleHousing 
SET SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE NashVilleHousing 
Add SaleDateConverted Date; 

Update NashVilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate) 

--Populate Property Address Data

Select * 
From [SQL Data Cleaning]..NashVilleHousing
Order by ParcelID 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [SQL Data Cleaning]..NashVilleHousing a
JOIN [SQL Data Cleaning]..NashVilleHousing b
    on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [SQL Data Cleaning]..NashVilleHousing a
JOIN [SQL Data Cleaning]..NashVilleHousing b
    on a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ] 

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress 
From [SQL Data Cleaning]..NashVilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From [SQL Data Cleaning]..NashVilleHousing 

ALTER TABLE NashVilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update NashVilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashVilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From [SQL Data Cleaning]..NashVilleHousing



Select OwnerAddress
From [SQL Data Cleaning]..NashVilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From [SQL Data Cleaning]..NashVilleHousing

ALTER TABLE NashVilleHousing
Add OwnerSplitAddress Nvarchar(255); 

Update NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashVilleHousing
Add OwnerSplitCity Nvarchar(255); 

Update NashVilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashVilleHousing 
Add OwnerSplitState Nvarchar(255); 

Update NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

Select *
From [SQL Data Cleaning]..NashVilleHousing 

--Change Y and N to Yes and No in "Sold as Vacant" field 

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From [SQL Data Cleaning]..NashVilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant 
, CASE When SoldAsVacant = 'Y' THEN 'Yes' 
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [SQL Data Cleaning]..NashVilleHousing

Update NashVilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
                        When SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant 
						END 

--Remove Duplicates 

WITH RowNumCTE AS (
Select *
, ROW_NUMBER() OVER (
  PARTITION BY  ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
				ORDER BY
					UniqueID ) row_num

From [SQL Data Cleaning]..NashVilleHousing
--Order by ParcelID 
) 
Select *
From RowNumCTE 
Where row_num > 1
--Order by PropertyAddress


-----------------------------------
--Delete Unused Columns 

Select *
From [SQL Data Cleaning]..NashVilleHousing

ALTER TABLE [SQL Data Cleaning]..NashVilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [SQL Data Cleaning]..NashVilleHousing
DROP COLUMN SaleDate

