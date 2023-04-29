/**
 * Created by Gopi on 11-07-2019.
 */

@IsTest
public without sharing class FS_SalesOrderRoutingRuleforWSPassTest {


    @TestSetup
    private static void setupRoutingRules() {
        //Test.startTest();
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        List<Framework.RoutingRule> rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_SalesOrderRoutingRuleforWSPass.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Sales_Order__c';
        routingRule.executionOrder = 68;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }


    @IsTest
    private static void insertWSPasstest() {
        Test.startTest();
        Account acc = FS_TestUtils.createAccount('Test Account');
        //insert Contact
        Contact ct = new Contact();
        ct.LastName = 'testC1';
        ct.accountId = acc.Id;
        insert ct;
        //insert salesorder
        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>();
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Account__c = acc.Id;
        so.OrderApi__Contact__c = ct.Id;
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
        itm.OrderApi__Is_Active__c = false;
        itm.Name = 'Workshop Pass 5';
        itm.FS_Workshop_Pass_Identifier__c = true;
        itm.FS_Type__c = 'Workshop';
        itm.FS_Number_Of_Passes__c = 5;
        itm.OrderApi__Price__c = 25;
        insert itm;
        OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c();
        soLine.OrderApi__Item__c = itm.Id;
        soLine.OrderApi__Sales_Order__c = so.Id;
        soLine.OrderApi__Sale_Price__c = 25;
        soLine.OrderApi__Total__c = 25;
        soLine.OrderApi__Quantity__c = 1;
        insert soLine;
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';
        update so;
        List<FS_Workshop_Pass__c> WSPlist = [SELECT Id FROM FS_Workshop_Pass__c WHERE FS_Sales_Order_Line__c = :soLine.Id];
        System.assertEquals(1, WSPlist.size());
       // delete so;
        Test.stopTest();
    }

}