# 610-Group-Project

The Old Star Pub & Brewery compiled data describing the amount of different raw materials and labor 
needed to brew the six types of beer that the brewery makes, and estimated demand for each over a 
six-month forecast horizon. The demand forecasts include beer sold for $3 per pint at the Pub, as well 
as kegs sold to volume customers (markets and ale houses) in the greater Houston area. For a volume 
customer, the selling price of a keg of beer is less than the revenue the same amount of beer would 
generate at the Pub ($3 per pint * 145 pints per keg = $435 per keg). 


Initially, they solved a linear programming model which revealed that additional brewing labor could 
increase their net profit. Subsequently, students at the Mays Business School developed a vehicle 
routing model that found they could reduce delivery cost by renting a 16-foot refrigerated truck for two 
days a month instead of outsourcing deliveries to volume customers. At the beginning of the month, 
deliveries are made to customers “inside the loop” (routes 1 and 2) and in the middle of the month to 
customers in Katy and North Houston (routes 3 and 4). The table below also includes the total transit 
time (in H:MM format) for the routes; the customer codes used can be found in the SAS data set routes.
In addition to the transit time, volume deliveries are estimated to take 2-3 minutes per keg (loading and 
unloading each full keg and loading and unloading an empty keg) and an additional 5 minutes per stop 
on each route. These trucks can carry 29 kegs by weight and 55 by volume (so there should always be 
room on the truck for empty kegs) and can be rented for 8 hours at a cost of $250 plus $50 for diesel 
fuel. The employees driving, loading, and unloading the rental truck make $15 per hour, and the rental 
location is 30 minutes away from the Old Star Pub and Brewery.

Brewing a batch of beer takes less than a day, but each batch must spend two weeks in a fermenting 
tank before it is transferred to kegs; hence the brewery’s five fermenting tanks limit production to ten 
batches of beer per month (each batch of beer produced yields 30 kegs of beer). The brewery staggers 
the batches so that (up to) five batches are ready for kegging at the beginning of the month and (up to) 
five batches are ready for kegging in the middle of the month. The brewery has cold storage that can 
hold 240 kegs; at the beginning of each month, they fill enough kegs from the fermenting tanks to make 
deliveries to volume customers “inside the loop” and then finish kegging during the day those deliveries 
are made – hence the cold storage space must hold the initial inventory plus kegs from the fermenting 
tanks less “inside the loop” volume customer deliveries. During the first fortnight of the month, this 
inventory can be used to satisfy demand at their attached pub. Likewise, in the middle of the month, 
they fill enough kegs to make deliveries to volume customers in Katy and North Houston and then finish 
kegging during the day those deliveries are made. The cold storage space must hold the remaining 
inventory plus kegs from the fermenting tanks less Katy and North Houston volume customer deliveries. 

During the final fortnight of the month, this inventory can be used to satisfy demand at the pub. 
Now the brewery wants to incorporate up to 210 overtime brewing hours at $27 per hour as part of a 
more granular production, inventory, and distribution model to schedule the brewing and delivery of 
kegs of beer to their volume customers in the greater Houston area over the next six months. In 
addition to brewing overtime and delivery costs detailed above, there are fixed overhead costs ($7,500 
per batch), and the costs of raw materials and brewing labor in the SAS data set beer_ingredients, which 
also includes the availability of raw materials and brewing labor over the six-month horizon. Resource 
requirements (per batch) for each type of beer are in the SAS data set beer_products. This SAS data set 
also includes their initial demand estimates (in batches) over the six-month horizon, which can ignored 
because they have developed more granular estimates. Each volume customer’s demand for kegs of 
each type of beer in each of the next six months is in the SAS data set demand (which also includes 
estimated demand at the pub, accounting for roughly two thirds of the total demand). For volume 
customers, the selling prices can be found for each type of beer in the SAS data set pricing, which also 
includes “break even” prices that can be used to estimate the value of any inventory (and kegs from 
batches fermenting) at the end of the sixth month. The initial inventory levels at the brewery, which 
include kegs from the batches brewed in the middle of the previous month, are in the SAS data set 
inventory (from which one could surmise that every type was brewed except Berry Wheat).


The production, inventory, and distribution model that you will develop for this project should find the 
optimal number of overtime brewing hours and create SAS data sets that prescribe the number of 
batches of each type of beer to brew in each fortnight of each of the next six months, the number of 
kegs of each type of beer to be delivered to each volume customer in each of the next six months, and 
the number of kegs of each type of beer delivered to the pub in each fortnight of each of the next six 
months. Your model should also account for the following additional restrictions:
• the number of batches brewed and the number of kegs delivered (each month to volume 
customers and each fortnight to the pub) must be integers;
• the number of kegs of each type of beer delivered to each customer cannot exceed the forecast 
demand for that month, and at least 95% of the total volume customer demand must be met 
each month, even though some volume customers might not receive any kegs of beer;
• the number of kegs of each type of beer delivered to the pub in each fortnight cannot exceed 
half the monthly demand (rounded up to the nearest integer);
• at least three batches of each type of beer must be brewed over the six-month horizon;
• the final inventory levels (plus the kegs from batches fermenting) at the end of the sixth month 
should be at least half the pub demand in the sixth month plus 95% of the “inside the loop” 
volume customer demand in the sixth month.


In addition to finding the production, inventory, and distribution solution that maximizes net profit, your 
group should also address the following additional questions:
• How sensitive is the result to the (number and variety of) of batches brewed at the beginning of 
the first month? What does this tell you about the optimization model?
• Old Star Pub & Brewery’s estimate of the loading and unloading time (2-3 minutes) is not very 
precise. How sensitive is the result to values in this range? Could your model be modified to 
use different loading and unloading times for each volume customer?
Your group’s primary mission is to produce a PROC OPTMODEL program that builds and solves a 
mathematical optimization model for the production, inventory, and distribution problem faced by 
the brewery, and produces SAS data sets and summary statistics for the optimal solution.
Your group’s project grade (out of 200 possible points) will be based on the following:
• the degree to which all of the stated restrictions are satisfied by your solution; (75 points)
• the realized net profit of your solution, penalized by any meaningful violation of the stated
restrictions; (50 points)
• the degree to which your deliverables (SAS data sets and summary statistics) meet the 
brewery’s requirements without including extraneous information; (25 points)
• an executive summary, whose required elements are outlined below. (50 points)
Your group’s executive summary should include:
• a condensed description of the model, including what is counted in the objective, and general 
types of constraints/restrictions that a (feasible) solution should satisfy; 
• any simplifying assumptions you have made in formulating your optimization model;
• a brief plain-language description of the methodology/software used to find the best solution;
• an estimate of how close your solution is to the best, or optimal solution to the problem;
• a breakdown of the net profit of the optimal solution into cost and revenue categories;
• a discussion of which constraints/restrictions limit the net profit of the solution to the model;
• answers to address the additional sensitivity questions about batches brewed at the beginning 
of the first month and the value used for the loading/unloading times;
• tables of summary statistics and/or graphs that provide insight for the decision maker.


At any point, your group can email me three SAS data sets: production (with column names Product, 
Month, Fortnight, and Batches), pub_deliveries (with column names Product, Month, Fortnight, and 
Kegs), and volume_deliveries (with column names Customer, Product, Month, and Kegs). I will reply 
and let you know if your solution is feasible (or send you a list of restrictions that are violated) and break 
down the revenue and cost of your solution by various categories.


I strongly recommend that you all start by producing a PROC OPTMODEL program that declares sets 
and parameters, reads data from SAS data sets, and prints the values of the parameter arrays so that 
your group can begin to work on formulating an optimization model.
