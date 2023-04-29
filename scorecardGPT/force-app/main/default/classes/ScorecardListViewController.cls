public without sharing class ScorecardListViewController 
{
    @AuraEnabled
    public static string getScorecards()
    {
        List<Scorecard__c> scorecards = ScorecardHelper.getUserScorecards(UserInfo.getUserId());
        System.debug('SCORECARDS SIZE '+scorecards.Size());
        List<Id> scorecardIds = new List<Id>();

        for(Scorecard__c scorecard : scorecards){
            scorecardIds.add(scorecard.Id);
        }

        List<Scorecard_User__c> scUsers = ScorecardHelper.getScorecardUsers(scorecardIds);
        System.debug('SCORECARDS USERS SIZE '+scUsers.Size());
        List<ScorecardViewModel> models = new List<ScorecardViewModel>();
        if(scorecards.size() > 0)
        {
            for(Scorecard__c scorecard : scorecards)
            {
                models.add(new ScorecardViewModel(scorecard, scUsers));
            }
        }
         System.debug('Models : '+models);
        return JSON.serialize(models);
    }
}