@IsTest
public class ScorecardUserTriggerHandlerTest  
{
	public static testmethod void willAllowInsert()
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


        Account acct = TestHelperAccount.insertAccount('My Test Account');

        Scorecard__c scorecard = new Scorecard__c();
        scorecard.Template__c = template.Id;
        scorecard.Organization__c = acct.Id;
        scorecard.Status__c = 'In Progress';
        scorecard.Viewable_Report__c = true;
        scorecard.Title__c = 'My First Scorecard';
        insert scorecard;

		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = UserInfo.getUserId();
		scUser.Role__c = 'Author';
		scUser.Scorecard__c = scorecard.Id;
		insert scUser;

        Test.stopTest();

		List<Scorecard_User__c> scUsers = [ SELECT Id, Role__c, User__c 
											FROM Scorecard_User__c  ];

        System.assertEquals(1, scUsers.size(), 'There needs to be 1 scorecard user.');
    }

	public static testmethod void willNoAllowMultipleRecords()
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


        Account acct = TestHelperAccount.insertAccount('My Test Account');

        Scorecard__c scorecard = new Scorecard__c();
        scorecard.Template__c = template.Id;
        scorecard.Organization__c = acct.Id;
        scorecard.Status__c = 'In Progress';
        scorecard.Viewable_Report__c = true;
        scorecard.Title__c = 'My First Scorecard';
        insert scorecard;

		Scorecard_User__c scUser1 = new Scorecard_User__c();
		scUser1.User__c = UserInfo.getUserId();
		scUser1.Role__c = 'Author';
		scUser1.Scorecard__c = scorecard.Id;
		insert scUser1;

        Test.stopTest();

		boolean errorThrown = false;

		try 
		{
			Scorecard_User__c scUser2 = new Scorecard_User__c();
			scUser2.User__c = UserInfo.getUserId();
			scUser2.Role__c = 'Author';
			scUser2.Scorecard__c = scorecard.Id;
			insert scUser2;
		}
		catch(Exception es)
		{
			errorThrown = true;
		}

        System.assertEquals(true, errorThrown, 'Error should have been thrown.');
    }

	public static testmethod void willNotAllowUpdates()
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

        Account acct = TestHelperAccount.insertAccount('My Test Account');

        Scorecard__c scorecard = new Scorecard__c();
        scorecard.Template__c = template.Id;
        scorecard.Organization__c = acct.Id;
        scorecard.Status__c = 'In Progress';
        scorecard.Viewable_Report__c = true;
        scorecard.Title__c = 'My First Scorecard';
        insert scorecard;

		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = UserInfo.getUserId();
		scUser.Role__c = 'Author';
		scUser.Scorecard__c = scorecard.Id;
		scUser.Is_Active__c = true;
		insert scUser;

        Test.stopTest();

		boolean errorThrown = false;

		try 
		{
			scUser.Role__c = 'Co-Author';
			update scUser;
		}
		catch(Exception es)
		{
			errorThrown = true;
		}

        System.assertEquals(true, errorThrown, 'Error should have been thrown.');
		errorThrown = false;
		scUser = getScorecardUser(scUser.Id);

		try 
		{
			scUser.Scorecard__c = null;
			update scUser;
		}
		catch(Exception es)
		{
			errorThrown = true;
		}

        System.assertEquals(true, errorThrown, 'Error should have been thrown.');
		errorThrown = false;
		scUser = getScorecardUser(scUser.Id);

		try 
		{
			scUser.User__c = null;
			update scUser;
		}
		catch(Exception es)
		{
			errorThrown = true;
		}

        System.assertEquals(true, errorThrown, 'Error should have been thrown.');
		errorThrown = false;
		scUser = getScorecardUser(scUser.Id);

		try 
		{
			scUser.Is_Active__c = false;
			update scUser;
		}
		catch(Exception es)
		{
			errorThrown = true;
		}

        System.assertEquals(false, errorThrown, 'Update should have gone through.');
		errorThrown = false;

		try 
		{
			delete scUser;
		}
		catch(Exception es)
		{
			errorThrown = true;
		}

        System.assertEquals(true, errorThrown, 'Deleting a scorecard user record should have thrown an error.');
	}

	public static Scorecard_User__c getScorecardUser(Id scId)
	{
		return [ SELECT Id, User__c, Role__c, Scorecard__c, Is_Active__c FROM Scorecard_User__c WHERE Id = :scId LIMIT 1];
	}
}