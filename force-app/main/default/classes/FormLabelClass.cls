/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc 
**/
public with sharing class FormLabelClass{
    public static void saveLabel(Map<String, Map<String,String>> objectNameToApiNameAndLabel, String accountId , String formName){
        try{
            String mainStringMap = JSON.serialize(objectNameToApiNameAndLabel);
            sObject sObj;
            Elixir_Custom_Setting__c labelObject = Elixir_Custom_Setting__c.getOrgDefaults();
            if(labelObject!=null){
                String labelObj = labelObject.Form_Label__c;
                if(String.isBlank(labelObj)){
                    labelObj = 'ElixirSuite__Form_Label__c';
                }
                system.debug('labelObj '+labelObj);
                // Wether to create New Object Or Not - START
                List<AggregateResult> sumOfCharResult = Database.query('SELECT SUM(label_length__c) c FROM '+labelObj);
                Decimal sumOfChar = (Decimal) sumOfCharResult[0].get('c');
                if(sumOfChar == null){
                    sumofChar = 0;
                }
                system.debug(sumOfCharResult);
                system.debug(mainStringMap);
                if(sumOfChar + mainStringMap.length() > 1600000){
                    Integer i = 0;
                    String objectNo = labelObj.substringBetween('Form_Label', '__c');
                    if(String.isNotBlank(objectNo)){
                        i = Integer.valueOf(objectNo) + 1;
                    }
                    // Wether to create New Object Or Not - END
                    MetadataService.MetadataPort service = createService();
                    MetadataService.CustomObject customObject = new MetadataService.CustomObject();
                    customObject.fullName = 'Form_Label'+i+'__c';
                    customObject.label = 'Form_Labels'+i;
                    customObject.pluralLabel = 'Form_Labels'+i;
                    List<MetadataService.SaveResult> results =
                        service.createMetadata(
                            new MetadataService.Metadata[] { customObject });
                    labelObj = 'Form_Label'+i+'__c';
                    
                    List<MetadataService.CustomField> fields = new List<MetadataService.CustomField>();
                    MetadataService.CustomField customField = new MetadataService.CustomField();
                    customField.fullName = labelObj + '.' + 'FormId__c';
                    customField.label = 'Form Name';
                    customField.type_x = 'Text';
                    fields.add(customField);
                    
                    MetadataService.CustomField customFieldNumber = new MetadataService.CustomField();
                    customFieldNumber.fullName = labelObj + '.' + 'Label_Length__c';
                    customFieldNumber.label = 'Form Name';
                    customFieldNumber.type_x = 'Number';
                    fields.add(customFieldNumber);
                    
                    MetadataService.CustomField customFieldAccount = new MetadataService.CustomField();
                    customFieldAccount.fullName = labelObj + '.' + 'AccountId__c';
                    customFieldAccount.label = 'AccountId';
                    customFieldAccount.type_x = 'Text';
                    fields.add(customFieldAccount);
                    
                    MetadataService.CustomField customFieldRich = new MetadataService.CustomField();
                    customFieldRich.fullName = labelObj + '.' + 'Label__c';
                    customFieldRich.label = 'Label';
                    customFieldRich.type_x = 'LongTextArea';
                    customFieldRich.length = 100000;
                    customFieldRich.visibleLines = 25;
                    fields.add(customFieldRich);
                    
                    service.createMetadata(fields);
                    //update metadata Form Label
                    if(labelObject!=null){
                        labelObject.Form_Label__c = labelObj;
                        if(Schema.sObjectType.Elixir_Custom_Setting__c.isUpdateable() &&
                        Schema.sObjectType.Elixir_Custom_Setting__c.fields.Form_Label__c.isUpdateable()){
                         
                        update labelObject; 
                    }
                } 
                }
                system.debug(labelObj);
                sObj = Schema.getGlobalDescribe().get(labelObj).newSObject(); 
                sObj.put('Label__c',mainStringMap);
                sObj.put('AccountId__c',accountId);
                sObj.put('FormId__c',formName);// Form Name
                
                // if(Schema.sObjectType.Elixir_Custom_Setting__c.isCreateable()){
                // insert sObj;// inserted label
                // }
                    DMLManager.insertAsUser(sObj);

                Id objId = sObj.Id;
                List<sObject> labels = Database.query('SELECT Label__c, Label_Length__c FROM '+labelObj+ ' WHERE Id =:objId');
                labels[0].put('Label__c',String.valueOf(labels[0].get('Label__c')).replaceAll('&quot;','"_reg_'));
                labels[0].put('Label_Length__c',String.valueOf(labels[0].get('Label__c')).length());
                // if(Schema.sObjectType.Elixir_Custom_Setting__c.isUpdateable()){
                // update labels;
                // }
                DMLManager.updateAsUser(labels);
            }
        }catch(Exception e){  
        }
    }
    public static void createMapOfLabel(Map<String, Map<String,String>> objectNameToApiNameAndLabel, String objectName, String fieldName, String fullLabel){
        if(String.isBlank(fieldName)){
            return;
        }
        if(objectNameToApiNameAndLabel.containsKey(objectName)){
            objectNameToApiNameAndLabel.get(objectName).put(fieldName,fullLabel);
        }else{
            Map <String,String> labelName = new Map<String,String>{fieldName => fullLabel};
                objectNameToApiNameAndLabel.put(objectName,labelName);
        }
    }
    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
    
}