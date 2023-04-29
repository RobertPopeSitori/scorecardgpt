public without sharing class FS_ResponsiveStateCountryController {
	public class MyPickListInfo {
        public String validFor;
    }

    public static String getJSONCountriesAndStates() {
        Map<String, Map<String, List<Object>>> controllingInfo = new Map<String, Map<String, List<Object>>>();

        Schema.DescribeFieldResult controllingFieldInfo = User.countrycode.getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = User.statecode.getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            controllingInfo.put(currControllingValue.getLabel(), new Map<String, List<Object>>());
            controllingInfo.get(currControllingValue.getLabel()).put('id', new List<String>());
            controllingInfo.get(currControllingValue.getLabel()).get('id').add(currControllingValue.getValue());
            controllingInfo.get(currControllingValue.getLabel()).put('states', new List<Map<String, String>>());
        }

        for (Schema.PicklistEntry currDependentValue : dependentValues) {
            String jsonString = JSON.serialize(currDependentValue);
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;

            Map<String, String> temp = new Map<String, String>();
            temp.put('label', currDependentValue.getLabel());
            temp.put('id', currDependentValue.getValue());

            for (Integer curr : hexString.getChars()) {
                Integer val = 0;
                if (curr >= 65) {
                    val = curr - 65 + 10;
                } else {
                    val = curr - 48;
                }

                if ((val & 8) == 8) {
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).get('states').add(temp);
                }
                if ((val & 4) == 4) {
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).get('states').add(temp);
                }
                if ((val & 2) == 2) {
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).get('states').add(temp);
                }
                if ((val & 1) == 1) {
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).get('states').add(temp);
                }

                baseCount += 4;
            }
        }
        return JSON.serialize(controllingInfo);
    }
}