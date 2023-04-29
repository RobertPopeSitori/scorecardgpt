@IsTest
public class EmailMigrationJobTest  
{
	@TestSetup
	public static void setup()
	{
		List<Email_Message__c> emails = new List<Email_Message__c>();
		for(integer x = 0; x < 10; x++)
		{
			Email_Message__c eml = new Email_Message__c();
			eml.ActivityId__c = '00T1a00000er' + x + 'xBEAQ';
			eml.BccAddress__c = 'bcc00' + x + '@onlinelearning-c.org';
			eml.CcAddress__c = 'cc00' + x + '@onlinelearning-c.org';
			eml.FirstOpenedDate__c = Datetime.now().addDays(-1 * x);
			eml.FromAddress__c = 'from00' + x + '@onlinelearning-c.org';
			eml.FromName__c = 'Auto Test00' + x;
			eml.Headers__c = 'HEADERS 000' + x;
			eml.HtmlBody__c = '<B>Html</B>';
			eml.IsExternallyVisible__c = true;
			eml.LastOpenedDate__c = Datetime.now();
			eml.MessageDate__c = Datetime.now().addDays(20 * x);
			eml.MessageIdentifier__c = '02s1a00000er' + x + 'xBEAQ';
			eml.Status__c = '';
			eml.Subject__c = 'Membership Reminder 00' + x;
			eml.TextBody__c = 'Txt Body 00' + x;
			eml.ToAddress__c = 'to00' + x + '@onlinelearning-c.org';
			eml.LegacyId__c = '02s1a00000er' + x + 'xBEAQ';
			eml.Migrated__c = false;

			emails.add(eml);
		}
		insert emails;
	}

	public static testmethod void willMigrateEmailMessage()
	{
		Test.startTest();
		
		List<SObject> lst = [	SELECT ActivityId__c, BccAddress__c, CcAddress__c, CreatedById__c, CreatedDate__c,
									EmailTemplateId__c, FirstOpenedDate__c, FromAddress__c, FromName__c, HasAttachment__c,
									Headers__c, HtmlBody__c, IsBounced__c, IsClientManaged__c, IsExternallyVisible__c,
									IsIncoming__c, IsOpened__c, IsPrivateDraft__c, IsTracked__c, LastModifiedBy__c,
									LastModifiedDate__c, LastOpenedDate__c, LegacyId__c, MessageDate__c, MessageIdentifier__c,
									Migrated__c, Parent__c, RelatedToId__c, ReplyToMessageId__c, Status__c,
									Subject__c, TextBody__c, ToAddress__c, ValidatedFromAddress__c 
								FROM Email_Message__c 
								WHERE (Migrated__c != true) ];

		System.debug('***LIST:' + lst);

		EmailMigrationJob job = new EmailMigrationJob();
		job.start(null);
		job.execute(null, lst);
		job.finish(null);

		Test.stopTest();

		List<EmailMessage> msgs = [ SELECT Id, LegacyId__c FROM EmailMessage ];
		System.assertEquals(10, msgs.size(), 'There should have been 10 EmailMessages.');
	}


}