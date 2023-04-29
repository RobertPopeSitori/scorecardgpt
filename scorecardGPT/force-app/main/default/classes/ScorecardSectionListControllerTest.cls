@IsTest
public class ScorecardSectionListControllerTest 
{
    public static testmethod void willGetScorecardSection()
    {
        Id scorecardId = ScorecardHelperTest.insertScorecard('My Scorecard', null);
        ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);

        Id sectionId;
        for(Id sId : detail.Sections.keySet()){
            sectionId = sId;
            break;
        }

        Id questionId;
        for(Id qId : detail.Questions.keySet()){
            questionId = qId;
            break;
        }

        string result = ScorecardSectionListController.getSectionList(scorecardId, sectionId, questionId);
        ScorecardSectionListController.getscorecard(scorecardId);
        System.assert(string.isNotBlank(result));
    }
}