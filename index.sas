libname Project "G:\Desktop";

data Project.Retirementfunds;
set retirement;
run;

* RENAMING THE DATA;

data retirement2;
set Project.Retirementfunds;
run;

* PRINTING ORIGINAL DATA;

proc print data = retirement2;
run;

* REPLACING THE VARIABLES WITH NUMBERS

  TYPE
	CHANGING VALUE = 0 
	GROWTH = 1
  MARKET CAP
	LARGE = 0
	MID-CAP = 1
	SMALL = 2
  RISK
	LOW = 0
	AVERAGE = 0
	HIGH = 1
  STAR RATING
	ONE = 0
	TWO = 1
	THREE = 2
	FOUR = 3
	FIVE = 4;

data retirement3;
set retirement2;
if Type = "Value" then Type = "0";
if Type = "Growth" then Type = "1";
if Market_Cap = "Large" then Market_Cap = "1";
if Market_Cap = "Mid-Cap" then Market_Cap = "2";
if Market_Cap = "Small" then Market_Cap = "3";
if Risk = "Low" then Risk = "0";
if Risk = "Average" then Risk = "0";
if Risk = "High" then Risk = "1";
if Star_Rating = "One" then Star_Rating = "1";
if Star_Rating = "Two" then Star_Rating = "2";
if Star_Rating = "Three" then Star_Rating = "3";
if Star_Rating = "Four" then Star_Rating = "4";
if Star_Rating = "Five" then Star_Rating = "5";
run;

* REPLACING THE VARIABLES WITH NUMERICAL VALUES;

data retirement4;
set retirement3;
Type1 = Type*1;
Market_Cap1 = Market_Cap*1;
Risk1 = Risk*1;
Star_Rating1 = Star_Rating*1;
run;

proc print data = retirement4;
run;


* REGRESSION FOR TYPE;

proc reg data = retirement4;
model v5YrReturn_ = Type1;
run; quit;

* REGRESSION FOR RISK;

proc reg data = retirement4;
model v5YrReturn_ = Risk1;
run; quit;

* CREATING DUMMY VARIABLES FOR MARKET CAP;

data retirement5;
set retirement4;
Large = .;
if Market_Cap = 1 then Large = 1;
else Large = 0;
MidCap = .;
if Market_Cap = 2 then MidCap = 1;
else MidCap = 0;
Small = .;
if Market_Cap = 3 then Small = 1;
else Small = 0;
run;

proc freq data = retirement5;
tables Large MidCap Small; run;

* REGRESSION MODEL FOR SIZE;

proc reg data = retirement5;
model v5YrReturn_ = Large MidCap Small;
run; quit;

data retirement6;
set retirement5;
One = .;
if Star_Rating = 1 then One = 1;
else One = 0;
Two = .;
if Star_Rating = 2 then Two =1;
else Two =0;
Three = .;
if Star_Rating = 3 then Three = 1;
else Three = 0;
Four = .;
if Star_Rating = 4 then Four = 1;
else Four =0;
Five = .;
if Star_Rating = 5 then Five = 1;
else Five = 0;
logOne = .;
run;

data retirement8;
set retirement7;
logOne = .;
if Star_Rating = 1 then logOne = 1;
else One = 0;
logTwo = .;
if Star_Rating = 2 then logTwo =1;
else Two =0;
logThree = .;
if Star_Rating = 3 then logThree = 1;
else Three = 0;
logFour = .;
if Star_Rating = 4 then logFour = 1;
else Four =0;
logFive = .;
if Star_Rating = 5 then logFive = 1;
else Five = 0;
v5YrReturnn = v5YrReturn_*1;
run;

* REGRESSION MODEL FOR STAR RATING;

proc reg data = retirement6;
model v5YrReturn_ = One Two Three Four Five;
run; quit;

* REGRESSION MODEL: BASIC VARIABLES;

proc reg data = retirement6;
model v5YrReturn_ = Assets Turnover_Ratio Beta SD Expense_Ratio;
run;

* REGRESSION MODEL: BASIC VARIABLES + TYPE + RISK;

proc reg data = retirement6;
model v5YrReturn_ = Assets Turnover_Ratio Beta SD Expense_Ratio Type1 Risk1;
run;

* REGRESSION MODEL: BASIC VARIABLES + TYPE + RISK + SIZE + RATING;

proc reg data = retirement6;
model v5YrReturn_ = Assets Turnover_Ratio Beta SD Expense_Ratio Type1 Risk1 Large MidCap Small One Two Three Four Five;
run; quit;

* REGRESSION MODEL: BASIC VARIABLES + TYPE + RISK + SIZE + RATING (EXLCUDING SMALL CAP AND ONE RATING)
  WE TAKE OUT SMALL CAP AND THE ONE RATING BECAUSE THEY WILL BE SERVING AS OUR "BASE CASE" IN ORDER TO RUN THE DUMMY VARIABLES;

proc reg data = retirement6;
model v5YrReturn_ = Assets Turnover_Ratio Beta SD Expense_Ratio Type1 Risk1 Large MidCap Two Three Four Five;
run; quit;

* MODEL SELECTION: CP METHOD
;

proc reg data = retirement6;
model v5YrReturn_ = Assets Turnover_Ratio Beta SD Expense_Ratio Type1 Risk1 Large MidCap Two Three Four Five/selection = cp;
run; quit;

* MODEL SELECTION: STEPWISE METHOD
;

proc reg data = retirement6;
model v5YrReturn_ = Assets Turnover_Ratio Beta SD Expense_Ratio Type1 Risk1 Large MidCap Two Three Four Five/selection = stepwise sle = 0.15 sls = 0.10;
run; quit;

* LOOKING AT THE RESULTS OF THE STEPWISE MODEL, WE SEE THAT THE HIGHEST R-SQUARE MODEL (R-SQUARE = 0.3696) CONTAINS EIGHT EXPLANATORY VARIABLES.  THOSE BEING:
	- TWO
	- THREE
	- FOUR
	- FIVE
	- LARGE
	- TYPE
	- BETA
	- TURNOVER RATIO

HOWEVER, ACCORDING TO THE MODEL TURNOVER RATION IS STATISTICALLY INSIGNIFICANT.  SO WE WILL EXCLUDE THAT FROM OUR MODEL.
WE THEN GET THE FOLLOWING AS OUR NEW MODEL:;



proc reg data = retirement6;
model v5YrReturn_ = Two Three Four Five Large Type1 Beta;
run; quit; 

*NOW, WE NEED TO CHECK THIS MODEL FOR LINEARITY;

proc reg data = retirement6;
model v5YrReturn_ = Beta/lackfit;
run; quit;

* WE FIND THAT THE MODEL DOES PAST THE LINEARITY TEST AS THE P-VALUE FOR LACK FO FIT IS 0.2642, WHICH IS GREATER THAN 0.05;

* NOW LET US CHECK FOR MULTICOLLINEARITY;

proc reg data = retirement6;
model v5YrReturn_ = Two Three Four Five Large Type1 Beta/vif;
run; quit;

* WE FIND THAT THE VARIABLE "FIVE" IS A TROUBLEMAKER AS IT HAS A VIF GREATER THAN 10, SO WE DROP THE VARIABLE;

* HERE IS THE NEW MODEL AFTER DROPPING "FIVE";

proc reg data = retirement6;
model v5YrReturn_ = Two Three Four Large Type1 Beta;
run; quit;

* NOW WE FIND THAT THE VARIABLE "THREE" IS STATISTICALLY INSIGNIFICANT, SO WE TAKE THAT OUT AS WELL
  THIS MAKES OUR NEW MODEL TO BE: ;

proc reg data = retirement6;
model v5YrReturn_ = Two Four Large Type1 Beta;
run; quit;

* LET'S CHECK THIS NEW MODEL FOR LINEARITY;

proc reg data = retirement6;
model v5YrReturn_ = Two Four Large Type1 Beta/lackfit;
run; quit;

* THIS STILL DOES NOT GIVE US LINEARITY;
* WE CAN NOW MOVE ON AND TEST FOR THE OTHER CLASSICAL ASSUMPTIONS;

* CLASSICAL ASSUMPTION II - RESIDUALS HAVE A MEAN OF ZERIO;

proc reg data = retirement6;
model v5YrReturn_ = Two Four Large Type1 Beta;
output out = residuals1
r = yresid zresid;run;
run;

proc univariate data = residuals1;
var yresid;
histogram yresid/normal;
run;

* THE MEAN OF THE RESIDUALS IS INDEED ZERO, SO WE CAN SAY THAT CA2 IS NOT VIOLATED;

* NOW LET US CHECK IF ANY OF THE EXPLANATORY VARIABLES ARE CORRELATED WITH THE ERROR TERM;

* CLASSICAL ASSUMPTION III - ALL EXPLANATORY VARIABLES ARE UNCORRELATED WITH THE ERROR TERM;

proc corr data = residuals1;
var Two Four Large Type1 Beta yresid;
run;

* LOOKS GOOD TO ME!

* CLASSICAL ASSUMPTION IV - NO SERIAL CORRELATION
		- FOR THIS WE USE THE DURBIN-WATSON TEST
		- WE ALSO MODLE OUT THE RESIDUALS FOR AN INFORMAL TEST;

proc reg data = retirement6;
model v5YrReturn_ = Two Four Large Type1 Beta/dw;
run;

* FOR THE DUBRIN-WATSON, WE GET A D-VALUE OF 1.601, WHICH IS LESS THAN THE VALUE NECESSARY 
		- FROM THE CRITICAL VALUES TABLE, WE CAN ESTIMATE THE CRITICAL VALUE TO BE BETWEEN 1.67 & 1.87;

proc reg data = retirement6;
model v5YrReturn_ = Two Four Large Type1 Beta;
output out = residuals
r= residuals;
run;

* CLASSICAL ASSUMPTION V - THE ERROR TERM HAS A CONSTANT VARIANCE
	- TO TEST FOR THIS, WE TRY THE "SPEC" TEST;

proc reg data = retirement6;
model v5YrReturn_ = Two Four Large Type1 Beta/spec; run;

* AFTER RUNNING THE SPEC TEST, WE GET A P-VALUE OF 0.004, WHICH IS FAR LESS THAN 0.05.  
	- DUE TO THE LOW P-VALUE, OUR MODEL DOES NOT HAVE A CONSTANT VARIANCE, AND WE DO 
	  HAVE HETEROSKEDASTICITY IN OUR MODEL;

proc transreg data = retirement6 details
plots = (transformation (dependent) obp);
model boxcox(v5YrReturn_/ convenient lambda = -1 to 2 by 0.5) =
qpoint (Beta);
run;
quit;

* CLASSICAL ASSUMPTION VI - NO MULTICOLLINEARITY;

proc reg data = retirement6;
model v5YrReturn_ = Two Four Large Type1 Beta/vif; 
run; quit;

* ALL LOOKS GOOD HERE, ONLY ONE CA LEFT!;

* CLASSICAL ASSUMPTION VII - THE ERROR TERM IS NORMALLY DISTRIBUTED;

proc reg data = retirement6;
model v5YrReturn_ = Two Four Large Type1 Beta;
output out = residuals1
r = yresid zresid;run;
run;

proc univariate data = residuals1;
var yresid;
histogram yresid/normal;
run;

* THE RESULTS OF THIS TELL US THAT THE ERRORS ARE NOT NORMALLY DISTRIBUTED AS THE
  P-VALUES ARE ALL <0.10;

proc transreg data=retirement6;
	model BoxCox(v5YrReturn_) = identity(Beta);
run;

* IN AN ATTEMPT TO FIX THIS, WE WANTED TO TAKE THE SQUARE OF THE Y VARIABLE (5 YEAR RETURN);

data retirement9;
set retirement6;
newv5YrReturn_ = sqrt(v5YrReturn_);
run;
quit;


proc reg data = retirement9;
model newv5YrReturn_ = Two Four Large Type1;
run;
quit;

output out = residuals1
r = yresid zresid;run;
run;

proc univariate data = residuals1;
var yresid;
histogram yresid/normal;
run;

* BUT NOW LET US SEE IF THE MODEL IS STILL RELIABLE;

proc reg data = retirement9;
model newv5YrReturn_ = Two Four Large Type1 Beta;
run; quit;

* THE RESULTS SHOW THAT IN THE NEW MODEL, THE "BETA" VARIABLE IS NO LONGER STATISTICALLY SIGNIFIANT
  - LET'S LOOK AT THE MODEL WITHOUT BETA;

proc reg data = retirement9;
model newv5YrReturn_ = Two Four Large Type1/;
run; quit;

* IN THIS NEW MODEL, ALL THE VARIABLES ARE SIGNIFICANT BUT THE R-SQUARE DROPS DOWN SIGNIFICANTLY. 
  - WE, AS RESEARCHERS, FEEL THAT IT IS NOT WORTH IT TO AVOID 

* NOW LET US LOOK TO SEE IF THERE ARE ANY OUTLIERS;

proc reg data = retirement6;
model v5YrReturn_ = Two Four Large Type1/vif dwprob spec ;
output out = residuals
r= residuals stdr = e_SE;
run;

* YEP, THERE IS A LOT OF OUTLIERS. LET US GO AHEAD AND SORT THEM TO SEE WHAT COMES UP;

proc sort data = residuals;
by residuals;
run;
proc print data = residuals;
	where residuals < -1.9 or residuals >1.9; run;

* WE GET A LOT OF OUTLIERS.  IT WOULD BE EXTEMELY TEDIOUS TO GO THROUGH EACH ONE, SO WE WILL DELETE ALL OF THE OUTLIERS AND SEE WHAT ENDS UP HAPPENING
	- FROM A FINANCIAL PERSPECTIVE, I THINK IT IS OKAY TO DELETE THE OUTLIERS AS EXTREME YEARS (2008, ETC.) HAPPEN EVERY SO OFTEN BUT THE MARKET
	  REGRESSES TO A MEAN OVER LONG PERIODS OF TIME;

data retirementdeleted;
set retirement6;
id = _N_;
run;

data retirementdeleted2;
set retirementdeleted;
if id < 58 then delete;
if id > 265 then delete;
run;
proc print data = retirementdeleted2; run;

* NOW LET US RUN THE REGRESSION ON THE NEW DATA SET;

proc reg data = retirementdeleted2;
model v5YrReturn_ = Two Four Large Type1;
run;
quit;

* NICE! IT LOOKS LIKE OUR R-SQUARE WENT UP SIGNIFICANTLY. LET US TAKE THAT AND RUN WITH IT;

* NOW LET US GO AHEAD AND LOOK FOR INFLUENTIAL POINTS;

proc reg data = retirementdeleted2;
model v5YrReturn_ = Two Four Large Type1/influence;
output out = dffits = difts;
output out = h = leverage;
run; quit;

* ANY OBSERVATION WHERE P > 2*[(P+1)/N]^1/2
  - 2*[5/208]^1/2
	= 0.3101;

data retirementdeleted3;
set retirementdeleted2;
if DFFITS > 0.3101 then delete;
run;

proc print data = retirementdeleted3; run;

* ANY OBSVERVATION WHERE P > 2[P+1]/N
	- 2[5]/208
	= 0.0962;

data retirementdeleted4;
set retirementdeleted2;
if leverage > 0.0962 then delete;
run;

proc print data = retirementdeleted4; run;

