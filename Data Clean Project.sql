-- SQL Project - Data Cleaning

-- Goal: Clean raw layoffs data for exploratory data analysis

------------------------------------------------------------
-- 1. Create Staging Table
------------------------------------------------------------

CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging
SELECT * FROM world_layoffs.layoffs;

------------------------------------------------------------
-- 2. Remove Duplicates (MySQL-safe approach)
------------------------------------------------------------

CREATE TABLE world_layoffs.layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT,
    row_num INT
);

INSERT INTO world_layoffs.layoffs_staging2
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off,
                     percentage_laid_off, `date`, stage, country,
                     funds_raised_millions
    ) AS row_num
FROM world_layoffs.layoffs_staging;

DELETE
FROM world_layoffs.layoffs_staging2
WHERE row_num > 1;

------------------------------------------------------------
-- 3. Standardize Data
------------------------------------------------------------

-- Convert blank industries to NULL
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate missing industry values using self-join
UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Standardize Crypto industry naming
UPDATE world_layoffs.layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Remove trailing periods from country names
UPDATE world_layoffs.layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

------------------------------------------------------------
-- 4. Fix Date Column
------------------------------------------------------------

UPDATE world_layoffs.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN `date` DATE;

------------------------------------------------------------
-- 5. Handle Null / Useless Rows
------------------------------------------------------------

DELETE
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

------------------------------------------------------------
-- 6. Final Cleanup
------------------------------------------------------------

ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN row_num;

-- Cleaned data ready for EDA
SELECT *
FROM world_layoffs.layoffs_staging2;
