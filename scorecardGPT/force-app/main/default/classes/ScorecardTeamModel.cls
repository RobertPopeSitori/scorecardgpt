public class ScorecardTeamModel  
{
	public string name { get; set; }
	public string id { get; set; }
	public string role { get; set; }

	public ScorecardTeamModel(string mId, string mName, string mRole)
	{
		this.name = mName;
		this.id = mId;
		this.role = mRole;
	}

	public static List<ScorecardTeamModel> toList(List<Scorecard_User__c> users)
	{
		List<ScorecardTeamModel> teamList = new List<ScorecardTeamModel>();
		if(users == null || users.size() == 0) return teamList;

		for(Scorecard_User__c scUser : users)
		{
			ScorecardTeamModel model = new ScorecardTeamModel(scUser.User__r.Id, scUser.User__r.Name, scUser.Role__c);
			teamList.add(model);
		}

		return teamList;
	}
}