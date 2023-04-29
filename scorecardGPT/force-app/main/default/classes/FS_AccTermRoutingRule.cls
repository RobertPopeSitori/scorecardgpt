/**
 *
 * @description handles updating an account if they purchase a Membership
 */
global without sharing class FS_AccTermRoutingRule extends Framework.Domain {


    private static final String ACCOUNT_STRING = 'Account';
    private static final String ACTIVE_STRING = 'Active';

    public FS_AccTermRoutingRule(List<OrderApi__Renewal__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_AccTermRoutingRule(sObjectList);
        }
    }

    global override void afterInsert() {
        System.debug('inside afterInsert ::::::::::.');
        Framework.Log.push(FS_AccTermRoutingRule.class.getName(), 'afterInsert');
        List<OrderApi__Renewal__c> termsToProcess = (List<OrderApi__Renewal__c>) records;
        List<Account> updatedAccounts = updateAccountsFromTerms(termsToProcess);
        Database.update(updatedAccounts, true);
        Framework.Log.pop();
    }


    global override void afterUpdate(Map<Id, SObject> existingRecords) {
        System.debug('inside afterUpdate ::::::::::.');

        Framework.Log.push(FS_AccTermRoutingRule.class.getName(), 'afterUpdate');
        List<OrderApi__Renewal__c> termsToProcess = (List<OrderApi__Renewal__c>) records;
        List<Account> updatedAccounts = updateAccountsFromTerms(termsToProcess);
        Database.update(updatedAccounts, true);
        Framework.Log.pop();
    }

    private List<Account> updateAccountsFromTerms(List<OrderApi__Renewal__c> termsToProcess) {

        Map<String, OrderApi__Renewal__c> termsBySubAndSalesOrderId = getTermsBySubAndSalesOrderIds(termsToProcess);
        System.debug('terms' + termsBySubAndSalesOrderId);

        Map<Id, Id> subsByTermId = getSubsByTermId(termsToProcess);
        System.debug(subsByTermId);

        List<OrderApi__Subscription__c> subsToProcess = FS_Utils.getSubsFromTerms(termsToProcess);
        System.debug('subs ' + subsToProcess);

        List<OrderApi__Subscription__c> orgMemSubs = FS_Utils.getOrgMemSubs(subsToProcess);
        System.debug('org mem subs' + orgMemSubs);

        Map<Id, Account> accountsToUpdate = FS_Utils.getAccountsByIdsFromSubs(orgMemSubs);
//        Map<Id, Account> profMemAccountsToUpdate = FS_Utils.getAccountsByIdsFromSubs(orgMemSubs);

        System.debug('accounts' + accountsToUpdate);

        Map<Id, OrderApi__Subscription__c> orgMemSubsById = mapSubsById(orgMemSubs);
        Map<Id, OrderApi__Renewal__c> termsById = mapTermsById(termsToProcess);

        updateAccountFromOrgMemTerms(accountsToUpdate, orgMemSubs, orgMemSubsById, termsById, subsByTermId);
        System.debug('updated' + accountsToUpdate);

        return accountsToUpdate.values();
    }


    private void updateAccountFromOrgMemTerms(Map<Id, Account> accountsToUpdate,
            List<OrderApi__Subscription__c> orgMemSubs,
            Map<Id, OrderApi__Subscription__c> subsById,
            Map<Id, OrderApi__Renewal__c> termsById,
            Map<Id, Id> subIdsByTermIds) {

        Map<Id, String> items = new Map<Id, String>();
        Map<Id, String> item_classes = new Map<Id, String>();

        List<Id> itemsToProcess = new List<Id>();
        for (Id termIdToUse : subIdsByTermIds.keySet()) {
            OrderApi__Renewal__c termToUse = termsById.get(termIdToUse);
            Id subId = subIdsByTermIds.get(termIdToUse);

            itemsToProcess.add(termToUse.OrderApi__Item__c);

        }

        for (OrderApi__Item__c item : [select ID, Name,OrderApi__Item_Class__r.Name from OrderApi__Item__c where Id IN :itemsToProcess]) {

            items.put(item.Id, item.Name);
            item_classes.put(item.Id, item.OrderApi__Item_Class__r.Name);
        }

        for (Id termIdToUse : subIdsByTermIds.keySet()) {
            Id subId = subIdsByTermIds.get(termIdToUse);
            OrderApi__Renewal__c termToUse = termsById.get(termIdToUse);
            OrderApi__Subscription__c sub = subsById.get(subId);

            if (sub != null && sub.OrderApi__Account__c != null && accountsToUpdate.get(sub.OrderApi__Account__c) != null) {
                Account accountToUpdate = accountsToUpdate.get(sub.OrderApi__Account__c);
                if (sub.OrderApi__Entity__c == ACCOUNT_STRING && sub.OrderApi__Status__c == ACTIVE_STRING) {
                    if (accountToUpdate.FS_Original_Join_Date__c == null) {
                        System.debug('original join date:::::::::.');
                        // assign original join date here if necessary
                        accountToUpdate.FS_Original_Join_Date__c = sub.OrderApi__Activated_Date__c;

                    } else if (accountToUpdate.FS_Organization_Grace_Period_End_Date__c != null &&
                            termToUse.OrderApi__Term_Start_Date__c != null &&
                            accountToUpdate.FS_Organization_Grace_Period_End_Date__c < termToUse.OrderApi__Term_Start_Date__c) {
                        System.debug('re-original join date:::::::::.');
                        accountToUpdate.FS_Re_Join_Date__c = termToUse.OrderApi__Term_Start_Date__c;
                    }
                    if (termToUse.OrderApi__Grace_Period_End_Date__c != null &&
                            (accountToUpdate.FS_Organization_Grace_Period_End_Date__c == null ||
                                    accountToUpdate.FS_Organization_Grace_Period_End_Date__c < termToUse.OrderApi__Grace_Period_End_Date__c)) {
                        accountToUpdate.FS_Organization_Grace_Period_End_Date__c = termToUse.OrderApi__Grace_Period_End_Date__c;
                    }
                    if (accountToUpdate.FS_Organization_Paid_Through_Date__c == null ||
                            accountToUpdate.FS_Organization_Paid_Through_Date__c < termToUse.OrderApi__Term_End_Date__c) {
                        System.debug('paid-through date  date:::::::::.');
                        // assign paid through date after join and re-join date so it can be used for re-join date
                        accountToUpdate.FS_Organization_Paid_Through_Date__c = termToUse.OrderApi__Term_End_Date__c;
                    }

                    if (accountToUpdate.FS_Organization_Member_Type__c == null) {
                        accountToUpdate.FS_Organization_Member_Type__c = items.get(termToUse.OrderApi__Item__c);
                    }
                }
            }
        }
    }


    private static Map<String, OrderApi__Renewal__c> getTermsBySubAndSalesOrderIds(List<OrderApi__Renewal__c> termsToProcess) {
        Map<String, OrderApi__Renewal__c> termsBySubIds = new Map<String, OrderApi__Renewal__c>();
        for (OrderApi__Renewal__c term : termsToProcess) {
            termsBySubIds.put(term.OrderApi__Subscription__c + '' + term.OrderApi__Sales_Order__c, term);
        }
        return termsBySubIds;
    }

    private static Map<Id, Id> getSubsByTermId(List<OrderApi__Renewal__c> termsToProcess) {
        Map<Id, Id> subsByTermId = new Map<Id, Id>();
        for (OrderApi__Renewal__c term : termsToProcess) {
            subsByTermId.put(term.Id, term.OrderApi__Subscription__c);
        }
        return subsByTermId;
    }

    private static Map<Id, OrderApi__Subscription__c> mapSubsById(List<OrderApi__Subscription__c> subsToProcess) {
        Map<Id, OrderApi__Subscription__c> subsById = new Map<Id, OrderApi__Subscription__c>();
        for (OrderApi__Subscription__c sub : subsToProcess) {
            subsById.put(sub.Id, sub);
        }
        return subsById;
    }
    private static Map<Id, OrderApi__Renewal__c> mapTermsById(List<OrderApi__Renewal__c> termsToProcess) {
        Map<Id, OrderApi__Renewal__c> termsById = new Map<Id, OrderApi__Renewal__c>();
        for (OrderApi__Renewal__c term : termsToProcess) {
            termsById.put(term.Id, term);
        }
        return termsById;
    }
}