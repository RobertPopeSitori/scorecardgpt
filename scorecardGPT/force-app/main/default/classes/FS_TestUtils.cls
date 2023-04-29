/**
 * @author Christopher Mudd
 * @date 6/20/19
 *
 * @description contains utility methods for test classes, mainly creating test data and performing test operations
 */

public class FS_TestUtils {

    private static final String ORG_MEM_STRING = 'Membership';
    private static final String ITEM_CLASS = 'Membership';
    private static final String PROF_MEM_STRING = 'Individual Membership';
    private static final String BUSINESS_GROUP_NAMESTRING = 'OLC';

    public static Account createAccount(String accName) {
        Account acc = new Account(Name=accName,Is_Vendor__c=false,Vendor_Type__c='');
        insert acc;
        return acc;
    }

    public static Contact createContact(String firstName, String lastName, Id accountId) {
        Contact con = new Contact(FirstName=firstName,LastName=lastName,AccountId=accountId);
        insert con;
        return con;
    }

    public static OrderApi__Business_Group__c createBusinessGroup() {
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = BUSINESS_GROUP_NAMESTRING);
        insert busGroup;
        return busGroup;
    }

    public static OrderApi__Payment_Terms__c createPaymentTerms() {
        OrderApi__Payment_Terms__c paymentTerms = new OrderApi__Payment_Terms__c(Name = 'Due on Receipt',
                OrderApi__Display_Name__c = 'Due at the time of Receipt',
                OrderApi__Display_Message__c = 'Please remit payment upon receipt of this invoice.',
                OrderApi__Variable__c = 0);
        insert paymentTerms;
        return paymentTerms;
    }

    public static OrderApi__Subscription_Plan__c createSubscriptionPlan(OrderApi__Payment_Terms__c paymentTerms, OrderApi__Business_Group__c busGroup) {
        OrderApi__Subscription_Plan__c subscriptionPlan = new OrderApi__Subscription_Plan__c(
                Name = '1 Year',
                OrderApi__Type__c = 'Termed', OrderApi__Grace_Period__c = 90, OrderApi__Initial_Term_Months__c = 12,
                OrderApi__Renewal_Term_Months__c = 12,
                OrderApi__Calendar_End_Day__c = '31',
                OrderApi__Calendar_End_Month__c = '12-Dec',OrderApi__Enable_Proration__c = true,
                OrderApi__Proration_Rule__c = 'Bi-Annually',
                OrderApi__Invoice_Days_Variable__c= 31, OrderApi__Auto_Renew_Option__c = 'Enabled',
                OrderApi__Payment_Terms__c = paymentTerms.Id ,OrderApi__Bill_Cycle__c = 'AUTO',
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Active__c = true
        );
        insert subscriptionPlan;
        return subscriptionPlan;
    }

    public static OrderApi__Item__c createSubItem(OrderApi__Business_Group__c busGroup) {
        OrderApi__Item_Class__c profMemItemClass= new OrderApi__Item_Class__c(Name = PROF_MEM_STRING,
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true);
        insert profMemItemClass;
        OrderApi__Item__c  profMemItem = new OrderApi__Item__c(Name=PROF_MEM_STRING,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = profMemItemClass.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = false, OrderApi__Price__c = 0);
        insert profMemItem;
        return profMemItem;
    }

    public static OrderApi__Item__c createOrgSubItem(OrderApi__Business_Group__c busGroup) {
//          OrderApi__Item_Class__c orgMemItemClass= new OrderApi__Item_Class__c(Name = ITEM_CLASS,
//                  OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true);
//          insert orgMemItemClass;
        OrderApi__Item_Class__c orgMemItemClass= createOrgMemItemClass(busGroup);
        OrderApi__Item__c  orgMemItem = new OrderApi__Item__c(Name=ORG_MEM_STRING,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = orgMemItemClass.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = false, OrderApi__Price__c = 0);
        insert orgMemItem;
        return orgMemItem;
    }

    public static OrderApi__Item__c createProSubItem(OrderApi__Business_Group__c busGroup) {
        OrderApi__Item_Class__c proMemItemClass= createOrgMemItemClass(busGroup);
        OrderApi__Item__c  orgMemItem = new OrderApi__Item__c(Name=PROF_MEM_STRING,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = proMemItemClass.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = false, OrderApi__Price__c = 0);
        insert orgMemItem;
        return orgMemItem;
    }


    public static OrderApi__Item_Subscription_Plan__c createSubscriptionPlanItemLink(OrderApi__Subscription_Plan__c subPlan, OrderApi__Item__c profMemItem) {

        OrderApi__Item_Subscription_Plan__c subPlanLink = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Item__c = profMemItem.Id, OrderApi__Is_Default__c = true
        );
        insert subPlanLink;
        profMemItem.OrderApi__Is_Active__c = true;
        update profMemItem;
        return subPlanLink;
    }

    public static OrderApi__Item_Class__c createOrgMemItemClass(OrderApi__Business_Group__c busGroup) {
        OrderApi__Item_Class__c orgMemItemClass= new OrderApi__Item_Class__c(Name = ORG_MEM_STRING,
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true);
        insert orgMemItemClass;
        return orgMemItemClass;
    }

//    public static OrderApi__Item_Class__c createIndMemItemClass() {
//        OrderApi__Item_Class__c indMemItemClass = new OrderApi__Item_Class__c();
//        insert indMemItemClass;
//        return indMemItemClass;
//    }
//
//    public static OrderApi__Item__c createProfMemItem() {
//        OrderApi__Item__c profMemItem = new OrderApi__Item__c();
//        insert profMemItem;
//        return profMemItem;
//    }

    public static PagesApi__Site__c createCommunitySite(OrderApi__Business_Group__c busGroup) {

        PagesApi__Site__c site = new PagesApi__Site__c(
                Name = 'Test Site',
                OrderApi__Business_Group__c=busGroup.Id
        );

        insert site;
        return site;
    }


}