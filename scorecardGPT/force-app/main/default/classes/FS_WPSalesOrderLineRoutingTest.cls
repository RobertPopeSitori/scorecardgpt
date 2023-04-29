/**
 * Created by santhosh on 24-07-2019.
 */

@IsTest
public without sharing class FS_WPSalesOrderLineRoutingTest {

    /*@TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_WPSalesOrderLineRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Sales_Order_Line__c';
        routingRule.executionOrder = 50;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }*/

    @IsTest
    private static void testOperations(){
        Test.startTest();
        Account acc = FS_TestUtils.createAccount('Test Account');
        Contact con = FS_TestUtils.createContact('Test', 'Test2', acc.Id);
        Contact con2 = FS_TestUtils.createContact('Test2', 'Test2', acc.Id);

        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(
                Name = 'Test BG');
        insert busGroup;

        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(
                Name='Test Item Class',
                OrderApi__Business_Group__c = busGroup.Id);
        insert itemClass;

        EventApi__Event__c event = new EventApi__Event__c(
                Name = 'TestEvent',
                EventApi__Event_Key__c = 'TestEventKey',
                EventApi__End_Date__c = System.today() +1,
                EventApi__Start_Date__c = System.today() +1,
                EventApi__Start_Time__c = '08:30 AM',
                EventApi__End_Time__c = '09:30 AM'
        );
        insert event;
        EventApi__Ticket_Type__c ticketType = new EventApi__Ticket_Type__c(
                Name = 'TestTicket',
                FS_Apply_Workshop_Pass_Benefit__c = true,
                EventApi__Event__c = event.Id

        );
        insert ticketType;

        //Item
        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        OrderApi__Item__c item1 = new OrderApi__Item__c(
                Name = 'Test Item1',
                //      OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                EventApi__Ticket_Type__c = ticketType.Id
        );
        itemList.add(item1);

        OrderApi__Item__c item2 = new OrderApi__Item__c(
                Name = 'Test Item2',
                //    OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Business_Group__c = busGroup.Id
        );
        itemList.add(item2);

        insert itemList;
        List<OrderApi__Item__c> itemTestList = [select id, FS_Apply_Workshop_Pass_Benefit__c from OrderApi__Item__c where id = :item1.Id and FS_Apply_Workshop_Pass_Benefit__c = true];
        System.assertEquals(itemTestList.size(), 1);

        List<FS_Workshop_Pass__c> wSPList = new List<FS_Workshop_Pass__c>();
        FS_Workshop_Pass__c wsp = new FS_Workshop_Pass__c(
                FS_Contact__c = con.id,
                FS_Account__c = acc.id,
                FS_Total__c = 5,
                FS_Start_Date__c = System.today() - 10,
                FS_End_Date__c = System.today() + 355,
                FS_Number_Used__c = 0
        );
        wSPList.add(wsp);
        FS_Workshop_Pass__c wsp2 = new FS_Workshop_Pass__c(
                FS_Contact__c = con.id,
                FS_Account__c = acc.id,
                FS_Total__c = 5,
                FS_Start_Date__c = System.today() - 10,
                FS_End_Date__c = System.today() + 255,
                FS_Number_Used__c = 0
        );
        wSPList.add(wsp2);
        FS_Workshop_Pass__c wsp3 = new FS_Workshop_Pass__c(
                FS_Contact__c = con2.id,
                FS_Account__c = acc.id,
                FS_Total__c = 5,
                FS_Start_Date__c = System.today() - 10,
                FS_End_Date__c = System.today() + 255,
                FS_Number_Used__c = 0
        );
        wSPList.add(wsp3);
        insert wSPList;



        List<OrderApi__Sales_Order__c> salesOrderList = new List<OrderApi__Sales_Order__c>();
        for(Integer i = 0; i <2 ; i++){
            OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
                    OrderApi__Account__c = acc.Id,

                    OrderApi__Status__c = 'Open',
                    OrderApi__Is_Posted__c  = false,
                    OrderApi__Entity__c = 'Contact',
                    OrderApi__Posting_Entity__c = 'Receipt',
                    OrderApi__Business_Group__c = busGroup.Id);
            if (i == 0) {
                salesOrder.OrderApi__Contact__c = con.Id;
            }else{
                salesOrder.OrderApi__Contact__c = con2.Id;
            }

            salesOrderList.add(salesOrder);
        }
        insert salesOrderList;


        //salesorderline - creation
        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = new List<OrderApi__Sales_Order_Line__c>();
        for(Integer i = 0; i < 8; i++){
            OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
            salesOrderLine.OrderApi__Sales_Order__c = salesOrderList[0].Id;
            salesOrderLine.OrderApi__Item__c = item1.Id;
            if(i == 0){
                salesOrderLine.OrderApi__Item__c = item2.Id;
            }else if (i == 7){
                salesOrderLine.OrderApi__Sales_Order__c = salesOrderList[1].Id;
                salesOrderLine.OrderApi__Item__c = item1.Id;
            }

            salesOrderLine.OrderApi__Sale_Price__c = 0;
            salesOrderLine.OrderApi__Quantity__c = 1;
            salesOrderLineList.add(salesOrderLine);
        }

        Set<Id> conIds = new Set<Id>();
        conIds.add(con.Id);
        conIds.add(con2.Id);

        //Testing Insert operation
        FS_WPSalesOrderLineRoutingRule.updateWorkshopPassWhenInsertAndDeleteOnSOL(salesOrderLineList,true);
        List<FS_Workshop_Pass__c> wPassList =  [select Id,FS_Contact__c, FS_Number_Used__c,FS_Start_Date__c, FS_End_Date__c,FS_Number_Available__c,FS_Status__c, FS_Total__c, 	FS_Sales_Order_Line__c from FS_Workshop_Pass__c where FS_Contact__c in :conIds order by FS_End_Date__c];
        System.assertEquals(wPassList[0].FS_Number_Used__c,5);
        System.assertEquals(wPassList[1].FS_Number_Used__c,1);
        System.assertEquals(wPassList[2].FS_Number_Used__c,1);
        insert salesOrderLineList;


        Map<id,OrderApi__Sales_Order_Line__c> oldMap=new Map<id,OrderApi__Sales_Order_Line__c>([select id,OrderApi__Item__c,OrderApi__Sales_Order__c,FS_WorkshopPass__c from OrderApi__Sales_Order_Line__c where id = :salesOrderLineList]);

        //Replacing non workshop pass item with workshop item
        salesOrderLineList[0].OrderApi__Item__c = item1.Id;
        //Replacing workshop pass item with non workshop item
        salesOrderLineList[7].OrderApi__Item__c = item2.Id;

        FS_WPSalesOrderLineRoutingRule.updateWorkshopPassWhenUpdateOnSOL(salesOrderLineList, oldMap);
        wPassList =  [select Id,FS_Contact__c, FS_Number_Used__c,FS_Start_Date__c, FS_End_Date__c,FS_Number_Available__c,FS_Status__c, FS_Total__c, 	FS_Sales_Order_Line__c from FS_Workshop_Pass__c where FS_Contact__c in :conIds order by FS_End_Date__c];
        System.assertEquals(wPassList[0].FS_Number_Used__c,5);
        System.assertEquals(wPassList[1].FS_Number_Used__c,0);
        System.assertEquals(wPassList[2].FS_Number_Used__c,2);
        update salesOrderLineList;

        FS_WPSalesOrderLineRoutingRule.updateWorkshopPassWhenInsertAndDeleteOnSOL(salesOrderLineList,false);
        wPassList =  [select Id,FS_Contact__c, FS_Number_Used__c,FS_Start_Date__c, FS_End_Date__c,FS_Number_Available__c,FS_Status__c, FS_Total__c, 	FS_Sales_Order_Line__c from FS_Workshop_Pass__c where FS_Contact__c in :conIds order by FS_End_Date__c];
        System.assertEquals(wPassList[0].FS_Number_Used__c,0);
        System.assertEquals(wPassList[1].FS_Number_Used__c,0);
        System.assertEquals(wPassList[2].FS_Number_Used__c,0);
        Test.stopTest();
    }

    /*
    @IsTest
    private static void testOperations2(){
        Test.startTest();
        Account acc = FS_TestUtils.createAccount('Test Account');
        Contact con = FS_TestUtils.createContact('Test', 'Test2', acc.Id);
        Contact con2 = FS_TestUtils.createContact('Test2', 'Test2', acc.Id);

        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(
                Name = 'Test BG');
        insert busGroup;

        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(
                Name='Test Item Class',
                OrderApi__Business_Group__c = busGroup.Id);
        insert itemClass;

        EventApi__Event__c event = new EventApi__Event__c(
                Name = 'TestEvent',
                EventApi__Event_Key__c = 'TestEventKey',
                EventApi__End_Date__c = System.today() +1,
                EventApi__Start_Date__c = System.today() +1,
                EventApi__Start_Time__c = '08:30 AM',
                EventApi__End_Time__c = '09:30 AM'
        );
        insert event;
        EventApi__Ticket_Type__c ticketType = new EventApi__Ticket_Type__c(
                Name = 'TestTicket',
                FS_Apply_Workshop_Pass_Benefit__c = true,
                EventApi__Event__c = event.Id

        );
        insert ticketType;

        //Item
        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        OrderApi__Item__c item1 = new OrderApi__Item__c(
                Name = 'Test Item1',
                //      OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                EventApi__Ticket_Type__c = ticketType.Id
        );
        itemList.add(item1);

        OrderApi__Item__c item2 = new OrderApi__Item__c(
                Name = 'Test Item2',
                //    OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Foundation_Pass_Eligible__c = true
        );
        itemList.add(item2);

        insert itemList;
        List<OrderApi__Item__c> itemTestList = [select id, FS_Apply_Workshop_Pass_Benefit__c from OrderApi__Item__c where id = :item1.Id and FS_Apply_Workshop_Pass_Benefit__c = true];
        System.assertEquals(itemTestList.size(), 1);

        List<FS_Workshop_Pass__c> wSPList = new List<FS_Workshop_Pass__c>();
        FS_Workshop_Pass__c wsp = new FS_Workshop_Pass__c(
                FS_Contact__c = con.id,
                FS_Account__c = acc.id,
                FS_Total__c = 5,
                FS_Start_Date__c = System.today() - 10,
                FS_End_Date__c = System.today() + 355,
                FS_Number_Used__c = 0,
                FS_Type__c = 'Workshop'
        );
        wSPList.add(wsp);
        FS_Workshop_Pass__c wsp2 = new FS_Workshop_Pass__c(
                FS_Contact__c = con.id,
                FS_Account__c = acc.id,
                FS_Total__c = 5,
                FS_Start_Date__c = System.today() - 10,
                FS_End_Date__c = System.today() + 255,
                FS_Number_Used__c = 0,
                FS_Type__c = 'Mastery'
        );
        wSPList.add(wsp2);
        FS_Workshop_Pass__c wsp3 = new FS_Workshop_Pass__c(
                FS_Contact__c = con2.id,
                FS_Account__c = acc.id,
                FS_Total__c = 5,
                FS_Start_Date__c = System.today() - 10,
                FS_End_Date__c = System.today() + 255,
                FS_Number_Used__c = 0,
                FS_Type__c = 'Foundation'
        );
        wSPList.add(wsp3);
        insert wSPList;

        List<OrderApi__Sales_Order__c> salesOrderList = new List<OrderApi__Sales_Order__c>();
        for(Integer i = 0; i <2 ; i++){
            OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
                    OrderApi__Account__c = acc.Id,

                    OrderApi__Status__c = 'Open',
                    OrderApi__Is_Posted__c  = false,
                    OrderApi__Entity__c = 'Contact',
                    OrderApi__Posting_Entity__c = 'Receipt',
                    OrderApi__Business_Group__c = busGroup.Id);
            if (i == 0) {
                salesOrder.OrderApi__Contact__c = con.Id;
            }else{
                salesOrder.OrderApi__Contact__c = con2.Id;
            }

            salesOrderList.add(salesOrder);
        }
        insert salesOrderList;


        //salesorderline - creation
        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = new List<OrderApi__Sales_Order_Line__c>();
        for(Integer i = 0; i < 8; i++){
            OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
            salesOrderLine.OrderApi__Sales_Order__c = salesOrderList[0].Id;
            salesOrderLine.OrderApi__Item__c = item1.Id;
            if(i == 0){
                salesOrderLine.OrderApi__Item__c = item2.Id;
            }else if (i == 7){
                salesOrderLine.OrderApi__Sales_Order__c = salesOrderList[1].Id;
                salesOrderLine.OrderApi__Item__c = item1.Id;
            }

            salesOrderLine.OrderApi__Sale_Price__c = 0;
            salesOrderLine.OrderApi__Quantity__c = 1;
            salesOrderLineList.add(salesOrderLine);
        }

        Set<Id> conIds = new Set<Id>();
        conIds.add(con.Id);
        conIds.add(con2.Id);

        //Testing Insert operation
        FS_WPSalesOrderLineRoutingRule.updateWorkshopPassWhenInsertAndDeleteOnSOL(salesOrderLineList,true);
        List<FS_Workshop_Pass__c> wPassList =  [select Id,FS_Contact__c, FS_Number_Used__c,FS_Start_Date__c, FS_End_Date__c,FS_Number_Available__c,FS_Status__c, FS_Total__c, 	FS_Sales_Order_Line__c from FS_Workshop_Pass__c where FS_Contact__c in :conIds order by FS_End_Date__c];
        System.assertEquals(0, wPassList[0].FS_Number_Used__c);
        System.assertEquals(0, wPassList[1].FS_Number_Used__c);
        System.assertEquals(6, wPassList[2].FS_Number_Used__c);
        insert salesOrderLineList;


        Map<id,OrderApi__Sales_Order_Line__c> oldMap=new Map<id,OrderApi__Sales_Order_Line__c>([select id,OrderApi__Item__c,OrderApi__Sales_Order__c,FS_WorkshopPass__c from OrderApi__Sales_Order_Line__c where id = :salesOrderLineList]);

        //Replacing non workshop pass item with workshop item
        salesOrderLineList[0].OrderApi__Item__c = item1.Id;
        //Replacing workshop pass item with non workshop item
        salesOrderLineList[7].OrderApi__Item__c = item2.Id;

        FS_WPSalesOrderLineRoutingRule.updateWorkshopPassWhenUpdateOnSOL(salesOrderLineList, oldMap);
        wPassList =  [select Id,FS_Contact__c, FS_Number_Used__c,FS_Start_Date__c, FS_End_Date__c,FS_Number_Available__c,FS_Status__c, FS_Total__c, FS_Sales_Order_Line__c from FS_Workshop_Pass__c where FS_Contact__c in :conIds order by FS_End_Date__c];
        System.assertEquals(0, wPassList[0].FS_Number_Used__c);
        System.assertEquals(0, wPassList[1].FS_Number_Used__c);
        System.assertEquals(6, wPassList[2].FS_Number_Used__c);
        update salesOrderLineList;

        FS_WPSalesOrderLineRoutingRule.updateWorkshopPassWhenInsertAndDeleteOnSOL(salesOrderLineList,false);
        wPassList =  [select Id,FS_Contact__c, FS_Number_Used__c,FS_Start_Date__c, FS_End_Date__c,FS_Number_Available__c,FS_Status__c, FS_Total__c, FS_Sales_Order_Line__c from FS_Workshop_Pass__c where FS_Contact__c in :conIds order by FS_End_Date__c];
        System.assertEquals(0, wPassList[0].FS_Number_Used__c);
        System.assertEquals(-1, wPassList[1].FS_Number_Used__c);
        System.assertEquals(-1, wPassList[2].FS_Number_Used__c);
        Test.stopTest();
    }

     */
}