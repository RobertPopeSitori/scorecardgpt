/**
 * @author Christopher Mudd from fusionSpan
 * @date 6/17/19
 * 
 * @description contains utility methods used by routing rules written by fusionSpan
 */

public without sharing class FS_Utils {

    // organization membership Item class -Membership ALso needs to check buisness group
    private static final String ORG_MEM_STRING = 'Membership';
    private static final String PROF_MEM_STRING = 'Individual Membership';
    private static final String STANDARD_BUISENSS_GROUP = 'OLC';

    private static final List<OrderApi__Business_Group__c> Buissness_group_List= [SELECT ID ,NAME from OrderApi__Business_Group__c Where Name=:STANDARD_BUISENSS_GROUP];
    public static final OrderApi__Business_Group__c BUSINESS_GROUP = Buissness_group_List.get(0);

    public static Map<Id, Contact> getContactsByIdsFromSubs(List<OrderApi__Subscription__c> subsToProcess) {
        Set<Id> contactIdList = new Set<Id>();
        for (OrderApi__Subscription__c sub : subsToProcess) {
            contactIdList.add(sub.OrderApi__Contact__c);
        }
        return new Map<Id, Contact>([
                SELECT Id,
                        AccountId,
                        FS_Professional_Membership__c,
                        FS_Professional_Member_Join_Date__c,
                        FS_Professional_Member_Re_Join_Date__c,
                        FS_Professional_Member_Grace_End_Date__c,
                        FS_Professional_Member_Paid_Through_Date__c,
                        FS_Receives_Org_Member_Benefits__c
                FROM Contact
                WHERE Id IN :contactIdList
        ]);
    }

    public static Map<Id, List<Contact>> getContactsByIdsFromAccountSubs(List<OrderApi__Subscription__c> subsToProcess) {
        Set<Id> accountIdList = new Set<Id>();
        for (OrderApi__Subscription__c sub : subsToProcess) {
            accountIdList.add(sub.OrderApi__Account__c);
        }
        List<Contact> contactList = [
                SELECT Id,
                        AccountId,
                        FS_Professional_Membership__c,
                        FS_Professional_Member_Join_Date__c,
                        FS_Professional_Member_Re_Join_Date__c,
                        FS_Professional_Member_Grace_End_Date__c,
                        FS_Professional_Member_Paid_Through_Date__c,
                        FS_Receives_Org_Member_Benefits__c
                FROM Contact
                WHERE AccountId IN :accountIdList
        ];
        Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();
        for (Contact con : contactList) {
            if (contactsByAccountId.get(con.AccountId) != null) {
                contactsByAccountId.get(con.AccountId).add(con);
            } else {
                contactsByAccountId.put(con.AccountId, new List<Contact>{ con });
            }
        }

        return contactsByAccountId;
    }

    public static List<OrderApi__Subscription__c> getProfMemSubs(List<OrderApi__Subscription__c> subsToProcess) {
        system.debug('subsToProcess:::::::'+subsToProcess.size());
        List<OrderApi__Subscription__c> retSubs = new List<OrderApi__Subscription__c>();

        OrderApi__Item_Class__c proMemItemClass = getProMemItemClass();
        for (OrderApi__Subscription__c sub : subsToProcess) {
            if (proMemItemClass!=null && sub.OrderApi__Item_Class__c == proMemItemClass.Id) {
                // system.assert(sub == null, sub + '\n' + orgMemItemClass);
                retSubs.add(sub);
            }
        }
        return retSubs;


//        OrderApi__Item__c profMemItem = getProfMemItem();
//        for (OrderApi__Subscription__c sub : subsToProcess) {
//            if (profMemItem != null && sub.OrderApi__Item__c == profMemItem.Id) {
//                retSubs.add(sub);
//            }
//        }
//        return retSubs;
    }

    public static List<OrderApi__Subscription__c> getOrgMemSubs(List<OrderApi__Subscription__c> subsToProcess) {
        List<OrderApi__Subscription__c> retSubs = new List<OrderApi__Subscription__c>();
        OrderApi__Item_Class__c orgMemItemClass = getOrgMemItemClass();
        for (OrderApi__Subscription__c sub : subsToProcess) {
            if (orgMemItemClass!=null && sub.OrderApi__Item_Class__c == orgMemItemClass.Id) {
                retSubs.add(sub);
            }
        }
        return retSubs;
    }

//    public static OrderApi__Item__c getProfMemItem() {
//        List<OrderApi__Item__c> profMemItemClass = [
//                SELECT Id,Name
//                FROM OrderApi__Item__c
//                WHERE Name = :PROF_MEM_STRING
//        ];
//        return profMemItemClass != null && !profMemItemClass.isEmpty() ?
//                profMemItemClass[0] : null;
//    }


    public static OrderApi__Item_Class__c getProMemItemClass() {
        List<OrderApi__Item_Class__c> proMemItemClass = [
                SELECT Id,Name
                FROM OrderApi__Item_Class__c
                WHERE Name = :PROF_MEM_STRING
                AND OrderApi__Business_Group__c=:BUSINESS_GROUP.Id
        ];
        return proMemItemClass != null && !proMemItemClass.isEmpty()
                ? proMemItemClass[0] : null;
    }

    public static OrderApi__Item_Class__c getOrgMemItemClass() {
//        List<OrderApi__Item_Class__c> itemClass = [
//                SELECT Id,Name
//                FROM OrderApi__Item_Class__c
//        ];
        List<OrderApi__Item_Class__c> orgMemItemClass = [
                SELECT Id,Name
                FROM OrderApi__Item_Class__c
                WHERE Name = :ORG_MEM_STRING
                AND OrderApi__Business_Group__c=:BUSINESS_GROUP.Id
        ];

        return orgMemItemClass != null && !orgMemItemClass.isEmpty() ? orgMemItemClass[0] :
                null;
    }

    public static Map<Id, OrderApi__Item_Class__c> getItemClassNames(List<OrderApi__Subscription__c> subsToProcess) {
        Set<Id> itemClassIds = new Set<Id>();
        for (OrderApi__Subscription__c sub : subsToProcess) {
            itemClassIds.add(sub.OrderApi__Item_Class__c);
        }
        return new Map<Id, OrderApi__Item_Class__c>([
                SELECT Id,Name
                FROM OrderApi__Item_Class__c
                WHERE Id IN :itemClassIds
        ]);
    }

    public static List<OrderApi__Subscription__c> getSubsFromTerms(List<OrderApi__Renewal__c> termsToProcess) {
        Set<Id> subIdsFromTerms = new Set<Id>();
        for (OrderApi__Renewal__c term : termsToProcess) {
            subIdsFromTerms.add(term.OrderApi__Subscription__c);
        }
        return [
                SELECT Id,
                        OrderApi__Account__c,
                        OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c,
                        OrderApi__Item_Class__c,
                        OrderApi__Item__c,
                        OrderApi__Status__c,
                        OrderApi__Entity__c,
                        OrderApi__Contact__c,
                        OrderApi__Activated_Date__c,
                        OrderApi__Grace_Period_End_Date__c
                FROM OrderApi__Subscription__c
                WHERE Id IN :subIdsFromTerms
        ];
    }

    public static Map<Id, Account> getAccountsByIdsFromSubs(List<OrderApi__Subscription__c> subsToProcess) {
        Set<Id> accountIdList = new Set<Id>();
        for (OrderApi__Subscription__c sub : subsToProcess) {
            accountIdList.add(sub.OrderApi__Account__c);
        }
        return new Map<Id, Account>([
                SELECT Id,
                        FS_Organization_Paid_Through_Date__c,
                        FS_Re_Join_Date__c,
                        FS_Organization_Member_Type__c,
                        FS_Professional_Membership_Count__c,
                        FS_Original_Join_Date__c,
                        FS_Organization_Grace_Period_End_Date__c
                FROM Account
                WHERE Id IN :accountIdList
        ]);
    }

    public static Map<Id, OrderApi__Subscription__c> getSubsByAccountIds(List<Id> accountIds) {
        Set<Id> accountIdSet = new Set<Id>(accountIds);
        OrderApi__Item_Class__c orgMemItemClass = getOrgMemItemClass();
        Map<Id, OrderApi__Subscription__c> subsByAccountIds = new Map<Id, OrderApi__Subscription__c>();
        List<OrderApi__Subscription__c> subs = [
                SELECT Id
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Account__c IN :accountIdSet
                AND OrderApi__Item_Class__c = :orgMemItemClass.Id
        ];
        for (OrderApi__Subscription__c sub : subs) {
            subsByAccountIds.put(sub.OrderApi__Account__c, sub);
        }
        return subsByAccountIds;
    }
}