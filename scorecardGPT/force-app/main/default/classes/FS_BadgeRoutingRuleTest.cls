/**
 * Created by Admin on 25-07-2019.
 */
@isTest
private class FS_BadgeRoutingRuleTest {
    @TestSetup
    private static void install() {
        Test.startTest();
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        List<Framework.RoutingRule> rules = new List<Framework.RoutingRule>();
        /* RoutingRule information*/
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_BadgeRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Badge__c';
        routingRule.executionOrder = 68;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }
    @IsTest
    private static void insertWSPasstest() {
        Test.startTest();
        //insert Account
        Account acc = new Account();
        acc.Name = 'test1';
        insert acc;
        //insert Contact
        Contact con = new Contact();
        con.LastName = 'testC1';
        insert con;
        //insert salesorder
        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>();
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Account__c = acc.Id;
        so.OrderApi__Contact__c = con.Id;
        so.OrderApi__Entity__c = 'Contact';
        so.OrderApi__Status__c = 'Open';
        insert so;
        OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c();
        bg.Name = 'OLC';
        insert bg;
        OrderApi__Item_Class__c itmClass = new OrderApi__Item_Class__c();
        itmClass.OrderApi__Business_Group__c = bg.Id;
        insert itmClass;
        OrderApi__Item__c itm = new OrderApi__Item__c();
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = true;
        itm.Name = 'Workshop Pass 5';
        itm.FS_Workshop_Pass_Identifier__c = true;
        itm.FS_Number_Of_Passes__c = 5;
        itm.OrderApi__Price__c = 25;
        insert itm;
        OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c();
        soLine.OrderApi__Item__c = itm.Id;
        soLine.OrderApi__Account__c = acc.Id;
        soLine.OrderApi__Contact__c = con.Id;
        soLine.OrderApi__Sales_Order__c = so.Id;
        soLine.OrderApi__Sale_Price__c = 25;
        soLine.OrderApi__Total__c = 25;
        soLine.OrderApi__Quantity__c = 1;
        insert soLine;
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';
        so.OrderApi__Closed_Date__c = System.Today();
        update so;
        FS_Workshop_Pass__c wsp = new FS_Workshop_Pass__c();
        wsp.FS_Contact__c = con.Id;
        wsp.FS_Account__c = acc.Id;
        wsp.FS_Total__c = 5;
        wsp.FS_Start_Date__c = so.OrderApi__Closed_Date__c;
        wsp.FS_End_Date__c =  wsp.FS_Start_Date__c + 365;
        wsp.FS_Number_Used__c = 0;
        wsp.FS_Sales_Order_Line__c = soLine.Id;
        insert wsp;
        OrderApi__Badge_Type__c bdgType = new OrderApi__Badge_Type__c();
        bdgType.Name = 'Workshop Pass';
        insert bdgType;
        OrderApi__Badge_Workflow__c badgWFlow = new OrderApi__Badge_Workflow__c();
        badgWFlow.Name = 'Workshop Pass 5';
        badgWFlow.OrderApi__Item__c = itm.Id;
        badgWFlow.OrderApi__Badge_Type__c = bdgType.Id;
        badgWFlow.OrderApi__Type__c = bdgType.Id;
        badgWFlow.OrderApi__Type__c = 'Line Contact';
        insert badgWFlow;
        Id badgeWorkflowId = [select Id from OrderApi__Badge_Workflow__c where Name = 'Workshop Pass 5' limit 1].Id;
        OrderApi__Badge__c badg = new OrderApi__Badge__c();
        badg.OrderApi__Badge_Workflow__c = badgeWorkflowId;
        badg.OrderApi__Item__c = itm.Id;
        badg.OrderApi__Sales_Order_Line__c = soLine.Id;
        insert badg;
        OrderApi__Badge__c badge =[select Id,FS_WorkshopPass__c,FS_Workshop_Pass_Expiration_Date__c,OrderApi__Expired_Date__c from OrderApi__Badge__c where Id =: badg.Id  ];
        system.assertEquals(badge.FS_WorkshopPass__c,wsp.Id);
        system.assertEquals(badge.FS_Workshop_Pass_Expiration_Date__c,wsp.FS_End_Date__c);
        system.assertEquals(badge.OrderApi__Expired_Date__c,wsp.FS_End_Date__c);
    }
}