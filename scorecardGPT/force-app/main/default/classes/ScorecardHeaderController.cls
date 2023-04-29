public without sharing class ScorecardHeaderController  
{
    @AuraEnabled
    public static string getScorecardSummary(string scorecardId)
    {
		AuraResponse response = new AuraResponse();

        ScorecardHelper.ScorecardDetail model = ScorecardHelper.getScorecard(scorecardId);
		if(model == null) response.success = false;
		else {
			response.success = true;
			response.model = model;
		}

        return JSON.serialize(response);
    }
}