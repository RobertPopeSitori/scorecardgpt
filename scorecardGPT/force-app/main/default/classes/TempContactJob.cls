global class TempContactJob implements Database.Batchable<sObject>
{
	//Id batchJobId = Database.executeBatch(new TempContactJob(), 200);
    global final String query;

	global TempContactJob()
    {
		string soql = 'SELECT Id, AccountId__c, Email__c, FirstName__c, LastName__c,';
		soql += ' LegacyId__c, MailingCity__c, MailingCountry__c, MailingPostalCode__c, MailingState__c,'; 
		soql += ' MailingStreet__c, OtherCity__c, OtherCountry__c, OtherPhone__c, ';
		soql += ' OtherPostalCode__c, OtherState__c, OtherStreet__c, Phone__c, Processed__c, Title__c ';
		soql += 'FROM TempContact__c ';
		soql += 'WHERE (Processed__c != true) ';

		query = soql;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
        if(scope.size() == 0) return;
   		Map<String, List<String>> countryStatesMap = PicklistHelper.getFieldDependencies('Account', 'BillingCountryCode', 'BillingStateCode');
		List<string> stateFullNames = new List<string>{'Alabama', 'Alaska', 'American Samoa', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Guam', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Minor Outlying Islands', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Northern Mariana Islands', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Puerto Rico', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'U.S. Virgin Islands', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'};
		List<string> stateAbbrevs = new List<string>{'AK', 'AL', 'AR', 'AS', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'GU', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MP', 'MS', 'MT', 'NC', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UM', 'UT', 'VA', 'VI', 'VT', 'WA', 'WI', 'WV', 'WY'};
        Map<String, string> stateFullMap = new Map<String, string>();
		Map<String, string> stateAbbrevMap = new Map<String, string>();
		for(integer x = 0; x < stateFullNames.size(); x++){
			stateFullMap.put(stateFullNames[x], stateAbbrevs[x]);
			stateAbbrevMap.put(stateAbbrevs[x], stateFullNames[x]);
		}
        
        Map<String, String> countryMap = new Map<String, String>();
		List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.BillingCountryCode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple) {
			countryMap.put(pickListVal.getLabel(), pickListVal.getLabel());
        } 

		Map<String, String> stateMap = new Map<String, String>();
		pickListValuesList = new List<String>();
        fieldResult = Account.BillingStateCode.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple) {
			stateMap.put(pickListVal.getLabel(), pickListVal.getLabel());
        } 

		List<string> legacyIds = new List<string>();
        List<string> accountIds = new List<string>();
		List<string> validStates;
		TempContact__c tempContact;

		for(SObject obj : scope)
		{
			tempContact = (TempContact__c)obj;
			if(String.isNotBlank(tempContact.LegacyId__c)) legacyIds.add(tempContact.LegacyId__c);
            if(String.isNotBlank(tempContact.AccountId__c)) accountIds.add(tempContact.AccountId__c);
		}

		List<Contact> cons = [	SELECT Id, AccountId, Email, FirstName, LastName, Phone, 
									MailingCity, MailingCountry, MailingState, MailingStreet, MailingPostalCode,
									OtherPhone, OtherStreet, OtherCity, OtherState, OtherCountry, OtherPostalCode,
									Legacy_Contact_Salesforce_ID__c, NeedsAddressCheck__c 
								FROM Contact 
								WHERE Legacy_Contact_Salesforce_ID__c  IN :legacyIds ];
        
		Map<String, Contact> conMap = new Map<String, Contact>();
		for(Contact con : cons)
		{
			conMap.put(con.Legacy_Contact_Salesforce_ID__c, con);
		}

        List<Account> accts = [	SELECT Id, Legacy_Account_ID__c FROM Account 
                              	WHERE Legacy_Account_ID__c IN :accountIds ];
        
        Map<String, Id> acctMap = new Map<String, Id>();
        for(Account acct : accts){
            acctMap.put(acct.Legacy_Account_ID__c, acct.Id);            
        }
        
		List<TempContact__c> tempContacts = new List<TempContact__c>();
		List<Contact> consForUpsert = new List<Contact>();

		Contact currentContact;
        string country;
        string state;
        
		for(SObject obj : scope)
		{
            country = null;
            state = null;
			tempContact = (TempContact__c)obj;
			currentContact = conMap.get(tempContact.LegacyId__c);
            if(currentContact == null){
               	currentContact = new Contact();
            }
            
            boolean isNew = false;
            if(string.isNotBlank(tempContact.AccountId__c)) {
                currentContact.AccountId = acctMap.get(tempContact.AccountId__c);                
                isNew = true;
            }
            
            if(string.isBlank(tempContact.LastName__c) && isNew) continue;
            
            currentContact.Email = tempContact.Email__c;
            currentContact.LastName = string.isBlank(tempContact.LastName__c) ? currentContact.LastName : tempContact.LastName__c;
            currentContact.FirstName = tempContact.FirstName__c;
            currentContact.Legacy_Contact_Salesforce_ID__c = tempContact.LegacyId__c;
            
            if(string.isNotBlank(tempContact.MailingCountry__c))
            {
                country = tempContact.MailingCountry__c;
                if(tempContact.MailingCountry__c == 'US' || tempContact.MailingCountry__c == 'USA' || tempContact.MailingCountry__c == 'United States') country = 'United States';
                if(tempContact.MailingCountry__c == 'CA') country = 'Canada';
                
                if(countryStatesMap.keySet().contains(country))
                {
                    currentContact.MailingCountry = country;
                    if(String.isNotBlank(tempContact.MailingState__c))
                    {
                        state = tempContact.MailingState__c;
                        if(tempContact.MailingState__c.length() == 2) state = stateAbbrevMap.get(tempContact.MailingState__c);
                        
                        validStates = countryStatesMap.get(country);
                        if(validStates != null && validStates.size() > 0){
                            if(validStates.contains(state)) currentContact.MailingState = state;
                        }
                        
                        if(String.isNotBlank(tempContact.MailingState__c) && String.isBlank(state)) currentContact.NeedsAddressCheck__c = true;
                    }
                }
                else currentContact.NeedsAddressCheck__c = true;
            }
            
            currentContact.MailingStreet = tempContact.MailingStreet__c;
            currentContact.MailingCity = tempContact.MailingCity__c;
            currentContact.MailingPostalCode = tempContact.MailingPostalCode__c;
            
            if(string.isNotBlank(tempContact.OtherCountry__c))
            {
                state = null;
                country = tempContact.OtherCountry__c;
                if(tempContact.OtherCountry__c == 'US' || tempContact.OtherCountry__c == 'USA' || tempContact.OtherCountry__c == 'United States') country = 'United States';
                if(tempContact.OtherCountry__c == 'CA') country = 'Canada';
                
                if(countryStatesMap.keySet().contains(country))
                {
                    currentContact.OtherCountry = country;
                    if(String.isNotBlank(tempContact.OtherState__c))
                    {
                        state = tempContact.OtherState__c;
                        if(tempContact.OtherState__c.length() == 2) state = stateAbbrevMap.get(tempContact.OtherState__c);
                        
                        validStates = countryStatesMap.get(country);
                        if(validStates != null && validStates.size() > 0){
                            if(validStates.contains(state)) currentContact.OtherState = state;
                        }
                        
                        if(String.isNotBlank(tempContact.OtherState__c) && String.isBlank(state)) currentContact.NeedsAddressCheck__c = true;
                    }
                }
                else currentContact.NeedsAddressCheck__c = true;
            }
            
            currentContact.OtherStreet = tempContact.OtherStreet__c;
            currentContact.OtherCity = tempContact.OtherCity__c;
            currentContact.OtherPostalCode = tempContact.OtherPostalCode__c;
			currentContact.Phone = tempContact.Phone__c;
            currentContact.OtherPhone = tempContact.OtherPhone__c;
            consForUpsert.add(currentContact);
            
			tempContact.Processed__c = true;
			tempContacts.add(tempContact);
		}

		if(tempContacts.size() > 0) update tempContacts;
		if(consForUpsert.size() > 0) upsert consForUpsert;
	}

	global void finish(Database.BatchableContext BC){ }

}