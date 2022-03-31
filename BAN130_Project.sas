libname mylib '/home/u59469373/Programming for Analytics/Project'; 


/* Data Import  */

proc import datafile="/home/u59469373/Programming for Analytics/Project/AdventureWorks.xlsx" 
out=mylib.Product 
dbms=xlsx replace;
SHEET="Product";
run;

proc import datafile="/home/u59469373/Programming for Analytics/Project/AdventureWorks.xlsx" 
out=mylib.SalesOrderDetail 
dbms=xlsx replace;
SHEET="SalesOrderDetail";
run;

title "SalesOrderDetail dataset";
proc print data=mylib.SalesOrderDetail  (obs=5);
run;

title "Product dataset";
proc print data=mylib.Product  (obs=5);
run;

proc print data=mylib.Product  (obs=5);
run;

proc contents data=mylib.Salesorderdetail;
run;
proc contents data=mylib.Product;
run;


/*	Data Cleaning  */

data mylib.Product_Clean;
set mylib.Product(keep= ProductID Name ProductNumber Color ListPrice);
if missing(Color) then Color = 'NA';
ListPrice_num = input(ListPrice,8.);
drop ListPrice;
rename ListPrice_num=ListPrice;
run;

data mylib.Product_Clean;
set mylib.Product_Clean;
informat ListPrice 8.2;
format ListPrice dollar10.2;
label ListPrice="ListPrice";
run;


proc contents data=mylib.Product_Clean;
run;

proc print data=mylib.Product_Clean  (obs=5);
run;



data mylib.SalesOrderDetail_Clean;
set mylib.SalesOrderDetail(keep= SalesOrderID SalesOrderDetailID OrderQty ProductID UnitPrice LineTotal ModifiedDate);
ModifiedDate_num = input(ModifiedDate,anydtdte21.);
UnitPrice_num = input(UnitPrice,8.);
LineTotal_num = input(LineTotal,8.);
OrderQty_num = input(OrderQty,8.);
drop ModifiedDate UnitPrice LineTotal OrderQty;
rename ModifiedDate_num=ModifiedDate
UnitPrice_num=UnitPrice
LineTotal_num=LineTotal
OrderQty_num=OrderQty;
run;


data mylib.SalesOrderDetail_Clean label;
set mylib.SalesOrderDetail_Clean;
informat ModifiedDate anydtdte21. UnitPrice 8. LineTotal 8. OrderQty 8.;
format ModifiedDate mmddyy10. UnitPrice dollar10.2 LineTotal dollar10.2 OrderQty 8.;
label ModifiedDate="ModifiedDate" 
UnitPrice="UnitPrice"
LineTotal="LineTotal"
OrderQty="OrderQty";
where year(ModifiedDate) in (2013,2014);
run;

proc contents data=mylib.SalesOrderDetail_Clean;
run;

proc print data=mylib.SalesOrderDetail_Clean  (obs=5);
where year(ModifiedDate) =2014;
run;


/* 3.	Joining and Merging */
proc sort data=mylib.salesorderdetail_clean;
by ProductID;
run;

proc sort data=mylib.Product_Clean;
by ProductID;
run;

data mylib.SalesDetails;
merge mylib.SalesOrderDetail_Clean(in=SalesOrderDetail_Clean)
	  mylib.Product_Clean(in=Product_Clean);
by ProductID;
if SalesOrderDetail_Clean=1 and Product_Clean=1;
drop SalesOrderID SalesOrderDetailID ProductNumber ListPrice; 
run;

title "SalesDetails Dataset";
proc print data=mylib.SalesDetails  (obs=5);
run;

/*
proc sort data=mylib.SalesDetails;
by ProductID;
run;
*/

proc sql;
create table mylib.SalesAnalysis as
select ProductID, ModifiedDate, 
max(UnitPrice) as UnitPrice format dollar12.2, 
sum(LineTotal) as LineTotal format dollar12.2, 
sum(OrderQty) as OrderQty format 8., 
Name, 
Color, 
sum(LineTotal) as SubTotal format dollar12.2
from mylib.SalesDetails group by ProductID,ModifiedDate,Name,Color;
quit;


title "SalesAnalysis Dataset";
proc print data=mylib.SalesAnalysis  (obs=5);
run;


/*
data mylib.SalesAnalysis;
set mylib.SalesDetails;
informat SubTotal 8.;
by ProductID;
if first.ProductID then SubTotal=0;
SubTotal+LineTotal;
if last.ProductID;
format SubTotal dollar14.2;
run;


proc contents data=mylib.SalesAnalysis;
run;

proc print data=mylib.SalesAnalysis (obs=5);
run;
*/
/* Data Analysis */

/* Question 1 */
title "Question 1: How many Red color Helmets are sold in 2013 and 2014?"; 
proc tabulate data=mylib.SalesAnalysis format=8.; 
class ModifiedDate Color; 
format ModifiedDate YEAR4.;
var OrderQty;
tables (ModifiedDate*Color), 
(OrderQty); 
where color='Red' and index(Name,"Helmet");
keylabel n=' '
Sum='Number of Red Helmets sold';
run; 

/*
proc print data=mylib.SalesAnalysis;
where color='Red' and year(ModifiedDate) in (2013,2014);
run;
*/

/* Question 2 */
title "Question 2: How many items sold in 2013 and 2014 have a Multi color?"; 
proc tabulate data=mylib.SalesAnalysis format=8.; 
class ModifiedDate Color; 
format ModifiedDate YEAR4.;
var OrderQty;
tables (ModifiedDate*Color), 
(OrderQty); 
where Color='Multi';
keylabel n=' '
Sum='Number of Multi color items sold';
run; 


/* Question 3 */
title "Question 3: What is the combined Sales total for all the helmets sold in 2013 and 2014"; 
proc tabulate data=mylib.SalesAnalysis format=dollar14.2;
class ModifiedDate; 
var SubTotal;
tables (ModifiedDate ALL), 
(SubTotal); 
where index(Name,"Helmet");
keylabel n=' '
ALL='Total'
Sum='Sum of sales for all Helmets';
format ModifiedDate YEAR4.;
run; 

/* Question 4 */
title "Question 4: How many Yellow Color Touring-1000 where sold in 2013 and 2014?"; 
proc tabulate data=mylib.SalesAnalysis format=8. ;
class ModifiedDate; 
var OrderQty;
tables (ModifiedDate ALL), 
(OrderQty); 
where index(Name,"Touring-1000") and Color='Yellow';
keylabel n=' '
ALL='Total'
Sum='Number of Touring-1000 yellow sold';
format ModifiedDate YEAR4.;
run; 

/* Question 5 */
title "Question 5: What was the total sales in 2013 and 2014?"; 
proc tabulate data=mylib.SalesAnalysis format=dollar14.2 ;
class ModifiedDate; 
var SubTotal;
tables (ModifiedDate ALL), 
(SubTotal); 
keylabel n=' '
ALL='Total'
Sum='Sum of Total sales';
format ModifiedDate YEAR4.;
run; 


/* Distribution of OrderQty with respect to color */
title "Distribution of Order Quantity with respect to color"; 
proc tabulate data=mylib.SalesAnalysis format=8.;
class Color; 
var OrderQty;
tables (Color), 
(OrderQty); 
keylabel n=' '
ALL='Total'
Sum='Distribution of Order Quantity with respect to color';
run; 








