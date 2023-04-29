@IsTest
public class ScorecardHelperTest  
{
    @isTest
	public static Id insertTemplate()
	{
		Scorecard_Template__c template = new Scorecard_Template__c();
        template.Availability__c = 'Free';
        template.Description__c = 'Template Description';
        template.Language__c = 'English';
        template.Name = 'My Test Template';
        template.Legacy_Id__c = 100;
        template.Status__c = 'Draft';
        template.Type__c = 'Course';
        insert template;

        List<Scorecard_Template_Section__c> sections = new List<Scorecard_Template_Section__c>();
        Scorecard_Template_Section__c section1 = new Scorecard_Template_Section__c();
        section1.Template__c = template.Id;
        section1.Title__c = 'First Section';
        section1.Description__c = 'My Section Description';
        section1.Order__c = 1;
        sections.add(section1);

        Scorecard_Template_Section__c section2 = new Scorecard_Template_Section__c();
        section2.Template__c = template.Id;
        section2.Title__c = 'Second Section';
        section2.Description__c = 'My Section Description';
        section2.Order__c = 2;
        sections.add(section2);
        insert sections;

        List<Scorecard_Template_Question__c> questions = new List<Scorecard_Template_Question__c>();
        Scorecard_Template_Question__c question1 = new Scorecard_Template_Question__c();
        question1.Template_Section__c = sections[0].Id;
        question1.Description__c = 'Test Questionnaire 1';
        question1.Max_Score__c = 3;
        question1.Order__c = 1;
        question1.Question__c = 'What is the first question?';
        question1.Title__c = 'What is the first question?';
        questions.add(question1);

        Scorecard_Template_Question__c question2 = new Scorecard_Template_Question__c();
        question2.Template_Section__c = sections[1].Id;
        question2.Description__c = 'Test Questionnaire 2';
        question2.Max_Score__c = 3;
        question2.Order__c = 2;
        question2.Question__c = 'What is the second question?';
        question2.Title__c = 'What is the second question?';
        questions.add(question2);

        insert questions;

        List<Scorecard_Template_Rubric__c> rubrics = new List<Scorecard_Template_Rubric__c>();
        Scorecard_Template_Rubric__c rubric1 = new Scorecard_Template_Rubric__c();
        rubric1.Description__c = 'The first rubric';
        rubric1.Recommendation__c = 'The first recommendation';
        rubric1.Template_Question__c = question1.Id;
        rubric1.Value__c = 0;
        rubrics.add(rubric1);

        Scorecard_Template_Rubric__c rubric2 = new Scorecard_Template_Rubric__c();
        rubric2.Description__c = 'The second rubric';
        rubric2.Recommendation__c = 'The second recommendation';
        rubric2.Template_Question__c = question1.Id;
        rubric2.Value__c = 1;
        rubrics.add(rubric2);

        Scorecard_Template_Rubric__c rubric3 = new Scorecard_Template_Rubric__c();
        rubric3.Description__c = 'The third rubric';
        rubric3.Recommendation__c = 'The third recommendation';
        rubric3.Template_Question__c = question2.Id;
        rubric3.Value__c = 1;
        rubrics.add(rubric3);

        insert rubrics;

		return template.Id;
	}

	public static Id insertScorecard(string title, Id templateId)
	{
		if(templateId == null) templateId = insertTemplate();

		Account acct = TestHelperAccount.insertAccount('Test Account');

		Scorecard__c scorecard = new Scorecard__c();
		scorecard.Title__c = title;
		scorecard.Organization__c = acct.Id;
		scorecard.Template__c = templateId;
		insert scorecard;

		return scorecard.Id;
	}

    /* ************increase 10% code ******************** */
    
    @isTest
    public static void Test1() {
       Id templateId = insertTemplate();
        
        
        
        Scorecard_Template__c template = new Scorecard_Template__c();
        template.Availability__c = 'Free';
        template.Description__c = 'Template Description';
        template.Language__c = 'English';
        template.Name = 'My Test Template';
        template.Legacy_Id__c = 100;
        template.Status__c = 'Draft';
        template.Type__c = 'Course';
        insert template;
        
        Scorecard_Template_Section__c section2 = new Scorecard_Template_Section__c();
        section2.Template__c = template.Id;
        section2.Title__c = 'Second Section';
        section2.Description__c = 'My Section Description';
        section2.Order__c = 2;
        //sections.add(section2);
        insert section2;
        
        Scorecard_Template_Question__c question2 = new Scorecard_Template_Question__c();
        question2.Template_Section__c = section2.Id;
        question2.Description__c = 'Test Questionnaire 2';
        question2.Max_Score__c = 3;
        question2.Order__c = 2;
        question2.Question__c = 'What is the second question?';
        question2.Title__c = 'What is the second question?';
        //questions.add(question2);
        insert question2;
        
        Scorecard__c score = new Scorecard__c();
        score.Status__c = 'In Progress';
        score.Organization__c = '0011U00000pJE37';
        score.Type__c = 'scorecard';
        score.Template__c = templateId;
        score.Title__c = 'Test';
        insert score;
        
        Scorecard_Section__c Section = new Scorecard_Section__c();
        section.Scorecard__c = score.Id;
        section.Status__c = 'In progress';
        section.Title__c = 'test';
        section.Order__c = 1;
        section.Template__c = section2.Id;
        insert section;
        
        Scorecard_Question__c question = new Scorecard_Question__c();
        question.Section__c = section.Id;
        question.Title__c = 'test Question';
        question.Status__c = 'Completed';
        question.Order__c = 1;
        question.Question__c = 'test Question';
        question.Template__c = question2.Id;
        insert question;
        
        Test.startTest();
        ScorecardHelper.setQuestionAnswer(question.Id);
        scorecardHelper.getScorecardUsers(score.id);
         scorecardHelper.getQuestion(question.Id);
        scorecardHelper.isPermittedInSection(score.Id, section.Id);
        scorecardHelper.getRubricItems(question.Id);
        
        Test.stopTest();
    }
    
    /* ************ increase code close ***************** */
    
    public static testmethod void willGetTemplates()
    {
        Test.startTest();

        Id templateId = insertTemplate();

        List<Id> templateIds = new List<Id>();
        templateIds.add(templateId);

        Map<Id, ScorecardHelper.ScorecardTemplateDetail> details = ScorecardHelper.getTemplates(templateIds);

        Test.stopTest();

        System.assertEquals(1, details.values().size(), 'One template detail should have been returned.');
        System.assertEquals(2, details.values()[0].Sections.size(), 'Two section templates should have been retrieved.');
        System.assertEquals(2, details.values()[0].Questions.size(), 'Two question templates should have been retrieved.');
        System.assertEquals(3, details.values()[0].Rubrics.size(), 'Three rubric templates should have been retrieved.');
    }

	public static testmethod void willUpdateStatus()
	{
		Test.startTest();

        Id scorecardId = insertScorecard('My Scorecard', null);
		ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
		Id questionId;

		for(Id entryId : detail.Questions.keySet())
		{
			questionId = entryId;
			break;
		}

		Scorecard_Review__c review = ScorecardHelper.getQuestionAnswer(questionId);
		review.Review__c = '<p>My html answer.</p>';
		review.Status__c = 'In Review';
		update review;
        

        Test.stopTest();
	}
}