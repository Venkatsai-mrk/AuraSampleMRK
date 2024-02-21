public with sharing class ElixirOEM_DependentPicklist {
    public static  List<String> getFields( List<String> allIncomingAPis ){
        List<String> objectNamesByApi = new List<String>();
        objectNamesByApi = fetchAllValidObject();
        Map<String,String> dpLst = new Map<String,String>();
        if(objectNamesByApi!=null && objectNamesByApi.size()>0){
            for(String obj : objectNamesByApi){
                Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Map <String, Schema.SObjectField> fieldMap = schemaMap.get(obj).getDescribe().fields.getMap();    
                
                for(Schema.SObjectField sfield : fieldMap.Values()){
                                  
                    schema.describefieldresult dfield = sfield.getDescribe();
                    if(allIncomingAPis.contains(dfield.getname())){ // this will make sure that only your asked fields are considered            
                        Schema.sObjectField dependedentField = dfield.getSObjectField();
                        Map<String,List<String>> controllingValueToDependentValues = new Map<String,List<String>>();
                        controllingValueToDependentValues = FormRenderUtility.getDependentPicklistValues(dependedentField);
                        if(controllingValueToDependentValues.size()>0){
                            dpLst.put(String.valueOf(dependedentField) ,  String.valueOf(dfield.getController()));
                        } 
                    }
                }
            }
        }
        
        return dplst.values();
    }
    public static  List<String> fetchAllValidObject(){
        List<Form_Object__mdt> allObjectNames = [select Object_Name__c from Form_Object__mdt 
                                                 WHERE Object_Name__c!=NULL WITH SECURITY_ENFORCED];
        List<String> objectNamesByApi = new List<String>();
        for(Form_Object__mdt recordInstance : allObjectNames){
            if(String.isNotBlank(recordInstance.Object_Name__c)){
                objectNamesByApi.addAll(recordInstance.Object_Name__c.split(';'));
            }
        }
        return objectNamesByApi;
    }
    
}