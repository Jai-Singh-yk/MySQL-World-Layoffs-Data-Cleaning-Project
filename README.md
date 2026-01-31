# MySQL-World-Layoffs-Data-Cleaning-Project

# 🌍 World Layoffs Data Cleaning SQL Project 


---

## 📌 Project Overview

This project focuses on **cleaning, standardizing, and preparing a real-world layoffs dataset** using **MySQL**. The dataset contains global company layoffs data from 2021 onward and is cleaned to ensure accuracy, consistency, and usability for downstream **Exploratory Data Analysis (EDA)**. The project follows a professional **data-cleaning workflow** used in real analytics and data engineering environments, including staging tables, duplicate handling, standardization, null-value treatment, and schema optimization.

---

## 🎯 Objectives

- 🗄️ Create raw and staging tables to preserve original data  
- 🧹 Identify and remove duplicate records safely  
- 🧩 Standardize inconsistent categorical values  
- 📆 Convert string-based dates into proper DATE format  
- 🔍 Handle null and missing values logically  
- 🧼 Remove unusable records and temporary columns  
- 📊 Prepare a clean dataset for analytics and visualization  
 
---

## 🗃️ Database Structure

### Tables Used

| Table Name | Description |
|-----------|------------|
| `layoffs` | Raw imported data (unchanged) |
| `layoffs_staging` | First staging table (working copy) |
| `layoffs_staging2` | Final cleaned dataset |

Staging tables are used to **protect raw data integrity**, following real-world best practices

---

## 1️⃣ ⚙️ Database Setup

Create Staging Table

```sql
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging
SELECT * FROM world_layoffs.layoffs;
```

---

## 2️⃣ 🧹 Duplicate Removal

Strategy

- Used ROW_NUMBER() window function
- Partitioned across all columns to identify true duplicates
- Created a second staging table due to MySQL delete limitations
```sql
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off,
                 percentage_laid_off, date, stage, country,
                 funds_raised_millions
)
```
Duplicates were removed where row_num > 1.

---

## 3️⃣ 🧩 Data Standardization

Industry Cleanup

- Converted blank industries to NULL
- Populated missing industries using a self-join
- Standardized inconsistent values - Crypto Currency, CryptoCurrency → Crypto
```sql
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');
```

Country Cleanup

- Removed trailing punctuation (e.g., United States. → United States)
```sql
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);
```

---

## 4️⃣ 📆 Date Formatting & Conversion

- Problem - Dates were stored as text in MM/DD/YYYY format
- Solution - Converted strings to DATE format using STR_TO_DATE & Updated column data type to DATE
```sql
UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;
```

This enables proper time-series analysis

---

## 5️⃣ 🔍 Handling Null Values

- Industry Null Population - Used a self-join to populate missing industry values when another row for the same company contained valid data

```sql
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
```

Some rows remain null when no reference value exists — preserved intentionally

---

## 6️⃣ 🗑️ Removing Useless Records

- Rows where both total_laid_off and percentage_laid_off were NULL were removed due to lack of analytical value

```sql
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
```
---

## 7️⃣ 🧼 Final Cleanup

- Removed helper column used for duplicate identification

```sql
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```

---

## 📈 Key Outcomes

-  Duplicate-free dataset  
-  Standardized industry and country values  
-  Proper `DATE` data type for time-series analysis  
-  Logical handling of missing values  
-  Analytics-ready final table  

---

## 🛠️ Tools & Concepts Used

- **MySQL**
- **SQL Window Functions** (`ROW_NUMBER`)
- **Self Joins**
- **String Functions** (`TRIM`, `STR_TO_DATE`)
- **Data Type Conversion**
- **Data Cleaning Best Practices**
- **Staging Table Architecture**

---

## 🚀 Next Steps

- Exploratory Data Analysis (EDA)
- Industry and country-level trend analysis
- Time-series layoffs analysis
- Visualization using Tableau, Power BI, or Python

---

## ✅ Conclusion

This project demonstrates a **real-world SQL data cleaning workflow** commonly used by data analysts and data engineers. By leveraging staging tables, window functions, and structured standardization techniques, the raw dataset is transformed into a reliable foundation for analysis and data-driven decision-making.

