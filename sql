Select * from world_layoffs.layoffs;

#MAKING A DUPLICATE TABLE TO WORK UPON
CREATE TABLE IF NOT EXISTS layoff_duplicate LIKE layoffs;

#1. REMOVING DUPLICATES

INSERT INTO layoff_duplicate
SELECT * 
FROM layoffs;

#TO REMOVE DUPLICATES, WE WILL BE USING WINDOW FUNCTION

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off,`date`,stage, country, funds_raised_millions) AS number_of_rows
FROM layoff_duplicate;

#NOW IF THE number_of_rows IS > 1 THEN IT IS A DUPLICATE

CREATE TABLE `layoff_duplicate2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `num_of_rows` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_duplicate2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off,`date`,stage, country, funds_raised_millions) AS number_of_rows
FROM layoff_duplicate;

SET SQL_SAFE_UPDATES=0;

DELETE FROM layoff_duplicate2
WHERE num_of_rows>1;

#2. STANDARDIZING 

UPDATE layoff_duplicate2
SET company = TRIM(company);

UPDATE layoff_duplicate2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoff_duplicate2
SET country = 'United States'
WHERE industry LIKE 'United States.';

UPDATE layoff_duplicate2 
SET `date` = str_to_date(`date`,'%m/%d/%Y');
 
ALTER TABLE layoff_duplicate2
MODIFY COLUMN `date` Date;

#3.REMOVING NULLS AND BLANKS SPACES


-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values




-- 4. remove any columns and rows we need to

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL;


SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM world_layoffs.layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT * 
FROM world_layoffs.layoffs_staging2;
