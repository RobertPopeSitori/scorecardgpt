/**
 * @author Christopher Mudd from fusionSpan
 * @date 06/17/19
 *
 */
@IsTest
public without sharing class FS_TermRoutingRuleTest {

    @TestSetup
    public static void setUpForTest() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_TermRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Renewal__c';
        routingRule.executionOrder = 60;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }

    @IsTest
    public static void testCreatingTerms_ExpectDateFieldsUpdated() {

        Account acc = FS_TestUtils.createAccount('Test Account');
        Contact con = FS_TestUtils.createContact('Test', 'Chris', acc.Id);
        OrderApi__Business_Group__c busGroup = FS_TestUtils.createBusinessGroup();
        OrderApi__Payment_Terms__c paymentTerms = FS_TestUtils.createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = FS_TestUtils.createSubscriptionPlan(paymentTerms, busGroup);
        PagesApi__Site__c site = FS_TestUtils.createCommunitySite(busGroup);
//        PagesApi__Community_Group__c commGroup = FS_TestUtils.createCommunityGroup(site);
        OrderApi__Item__c subItem = FS_TestUtils.createSubItem(busGroup);
        OrderApi__Item_Subscription_Plan__c subPlanLink = FS_TestUtils.createSubscriptionPlanItemLink(subscriptionPlan, subItem);

        //Create sales order for user to checkout
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c  = false,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id);
        insert salesOrder;

        OrderApi__Sales_Order_Line__c orderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = subItem.OrderApi__Item_Class__c,
                OrderApi__Item__c = subItem.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = acc.Id
        );

        insert orderLine;

        Test.startTest();

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Posted';
        update salesOrder;

        Test.stopTest();

        List<Contact> contactToCheck = [
                SELECT Id,
                        FS_Professional_Member_Paid_Through_Date__c,
                        FS_Professional_Member_Join_Date__c,
                        FS_Professional_Member_Re_Join_Date__c,
                        FS_Professional_Member_Grace_End_Date__c,
                        FS_Professional_Membership__c,
                        FS_Receives_Org_Member_Benefits__c
                FROM Contact
                WHERE Id = :con.Id
        ];

        List<OrderApi__Renewal__c> termsGenerated = [
                SELECT Id,
                        OrderApi__Term_End_Date__c,
                        OrderApi__Grace_Period_End_Date__c,
                        OrderApi__Term_Start_Date__c
                FROM OrderApi__Renewal__c
        ];

        List<OrderApi__Subscription__c> subs = [
                SELECT Id,OrderApi__Activated_Date__c
                FROM OrderApi__Subscription__c
        ];

        System.debug('contact list: ' + contactToCheck);

        System.assertEquals(contactToCheck[0].FS_Professional_Member_Join_Date__c, subs[0].OrderApi__Activated_Date__c, 'Join dates do not match. ');
        System.assertEquals(contactToCheck[0].FS_Professional_Member_Paid_Through_Date__c, termsGenerated[0].OrderApi__Term_End_Date__c, 'Paid through date does not match term end date. ');
        System.assertEquals(contactToCheck[0].FS_Professional_Member_Grace_End_Date__c, termsGenerated[0].OrderApi__Grace_Period_End_Date__c, 'Grace period end dates do not match. ');
        System.assertEquals(contactToCheck[0].FS_Professional_Member_Re_Join_Date__c, null, 'Rejoin date not null. ');

    }

    @IsTest
    public static void testRenewingMembership_ExpectRejoinDatePopulated() {

        Account acc = FS_TestUtils.createAccount('Test Account');
        Contact con = FS_TestUtils.createContact('Test', 'Chris', acc.Id);
        OrderApi__Business_Group__c busGroup = FS_TestUtils.createBusinessGroup();
        OrderApi__Payment_Terms__c paymentTerms = FS_TestUtils.createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = FS_TestUtils.createSubscriptionPlan(paymentTerms, busGroup);
        PagesApi__Site__c site = FS_TestUtils.createCommunitySite(busGroup);
//        PagesApi__Community_Group__c commGroup = FS_TestUtils.createCommunityGroup(site);
        OrderApi__Item__c subItem = FS_TestUtils.createSubItem(busGroup);
        OrderApi__Item_Subscription_Plan__c subPlanLink = FS_TestUtils.createSubscriptionPlanItemLink(subscriptionPlan, subItem);

        con.FS_Professional_Member_Paid_Through_Date__c = System.today().addYears(-1);
        con.FS_Professional_Member_Join_Date__c = System.today().addYears(-2);
        con.FS_Professional_Member_Grace_End_Date__c = System.today().addYears(-1).addMonths(1);

        update con;

        //Create sales order for user to checkout
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
//                OrderApi__Account__c = acc.Id,
//                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c  = false,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id);
        insert salesOrder;

        OrderApi__Sales_Order_Line__c orderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = subItem.OrderApi__Item_Class__c,
                OrderApi__Item__c = subItem.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = acc.Id
        );

        insert orderLine;

        Test.startTest();

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Posted';
        update salesOrder;

        Test.stopTest();

        List<Contact> contactToCheck = [
                SELECT Id,
                        FS_Professional_Member_Paid_Through_Date__c,
                        FS_Professional_Member_Join_Date__c,
                        FS_Professional_Member_Re_Join_Date__c,
                        FS_Professional_Member_Grace_End_Date__c,
                        FS_Professional_Membership__c,
                        FS_Receives_Org_Member_Benefits__c
                FROM Contact
                WHERE Id = :con.Id
        ];

        List<OrderApi__Renewal__c> termsGenerated = [
                SELECT Id,
                        OrderApi__Term_End_Date__c,
                        OrderApi__Grace_Period_End_Date__c,
                        OrderApi__Term_Start_Date__c
                FROM OrderApi__Renewal__c
                ORDER BY OrderApi__Term_Start_Date__c DESC
        ];


        System.assert(contactToCheck[0].FS_Professional_Member_Paid_Through_Date__c!=null);
        System.assert(contactToCheck[0].FS_Professional_Member_Grace_End_Date__c!=null);
        System.assert(contactToCheck[0].FS_Professional_Member_Re_Join_Date__c!=null);
//
//        System.assertEquals(contactToCheck[0].FS_Professional_Member_Paid_Through_Date__c, termsGenerated[0].OrderApi__Term_End_Date__c, 'Paid through date does not match term end date. ');
//        System.assertEquals(contactToCheck[0].FS_Professional_Member_Grace_End_Date__c, termsGenerated[0].OrderApi__Grace_Period_End_Date__c, 'Grace period end dates do not match. ');
//        System.assertEquals(contactToCheck[0].FS_Professional_Member_Re_Join_Date__c, termsGenerated[0].OrderApi__Term_Start_Date__c, 'Rejoin date not null. ');

    }
}