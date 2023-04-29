public class StringHelper 
{
    private static final Map<Integer, Integer> MULTIPLIERS = new Map<Integer, Integer> {
        1 => 10,
        2 => 100,
        3 => 1000,
        4 => 10000,
        5 => 100000,
        6 => 1000000
        };
        
    public static String format(Decimal d, Integer places) 
    {
        if (d != null) 
        {
            Decimal dd = d.setScale(places);
            String w = dd.longValue().format();

            if (places != 0) {
                if (dd < 0) dd = -dd;
                Integer multiplier = MULTIPLIERS.get(places);
                String f = String.valueOf(multiplier + Math.mod((dd * multiplier).longValue(), multiplier));

                return w + '.' + f.substring(1);
            } else {
                return w;
            }
        } else {
            return null;
        }
    }

    public static string format(DateTime dateInput)
    {
        if(dateInput == null) return '';
        
        return dateInput.format('M/d/yyyy hh:mm a');
    }

    public static boolean isValidSalesforceId(string sfdcId, System.Type t )
    {
        try 
        { 
            if ( Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( sfdcId ).matches() )
            {
                Id id = sfdcId;
                sObject sObj = (sObject) t.newInstance();
                sObj.Id = id;
 
                return true;
            }

            return false;
        } 
        catch ( Exception e )
        {
            return false;
        } 
    }
}