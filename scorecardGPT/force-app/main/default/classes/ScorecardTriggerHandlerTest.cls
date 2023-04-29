@IsTest
public class ScorecardTriggerHandlerTest  
{
    public static testmethod void willApplyTemplateOnInsert()
    {
        Test.startTest(); 

        Scorecard_Template__c template = new Scorecard_Template__c();
        template.Availability__c = 'Free';
        template.Description__c = 'Template Description';
        template.Language__c = 'English';
        template.Name = 'My Test Template';
        template.Legacy_Id__c = 100;
        template.Status__c = 'Published';
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
        question1.Template_Section__c = section1.Id;
        question1.Description__c = 'Test Questionnaire 1';
        question1.Max_Score__c = 3;
        question1.Order__c = 1;
        question1.Question__c = 'What is the first question?';
	   question1.Title__c = 'What is the first question?';
        questions.add(question1);

        Scorecard_Template_Question__c question2 = new Scorecard_Template_Question__c();
        question2.Template_Section__c = section2.Id;
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


        Account acct = TestHelperAccount.insertAccount('Test Account');

        Scorecard__c scorecard = new Scorecard__c();
        scorecard.Template__c = template.Id;
        scorecard.Organization__c = acct.Id;
        scorecard.Status__c = 'In Progress';
        scorecard.Viewable_Report__c = true;
        scorecard.Title__c = 'My First Scorecard';
        insert scorecard;

        Test.stopTest();

        ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecard.Id);
        System.assert(detail.Scorecard != null, 'The scorecard should have been retrieved.');
        System.assertEquals(2, detail.Sections.size(), 'The scorecard should have 1 section.');
        System.assertEquals(2, detail.Questions.size(), 'The scorecard should have 2 questions.');
        System.assertEquals(3, detail.Rubrics.size(), 'The scorecard should have 3 rubrics.');
    }
}