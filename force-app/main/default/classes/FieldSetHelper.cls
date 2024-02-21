public class FieldSetHelper {
    
    public static List<Schema.FieldSetMember> getFieldSet(String ObjectName, String fieldSetName){
        List<Schema.FieldSetMember> fieldSetMemberList = new List<Schema.FieldSetMember>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        fieldSetMemberList = fieldSetObj.getFields();
        if(fieldSetMemberList != NULL && fieldSetMemberList.size() > 0){
            return fieldSetMemberList;
        }else{
            return NULL;
        }
    }
    public class WrapperOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String fieldType;
        public WrapperOption(String value, String label,String fieldType) {
            this.label = label;
            this.value = value;
            this.fieldType = fieldType; 
        }
    }
    public static List<WrapperOption> getFieldSetLabelValues(String ObjectName, String fieldSetName){
        List<WrapperOption> options = new List<WrapperOption>();
        List<Schema.FieldSetMember> fieldSetMemberList = getFieldSet(ObjectName,fieldSetName);
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            String value = fieldSetMemberObj.getFieldPath();
            String label = fieldSetMemberObj.getLabel();
            String fieldType = fieldSetMemberObj.getType().name();  
            options.add(new WrapperOption(value,label,fieldType));
        }
        if(options != NULL && options.size() > 0){
            return options;
        }else{
            return NULL;
        }
    }
    
}