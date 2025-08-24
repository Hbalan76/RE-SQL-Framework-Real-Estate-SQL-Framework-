SELECT
*
FROM silver.NY_House_Dataset

-- query to check column data type

	SELECT COLUMN_NAME, DATA_TYPE
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE 
			TABLE_NAME = 'NY_House_Dataset'
		AND COLUMN_NAME = 'price'
		AND TABLE_SCHEMA = 'silver'
	

-- Phase 1: Data Understanding & Profilling

	-- Goal: Build awareness of data quality, distribution, and completeness.

	-- tasks 1 -
			
			/*
				Column Summary Report
			*/

			-- query to check NULL(apply this all columns)
			
			SELECT
			BROKERTITLE
			FROM silver.NY_House_Dataset
			WHERE BROKERTITLE IS NULL

			-- query to check LEN of a column

			SELECT
			TYPE,
			LEN(TYPE)
			FROM silver.NY_House_Dataset

			-- query to check distinct BROKERS

			SELECT DISTINCT
			BROKERTITLE
			FROM silver.NY_House_Dataset

			-- query to check distinct type of property

			SELECT DISTINCT
			TYPE
			FROM silver.NY_House_Dataset
			
			-- query to check total states

			SELECT DISTINCT
			STATE
			FROM silver.NY_House_Dataset
			
	-- tasks 2 -
			
			/*
				Basic Stats
			*/

			-- query to check avg price

			SELECT
			ROUND(AVG(CAST(price AS FLOAT)), 2) AS avg_price
			FROM silver.NY_House_Dataset

			-- query to check property with max price

			SELECT
			*
			FROM silver.NY_House_Dataset
			WHERE PRICE = (SELECT MAX(PRICE) FROM silver.NY_House_Dataset)

			-- query to check property with min price

			SELECT
			*
			FROM silver.NY_House_Dataset
			WHERE PRICE = (SELECT MIN(PRICE) FROM silver.NY_House_Dataset)
			
			-- query to check avg BEDS

			SELECT
			AVG(BEDS) AS avg_beds
			FROM silver.NY_House_Dataset

			-- query to check avg BATH

			SELECT
			AVG(BATH) AS avg_bath
			FROM silver.NY_House_Dataset
			WHERE BATH != 2.37386083602905
			/*
				We observed that the value 2.37386083602905 appears frequently 
				in the bath column.This figure represents the average number 
				of bathrooms and has been used to impute missing values 
				(i.e., it replaces NULL entries in the dataset). - (same with PROPERTYSQFT)
			*/

			-- query to check avg PROPERTYSQFT

			SELECT
			AVG(PROPERTYSQFT)
			FROM silver.NY_House_Dataset
			WHERE PROPERTYSQFT <> 2184.20776367188

	-- task 3 -
			
			/*
				Geographic Coverage
			*/

			-- query to check distinct states

			SELECT DISTINCT
			STATE
			FROM silver.NY_House_Dataset

			-- query to check distinct locality

			SELECT DISTINCT
			LOCALITY
			FROM silver.NY_House_Dataset

			-- query to check sub locality

			SELECT DISTINCT
			SUBLOCALITY
			FROM silver.NY_House_Dataset

			-- query to check administrative_area_level_2

			SELECT DISTINCT
			ADMINISTRATIVE_AREA_LEVEL_2
			FROM silver.NY_House_Dataset

	-- task 4 -
			
			/*
				Address Structure Check
			*/

			-- query to check Address Structure
			SELECT
				ADDRESS,
				MAIN_ADDRESS,
				FORMATTED_ADDRESS,
				LONG_NAME
			FROM silver.NY_House_Dataset


-- Phase 2: Data Cleaning & Validation
			
	-- Goal: Standardize formats, handle missing values, and flag anomalies.

	-- tasks 1 -
				
			/*
				Outlier Detection on price Using Z-score
				Formula:
				Z = (Value − Mean) / Standard Deviation
				This formula helps identify values in the price column that significantly 
				deviate from the average. Typically:
				- Z > +3 or Z < –3 → considered outliers
				- Useful for flagging extreme pricing anomalies in real estate dataset
			*/

			WITH z_scores AS (
			SELECT *,
					(PRICE - AVG(CAST(PRICE AS FLOAT)) OVER()) / STDEV(PRICE) OVER() AS z_score
			FROM silver.NY_House_Dataset
			) 
			SELECT *
			FROM z_scores
			WHERE ABS(z_score) > 3;


			/*
				Outlier Detection on sqft z-score 
			*/
			WITH z_score AS (
			SELECT *,
					(PROPERTYSQFT - AVG(CAST(PROPERTYSQFT AS FLOAT)) OVER()) / STDEV(PROPERTYSQFT) OVER() AS z_score
			FROM silver.NY_House_Dataset
			)
			SELECT *
			FROM z_score
			WHERE ABS(z_score) > 3

			/*
			Summary: Z-score Outlier Detection on PROPERTYSQFT
				- Calculates Z-score for each row in the silver.NY_House_Dataset based on the PROPERTYSQFT column.
				- Z-score formula:
				Z = \frac{\text{Value} - \text{Mean}}{\text{Standard Deviation}}
				- Filters rows where the absolute Z-score is greater than 3 → these are considered statistical outliers.
				- Purpose: Identify unusually large or small property sizes that may be errors or rare cases.
			*/


-- Phase 3: Business Logic & Derived Insight
		-- Goal: Create meaningful metrics and flags for decision-making.

		-- task 1 -

			/*
				query to check price per sqft
			*/
			
			SELECT
				PRICE,
				PROPERTYSQFT,
				ROUND((PRICE / PROPERTYSQFT), 2) AS price_persqft
			FROM silver.NY_House_Dataset


			-- Adding a new column in table

			ALTER TABLE silver.NY_House_Dataset
			ADD PRICEPERSQFT FLOAT

			-- Now going to insert price / sqft in new column

			UPDATE silver.NY_House_Dataset
			SET PRICEPERSQFT = ROUND((PRICE / PROPERTYSQFT),2)


			/*
				query to check room density
			*/

			SELECT
			PROPERTYSQFT,
			((BEDS + BATH)/PROPERTYSQFT) AS ROOM_DENSITY
			FROM silver.NY_House_Dataset

			/*
				Query to check top brokers
			*/

			SELECT TOP 11
			BROKERTITLE,
			total_listing,
			DENSE_RANK() OVER (ORDER BY total_listing DESC) AS RANK
			FROM (
				SELECT
					BROKERTITLE,
					COUNT(*) AS total_listing
				FROM silver.NY_House_Dataset
				GROUP BY BROKERTITLE
				) AS ranked_brokers
			ORDER BY RANK 



			SELECT TOP 100
			*
			FROM silver.NY_House_Dataset
