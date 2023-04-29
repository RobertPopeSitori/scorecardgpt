/**
 * @author Christopher Mudd from fusionSpan
 * @date 06/17/19
 *
 * @description handles updating a Contact if they purchase a product w/ item class = Professional Membership
 */

global without sharing class FS_TermRoutingRule extends Framework.Domain {

    private static final String CONTACT_STRING = 'Contact';
    private static final String ACTIVE_STRING = 'Active';

    public FS_TermRoutingRule(List<OrderApi__Renewal__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_TermRoutingRule(sObjectList);
        }
    }

    global override void afterInsert() {
        Framework.Log.push(FS_TermRoutingRule.class.getName(), 'afterInsert');
        List<OrderApi__Renewal__c> termsToProcess = (List<OrderApi__Renewal__c>) records;
        List<Contact> updatedContacts = updateContactsFromTerms(termsToProcess);
        Database.update(updatedContacts, false);
        Framework.Log.pop();
    }


    global override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_TermRoutingRule.class.getName(), 'afterUpdate');
        List<OrderApi__Renewal__c> termsToProcess = (List<OrderApi__Renewal__c>) records;
        List<Contact> updatedContacts = updateContactsFromTerms(termsToProcess);
        Database.update(updatedContacts, false);
        Framework.Log.pop();
    }

    private List<Contact> updateContactsFromTerms(List<OrderApi__Renewal__c> termsToProcess) {

        Map<String, OrderApi__Renewal__c> termsBySubAndSalesOrderId = getTermsBySubAndSalesOrderIds(termsToProcess);
        System.debug('==== terms to process ==== ' + termsBySubAndSalesOrderId);

        Map<Id, Id> subsByTermId = getSubsByTermId(termsToProcess);
        System.debug(subsByTermId);

        List<OrderApi__Subscription__c> subsToProcess = FS_Utils.getSubsFromTerms(termsToProcess);
        System.debug('==== subs to process ==== ' + subsToProcess);

        List<OrderApi__Subscription__c> profMemSubs = FS_Utils.getProfMemSubs(subsToProcess);
        System.debug('==== prof mem subs to process ==== ' + profMemSubs);

        Map<Id, Contact> contactsToUpdate = FS_Utils.getContactsByIdsFromSubs(profMemSubs);
        System.debug('==== contacts to process ==== ' + contactsToUpdate);

        Map<Id, OrderApi__Subscription__c> profMemSubsById = mapSubsById(profMemSubs);
        Map<Id, OrderApi__Renewal__c> termsById = mapTermsById(termsToProcess);

        updateContactsFromProfMemTerms(contactsToUpdate, profMemSubs, profMemSubsById, termsById, subsByTermId);
        System.debug('==== should be updated now ==== ' + contactsToUpdate);

        return contactsToUpdate.values();
    }

    private void updateContactsFromProfMemTerms(Map<Id, Contact> contactsToUpdate,
            List<OrderApi__Subscription__c> profMemSubs,
//            Map<String, OrderApi__Renewal__c> termsBySubAndSalesOrderIds,
            Map<Id, OrderApi__Subscription__c> subsById,
            Map<Id, OrderApi__Renewal__c> termsById,
            Map<Id, Id> subIdsByTermIds) {
//        List<Contact> updatedContacts = new List<Contact>();
        for (Id termIdToUse : subIdsByTermIds.keySet()) {
            Id subId = subIdsByTermIds.get(termIdToUse);
            System.debug('subids by termids: ' + subIdsByTermIds);
            System.debug('termid to use: ' + termIdToUse);
            System.debug('subid' + subId);
            OrderApi__Renewal__c termToUse = termsById.get(termIdToUse);
            OrderApi__Subscription__c sub = subsById.get(subId);
            System.debug(sub);
            System.debug(termToUse);
            System.debug(contactsToUpdate);
            if (sub != null && sub.OrderApi__Contact__c != null && contactsToUpdate != null && contactsToUpdate.get(sub.OrderApi__Contact__c) != null) {
                Contact contactToUpdate = contactsToUpdate.get(sub.OrderApi__Contact__c);

                if (sub.OrderApi__Entity__c == CONTACT_STRING && sub.OrderApi__Status__c == ACTIVE_STRING) {
                    if (contactToUpdate.FS_Professional_Member_Join_Date__c == null) {
                        // assign original join date here if necessary
                        contactToUpdate.FS_Professional_Member_Join_Date__c = sub.OrderApi__Activated_Date__c;

                    } else if (contactToUpdate.FS_Professional_Member_Grace_End_Date__c != null &&
                            termToUse.OrderApi__Term_Start_Date__c != null &&
                            contactToUpdate.FS_Professional_Member_Grace_End_Date__c < termToUse.OrderApi__Term_Start_Date__c) {
                        // assign re-join date here
                        contactToUpdate.FS_Professional_Member_Re_Join_Date__c = termToUse.OrderApi__Term_Start_Date__c;

                    }
                    if (termToUse.OrderApi__Grace_Period_End_Date__c != null &&
                            (contactToUpdate.FS_Professional_Member_Grace_End_Date__c == null ||
                                    contactToUpdate.FS_Professional_Member_Grace_End_Date__c < termToUse.OrderApi__Grace_Period_End_Date__c)) {
                        contactToUpdate.FS_Professional_Member_Grace_End_Date__c = termToUse.OrderApi__Grace_Period_End_Date__c;
                    }
                    if (contactToUpdate.FS_Professional_Member_Paid_Through_Date__c == null ||
                            contactToUpdate.FS_Professional_Member_Paid_Through_Date__c < termToUse.OrderApi__Term_End_Date__c) {
                        // assign paid through date after join and re-join date so it can be used for re-join date
//                    if (termToUse.OrderApi__Renewed_Date__c != null) {
//                        contactToUpdate.FS_Professional_Member_Paid_Through_Date__c = termToUse.OrderApi__Renewed_Date__c;
//                    } else {
                        contactToUpdate.FS_Professional_Member_Paid_Through_Date__c = termToUse.OrderApi__Term_End_Date__c;
//                    }
                    }
                }
            }
//
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