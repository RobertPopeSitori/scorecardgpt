@isTest
public class FS_ResponsiveStateCountryControllerTest {
	@isTest 
    static void testCountryState() {
        String result = FS_ResponsiveStateCountryController.getJSONCountriesAndStates();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(m.get('United States') != null);
    }
}