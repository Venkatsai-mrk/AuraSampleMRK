public class PicklistHelper {
    
    public class PicklistOptionWrapper {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        
        public PicklistOptionWrapper(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
    
    public static List<PicklistOptionWrapper> getPicklistOptions(String objectApiName, String fieldApiName) {
        List<PicklistOptionWrapper> picklistOptions = new List<PicklistOptionWrapper>();
        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            PicklistOptionWrapper optionWrapper = new PicklistOptionWrapper(picklistEntry.getValue(), picklistEntry.getLabel());
            picklistOptions.add(optionWrapper);
        }
        if(picklistOptions != NULL && picklistOptions.size() > 0){
            return picklistOptions;
        }else{
            return NULL;
        }
    }
}