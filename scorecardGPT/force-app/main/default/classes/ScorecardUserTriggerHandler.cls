public class ScorecardUserTriggerHandler implements ITriggerHandler
{
     public static Boolean TriggerDisabled = false;
     private static final ScorecardUserTriggerHandler handler = new ScorecardUserTriggerHandler();

     public void BeforeInsert(List<SObject> newItems) {

          List<Id> scorecardIds = new List<Id> ();
          for (SObject item : newItems)
          {
               Scorecard_User__c record = (Scorecard_User__c) item;
               scorecardIds.add(record.Scorecard__c);
          }

          List<Scorecard_User__c> userList = [SELECT Id, User__c, Role__c, Is_Active__c
                                              FROM Scorecard_User__c
                                              WHERE(Scorecard__c IN :scorecardIds)];

          for (SObject item : newItems)
          {
               Scorecard_User__c scUser = (Scorecard_User__c) item;
               for (Scorecard_User__c exist : userList)
               {
                    if (scUser.User__c == exist.User__c && exist.Is_Active__c)
                    {
                         item.addError('This user has an active role in this scorecard.');
                    }
               }
          }

     }

     public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
	 { 
		for (SObject item : newItems.values()) 
		{
			SObject oldItem = oldItems.get(item.Id);
			if(oldItem.get('Role__c') != item.get('Role__c')){
               item.addError('You can not change the role of this user.\r\nYou need to deactivate this user and add the same user with the new role.');
			   continue;
			}

			if(oldItem.get('User__c') != item.get('User__c')){
               item.addError('You can not change the user.\r\nYou need to deactivate this record and add the new user with the same role.');
			   continue;
			}

			if(oldItem.get('Scorecard__c') != item.get('Scorecard__c')){
               item.addError('You can not change the scorecard.\r\nYou need to deactivate this record and add the new userin the target scorecard.');
			   continue;
			}
        }
	 }

     public void BeforeDelete(Map<Id, SObject> oldItems) 
	 { 
		for (SObject item : oldItems.values())
        {
			item.addError('To keep tack of user activities and record histories, we do not allow scorecard users to be deleted.\r\nThe record should have been marked as Inactive instead.');
        }
	 }

     public void AfterInsert(Map<Id, SObject> newItems) {
          ScorecardUserHelper.grantScorecardSectionsAccess(newItems.values());
          ScorecardUserHelper.setupDefaultReviews(newItems.values());
          //ScorecardUserHelper.sendJoinNotificationEmail(newItems.values());
     }

     public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

     public void AfterDelete(Map<Id, SObject> oldItems) { }

     public void AfterUndelete(Map<Id, SObject> oldItems) { }
}