select * from fact_win_loss;

select * from dim_sport;

ALTER TABLE fact_win_loss MODIFY COLUMN SPORTSCODE BIGINT(20);

ALTER TABLE dim_sport MODIFY COLUMN sportcode BIGINT(20);

select * from dim_classification;

ALTER TABLE SportFinances ADD PRIMARY KEY (`index`);

select * from SportFinances;

ALTER TABLE Headcounts ADD PRIMARY KEY (`index`);

select * from Headcounts
where `index` = 0;

ALTER TABLE Schools ADD PRIMARY KEY (unitid);


select * from fact_win_loss
where WinLossID = 1344;

ALTER TABLE fact_win_loss 
ADD CONSTRAINT fk_school 
FOREIGN KEY (unitid) 
REFERENCES dim_school(unitid);

ALTER TABLE fact_win_loss 
ADD CONSTRAINT fk_sport 
FOREIGN KEY (SPORTSCODE) 
REFERENCES dim_sport(sportcode);

ALTER TABLE fact_win_loss 
ADD CONSTRAINT fk_classification 
FOREIGN KEY (classificationcode) 
REFERENCES dim_classification(classificationcode);

ALTER TABLE Headcounts 
ADD CONSTRAINT fk_headcounts 
FOREIGN KEY (unitid) 
REFERENCES dim_school(unitid);


ALTER TABLE Headcounts 
ADD PRIMARY KEY (sportstype(100), SPORTSCODE, unitid, year);

ALTER TABLE Headcounts
ADD COLUMN `index` BIGINT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE Headcounts
DROP PRIMARY KEY;




