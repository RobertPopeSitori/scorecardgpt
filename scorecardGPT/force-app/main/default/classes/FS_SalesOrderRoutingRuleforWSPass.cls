/*
 Created by Gopi on 11-07-2019.
 */
global class FS_SalesOrderRoutingRuleforWSPass extends Framework.Domain {
    public FS_SalesOrderRoutingRuleforWSPass(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_SalesOrderRoutingRuleforWSPass(sObjectList);
        }
    }
    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_SalesOrderRoutingRuleforWSPass.class.getName(), 'After update');
        FS_SalesOrderRoutingRuleforWSPass.insertWSPass((List<OrderApi__Sales_Order__c>) records, existingRecords);
        Framework.Log.pop();
    }
    public override void beforeDelete() {
        Framework.Log.push(FS_SalesOrderRoutingRuleforWSPass.class.getName(), 'Before delete');
        FS_SalesOrderRoutingRuleforWSPass.deleteSOLine((List<OrderApi__Sales_Order__c>) records);
        Framework.Log.pop();
    }
    //This method is for inserting new record into WorkShopPass object whenever we purchase WorkShopPass 5 or 10 item.
    public static void insertWSPass(List<OrderApi__Sales_Order__c> soList, Map<Id, SObject> existingRecords) {
        List<FS_Workshop_Pass__c> wpsList = new List<FS_Workshop_Pass__c>();
        //for set of Ids for the corresponding sales order lines on which payment is made
        set<Id> solID = new set<Id>();
        for (OrderApi__Sales_Order__c saleOrder : soList) {
            OrderApi__Sales_Order__c oldSO = (OrderApi__Sales_Order__c) existingRecords.get(saleOrder.Id);
            if ((saleOrder.OrderApi__Status__c == 'closed' && saleOrder.OrderApi__Posting_Status__c == 'posted') &&
                    (oldSO.OrderApi__Posting_Status__c != 'posted')) {
                solID.add(saleOrder.Id);
            }
        }
        //Querying SalesOrderLines with FS_Workshop_Pass_Identifier__c as true for WorkShopPass 5 or 10 items
        List<OrderApi__Sales_Order_Line__c> soLineList = [
                SELECT Id,OrderApi__Item__c,OrderApi__Account__c,OrderApi__Contact__c,
                        OrderApi__Item__r.name,OrderApi__Quantity__c,OrderApi__Sales_Order__r.OrderApi__Closed_Date__c,OrderApi__Item__r.FS_Workshop_Pass_Identifier__c, OrderApi__Item__r.FS_Number_Of_Passes__c, OrderApi__Item__r.FS_Type__c, (SELECT Id FROM OrderApi__Badges__r)
                FROM OrderApi__Sales_Order_Line__c
                WHERE OrderApi__Sales_Order__c IN :solID and OrderApi__Item__r.FS_Workshop_Pass_Identifier__c = true
        ];

        //Inserting new Pass Record for every respective SalesOrderLine
        for (OrderApi__Sales_Order_Line__c soLine : soLineList) {
            FS_Workshop_Pass__c pass = new FS_Workshop_Pass__c();
            pass.FS_Contact__c = soLine.OrderApi__Contact__c;
            pass.FS_Account__c = soLine.OrderApi__Account__c;
            pass.FS_Quantity__c = soLine.OrderApi__Quantity__c;
            pass.FS_Total__c = soLine.OrderApi__Item__r.FS_Number_Of_Passes__c * soLine.OrderApi__Quantity__c;
            pass.FS_Start_Date__c = soLine.OrderApi__Sales_Order__r.OrderApi__Closed_Date__c;
            pass.FS_Sales_Order_Line__c = soLine.Id;
            pass.FS_End_Date__c = pass.FS_Start_Date__c + 365;
            pass.FS_Number_Used__c = 0;
            pass.FS_Type__c = soLine.OrderApi__Item__r.FS_Type__c;
            wpsList.add(pass);
        }
        insert wpsList;
    }
    //Deleting ALL the child records (Sales Order Lines) whenever the respective parent records (Sales Orders) are getting deleted
    public static void deleteSOLine(List<OrderApi__Sales_Order__c> soList) {
        List<OrderApi__Sales_Order_Line__c> soLineList = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :soList];
        delete soLineList;
    }
}