/**
 * @author Christopher Mudd from fusionSpan
 * @date 06/19/19
 *
 */
@IsTest
public without sharing class FS_ContactRoutingRuleTest {

    @TestSetup
    public static void setUpForTest() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_ContactRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'Contact';
        routingRule.executionOrder = 100;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }

    @IsTest
    public static void testChangingAccount_ExpectMemberBenefitsUnchecked() {

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

        con.AccountId = null;
        update con;


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
        ];

        List<OrderApi__Renewal__c> termsGenerated = [
                SELECT Id,
                        OrderApi__Term_End_Date__c,
                        OrderApi__Grace_Period_End_Date__c,
                        OrderApi__Term_Start_Date__c
                FROM OrderApi__Renewal__c
        ];

        System.assert(!contactToCheck[0].FS_Receives_Org_Member_Benefits__c, 'Receives Member benefits still checked. ');

    }


    @IsTest
    public static void testChangingAccount_ExpectMemberBenefitsStillChecked() {

        Account acc = FS_TestUtils.createAccount('Test Account');
        Account switchAcc = FS_TestUtils.createAccount('Test Switch Account');
        Contact con = FS_TestUtils.createContact('Test', 'Chris', acc.Id);
        OrderApi__Business_Group__c busGroup = FS_TestUtils.createBusinessGroup();
        OrderApi__Payment_Terms__c paymentTerms = FS_TestUtils.createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = FS_TestUtils.createSubscriptionPlan(paymentTerms, busGroup);
        PagesApi__Site__c site = FS_TestUtils.createCommunitySite(busGroup);
//        PagesApi__Community_Group__c commGroup = FS_TestUtils.createCommunityGroup(site);
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createOrgMemItemClass(busGroup);
        OrderApi__Item__c subItem = FS_TestUtils.createOrgSubItem(busGroup);
        OrderApi__Item_Subscription_Plan__c subPlanLink = FS_TestUtils.createSubscriptionPlanItemLink(subscriptionPlan, subItem);

//        Create sales order for user to checkout
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
//                OrderApi__Account__c = acc.Id,
//                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c  = false,
                OrderApi__Entity__c = 'Account',
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

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Posted';
        update salesOrder;

        con.FS_Receives_Org_Member_Benefits__c = true;
        update con;

//        salesOrder.OrderApi__Status__c = 'Closed';
//        salesOrder.OrderApi__Posting_Status__c = 'Posted';
//        update salesOrder;

        Test.startTest();

        con.AccountId = switchAcc.Id;
        update con;

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
        ];

        List<OrderApi__Renewal__c> termsGenerated = [
                SELECT Id,
                        OrderApi__Term_End_Date__c,
                        OrderApi__Grace_Period_End_Date__c,
                        OrderApi__Term_Start_Date__c
                FROM OrderApi__Renewal__c
        ];

        System.assert(!contactToCheck[0].FS_Receives_Org_Member_Benefits__c, 'Receives member benefits still checked. ');

    }
}