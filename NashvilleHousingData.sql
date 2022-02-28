/* Standardize the date format
	Currently looks like 2015-10-23 00:00:00.000
	Creating a new column that looks like 2015-10-23 without the time */

SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing..NashvilleHousing

Update NashvilleHousing..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


/* Add as a new column instead of altering the existing one */

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


/* Populate Property Address data */

SELECT *
FROM NashvilleHousing..NashvilleHousing

WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT	a.ParcelID
	,a.PropertyAddress
	,b.ParcelID
	,b.PropertyAddress
	,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing..NashvilleHousing a
JOIN NashvilleHousing..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing..NashvilleHousing a
JOIN NashvilleHousing..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

WHERE a.PropertyAddress is null


/* Breaking out address into individual columns (Address, City, State) */

/* Split up the property address info */

SELECT PropertyAddress
FROM NashvilleHousing..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )					AS Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))	AS City

FROM NashvilleHousing..NashvilleHousing


ALTER TABLE NashvilleHousing..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update NashvilleHousing..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


/* Split up the owner address info */

SELECT OwnerAddress
FROM NashvilleHousing..NashvilleHousing

SELECT	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)	-- Address
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)		-- City
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)		-- State
FROM NashvilleHousing..NashvilleHousing

ALTER TABLE NashvilleHousing..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update NashvilleHousing..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

Update NashvilleHousing..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

Update NashvilleHousing..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


/* Change Y and N to Yes and No in "Sold as Vacant" field.
In the dataset there are four different options. Yes, No, Y, and N */

SELECT	Distinct(SoldAsVacant)
	,Count(SoldAsVacant)
FROM NashvilleHousing..NashvilleHousing

GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
	,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing..NashvilleHousing

Update NashvilleHousing..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


/* Practice removing duplicates */

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM NashvilleHousing..NashvilleHousing
--order by ParcelID
)
SELECT *
FROM RowNumCTE

WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
FROM NashvilleHousing..NashvilleHousing


/* Delete Unused Columns */

SELECT *
FROM NashvilleHousing..NashvilleHousing

ALTER TABLE NashvilleHousing..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
