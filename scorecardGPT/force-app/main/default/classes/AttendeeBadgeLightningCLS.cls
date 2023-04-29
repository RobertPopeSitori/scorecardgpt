public class AttendeeBadgeLightningCLS {
    @AuraEnabled
    public static string getAttende(id AttendeID){
        date sd = Date.newInstance( 1960, 1, 1 );
        date ed = Date.newInstance( 1960, 1, 1 );
        string URLNav = '/apex/AttendeeBadgeVFP?id='+AttendeID+'&&sd='+sd+'&&ed='+ed;
        return URLNav;
    }
}