/**
 * Created by daweima on 2019-09-04.
 */

public class FS_LTEventComponentController {

    @AuraEnabled
    public static String encodeString(String input) {
        return EncodingUtil.urlEncode(input, 'UTF-8');
    }

}