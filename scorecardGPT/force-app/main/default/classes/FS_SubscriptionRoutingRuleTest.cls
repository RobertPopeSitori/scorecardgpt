/**
 * @author Christopher Mudd from fusionSpan
 * @date 06/19/19
 *
 */
@IsTest
public without sharing class FS_SubscriptionRoutingRuleTest {

    @TestSetup
    public static void setUpForTest() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_SubscriptionRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Subscription__c';
        routingRule.executionOrder = 40;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }

    @IsTest
    public static void testCreatingSubscription_ExpectProfessionalMemberChecked() {
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



        System.debug('contact list: ' + contactToCheck);

//        System.assertEquals(contactToCheck.size(), 1, 'more than one contact returned');
        System.assert(contactToCheck[0].FS_Professional_Membership__c, 'Professional member not checked. ' + contactToCheck);

    }

    @IsTest
    public static void testCreatingOrgSubscription_ExpectReceivesOrgmemberBenefitsUpdated() {
        Account acc = FS_TestUtils.createAccount('Test Account');
        Contact con = FS_TestUtils.createContact('Test', 'Chris', acc.Id);
        OrderApi__Business_Group__c busGroup = FS_TestUtils.createBusinessGroup();
        OrderApi__Payment_Terms__c paymentTerms = FS_TestUtils.createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = FS_TestUtils.createSubscriptionPlan(paymentTerms, busGroup);
        PagesApi__Site__c site = FS_TestUtils.createCommunitySite(busGroup);
//        PagesApi__Community_Group__c commGroup = FS_TestUtils.createCommunityGroup(site);
//        OrderApi__Item_Class__c itemClass = FS_TestUtils.createOrgMemItemClass(busGroup);
        OrderApi__Item__c subItem = FS_TestUtils.createOrgSubItem(busGroup);
        List<OrderApi__Item_Class__c> orgmemItemClass = [SELECT Id FROM OrderApi__Item_Class__c WHERE Id = :subItem.OrderApi__Item_Class__c];
        System.assert(orgmemItemClass != null, orgmemItemClass);
        OrderApi__Item_Subscription_Plan__c subPlanLink = FS_TestUtils.createSubscriptionPlanItemLink(subscriptionPlan, subItem);

        //Create sales order for user to checkout
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
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

        System.debug(subItem);

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


        System.assert(contactToCheck[0].FS_Receives_Org_Member_Benefits__c, 'Receives org member benefits did not get checked: ' + contactToCheck);
    }


}