public class TriggerManager  
{
	public static void Invoke(string objectType)
	{
		List<Trigger_Handler__mdt> handlers = [ SELECT Class__c, Is_After_Delete__c, Is_After_Undelete__c, 
													Is_After_Insert__c, Is_After_Update__c, Is_Before_Delete__c, 
													Is_Before_Insert__c, Is_Before_Update__c,
													Is_Enabled__c, Object__c, Order__c
												FROM Trigger_Handler__mdt
												WHERE Object__c = :objectType
												ORDER BY Order__c ASC ];

		for(Trigger_Handler__mdt handler : handlers)
		{
			try 
			{
				if(handler.Is_Enabled__c)
				{
					ITriggerHandler instance = (ITriggerHandler)Type.forName(handler.Class__c).newInstance();
					if(instance != null) TriggerManager.Run(instance, handler);
				}
			}
			catch(Exception e){}
		}

	}

    public static void Run(ITriggerHandler handler, Trigger_Handler__mdt mdtSettings)
    {
            
        if (Trigger.IsBefore )
        {
            if (Trigger.IsInsert && mdtSettings.Is_Before_Insert__c)
                handler.BeforeInsert(trigger.new);
 
            if (Trigger.IsUpdate && mdtSettings.Is_Before_Update__c)
                handler.BeforeUpdate(trigger.newMap, trigger.oldMap);
 
            if (Trigger.IsDelete && mdtSettings.Is_Before_Delete__c)
                handler.BeforeDelete(trigger.oldMap);
        }
         

        if (Trigger.IsAfter)
        {
            if (Trigger.IsInsert && mdtSettings.Is_After_Insert__c)
                handler.AfterInsert(Trigger.newMap);
 
            if (Trigger.IsUpdate && mdtSettings.Is_After_Update__c)
                handler.AfterUpdate(trigger.newMap, trigger.oldMap);
 
            if (trigger.IsDelete && mdtSettings.Is_After_Delete__c)
                handler.AfterDelete(trigger.oldMap);
 
            if (trigger.isUndelete && mdtSettings.Is_After_Undelete__c)
                handler.AfterUndelete(trigger.oldMap);
        }
    }
}