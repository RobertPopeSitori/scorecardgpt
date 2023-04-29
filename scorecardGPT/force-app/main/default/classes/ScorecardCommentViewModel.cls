public class ScorecardCommentViewModel  
{
	public ScorecardCommentViewModel(){ }

	public ScorecardCommentViewModel(Scorecard_Comment__c comment)
	{
		if(comment == null) return;

		this.id = comment.Id;
		this.text = comment.Comment__c;
		this.createdDate = StringHelper.format(comment.CreatedDate);
		this.createdBy = comment.CreatedBy.Name;
		this.parentType = comment.Parent_Type__c;
		this.parentId = comment.Parent_Id__c;
	}

	public string id { get; set; }
	public string text { get; set; }
	public string createdDate { get; set; }
	public string createdBy { get; set; }
	public string parentId { get; set; }
	public string parentType { get; set; }

	public static List<ScorecardCommentViewModel> toList(List<Scorecard_Comment__c> comments)
	{
		List<ScorecardCommentViewModel> commentList = new List<ScorecardCommentViewModel>();

		if(comments != null && comments.size() > 0)
		{
			for(Scorecard_Comment__c comment : comments)
			{
				ScorecardCommentViewModel model = new ScorecardCommentViewModel(comment);
				commentList.add(model);
			}
		}

		return commentList;
	}
}