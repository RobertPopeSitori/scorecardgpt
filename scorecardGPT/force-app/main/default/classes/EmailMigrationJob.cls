global class EmailMigrationJob implements Database.Batchable<sObject>
{
	//Id batchJobId = Database.executeBatch(new EmailMigrationJob(), 200);
    global final String query;

	global EmailMigrationJob()
    {
		string soql = 'SELECT ActivityId__c, BccAddress__c, CcAddress__c, CreatedById__c, CreatedDate__c,';
		soql += '	EmailTemplateId__c, FirstOpenedDate__c, FromAddress__c, FromName__c, HasAttachment__c,';
		soql += '	Headers__c, HtmlBody__c, IsBounced__c, IsClientManaged__c, IsExternallyVisible__c,';
		soql += '	IsIncoming__c, IsOpened__c, IsPrivateDraft__c, IsTracked__c, LastModifiedBy__c,';
		soql += '	LastModifiedDate__c, LastOpenedDate__c, LegacyId__c, MessageDate__c, MessageIdentifier__c,';
		soql += '	Migrated__c, Parent__c, RelatedToId__c, ReplyToMessageId__c, Status__c,';
		soql += '	Subject__c, TextBody__c, ToAddress__c, ValidatedFromAddress__c ';
		soql += 'FROM Email_Message__c ';
		soql += 'WHERE (Migrated__c != true) ';

		query = soql;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		List<EmailMessage> emails = new List<EmailMessage>();
		List<Email_Message__c> items = new List<Email_Message__c>();

		Email_Message__c eml;
		Set<string> relatedIds = new Set<string>();
		Set<string> userIds = new Set<string>();
		Set<string> activityIds = new Set<string>();
		for(sObject item : scope)
		{
			eml = (Email_Message__c) item;

			if(String.isNotBlank(eml.ActivityId__c)) activityIds.add(eml.ActivityId__c);
			if(String.isNotBlank(eml.CreatedById__c)) userIds.add(eml.CreatedById__c);
			if(String.isNotBlank(eml.LastModifiedBy__c)) userIds.add(eml.LastModifiedBy__c);
			if(String.isNotBlank(eml.RelatedToId__c)) relatedIds.add(eml.RelatedToId__c);
		}

		Map<string, Id> relatedMap = new Map<string, Id>();
		List<SObject> relateds = [ SELECT Id, Legacy_Activity_Salesforce_ID__c FROM Event WHERE Legacy_Activity_Salesforce_ID__c IN :activityIds ];
		for(SObject obj : relateds)	{
			relatedMap.put(((Event)obj).Legacy_Activity_Salesforce_ID__c, ((Event)obj).Id);
		}

		relateds = [ SELECT Id, LegacyId__c FROM User WHERE LegacyId__c IN :userIds ];
		for(SObject obj : relateds)	{
			relatedMap.put(((User)obj).LegacyId__c, ((User)obj).Id);
		}

		relateds = [ SELECT Id, Legacy_Contact_Salesforce_ID__c FROM Contact WHERE Legacy_Contact_Salesforce_ID__c IN :relatedIds ];
		for(SObject obj : relateds){
			relatedMap.put(((Contact)obj).Legacy_Contact_Salesforce_ID__c, ((Contact)obj).Id);
		}

		relateds = [ SELECT Id, Legacy_Opportunity_Salesforce_ID__c FROM Opportunity WHERE Legacy_Opportunity_Salesforce_ID__c IN :relatedIds ];
		for(SObject obj : relateds){
			relatedMap.put(((Opportunity)obj).Legacy_Opportunity_Salesforce_ID__c, ((Opportunity)obj).Id);
		}

		relateds = [ SELECT Id, Legacy_Account_ID__c FROM Account WHERE Legacy_Account_ID__c IN :relatedIds ];
		for(SObject obj : relateds){
			relatedMap.put(((Account)obj).Legacy_Account_ID__c, ((Account)obj).Id);
		}

		Map<String, String> validateds = new Map<String, String>();
		List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = EmailMessage.ValidatedFromAddress.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple) {
			validateds.put(pickListVal.getLabel(), pickListVal.getLabel());
        }    

		for(sObject item : scope)
		{
			eml = (Email_Message__c) item;

			EmailMessage newEmail = new EmailMessage();
			newEmail.BccAddress = eml.BccAddress__c;
			newEmail.CcAddress = eml.CcAddress__c;
			newEmail.FirstOpenedDate = eml.FirstOpenedDate__c;
			newEmail.FromAddress = eml.FromAddress__c;
			newEmail.FromName = eml.FromName__c;
			newEmail.Headers = eml.Headers__c;
			newEmail.HtmlBody = eml.HtmlBody__c;
			newEmail.IsExternallyVisible = eml.IsExternallyVisible__c;
			newEmail.LastOpenedDate = eml.LastOpenedDate__c;
			newEmail.MessageDate = eml.MessageDate__c;
			newEmail.MessageIdentifier = eml.MessageIdentifier__c;
			newEmail.ParentId = eml.Parent__c;
			newEmail.Status = eml.Status__c;
			newEmail.Subject = eml.Subject__c;
			newEmail.TextBody = eml.TextBody__c;
			newEmail.ToAddress = eml.ToAddress__c;
			newEmail.LegacyId__c = eml.LegacyId__c;
			newEmail.CreatedDate = eml.CreatedDate__c;
			newEmail.LastModifiedDate = eml.LastModifiedDate__c;

			if(String.isNotBlank(eml.ValidatedFromAddress__c)){
				newEmail.ValidatedFromAddress = validateds.get(eml.ValidatedFromAddress__c);
			}

			string createdBy = relatedMap.get(eml.CreatedById__c);
			if(String.isNotBlank(createdBy)) newEmail.CreatedById = createdBy;

			string modifiedBy = relatedMap.get(eml.LastModifiedBy__c);
			if(String.isNotBlank(modifiedBy)) newEmail.LastModifiedById = modifiedBy;

			if(String.isNotBlank(eml.ActivityId__c)){
				string activity = relatedMap.get(eml.ActivityId__c);
				if(String.isNotBlank(activity)) newEmail.ActivityId = activity;
			}

			if(String.isNotBlank(eml.RelatedToId__c)){
				string relatedTo = relatedMap.get(eml.RelatedToId__c);
				if(String.isNotBlank(relatedTo)) newEmail.RelatedToId = relatedTo;
			}

			emails.add(newEmail);

			((Email_Message__c)item).Migrated__c = true;
			items.add((Email_Message__c)item);
		}
		
		if(emails.size() > 0) 
		{
			insert emails;
			update items;
		}	
	}

	global void finish(Database.BatchableContext BC){ }
}