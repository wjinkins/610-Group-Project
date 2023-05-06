%let beer_price = 3;
%let pints_per_batch = 4350;
%let fixed_cost = 7500;
%let price_per_keg = 435;
%let employee_cost = 15;
%let overtime_labor = 27;
%let time_per_keg = 3;
%let time_per_stop = 5;

proc optmodel;
   /* declare sets and parameters */
   set <str> PRODUCTS, RESOURCES, CUSTOMERS;
   set <num> MONTHS = 1..6;
   set <str> DISTANTCUST = CUSTOMERS diff /OSPB/;
   set <num> FORTNIGHT = 1..2; 
   set <num> ROUTES = 1..4;
   
   
   num cost {RESOURCES}, availability {RESOURCES};
   num selling_price {PRODUCTS};
   num break_even_price {PRODUCTS};
   num required {PRODUCTS, RESOURCES} init 0; 
   num kegs {CUSTOMERS, PRODUCTS, MONTHS} init 0;
   num route {CUSTOMERS};
   num init_inventory {PRODUCTS};
   num stops {Routes} = [6 5 3 2];
   num transit_time {Routes} = [85 49 72 54];
   
   print stops;
   print transit_time;
   
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
     sum {p in PRODUCTS, m in MONTHS, f in FORTNIGHT} production[p,m,f] * required[p,r];
     
     /*Batch Costs*/
   impvar BatchCost = 
     &fixed_cost * sum {p in PRODUCTS, m in MONTHS, f in FORTNIGHT} production[p,m,f];
     
     /*Driving Cost*/
   impvar RentalCost = 300 * 6 * 2;
     
     /*Delivery Time*/
   impvar Delivery {m in MONTHS, f in FORTNIGHT} = 120 + if  f = 1 then
    (stops[1] + stops[2]) * &time_per_stop + transit_time[1] + transit_time[2] +
    (SUM{d in DISTANTCUST, p in PRODUCTS: route[d] in 1..2} volume_deliveries [p,m,d]) * &time_per_keg
    else
    (stops[3] + stops[4]) * &time_per_stop + transit_time[3] + transit_time[4] +
    (SUM{d in DISTANTCUST, p in PRODUCTS: route[d] in 3..4} volume_deliveries [p,m,d]) * &time_per_keg;   

   impvar ProdCost = BatchCost +
     sum {r in RESOURCES} cost[r] * AmountUsed[r] + overtime * (&overtime_labor - cost["Brewing_Labor"]);
     
   impvar Revenue = SUM {p in PRODUCTS, m in MONTHS, f in FORTNIGHT} pub_deliveries[p,m,f] * &price_per_keg 
      + SUM{p in PRODUCTS, m in MONTHS, d in DISTANTCUST} volume_deliveries[p,m,d] * selling_price[p];
      
      impvar Future_Revenue = SUM{p in PRODUCTS} (numInv[p,6] + production[p,6,2] * 30) * break_even_price[p]; 
  
   /*Driver Labor*/
   impvar Driver_Labor = sum{m in MONTHS, f in FORTNIGHT} (Delivery[m,f]/60) * &employee_cost;
  
      /*Total Cost*/
   impvar Total_Cost = ProdCost + Driver_Labor + RentalCost;
  
   /* declare contraints */     
   con Beginning_balance {p in PRODUCTS}:
      init_inventory [p] + (production [p,1,1]) * 30 = 
      NumINV[p,1] + SUM{d in DISTANTCUST} volume_deliveries [p,1,d] + pub_deliveries [p,1,1] + pub_deliveries [p,1,2];
      
   con Inventory_balance {p in PRODUCTS, m in MONTHS diff /1/}:
      (production [p,m-1,2] + production [p,m,1]) * 30 + NumINV[p,m-1] = 
      NumINV[p,m] + SUM{d in DISTANTCUST} volume_deliveries [p,m,d] + pub_deliveries [p,m,1] + pub_deliveries [p,m,2];
      
   con Demand_con4 {p in PRODUCTS, m in MONTHS}: 
   sum{f in Fortnight} pub_deliveries[p,m,f] <= kegs['OSPB',p,m];
   
   con prod_con {m in MONTHS, f in FORTNIGHT}: SUM {p in PRODUCTS} production [p,m,f] <= 5;
   
   con prod_con2 {p in PRODUCTS} : SUM {m in MONTHS, f in FORTNIGHT} production [p,m,f] >= 3;
   
   con Demand_con {p in PRODUCTS, m in MONTHS, d in DISTANTCUST}: 
   volume_deliveries[p,m,d] <= kegs[d,p,m];
   
   con Demand_con3 {p in PRODUCTS, m in MONTHS, f in FORTNIGHT}: 
   pub_deliveries[p,m,f] <= ceil(0.5 * kegs['OSPB',p,m]);
   
   con TruckCapacity {r in ROUTES, m in MONTHS}: 
   SUM{p in PRODUCTS, d in DISTANTCUST:route[d] = r}volume_deliveries [p,m,d] <= 29;
   
   /* !!!Constraint for 95% of demand must be met!!!*/
  
   con Demand_con2 {m in MONTHS}: 
   SUM{p in PRODUCTS, d in DISTANTCUST}volume_deliveries[p,m,d] >= 0.95 * SUM{p in PRODUCTS, d in DISTANTCUST}kegs[d,p,m];
   
   /*!!!Constraint for cold storage 240 kegs at beginning of month!!!*/
  
   con StorageCapacity {m in MONTHS}:
    SUM{p in PRODUCTS}BegInv[p,m] <= 240;
    
   con StorageCapacity2 {m in MONTHS}:
    SUM{p in PRODUCTS}PostInv[p,m] <= 240;
    
   con StorageCapacity3 {m in MONTHS, p in PRODUCTS}:
    MidInv[p,m] >= 0;
  
   
   /*For Overtime*/
   con Usage {r in RESOURCES}: 
     AmountUsed[r] <= availability[r]
        + if (r='Brewing_Labor') then overtime else 0;
        
   con OvertimeLimit: overtime <= 210;
        
        /*add constraint for no more than 210 OT hours*/
       
    /*Half pub demand, final invetory */   
   
   con final_inv{p in PRODUCTS}: numInv[p,6] + production[p,6,2]*30 >= kegs['OSPB',p,6] * 0.5+
   0.95*(SUM{d in DISTANTCUST: route[d] in 1..2} kegs [d,p,6]);     
   
   /* Use this section to iterate on the sensitivity
   Save the solution information each time*/
   fix production["Dark_Ale",1,1] = 1;
   
   /*add this statement when running the final version*/
   /*unfix production;*/
   
   expand final_inv;
        
      /* declare objective */
   max TotalProfit = Revenue + Future_Revenue - Total_Cost;
   
   /*The best value used was relobjgap of 0.0078, this took about 90 sec for a run*/
   solve with milp / relobjgap = 0.01;
   
   for {p in PRODUCTS, m in MONTHS, f in FORTNIGHT}
   production [p,m,f] = round(production [p,m,f]);
   
   for {p in PRODUCTS, m in MONTHS, f in FORTNIGHT}
   pub_deliveries [p,m,f] = round(pub_deliveries [p,m,f]);
   
   for {p in PRODUCTS, m in MONTHS, d in DISTANTCUST}
   volume_deliveries [p,m,d] = round(volume_deliveries [p,m,d]);
      
   print Delivery;
   print {p in PRODUCTS} production[p,1,1];
   
   print pub_deliveries {p in PRODUCTS,m in  MONTHS,f in FORTNIGHT} (kegs ["OSPB", p,m]/2);
  
      
   create data proj.production from [Product Month Fortnight] Batches=production;
   create data proj.pub_deliveries from [Product Month Fortnight] Kegs=pub_deliveries;
   create data proj.volume_deliveries from [Product Month Customer] Kegs=volume_deliveries; 
   
   
   
   print NumINV;
   print BegInv;
   print MidInv;
   print PostInv;
   print overtime;
   

   
   
   quit;
