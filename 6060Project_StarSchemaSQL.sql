drop table dim_sport;
CREATE TABLE dim_sport (
    sportcode INT PRIMARY KEY,
    sportname VARCHAR(100) NOT NULL
);

INSERT INTO dim_sport (sportcode, sportname)
SELECT CAST(SPORTSCODE AS CHAR(10)), Sports
FROM Sports;

select * from dim_sport;
################################
CREATE TABLE dim_classification (
    classificationcode VARCHAR(10) PRIMARY KEY,
    classification_name VARCHAR(100) NOT NULL
);

INSERT INTO dim_classification (classificationcode, classification_name)
SELECT CAST(ClassificationCode AS CHAR(10)), classification_name
FROM Classifications;

select * from dim_classification;
#####################################
CREATE TABLE dim_school (
    unitid INT PRIMARY KEY,
    institution_name VARCHAR(255) NOT NULL,
    address1 VARCHAR(255),
    address2 VARCHAR(255),
    city VARCHAR(100),
    state CHAR(2),
    zip VARCHAR(10)
);

INSERT INTO dim_school (unitid, institution_name, address1, address2, city, state, zip)
SELECT unitid,
       institution_name,
       addr1_txt AS address1,
       addr2_txt AS address2,
       city_txt AS city,
       state_cd AS state,
       Zip_text AS zip
FROM Schools;

SELECT * from dim_school;
##################################
CREATE TABLE dim_date (
    yearID INT PRIMARY KEY
);

INSERT INTO dim_date (yearID)
SELECT DISTINCT Year
FROM Wins;

select * from dim_date;
###################################
drop table dim_expense_type;
CREATE TABLE dim_expense_type (
    expensetypeID INT AUTO_INCREMENT PRIMARY KEY,
    ExpenseType VARCHAR(255) NOT NULL,
    SportType TEXT
);

INSERT INTO dim_expense_type (ExpenseType, SportType)
SELECT DISTINCT expense_type, sportstype
FROM ExpenseDetail;

select * from dim_expense_type;
#####################################
CREATE TABLE dim_financial_type (
    ledger_id INT AUTO_INCREMENT PRIMARY KEY,
    ledger_type VARCHAR(255) NOT NULL
);

INSERT INTO dim_financial_type (ledger_type)
SELECT DISTINCT ledger
FROM SportFinances;

SELECT * from dim_financial_type;
################################################################################
# fact winloss
# FKS : yearid, unitid, sportcode, classificationcode
# Wins, Losses, WinPercentage, Amount

drop table fact_winloss_expenses_temp;
CREATE TABLE fact_winloss (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,
    yearID INT,
    unitid INT,
    sportcode INT,
    classificationcode INT,
    Wins INT,
    Losses INT,
    WinPercentage DECIMAL(5,2),
    FOREIGN KEY (yearID) REFERENCES dim_date(yearID),
    FOREIGN KEY (unitid) REFERENCES dim_school(unitid),
    FOREIGN KEY (sportcode) REFERENCES dim_sport(sportcode),
    FOREIGN KEY (classificationcode) REFERENCES dim_classification(classificationcode)
);

ALTER TABLE fact_winloss
MODIFY Sportcode INT;

INSERT INTO fact_winloss (yearID, unitid, sportcode, classificationcode, Wins, Losses, Amount)
SELECT 
    dd.yearID,
    s.unitid AS unitid,
    f.SPORTSCODE AS sportcode,
    w.Code AS classificationcode,
    w.Won AS Wins,
    w.Loss AS Losses,
    f.amount AS Amount
FROM 
    Wins w
JOIN 
    SportFinances f ON w.year = f.year AND w.unitid = f.unitid
JOIN 
    Schools s ON w.unitid = s.unitid
JOIN dim_date dd
	ON dd.yearID = f.year;


select * from fact_winloss;
################################################################################
# Fact_expenses
# FKS : yearID, unitid, ExpenseTypeID
# Amount

CREATE TABLE Fact_expenses (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,
    yearID INT,
    unitid INT,
    ExpenseTypeID INT,
    Amount DECIMAL(10,2),
    FOREIGN KEY (yearID) REFERENCES dim_date(yearID),
    FOREIGN KEY (unitid) REFERENCES dim_school(unitid),
    FOREIGN KEY (ExpenseTypeID) REFERENCES dim_expense_type(expensetypeID)
);

INSERT INTO Fact_expenses (yearID, unitid, ExpenseTypeID, Amount)
SELECT 
    d.yearID,
    ed.unitid,
    et.expensetypeID,
    ed.amount
FROM 
    Schools s
JOIN 
    ExpenseDetail ed ON ed.unitid = s.unitid
JOIN 
    dim_expense_type et ON ed.expense_type = et.ExpenseType
JOIN 
    dim_date d ON ed.year = d.yearID;

select count(*) from Fact_expenses;
######################################################################################
# fact headcounts 
# FKS : yearid, unitid, expensetypeID, sportcode
# PARTIC_MEN, PARTIC_WOMEN, SUM_PARTIC_MEN, SUM_PARTIC_WOMEN, MEN_TOTAL_HEADCOACH, WOMEN_TOTAL_HDCOACH  
# COED_TOTAL_HDCOACH, SUM_TOTAL_HDCOACH, MEN_TOTAL_ASSTCOACH, WOMEN_TOTAL_ASTCOACH, COED_TOTAL_ASTCOACH, SUM_TOTAL_ASSTCOACH 

CREATE TABLE fact_headcount (
    yearID INT,
    unitid INT,
    expensetypeID INT,
    sportcode INT,
    PARTIC_MEN INT,
    PARTIC_WOMEN INT,
    SUM_PARTIC_MEN INT,
    SUM_PARTIC_WOMEN INT,
    MEN_TOTAL_HEADCOACH INT,
    WOMEN_TOTAL_HDCOACH INT,
    COED_TOTAL_HDCOACH INT,
    SUM_TOTAL_HDCOACH INT,
    MEN_TOTAL_ASSTCOACH INT,
    WOMEN_TOTAL_ASTCOACH INT,
    COED_TOTAL_ASTCOACH INT,
    SUM_TOTAL_ASSTCOACH INT,
    FOREIGN KEY (yearID) REFERENCES dim_date(yearID),
    FOREIGN KEY (unitid) REFERENCES dim_school(unitid),
    FOREIGN KEY (expensetypeID) REFERENCES dim_expense_type(expensetypeID),
    FOREIGN KEY (sportcode) REFERENCES dim_sport(sportcode)
);

INSERT INTO fact_headcount (
    yearID, unitid, expensetypeID, sportcode,
    PARTIC_MEN, PARTIC_WOMEN, SUM_PARTIC_MEN, SUM_PARTIC_WOMEN,
    MEN_TOTAL_HEADCOACH, WOMEN_TOTAL_HDCOACH, COED_TOTAL_HDCOACH, SUM_TOTAL_HDCOACH,
    MEN_TOTAL_ASSTCOACH, WOMEN_TOTAL_ASTCOACH, COED_TOTAL_ASTCOACH, SUM_TOTAL_ASSTCOACH
)
SELECT 
    d.yearID,
    h.unitid,
    et.expensetypeID,
    h.SPORTSCODE,
    h.PARTIC_MEN,
    h.PARTIC_WOMEN,
    h.SUM_PARTIC_MEN,
    h.SUM_PARTIC_WOMEN,
    h.MEN_TOTAL_HEADCOACH,
    h.WOMEN_TOTAL_HDCOACH,
    h.COED_TOTAL_HDCOACH,
    h.SUM_TOTAL_HDCOACH,
    h.MEN_TOTAL_ASSTCOACH,
    h.WOMEN_TOTAL_ASTCOACH,
    h.COED_TOTAL_ASTCOACH,
    h.SUM_TOTAL_ASSTCOACH
FROM 
    Headcounts h
JOIN 
    dim_date d ON h.year = d.yearID 
JOIN
	ExpenseDetail ed on ed.unitid = h.unitid
JOIN 
    dim_expense_type et ON ed.expense_type = et.ExpenseType;
    
SELECT count(*) from fact_headcount;

#########################################################
# fact SportsFinance
# FKS : Sportscode, unitid, ledger_id
# Amount

CREATE TABLE fact_sports_finance (
    sportcode INT,
    unitid INT,
    ledger_id INT,
    Amount DECIMAL(10, 2),
    FOREIGN KEY (sportcode) REFERENCES dim_sport(sportcode),
    FOREIGN KEY (unitid) REFERENCES dim_school(unitid),
    FOREIGN KEY (ledger_id) REFERENCES dim_financial_type(ledger_id)
);

INSERT INTO fact_sports_finance (yearID, unitid, sportcode, classificationcode, Wins, Losses, Amount, ExpenseType)
SELECT 
    s.unitid AS unitid,
    s.SPORTSCODE AS sportcode,
    dft.ledger_id,
    s.amount AS Amount
FROM 
    SportFinances s
JOIN 
    dim_financial_type dft ON s.ledger = dft.ledger_type;

select count(*) from fact_sports_finance;

select * from Headcounts
where year = 2016
limit 5;

select * from fact_headcountss
limit 5;

RENAME TABLE fact_headcountss TO fact_headcounts;

drop table new_table_name;


ALTER TABLE Headcounts
MODIFY year DATE,
MODIFY unitid INT;

ALTER TABLE fact_headcounts
MODIFY COLUMN `year` YEAR;

ALTER TABLE fact_headcounts
ADD CONSTRAINT `year`
    FOREIGN KEY (`year`) 
    REFERENCES dim_date(yearID);

ALTER TABLE fact_headcounts
ADD CONSTRAINT unitid
    FOREIGN KEY (unitid) 
    REFERENCES dim_school(unitid);

ALTER TABLE fact_headcounts
ADD CONSTRAINT SPORTSCODE
    FOREIGN KEY (SPORTSCODE) 
    REFERENCES dim_sport(sportcode);
