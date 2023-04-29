/**
 * Created by archanapatel on 2019-07-18.
 */

global without sharing class FS_AccountRoutingRule extends Framework.Domain {

    private static final String PROF_MEM_STRING = 'Individual Membership';


    public FS_AccountRoutingRule(List<Account> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_AccountRoutingRule(sObjectList);
        }
    }

    global override void beforeUpdate(Map<Id, SObject> existingRecords) {
        List<Account> updatedAccounts = (List<Account>) records;
        AggregateResult[] results = [
                SELECT Count(Id) subCnt, OrderApi__Account__c
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Account__c IN :updatedAccounts AND OrderApi__Status__c = 'Active' AND OrderApi__Item_Class__r.Name = :PROF_MEM_STRING
                AND OrderApi__Entity__c = 'Contact'
                GROUP BY OrderApi__Account__c
        ];

        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>();
        for (Account acc : updatedAccounts) {
            accountIdToAccountMap.put(acc.Id, acc);
        }

        for (AggregateResult result : results) {
            Account relevantAccount = accountIdToAccountMap.get((Id) result.get('OrderApi__Account__c'));
            if (relevantAccount != null) {
                System.debug('Updating account count to ' + Integer.valueOf(result.get('subCnt')));
                relevantAccount.FS_Professional_Membership_Count__c = Integer.valueOf(result.get('subCnt'));
            }
        }

    }
}