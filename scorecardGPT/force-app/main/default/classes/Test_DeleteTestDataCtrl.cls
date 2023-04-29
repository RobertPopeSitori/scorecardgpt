@IsTest
public class Test_DeleteTestDataCtrl {

   static Boolean isInstalled = false;

    public static void install() {
        if (!isInstalled) {
            Framework.Installer.install();
            PagesApi.PackageScripts.install();
            OrderApi.PackageScripts.install();
            EventApi.PackageScripts.install();
            isInstalled = true;
        }
    }

    @IsTest
    static void testCleanData() {
        install();
        Test.startTest();
        DeleteTestDataCtrl dt = new DeleteTestDataCtrl();
        DeleteTestDataCtrl.apex_cleanData();
        Test.stopTest();
    }
}