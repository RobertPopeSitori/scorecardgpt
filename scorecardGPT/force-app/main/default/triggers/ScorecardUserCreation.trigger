trigger ScorecardUserCreation on Scorecard__c (after insert) {
    set<Id> communityUserId = new set<Id>();
    List<Scorecard_User__c> listscorecardUser = new List<Scorecard_User__c>();
    for(Scorecard__c sc:trigger.new){
        Scorecard_User__c scorecardUser = new Scorecard_User__c (Role__c ='Author',User__c = sc.createdById,
                                                                 Is_Active__c =true, Scorecard__c = sc.id);
        listscorecardUser.add(scorecardUser);
    }
    insert listscorecardUser;
}