@IsTest
public class ScorecardQuestionViewModelTest  
{
	public static testmethod void willInitialize()
	{
		ScorecardQuestionViewModel model = new ScorecardQuestionViewModel();

		Scorecard_Question__c question = new Scorecard_Question__c();
		
		Scorecard_Role__mdt permission = new Scorecard_Role__mdt();
		permission.DeveloperName = 'Observer';
		permission.Answer_Question__c = true;
        permission.Review_Question__c = true;
        permission.Review_Question_Final__c = true;

		List<Scorecard_Review__c> reviews = new List<Scorecard_Review__c>();
		Scorecard_Review__c rev1 = new Scorecard_Review__c();
		rev1.Type__c = 'Answer';
		reviews.add(rev1);

		Scorecard_Review__c rev2 = new Scorecard_Review__c();
		rev2.Type__c = 'Review';
		reviews.add(rev2);

		Scorecard_Review__c rev3 = new Scorecard_Review__c();
		rev3.Type__c = 'Final Review';
		reviews.add(rev3);

		model = new ScorecardQuestionViewModel(question, permission, reviews);

		permission.DeveloperName = 'Reviewer';
		model = new ScorecardQuestionViewModel(question, permission, reviews);

		permission.DeveloperName = 'Lead_Reviewer';
		model = new ScorecardQuestionViewModel(question, permission, reviews);
	}
}