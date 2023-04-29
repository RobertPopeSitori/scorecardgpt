public without sharing class AccountAddressHelper  
{
	public static void moveAddresses(List<SObject> allItems)
	{
		List<Id> oldAddressIds = new List<Id>();
		for(SObject item : allItems){
			oldAddressIds.add(item.Id);
		}

		List<Old_Address__c> addrs = [	SELECT Id, BillingCity__c, BillingCountry__c, BillingPostalCode__c, BillingState__c,
											BillingStreet__c, HasErrors__c, LegacyId__c, Migrated__c, ShippingCity__c, ShippingCountry__c,
											ShippingPostalCode__c, ShippingState__c, ShippingStreet__c 
										FROM Old_Address__c
										WHERE Id IN :oldAddressIds ];

		if(addrs.size() == 0) return;

		Map<String, List<String>> countryStatesMap = PicklistHelper.getFieldDependencies('Account', 'BillingCountryCode', 'BillingStateCode');
		List<string> stateFullNames = new List<string>{'Alabama', 'Alaska', 'American Samoa', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Guam', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Minor Outlying Islands', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Northern Mariana Islands', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Puerto Rico', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'U.S. Virgin Islands', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'};
		List<string> stateAbbrevs = new List<string>{'AK', 'AL', 'AR', 'AS', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'GU', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MP', 'MS', 'MT', 'NC', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UM', 'UT', 'VA', 'VI', 'VT', 'WA', 'WI', 'WV', 'WY'};
		
		Map<String, string> stateFullMap = new Map<String, string>();
		Map<String, string> stateAbbrevMap = new Map<String, string>();
		for(integer x = 0; x < stateFullNames.size(); x++){
			stateFullMap.put(stateFullNames[x], stateAbbrevs[x]);
			stateAbbrevMap.put(stateAbbrevs[x], stateFullNames[x]);
		}

		List<Id> accountIds = new List<Id>();

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

		for(Old_Address__c obj : addrs)
		{
			if(String.isNotBlank(obj.LegacyId__c)) accountIds.add(obj.LegacyId__c);
		}

		if(accountIds.size() == 0) return;

		List<Account> accts = [ SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, OldAddress__c,
									ShippingStreet, ShippingCity, ShippingState, ShippingPostalcode, ShippingCountry, 
									Legacy_Account_ID__c, NeedsAddressCheck__c
								FROM Account 
								WHERE Legacy_Account_ID__c IN :accountIds ];

		System.debug('***LEGACY-IDS:' + accountIds);
		System.debug('***ACCTS:' + accts);


		Map<String, Account> accountMap = new Map<String, Account>();
		for(Account item : accts)
		{
			accountMap.put(item.Legacy_Account_ID__c, item);
		}

		Account acct;
		string country;
		string state;
		boolean needsUpdate = false;
		Map<Id, Account> acctsForUpdate = new Map<Id, Account>();
		List<string> validStates;

		for(Old_Address__c addr : addrs)
		{
			needsUpdate = false;
			addr.Migrated__c = true;
			acct = accountMap.get(addr.LegacyId__c);
			if(acct != null)
			{
				try 
				{
					acct.OldAddress__c = addr.Id;
					if(String.isNotBlank(addr.BillingCountry__c))
					{
						country = null;
						state = null;

						if(addr.BillingCountry__c == 'US' || addr.BillingCountry__c == 'USA' || addr.BillingCountry__c == 'United States') country = 'United States';
						if(addr.BillingCountry__c == 'CA') country = 'Canada';

						if(countryStatesMap.keySet().contains(country))
						{
							acct.BillingCountry = country;
							if(String.isNotBlank(addr.BillingState__c))
							{
								state = addr.BillingState__c;
								if(addr.BillingState__c.length() == 2) state = stateAbbrevMap.get(addr.BillingState__c);

								validStates = countryStatesMap.get(country);
								if(validStates != null && validStates.size() > 0){
									if(validStates.contains(state)) acct.BillingState = state;
								}

								if(String.isNotBlank(addr.BillingState__c) && String.isBlank(state)) acct.NeedsAddressCheck__c = true;
							}
						}
						else acct.NeedsAddressCheck__c = true;
					}

					acct.BillingStreet = addr.BillingStreet__c;
					acct.BillingCity = addr.BillingCity__c;
					acct.BillingPostalCode = addr.BillingPostalCode__c;

					if(String.isNotBlank(addr.ShippingCountry__c))
					{
						country = null;
						state = null;

						if(addr.ShippingCountry__c == 'US' || addr.ShippingCountry__c == 'USA' || addr.ShippingCountry__c == 'United States') country = 'United States';
						if(addr.ShippingCountry__c == 'CA') country = 'Canada';

						if(countryStatesMap.keySet().contains(country))
						{
							acct.ShippingCountry = country;
							if(String.isNotBlank(addr.ShippingState__c))
							{
								state = addr.ShippingState__c;
								if(addr.ShippingState__c.length() == 2) state = stateAbbrevMap.get(addr.ShippingState__c);

								validStates = countryStatesMap.get(country);
								if(validStates != null && validStates.size() > 0){
									if(validStates.contains(state)) acct.ShippingState = state;
								}

								if(String.isNotBlank(addr.ShippingState__c) && String.isBlank(state)) acct.NeedsAddressCheck__c = true;
							}
						}
						else acct.NeedsAddressCheck__c = true;
					}

					acct.BillingStreet = addr.BillingStreet__c;
					acct.BillingCity = addr.BillingCity__c;
					acct.BillingPostalCode = addr.BillingPostalCode__c;
				}
				catch(Exception ex)
				{
				}

				acctsForUpdate.put(acct.Id, acct);
			}
		}

		update addrs;
		if(acctsForUpdate.size() > 0) update acctsForUpdate.values();
	}
}