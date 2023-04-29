/**
 * Created by daweima on 2019-09-04.
 */

@isTest
public with sharing class FS_LTEventComponentControllerTest {
    @isTest
    static void testEncoder(){
        String result = FS_LTEventComponentController.encodeString('test');
        System.assert(!String.isBlank(result));
    }
}