-- Cleaning data in Property analysis table

select * from PortfolioProjectCovid.dbo.PropertyAnalysis

-- Standardize date format


select SaleDate, convert(Date,SaleDate) from PortfolioProjectCovid.dbo.PropertyAnalysis

Alter table propertyAnalysis
Add NewSaleDate Date

Update PropertyAnalysis
Set NewSaleDate = convert(date,SaleDate)


-- Populate Property address data

Select PropertyAddress
from dbo.PropertyAnalysis

Select PropertyAddress
from dbo.PropertyAnalysis where PropertyAddress is Null

-- same ParcelId have same property address but uniqueId are different

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress from 
PortfolioProjectCovid..PropertyAnalysis a join
PortfolioProjectCovid..PropertyAnalysis b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNull(a.propertyaddress,b.PropertyAddress) from 
PortfolioProjectCovid..PropertyAnalysis a join
PortfolioProjectCovid..PropertyAnalysis b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null


Update a 
Set PropertyAddress = IsNull(a.propertyaddress,b.PropertyAddress) from
PortfolioProjectCovid..PropertyAnalysis a join
PortfolioProjectCovid..PropertyAnalysis b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null

-- Breaking out Address into individual column (Address,City,State)
-- charIndex() returns value

Select PropertyAddress
from dbo.PropertyAnalysis

Select SUBSTRING(PropertyAddress,1,charIndex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,charIndex(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from dbo.PropertyAnalysis


Alter Table PropertyAnalysis
Add PropertySplitAddress Nvarchar(255)

Update PropertyAnalysis
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,charIndex(',',PropertyAddress)-1)

Alter table PropertyAnalysis
add PropertySplitCity Nvarchar(255)

Update PropertyAnalysis
Set PropertySplitCity = SUBSTRING(PropertyAddress,charIndex(',',PropertyAddress)+1,LEN(PropertyAddress))

-- Owner address
 Select owneraddress
 from dbo.PropertyAnalysis

 Select PARSENAME(Replace(OwnerAddress,',','.'),3),
        PARSENAME(Replace(OwnerAddress,',','.'),2),
		PARSENAME(Replace(OwnerAddress,',','.'),1)
 from dbo.PropertyAnalysis


Alter table PropertyAnalysis
add OwnerSplitAddress varchar(255)
 
Update PropertyAnalysis
Set OwnerSplitAddress = ParseName(Replace(OwnerAddress,',','.'),3)

Alter table PropertyAnalysis
add OwnerSplitCity varchar(255)

Update PropertyAnalysis
Set OwnerSplitCity = ParseName(Replace(OwnerAddress,',','.'),2)

Alter table PropertyAnalysis
add OwnerSplitState varchar(255)

Update PropertyAnalysis
Set OwnerSplitState = ParseName(Replace(OwnerAddress,',','.'),1)




-- Change Y and N to Yes and No in SoldAsVacant

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from dbo.PropertyAnalysis
group by SoldAsVacant

Select SoldAsVacant, 
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
from dbo.PropertyAnalysis	

Update PropertyAnalysis
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
from dbo.PropertyAnalysis


-- Remove Duplicates

With RowNumCTE as
(
Select *,
       ROW_NUMBER() over (partition by ParcelID,
									   PropertyAddress,
									   SalePrice,
									   SaleDate,
									   LegalReference
									   Order by
									   UniqueID
									   ) row_num
from dbo.PropertyAnalysis	
--order by ParcelID
)
--Delete from RowNumCTE
--where row_num>1
----Order by PropertyAddress

Select * from RowNumCTE
where row_num > 1


-- Delete Unused Columns

Select * from dbo.PropertyAnalysis

Alter table PropertyAnalysis
Drop Column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

Alter table PropertyAnalysis
Drop Column SaleDate


