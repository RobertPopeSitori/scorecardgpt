@IsTest
public class ScorecardCommentViewModelTest  
{
	public static testmethod void willInitialize()
	{
		ScorecardCommentViewModel model = new ScorecardCommentViewModel();

		Scorecard_Comment__c com = new Scorecard_Comment__c();
		model = new ScorecardCommentViewModel(com);

		List<Scorecard_Comment__c> coms = new List<Scorecard_Comment__c>();
		coms.add(com);

		List<ScorecardCommentViewModel> models = ScorecardCommentViewModel.toList(coms);
	}
}