public class ScorecardViewModel 
{
    public ScorecardViewModel(){}
    
    public ScorecardViewModel(Scorecard__c scorecard) 
    {
        this.id = scorecard.Id;
        this.scorecardNumber = scorecard.Name;
        this.title = scorecard.Title__c;
        this.createdDate = StringHelper.format(scorecard.CreatedDate);
        this.type = scorecard.Type__c;
        this.account = scorecard.Organization__r.Name;
        this.status = scorecard.Status__c;
    }

    public ScorecardViewModel(Scorecard__c scorecard, List<Scorecard_User__c> scUsers)
    {
        this.id = scorecard.Id;
        this.scorecardNumber = scorecard.Name;
        this.title = scorecard.Title__c;
        this.createdDate = StringHelper.format(scorecard.CreatedDate);
        this.type = scorecard.Type__c;
        this.account = scorecard.Organization__r.Name;
        this.status = scorecard.Status__c;
        this.owner = scorecard.Owner.Name;

        /*for(Scorecard_User__c scUser : scUsers){
            if(scUser.Role__c == 'Author'){
                this.owner = scUser.User__r.Name;
                break;
            }
        }

        if(string.isBlank(this.owner)){
            for(Scorecard_User__c scUser : scUsers){
                if(scUser.Role__c == 'Co-Author'){
                    this.owner = scUser.User__r.Name;
                    break;
                }
            }
        }*/

    }

    public string id { get; set; }
    public string scorecardNumber { get; set; }
    public string title { get; set; }
    public string account { get; set; }
    public string owner { get; set; }
    public string createdDate { get; set; }    
    public string type { get; set; }
    public string status { get; set; }
}