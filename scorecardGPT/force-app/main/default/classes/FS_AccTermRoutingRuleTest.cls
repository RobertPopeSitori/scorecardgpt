/**
 * @date 06/17/2019
 *
 * @description handles updating an account if they purchase a product w/ item class = Organizational Membership
 */
@IsTest
public without sharing class FS_AccTermRoutingRuleTest {

    @TestSetup
    public static void setUpForTest() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule1 = new Framework.RoutingRule();
        routingRule1.apexClass = FS_AccTermRoutingRule.class.getName();
        routingRule1.namespace = '';
        routingRule1.isEnabled = true;
        routingRule1.sObjectName = 'OrderApi__Renewal__c';
        routingRule1.executionOrder = 1;


        Framework.RoutingRule routingRule2 = new Framework.RoutingRule();
        routingRule2.apexClass = FS_SubscriptionRoutingRule.class.getName();
        routingRule2.namespace = '';
        routingRule2.isEnabled = true;
        routingRule2.sObjectName = 'OrderApi__Subscription__c';
        routingRule2.executionOrder = 2;


        Framework.RoutingRule routingRule3 = new Framework.RoutingRule();
        routingRule3.apexClass = FS_AccountRoutingRule.class.getName();
        routingRule3.namespace = '';
        routingRule3.isEnabled = true;
        routingRule3.sObjectName = 'Account';
        routingRule3.executionOrder = 3;


        rules.add(routingRule1);
        rules.add(routingRule2);
        rules.add(routingRule3);
        Framework.Config.push(rules);
    }

    @IsTest
    public static void testCreatingTerms_ExpectDateFieldsUpdated() {

        System.debug('line1');


        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>();
        List<OrderApi__Sales_Order_Line__c> salesOrderLines = new List<OrderApi__Sales_Order_Line__c>();
        List<Contact> contacts = new List<Contact>();

        Account acc = FS_TestUtils.createAccount('Test Account');

        Contact con1 = new Contact(FirstName = 'Test contact 1', LastName = 'Name1', AccountId = acc.Id);
        contacts.add(con1);
        insert contacts;

        OrderApi__Business_Group__c busGroup = FS_TestUtils.createBusinessGroup();
        OrderApi__Payment_Terms__c paymentTerms = FS_TestUtils.createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = FS_TestUtils.createSubscriptionPlan(paymentTerms, busGroup);
//        OrderApi__Item__c subProItem = FS_TestUtils.createProSubItem(busGroup);
//        OrderApi__Item_Class__c itemClass = FS_TestUtils.createOrgMemItemClass(busGroup);
        OrderApi__Item__c subOrgItem = FS_TestUtils.createOrgSubItem(busGroup);
        OrderApi__Sales_Order__c salesOrder1 = new OrderApi__Sales_Order__c (
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con1.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c = false,
                OrderApi__Entity__c = 'Account',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id);

//        OrderApi__Sales_Order__c salesOrder2 = new OrderApi__Sales_Order__c (
//                OrderApi__Contact__c = con1.Id,
//                OrderApi__Status__c = 'Open',
//                OrderApi__Is_Posted__c = false,
//                OrderApi__Entity__c = 'Contact',
//                OrderApi__Posting_Entity__c = 'Receipt',
//                OrderApi__Business_Group__c = busGroup.Id);

        salesOrders.add(salesOrder1);
//        salesOrders.add(salesOrder2);
        insert salesOrders;


        System.debug('line3');

        OrderApi__Sales_Order_Line__c orderLine1 = new OrderApi__Sales_Order_Line__c(
//                OrderApi__Item_Class__c = itemClass.id,
                OrderApi__Item__c = subOrgItem.Id,
                OrderApi__Sales_Order__c = salesOrder1.Id,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con1.Id,
                OrderApi__Subscription_Plan__c = subscriptionPlan.id
        );

//        OrderApi__Sales_Order_Line__c orderLine2 = new OrderApi__Sales_Order_Line__c(
////                OrderApi__Item_Class__c = itemClass.id,
//                OrderApi__Item__c = subProItem.Id,
//                OrderApi__Sales_Order__c = salesOrder1.Id,
//                OrderApi__Sale_Price__c = 0,
//                OrderApi__Account__c = acc.Id,
//                OrderApi__Subscription_Plan__c = subscriptionPlan.id
//        );

        salesOrderLines.add(orderLine1);
//        salesOrderLines.add(orderLine2);

        insert salesOrderLines;


List<OrderApi__Sales_Order__c> updateOrders= new List<OrderApi__Sales_Order__c>();
        Test.startTest();

        salesOrder1.OrderApi__Status__c = 'Closed';
        salesOrder1.OrderApi__Posting_Status__c = 'Posted';


//        salesOrder2.OrderApi__Status__c = 'Closed';
//        salesOrder2.OrderApi__Posting_Status__c = 'Posted';

        updateOrders.add(salesOrder1);
//        updateOrders.add(salesOrder2);
//        update updateOrders;
        update salesOrder1;

        Test.stopTest();

        acc.Description= 'test update description';
        update acc;
        acc.Description ='test addition';
        update acc;

//        List<OrderApi__Renewal__c> termsGenerated = [
//                SELECT Id,
//                        OrderApi__Term_End_Date__c,
//                        OrderApi__Grace_Period_End_Date__c,
//                        OrderApi__Term_Start_Date__c
//                FROM OrderApi__Renewal__c
//                WHERE OrderApi__Account__c = :acc.Id
//        ];

//        List<OrderApi__Subscription__c> subs = [
//                SELECT Id,OrderApi__Activated_Date__c
//                FROM OrderApi__Subscription__c
//                WHERE Id = :acc.Id
//
//        ];

        List<Account> accountToCheck = [
                SELECT Id,
                        FS_Organization_Paid_Through_Date__c,
                        FS_Re_Join_Date__c,
                        FS_Organization_Member_Type__c,
                        FS_Professional_Membership_Count__c,
                        FS_Original_Join_Date__c,
                        FS_Organization_Grace_Period_End_Date__c,
                                Description
                FROM Account
                WHERE Id = :acc.Id
        ];

        System.assertEquals(accountToCheck[0].FS_Re_Join_Date__c, null, 'Rejoin date not null. ');
        System.assert(accountToCheck[0].FS_Original_Join_Date__c!=null);
//        System.assertEquals(accountToCheck[0].FS_Original_Join_Date__c,subs.get(0).OrderApi__Activated_Date__c);
        System.assert(accountToCheck[0].FS_Organization_Paid_Through_Date__c!=null);
        System.assert(accountToCheck[0].FS_Organization_Grace_Period_End_Date__c!=null);
    }




    @IsTest
    public static void testProfeesionalMembersCount() {
        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>();
        List<OrderApi__Sales_Order_Line__c> salesOrderLines = new List<OrderApi__Sales_Order_Line__c>();
        List<Contact> contacts = new List<Contact>();

        Account acc = FS_TestUtils.createAccount('Test Account');

        Contact con1 = new Contact(FirstName = 'Test contact 1', LastName = 'Name1', AccountId = acc.Id);
        contacts.add(con1);
        insert contacts;

        OrderApi__Business_Group__c busGroup = FS_TestUtils.createBusinessGroup();
        OrderApi__Payment_Terms__c paymentTerms = FS_TestUtils.createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = FS_TestUtils.createSubscriptionPlan(paymentTerms, busGroup);
        OrderApi__Item__c subProItem = FS_TestUtils.createProSubItem(busGroup);
        OrderApi__Sales_Order__c salesOrder1 = new OrderApi__Sales_Order__c (
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con1.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c = false,
                OrderApi__Entity__c = 'Account',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id);
        salesOrders.add(salesOrder1);
        insert salesOrders;

        OrderApi__Sales_Order_Line__c orderLine1 = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item__c = subProItem.Id,
                OrderApi__Sales_Order__c = salesOrder1.Id,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con1.Id,
                OrderApi__Subscription_Plan__c = subscriptionPlan.id
        );

        Test.startTest();

        salesOrder1.OrderApi__Status__c = 'Closed';
        salesOrder1.OrderApi__Posting_Status__c = 'Posted';
        update salesOrder1;

        Test.stopTest();

        con1.Email='test@testingcompany.com';
        update con1;
        con1.Email='test@fusionspan.com';
        update con1;

        acc.Description= 'test update description';
        update acc;
        acc.Description ='test addition';
        update acc;

        List<Account> accountToCheck = [
                SELECT Id,
                        FS_Organization_Paid_Through_Date__c,
                        FS_Re_Join_Date__c,
                        FS_Organization_Member_Type__c,
                        FS_Professional_Membership_Count__c,
                        FS_Original_Join_Date__c,
                        FS_Organization_Grace_Period_End_Date__c,
                        Description
                FROM Account
                WHERE Id = :acc.Id
        ];

        System.assert(accountToCheck[0].FS_Professional_Membership_Count__c!=null);
//        System.assert(accountToCheck[0].FS_Professional_Membership_Count__c==1);
    }
}