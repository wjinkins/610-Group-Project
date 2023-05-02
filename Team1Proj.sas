%let beer_price = 3;
%let pints_per_batch = 4350;
%let fixed_cost = 7500;
%let price_per_keg = 435;
%let employee_cost = 15;
%let overtime_labor = 27;

proc optmodel;
   /* declare sets and parameters */
   set <str> PRODUCTS, RESOURCES, CUSTOMERS;
   set <num> MONTHS = 1..6;
   set <str> DISTANTCUST = CUSTOMERS diff /OSPB/;
   set <num> FORTNIGHT = 1..2; 
   
   num cost {RESOURCES}, availability {RESOURCES};
   num selling_price {PRODUCTS};
   num break_even_price {PRODUCTS};
   num required {PRODUCTS, RESOURCES} init 0; 
   num kegs {CUSTOMERS, PRODUCTS, MONTHS};
   num route {CUSTOMERS};
   num init_inventory {PRODUCTS};
   
   
   /* read data from SAS data sets */
   read data proj.beer_ingredients into RESOURCES=[Raw_Material] 
     cost=Unit_Cost availability;

   read data proj.beer_products nomiss into PRODUCTS=[Libation]  
     {r in RESOURCES} <required[Libation,r]=col(r)>;
  
   read data proj.routes into CUSTOMERS = [Code] Route;
  
   read data proj.demand into [Customer Product Month] kegs;
  
   read data proj.pricing into [Product] selling_price break_even_price;
   
   read data proj.inventory into [Product] init_inventory = initial_inventory;
   
   /* print parameter arrays */
   print cost availability;
   print required;
   print kegs;
   print route;
   print selling_price;
   print break_even_price;
   print init_inventory;
   
   
   /* declare variables */
   var NumInv {PRODUCTS, MONTHS} >= 0;
   var NumProd {PRODUCTS} >= 0;
     
  /* declare decision variables*/
   var production {PRODUCTS, MONTHS, FORTNIGHT} >=0 integer;
  
   var pub_deliveries {PRODUCTS, MONTHS, FORTNIGHT} >=0 integer;
   
   var volume_deliveries {PRODUCTS, MONTHS, DISTANTCUST} >=0 integer; 
   
   var overtime >=0; 
  
   impvar BegInv {p in PRODUCTS, m in MONTHS} = if m = 1 then 
    init_inventory [p] - 
      SUM{d in DISTANTCUST: route[d] in 1..2} volume_deliveries [p,1,d] 
   else
      production [p,m-1,2] * 30 + NumINV[p,m-1] - 
      SUM{d in DISTANTCUST: route[d] in 1..2} volume_deliveries [p,m,d];
  
    impvar midInv {p in PRODUCTS, m in MONTHS} = if m = 1 then 
    init_inventory [p] - 
      SUM{d in DISTANTCUST: route[d] in 1..2} volume_deliveries [p,1,d] - pub_deliveries [p,1,1]
   else
      production [p,m-1,2] * 30 + NumINV[p,m-1] - 
      SUM{d in DISTANTCUST: route[d] in 1..2} volume_deliveries [p,m,d] - pub_deliveries [p,m,1];
  
    impvar PostInv {p in PRODUCTS, m in MONTHS} = if m = 1 then 
    init_inventory [p] + (production [p,1,1] * 30) - 
      SUM{d in DISTANTCUST} volume_deliveries [p,1,d] - pub_deliveries [p,1,1]
   else
      production [p,m-1,2] * 30 + NumINV[p,m-1] + (production [p,m,1] * 30)- 
      SUM{d in DISTANTCUST} volume_deliveries [p,m,d] - pub_deliveries [p,m,1];
    
     /*Calculate Costs*/
     /*Amount of Resources Used Cost*/
     impvar AmountUsed {r in RESOURCES} = 
     sum {p in PRODUCTS} production * required[p,r];
     
     /*Batch Costs*/
     impvar BatchCost = 
     &fixed_cost * sum {p in PRODUCTS} production;
     
     /*Driving Cost*/
    /*Rental Truck Cost ($250 * 8) + diesel costs $50 and then add to 
     
     /*Total Cost*/
     impvar TotalCost = BatchCost +
     sum {r in RESOURCES} cost[r] * AmountUsed[r] + (overtime * &overtime_labor);
     
     impvar Revenue = SUM {p in PRODUCTS, m in MONTHS, f in FORTNIGHT} pub_deliveries[p,m,f] * &price_per_keg 
      + SUM{p in PRODUCTS, m in MONTHS, d in DISTANTCUST} volume_deliveries[p,m,d] * selling_price[p];
  
   /* declare contraints */     
   con Beginning_balance {p in PRODUCTS}:
      init_inventory [p] + (production [p,1,1]) * 30 = 
      NumINV[p,1] + SUM{d in DISTANTCUST} volume_deliveries [p,1,d] + pub_deliveries [p,1,1] + pub_deliveries [p,1,2];
      
   con Inventory_balance {p in PRODUCTS, m in MONTHS diff /1/}:
      (production [p,m-1,2] + production [p,m,1]) * 30 + NumINV[p,m-1] = 
      NumINV[p,m] + SUM{d in DISTANTCUST} volume_deliveries [p,m,d] + pub_deliveries [p,m,1] + pub_deliveries [p,m,2];
   
   con prod_con {m in MONTHS, f in FORTNIGHT}: SUM {p in PRODUCTS} production [p,m,f] <= 5;
   
   /*For Overtime*/
   con Usage {r in RESOURCES}: 
     AmountUsed[r] <= availability[r]
        + if (r='Brewing_Labor') then overtime else 0;
        
      /* declare objective */
    /* max TotalProfit = Revenue - TotalCost; */
   
   solve;
      
   /*create data proj.production from [Products] {m in Months} {f in Fortnight} [Production? to Batches];*/
   /*create data pub_deliveries from [Products] {m in Months} {f in Fortnight} kegs;*/
   /*create data volume_deliveries from [Customers Products] {m in Months} kegs; */
   
   
   print NumINV;
   
   
   quit;
