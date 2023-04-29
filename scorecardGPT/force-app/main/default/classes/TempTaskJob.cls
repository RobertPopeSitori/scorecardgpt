global class TempTaskJob implements Database.Batchable<sObject>
{
	//Id batchJobId = Database.executeBatch(new TempTaskJob(), 200);
    global final String query;

	global TempTaskJob()
    {
		string soql = 'SELECT Id, CallNumberInSeconds__c, CallObject__c, CallType__c, Description__c,';
		soql += ' IsReminderSet__c, IsVisibleSelfService__c, LegacyId__c, Priority__c, Processed__c,'; 
		soql += ' RecurrenceDayOfMonth__c, RecurrenceDayOfWeek__c, RecurrenceInterval__c, RecurrenceTimeZone__c, ';
		soql += ' ReminderDateTime__c, Status__c, Subject__c, Type__c, ActivityDate__c ';
		soql += 'FROM TempTask__c ';
		soql += 'WHERE (Processed__c != true) ';

		query = soql;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		List<string> legacyIds = new List<string>();
		TempTask__c tempTask;

		for(SObject obj : scope)
		{
			tempTask = (TempTask__c)obj;
			if(String.isNotBlank(tempTask.LegacyId__c)) legacyIds.add(tempTask.LegacyId__c);
		}

		List<Task> tasks = [	SELECT Id, ActivityDate, CallDurationInSeconds, CallObject, CallType, Description,
									IsReminderSet, IsVisibleInSelfService, Priority, RecurrenceDayOfMonth, RecurrenceDayOfWeekMask,
									RecurrenceInterval, RecurrenceTimeZoneSidKey, ReminderDateTime, Status, Subject, Type,
									Legacy_Activity_Salesforce_ID__c
								FROM Task 
								WHERE Legacy_Activity_Salesforce_ID__c IN :legacyIds ];

		Map<String, Task> taskMap = new Map<String, Task>();
		for(Task tsk : tasks)
		{
			taskMap.put(tsk.Legacy_Activity_Salesforce_ID__c, tsk);
		}

		List<TempTask__c> tempTasks = new List<TempTask__c>();
		List<Task> currentTasks = new List<Task>();

		Task currentTask;
		for(SObject obj : scope)
		{
			tempTask = (TempTask__c)obj;
			currentTask = taskMap.get(tempTask.LegacyId__c);
			if(currentTask != null)
			{
				currentTask.ActivityDate = tempTask.ActivityDate__c;
				currentTask.CallDurationInSeconds = tempTask.CallNumberInSeconds__c == null ? null : Integer.valueOf(tempTask.CallNumberInSeconds__c);
				currentTask.CallObject = tempTask.CallObject__c;
				currentTask.CallType = tempTask.CallType__c;
				currentTask.Description = tempTask.Description__c;
				currentTask.IsReminderSet = tempTask.IsReminderSet__c;
				currentTask.IsVisibleInSelfService = tempTask.IsVisibleSelfService__c;
				currentTask.RecurrenceDayOfMonth = tempTask.RecurrenceDayOfMonth__c == null ? null : Integer.valueOf(tempTask.RecurrenceDayOfMonth__c);
				currentTask.RecurrenceDayOfWeekMask = tempTask.RecurrenceDayOfWeek__c == null ? null : Integer.valueOf(tempTask.RecurrenceDayOfWeek__c);
				currentTask.RecurrenceInterval = tempTask.RecurrenceInterval__c == null ? null : Integer.valueOf(tempTask.RecurrenceInterval__c);
				currentTask.RecurrenceTimeZoneSidKey = tempTask.RecurrenceTimeZone__c;
				currentTask.ReminderDateTime = tempTask.ReminderDateTime__c;
				currentTask.Subject = tempTask.Subject__c;
				currentTask.Type = tempTask.Type__c;

				if(String.isNotBlank(tempTask.Priority__c)) currentTask.Priority = tempTask.Priority__c;
				if(String.isNotBlank(tempTask.Status__c)) currentTask.Status = tempTask.Status__c;

				currentTasks.add(currentTask);
			}

			tempTask.Processed__c = true;
			tempTasks.add(tempTask);
		}

		if(tempTasks.size() > 0) update tempTasks;
		if(currentTasks.size() > 0) update currentTasks;
	}

	global void finish(Database.BatchableContext BC){ }

}