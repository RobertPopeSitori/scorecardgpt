global class FS_WPSalesOrderLineRoutingRule extends Framework.Domain {
    public FS_WPSalesOrderLineRoutingRule(List<OrderApi__Sales_Order_Line__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_WPSalesOrderLineRoutingRule(sObjectList);
        }
    }
    public override void beforeInsert() {
        Framework.Log.push(FS_WPSalesOrderLineRoutingRule.class.getName(),'before Insert');
        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = (List<OrderApi__Sales_Order_Line__c>) records;
        updateWorkshopPassWhenInsertAndDeleteOnSOL(salesOrderLineList, true);
        Framework.Log.pop();
    }
    public override void beforeDelete(){
        Framework.Log.push(FS_WPSalesOrderLineRoutingRule.class.getName(),'Before delete');
        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = (List<OrderApi__Sales_Order_Line__c>) records;
        updateWorkshopPassWhenInsertAndDeleteOnSOL(salesOrderLineList, false);
        Framework.Log.pop();
    }
    public override void beforeUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_WPSalesOrderLineRoutingRule.class.getName(),'before update');
        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = (List<OrderApi__Sales_Order_Line__c>) records;
        updateWorkshopPassWhenUpdateOnSOL(salesOrderLineList, existingRecords);
        Framework.Log.pop ();
    }


    /*This method is to either increase or decrease the number used field of workshop pass object for the update operation on sales order line object
      and also to update the sales order line with workshop pass which is being used*/
    public static void updateWorkshopPassWhenUpdateOnSOL(List<OrderApi__Sales_Order_Line__c> newRecords, Map<Id, SObject> existingRecords) {
        Set<Id> newItemIds = new Set<Id>();
        Set<Id> oldItemIds = new Set<Id>();
        Set<Id> soIds = new Set<Id>();
        List<OrderApi__Sales_Order_Line__c> newSolList = new List<OrderApi__Sales_Order_Line__c>();
        List<OrderApi__Sales_Order_Line__c> oldSolList = new List<OrderApi__Sales_Order_Line__c>();

        for (OrderApi__Sales_Order_Line__c newSol : newRecords) {
            OrderApi__Sales_Order_Line__c oldSol = (OrderApi__Sales_Order_Line__c) existingRecords.get(newSol.Id);
            if (newSol.OrderApi__Item__c != oldSol.OrderApi__Item__c) {//If we are changing the Item then we need to increase or decrease
                newItemIds.add(newSol.OrderApi__Item__c);
                oldItemIds.add(oldSol.OrderApi__Item__c);
                soIds.add(newSol.OrderApi__Sales_Order__c);
                newSolList.add(newSol);
                oldSolList.add(oldSol);
            }
        }


        //Retrieving the new items map of sales order lines where item is a pass
        Map<Id, OrderApi__Item__c> newItemsMap = new Map<Id, OrderApi__Item__c>([
                SELECT Id, FS_Apply_Workshop_Pass_Benefit__c, FS_Foundation_Pass_Eligible__c, FS_Mastery_Pass_Eligible__c
                FROM OrderApi__Item__c
                WHERE Id IN :newItemIds AND (
                        FS_Apply_Workshop_Pass_Benefit__c = TRUE OR
                        FS_Foundation_Pass_Eligible__c = TRUE OR
                        FS_Mastery_Pass_Eligible__c = TRUE
                )
        ]);

        //Retrieving the old items map of sales order lines where item is a pass
        Map<Id, OrderApi__Item__c> oldItemsMap = new Map<Id, OrderApi__Item__c>([
                SELECT Id, FS_Apply_Workshop_Pass_Benefit__c, FS_Foundation_Pass_Eligible__c, FS_Mastery_Pass_Eligible__c
                FROM OrderApi__Item__c
                WHERE Id IN :oldItemIds AND (
                        FS_Apply_Workshop_Pass_Benefit__c = TRUE OR
                        FS_Foundation_Pass_Eligible__c = TRUE OR
                        FS_Mastery_Pass_Eligible__c = TRUE
                )
        ]);

        //Retrieving the sales orders map of sales order lines
        Map<Id, OrderApi__Sales_Order__c> soMap = new Map<Id, OrderApi__Sales_Order__c>([
                SELECT Id, OrderApi__Is_Closed__c, OrderApi__Is_Posted__c, OrderApi__Contact__c
                FROM OrderApi__Sales_Order__c
                WHERE Id IN :soIds
        ]);

        Set<Id> decContactIds = new Set<Id>();
        Set<Id> incContactIds = new Set<Id>();
        Map<Id, Id> decSoContactIdsMap = new Map<Id, Id>();
        Map<Id, Id> incSoContactIdsMap = new Map<Id, Id>();

        for (OrderApi__Sales_Order_Line__c sol : newSolList) {
            OrderApi__Sales_Order__c salesOrder = soMap.get(sol.OrderApi__Sales_Order__c);
            if (salesOrder != null && !salesOrder.OrderApi__Is_Posted__c){
                OrderApi__Sales_Order_Line__c oldSOL = (OrderApi__Sales_Order_Line__c) existingRecords.get(sol.Id);
                //For bulk updates we may have both increase and decrease sales order lines
                //This is true if replacing the non workshop pass item with the workshop item, so we need to increase the number used field of workshop pass
                if (newItemsMap.containsKey(sol.OrderApi__Item__c) && !oldItemsMap.containsKey(oldSOL.OrderApi__Item__c)) {
                    //For increase sales order lines : Creating contact Ids list and map of sales order line ID & contact ID
                    incContactIds.add(salesOrder.OrderApi__Contact__c);
                    incSoContactIdsMap.put(salesOrder.Id, salesOrder.OrderApi__Contact__c);
                }//This is true if replacing the workshop pass item with the non workshop item, so we need to decrease the number used field of workshop pass
                else if (oldItemsMap.containsKey(oldSOL.OrderApi__Item__c) && !newItemsMap.containsKey(sol.OrderApi__Item__c)) {
                    //For decrease sales order lines : Creating contact Ids list and map of sales order line ID & contact ID
                    decContactIds.add(salesOrder.OrderApi__Contact__c);
                    decSoContactIdsMap.put(salesOrder.Id, salesOrder.OrderApi__Contact__c);
                }//This is true if replacing one pass type item with another pass item
                else if(newItemsMap.containsKey(sol.OrderApi__Item__c) && oldItemsMap.containsKey(oldSOL.OrderApi__Item__c)){
                    incContactIds.add(salesOrder.OrderApi__Contact__c);
                    incSoContactIdsMap.put(salesOrder.Id, salesOrder.OrderApi__Contact__c);
                    decContactIds.add(salesOrder.OrderApi__Contact__c);
                    decSoContactIdsMap.put(salesOrder.Id, salesOrder.OrderApi__Contact__c);
                }
            }
        }


        List<FS_Workshop_Pass__c> passList = new List<FS_Workshop_Pass__c>();
        if(decContactIds.size() > 0){
            increaseOrDecreaseNumberUsedField(decContactIds, decSoContactIdsMap, passList, false, newSolList, oldItemsMap, existingRecords);
        }
        if(incContactIds.size() > 0){
            increaseOrDecreaseNumberUsedField(incContactIds, incSoContactIdsMap, passList, true, newSolList, newItemsMap, existingRecords);
        }
        if(passList.size() > 0){
            update passList;
        }
    }

    /*This method is to either increase or decrease the number used field of workshop pass object for the insert and delete operations on sales order line object
      and also to update the sales order line with workshop pass which is being used,
      isIncrease property describes the operation, it is true for insert and false for delete operation*/
    public static void updateWorkshopPassWhenInsertAndDeleteOnSOL(List<OrderApi__Sales_Order_Line__c> salesOrderLineList, Boolean isIncrease){
        Set<Id> itemIds = new Set<Id>();
        Set<Id> soIds = new Set<Id>();
        for(OrderApi__Sales_Order_Line__c sol : salesOrderLineList){
            itemIds.add(sol.OrderApi__Item__c);
            soIds.add(sol.OrderApi__Sales_Order__c);
        }
        //Retrieving the items map of sales order lines
        Map<Id, OrderApi__Item__c> itemsMap = new Map<Id, OrderApi__Item__c>([
                SELECT Id, FS_Apply_Workshop_Pass_Benefit__c, FS_Foundation_Pass_Eligible__c, FS_Mastery_Pass_Eligible__c
                FROM OrderApi__Item__c
                WHERE Id IN :itemIds AND (
                        FS_Apply_Workshop_Pass_Benefit__c = TRUE OR
                        FS_Foundation_Pass_Eligible__c = TRUE OR
                        FS_Mastery_Pass_Eligible__c = TRUE
                )
        ]);

        //Retrieving the sales order map of sales order lines
        Map<Id, OrderApi__Sales_Order__c> soMap = new Map<Id, OrderApi__Sales_Order__c>([
                SELECT Id,OrderApi__Is_Closed__c, OrderApi__Is_Posted__c,OrderApi__Contact__c
                FROM OrderApi__Sales_Order__c
                WHERE Id IN :soIds
        ]);
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Id> soContactIdsMap = new Map<Id, Id>();
        for (OrderApi__Sales_Order_Line__c sol : salesOrderLineList){
            if (itemsMap.get(sol.OrderApi__Item__c) != null && soMap.get(sol.OrderApi__Sales_Order__c) != null){
                OrderApi__Sales_Order__c so = soMap.get(sol.OrderApi__Sales_Order__c);
                if (so != null && !so.OrderApi__Is_Posted__c){
                    contactIds.add(so.OrderApi__Contact__c);
                    soContactIdsMap.put(so.Id, so.OrderApi__Contact__c);
                }
            }
        }
        List<FS_Workshop_Pass__c> passList = new List<FS_Workshop_Pass__c>();
        increaseOrDecreaseNumberUsedField(contactIds, soContactIdsMap, passList, isIncrease, salesOrderLineList, itemsMap, null);
        if(passList.size() > 0){
            update passList;
        }
    }


    //This is method is to either increase or decrease the number used field on workshop pass object
    private static void increaseOrDecreaseNumberUsedField(Set<Id> contactIds, Map<Id, Id> solContactIdsMap, List<FS_Workshop_Pass__c> passList,
            Boolean isIncrease, List<OrderApi__Sales_Order_Line__c> newSolList, Map<Id, OrderApi__Item__c> newItemsMap, Map<Id, SObject>  existingRecords)
    {
        Map<Id, FS_Workshop_Pass__c> passMap = new Map<Id, FS_Workshop_Pass__c>();
        for (FS_Workshop_Pass__c pass : passList){
            passMap.put(pass.Id, pass);
        }
        if (passList.size() > 0){
            passList.clear();
        }
        //Retrieving the pass objects and creating a map of contact Id and list of pass objects
        Map<Id, List<FS_Workshop_Pass__c>> contactPassListMap = new Map<Id, List<FS_Workshop_Pass__c>>();
        for (FS_Workshop_Pass__c pass : [
                SELECT Id, FS_Contact__c, FS_Number_Used__c, FS_Start_Date__c, FS_End_Date__c, FS_Number_Available__c, FS_Status__c, FS_Total__c, FS_Sales_Order_Line__c, FS_Type__c
                FROM FS_Workshop_Pass__c
                WHERE FS_Contact__c IN :contactIds
                ORDER BY FS_End_Date__c
        ]){
            if (contactPassListMap.containsKey(pass.FS_Contact__c)){
                List<FS_Workshop_Pass__c> passMapList = contactPassListMap.get(pass.FS_Contact__c);
                passMapList.add(pass);
            } else {
                List<FS_Workshop_Pass__c> passMapList = new List<FS_Workshop_Pass__c>();
                passMapList.add(pass);
                contactPassListMap.put(pass.FS_Contact__c, passMapList);
            }
        }


        //Iterating through sales order lines
        for (OrderApi__Sales_Order_Line__c sol : newSolList) {
            if (newItemsMap.get(sol.OrderApi__Item__c) != null ||
                    (existingRecords != null && existingRecords.get(sol.Id) != null && newItemsMap.get(((OrderApi__Sales_Order_Line__c) existingRecords.get(sol.Id)).OrderApi__Item__c) != null)){
                //Getting contact Id associated to sales order
                Id contactId = solContactIdsMap.get(sol.OrderApi__Sales_Order__c);
                //Getting workshop pass list by contact Id
                List<FS_Workshop_Pass__c> passOpList = contactPassListMap.get(contactId); // get all the pass contact has
                if (passOpList != null) {
                    Integer wsPassCount = 0;//Workshop passes count
                    Integer mPassCount = 0;//Mastery passes count
                    Integer fPassCount = 0;//Foundation passes count
                    for (FS_Workshop_Pass__c pass : passOpList){
                        if (pass.FS_Type__c == 'Mastery'){
                            mPassCount++;
                        }else if (pass.FS_Type__c == 'Foundation'){
                            fPassCount++;
                        } else if (pass.FS_Type__c == 'Workshop') {
                            wsPassCount++;
                        }
                    }
                    //Map<String, Integer> typeCountMap = new Map<String, Integer>();

                    //populate countMap
//                    for (FS_Workshop_Pass__c pass : passOpList){
//                        if (typeCountMap.get(pass.FS_Type__c)==null){
//                            typeCountMap.put(pass.FS_Type__c,0);
//                        }
//                        typeCountMap.put(pass.FS_Type__c,typeCountMap.get(pass.FS_Type__c)+1);
//                    }
                    OrderApi__Item__c solItem  = null;
                    if(!isIncrease && existingRecords != null && existingRecords.get(sol.Id) != null){
                        solItem = newItemsMap.get(((OrderApi__Sales_Order_Line__c)existingRecords.get(sol.Id)).OrderApi__Item__c);
                    }else{
                        solItem = newItemsMap.get(sol.OrderApi__Item__c);
                    }

                    Integer count = wsPassCount;
                    if(solItem.FS_Mastery_Pass_Eligible__c )
                        count = mPassCount;
                    else if (solItem.FS_Foundation_Pass_Eligible__c)
                        count = fPassCount;

                    for (FS_Workshop_Pass__c pass : passOpList){        // for every pass contact has
                        //Integer count2 = typeCountMap.get(pass.FS_Type__c);
                        if (passMap.containsKey(pass.Id)){
                            pass = passMap.get(pass.Id);
                        }
                        //For increase case: This is true if number used is equal to the total and contact has more than one workshop pass objects, so we can increase the another workshop pass
                        //or
                        //For decrease case: This is true if number used is zero and contact has more than one workshop pass objects, so we can decrease the another workshop pass
                        //also, pass type must match item type
                        System.debug('-------daviddebug------Item: ');
                        System.debug(sol.Id);

//                        OrderApi__Sales_Order_Line__c itemSelect = [SELECT Id, Name, OrderApi__Item__r.Name,OrderApi__Item__r.FS_Mastery_Pass_Eligible__c, OrderApi__Item__r.FS_Foundation_Pass_Eligible__c,OrderApi__Item__r.FS_Apply_Workshop_Pass_Benefit__c
//                        FROM OrderApi__Sales_Order_Line__c WHERE Id = :sol.Id][0];
//                        System.debug(itemSelect);
//                        System.debug(itemSelect.OrderApi__Item__r.FS_Mastery_Pass_Eligible__c);
//                        System.debug(itemSelect.OrderApi__Item__r.FS_Foundation_Pass_Eligible__c);
//                        System.debug(itemSelect.OrderApi__Item__r.FS_Apply_Workshop_Pass_Benefit__c);
//                        System.debug(pass.FS_Type__c);
//                        System.debug(sol.FS_WorkshopPass__c);
                        //TODO: query for the item inside sales order line to get the flag.
                        if ((solItem.FS_Mastery_Pass_Eligible__c && pass.FS_Type__c == 'Mastery') ||
                                (solItem.FS_Foundation_Pass_Eligible__c && pass.FS_Type__c == 'Foundation') ||
                                (solItem.FS_Apply_Workshop_Pass_Benefit__c && pass.FS_Type__c == 'Workshop')) {
                            if ( (pass.FS_Total__c - pass.FS_Number_Used__c  == 0 && count > 1 && isIncrease)
                                    || (pass.FS_Number_Used__c == 0 && count > 1 && !isIncrease)){
                                //if (passTypeMatch(pass, newItemsMap, existingRecords, sol)) {
                                count--;
                                //typeCountMap.put(pass.FS_Type__c, count2);
                                //}
                                continue;
                            }
                            if (isIncrease) {
                                pass.FS_Number_Used__c = pass.FS_Number_Used__c + 1;
                                sol.FS_WorkshopPass__c = pass.Id;
                            } else {
                                pass.FS_Number_Used__c = pass.FS_Number_Used__c - 1;
                                if (existingRecords != null){
                                    sol.FS_WorkshopPass__c = null;
                                }
                            }
                            passMap.put(pass.Id, pass);
                            break;
                        }
                    }
                }
            }
        }

        passList.addAll(passMap.values());
    }

    //determine if pass type matches item eligibility (workshop, mastery, or foundation)
    private static Boolean passTypeMatch(FS_Workshop_Pass__c pass, Map<Id, OrderApi__Item__c> newItemsMap, Map<Id, SObject>  existingRecords, OrderApi__Sales_Order_Line__c sol) {
        OrderApi__Item__c item = newItemsMap.get(sol.OrderApi__Item__c);
        if (item == null) {
            item = newItemsMap.get(((OrderApi__Sales_Order_Line__c) existingRecords.get(sol.Id)).OrderApi__Item__c);
        }
        if ((pass.FS_Type__c == 'Workshop' && item.FS_Apply_Workshop_Pass_Benefit__c) ||
                (pass.FS_Type__c == 'Mastery' && item.FS_Mastery_Pass_Eligible__c) ||
                (pass.FS_Type__c == 'Foundation' && item.FS_Foundation_Pass_Eligible__c)) {
            return true;
        } else {
            return false;
        }
    }
}