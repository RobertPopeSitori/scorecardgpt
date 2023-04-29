/**
 * -----------------------------------------------------------------------------
 * COPYRIGHT (C) 2014, FONTEVA, INC.
 * ALL RIGHTS RESERVED.
 *
 * ALL INFORMATION CONTAINED HEREIN IS, AND REMAINS THE PROPERTY OF FONTEVA
 * INCORPORATED AND ITS SUPPLIERS, IF ANY. THE INTELLECTUAL AND TECHNICAL
 * CONCEPTS CONTAINED HEREIN ARE PROPRIETARY TO FONTEVA INCORPORATED AND
 * ITS SUPPLIERS AND MAY BE COVERED BY U.S. AND FOREIGN PATENTS, PATENTS IN
 * PROCESS, AND ARE PROTECTED BY TRADE SECRET OR COPYRIGHT LAW. DISSEMINATION
 * OF THIS INFORMATION OR REPRODUCTION OF THIS MATERIAL IS STRICTLY FORBIDDEN
 * UNLESS PRIOR WRITTEN PERMISSION IS OBTAINED FROM FONTEVA, INC.
 * -----------------------------------------------------------------------------
 *
 * Domain class for the Sales_Order_Line__c SObjectType
 * @author Mac Anderson
 **/
 global class GDO_SalesOrderLines extends Framework.Domain {

    public GDO_SalesOrderLines(List<OrderApi__Sales_Order_Line__c> sObjectList) {
        super(sObjectList);
    } 

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new GDO_SalesOrderLines(sObjectList);
        }
    }


    // membership -- New Member, Renewals
    // education -- Candidate Fees, Maintenance Fees
    // events -- Registration, Sponsorship, Other
    // other -- Other
    public override void applyDefaults() {
        Framework.Log.push(GDO_SalesOrderLines.class.getName(),'applyDefaults');
        for (OrderApi__Sales_Order_Line__c sol : (OrderApi__Sales_Order_Line__c[]) records) {
            // MEMBERSHIPS
            if (sol.OrderApi__Subscription_Plan__c != null) {
                sol.Revenue_Category__c = 'Membership';
                if (sol.OrderApi__Is_Renewal__c) {
                    sol.Revenue_Subcategory__c = 'Renewals';
                } else {
                    sol.Revenue_Subcategory__c = 'New Member';
                }
            // EVENTS
            } else if (sol.EventApi__Event__c != null) {
                sol.Revenue_Category__c = 'Events';
                if (sol.EventApi__Ticket_Type__c != null) {
                    sol.Revenue_Subcategory__c = 'Registration';
                } else if (sol.EventApi__Sponsor_Package__c != null) {
                    sol.Revenue_Subcategory__c = 'Sponsorship';
                } else if (sol.EventApi__Schedule_Item__c != null) {
                    sol.Revenue_Subcategory__c = 'Other';
                } else {
                    sol.Revenue_Subcategory__c = 'Other';
                }
            // EDUCATION
            } else if (sol.ProgramApi__Program_Term__c != null) {
                sol.Revenue_Category__c = 'Education';
                if (sol.Program_Term_Is_Maintenance__c) {
                    sol.Revenue_Subcategory__c = 'Maintenance Fees';
                } else {
                    sol.Revenue_Subcategory__c = 'Candidate Fees';
                }
            // TAXES
            } else if (sol.OrderApi__Is_Tax__c) {
                sol.Revenue_Category__c = 'Shipping, Tax & Delivery';
                sol.Revenue_Subcategory__c = 'Tax/VAT';
            // SHIPPING
            } else if (sol.OrderApi__Is_Shipping_Rate__c) {
                sol.Revenue_Category__c = 'Shipping, Tax & Delivery';
                sol.Revenue_Subcategory__c = 'Shipping';
            } else {
                sol.Revenue_Category__c = 'Other';
                sol.Revenue_Subcategory__c = 'Other';
            }
        }
        Framework.Log.pop();
    }


}