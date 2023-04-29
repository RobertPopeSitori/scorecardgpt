public class ScorecardCommentsController  
{
	@AuraEnabled
	public static string saveComment(string parentId, string parentType, string commentText)
	{
		AuraResponse response = new AuraResponse();
		if(String.isBlank(parentId))
		{
			response.success = false;
			response.message = 'Invalid or missing parameter: parentId.';
			return JSON.serialize(response);
		}

		if(String.isBlank(parentType))
		{
			response.success = false;
			response.message = 'Invalid or missing parameter: parentType.';
			return JSON.serialize(response);
		}

		if(String.isBlank(commentText))
		{
			response.success = false;
			response.message = 'Invalid or missing parameter: comment.';
			return JSON.serialize(response);
		}

		Scorecard_Comment__c com = new Scorecard_Comment__c();
		com.Parent_Id__c = parentId;
		com.Parent_Type__c = parentType;
		com.Comment__c = commentText;
		insert com;

		return getComments(parentId);
	}

	@AuraEnabled 
	public static string getComments(string parentId)
	{
		AuraResponse response = new AuraResponse();
		if(String.isBlank(parentId))
		{
			response.success = false;
			response.message = 'Invalid or missing parameter: parentId.';
			return JSON.serialize(response);
		}

		List<Scorecard_Comment__c> coms = [ SELECT Id, Name, Parent_Id__c, Parent_Type__c, Comment__c,
												CreatedDate, CreatedBy.Name
											FROM Scorecard_Comment__c
											WHERE Parent_Id__c = :parentId 
											ORDER BY CreatedDate DESC ];

		List<ScorecardCommentViewModel> model = ScorecardCommentViewModel.toList(coms);
		response.success = true;
		response.model = model;

		return JSON.serialize(response);
	}
}