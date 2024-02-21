global class AuditTrailUtility implements Queueable{
    
    global Map<Id,sObject> newSobjectMap;
    global Map<Id,sObject> oldSobjectMap;
    global String objectName;
    global String actionType;
    @deprecated
    global AuditTrailUtility(Map<Id,sObject> newSobjectMap,Map<Id,sObject> oldSobjectMap){ }
    global AuditTrailUtility(Map<Id,sObject> newSobjectMap,Map<Id,sObject> oldSobjectMap,String objectName){
        this.newSobjectMap = newSobjectMap;
        this.oldSobjectMap = oldSobjectMap;
        this.objectName = objectName;
    }
    global void execute(QueueableContext context) {
        List<Audit_Log__c> auditList = new List<Audit_Log__c>();
        Map<String,Set<String>> objToField = new Map<String,Set<String>>();
        
        Set<String> allFields = new Set<String>();
        Set<String> allObjects = new Set<String>();
        
        System.debug('newSobjectMap**'+newSobjectMap);
        System.debug('oldSobjectMap**'+oldSobjectMap);
        System.debug('objectName**'+objectName);
        
        try{
            
            allObjects.add(objectName);
            List<ElixirSuite__Audit_fields_new__mdt> metadata = [SELECT Id, 
                                                                 ElixirSuite__Audit_Object__c, 
                                                                 ElixirSuite__Audit_fields__c 
                                                                 FROM ElixirSuite__Audit_fields_new__mdt
                                                                 WHERE ElixirSuite__Audit_Object__c IN : allObjects
                                                                 WITH SECURITY_ENFORCED];//Getting metadata
            
            if(metadata!=null && metadata.size()>0){ 
                for(ElixirSuite__Audit_fields_new__mdt meta : metadata){
                    allFields.addAll((meta.ElixirSuite__Audit_fields__c.split(';')));
                    objToField.put(meta.ElixirSuite__Audit_Object__c,new Set<String>(meta.ElixirSuite__Audit_fields__c.split(';')));
                }
            }
            
            System.debug('allFields**'+allFields);
            
            for(sObject newSobject : newSobjectMap.values()){
                Schema.DescribeSObjectResult obj= newSobject.Id.getsobjecttype().getDescribe();
                
                if(allFields!=null && allFields.size()>0){
                    for(String fieldApi :allFields){
                        SObjectType objName = ((SObject) Type.forName(objectName).newInstance()).getSObjectType();
                        Map<String,Schema.SObjectField> mfields = objName.getDescribe().fields.getMap();
                        Schema.DescribeFieldResult fieldResult = mfields.get(fieldApi).getDescribe();
                        System.debug('field label*****'+fieldResult.getLabel());
                        String fieldLabel = fieldResult.getLabel();
                        system.debug('oldSobjectMap '+oldSobjectMap);
                        if(((oldSobjectMap != null && oldSobjectMap.get(newSobject.Id)!=null) && oldSobjectMap.get(newSobject.Id).get(fieldApi) != newSobjectMap.get(newSobject.Id).get(fieldApi)) || (oldSobjectMap == null)){
                            System.debug('line 78');
                            
                            Audit_Log__c auditLog = new Audit_Log__c();
                            auditLog.Field_Api_Name__c = fieldApi;
                            auditLog.Parent_Id__c = newSobject.Id;
                            auditLog.ElixirSuite__Field_Label__c = fieldLabel;
                            if(objectName=='Account'){
                                auditLog.Account_Name__c = newSobject.Id;
                            }
                            if(objectName=='ElixirSuite__Patient_Device__c' && newSobject != null && newSobject.get('ElixirSuite__Account__c') != null){
                                auditLog.ElixirSuite__Account_Name__c = (String)newSobject.get('ElixirSuite__Account__c');
                            }
                            auditLog.Object_Name__c = obj.getName();
                            auditLog.Modified_Date__c = System.now();
                            String fieldName = 'lastmodifieddate';
                            Schema.DisplayType fieldDataType = obj.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
                            if(String.valueOf(fieldDataType) == 'DATETIME'){
                                if(oldSobjectMap == null || oldSobjectMap.get(newSobject.Id)==null){
                                    auditLog.Old_Value_Datetime__c = null;
                                }else{
                                    auditLog.Old_Value_Datetime__c = Datetime.valueOf(oldSobjectMap.get(newSobject.Id).get(fieldName));
                                }
                                auditLog.New_Value_Datetime__c = Datetime.valueOf(newSobjectMap.get(newSobject.Id).get(fieldName));
                            }
                            
                            Schema.DescribeFieldResult dr = obj.fields.getMap().get(fieldApi).getDescribe();
                            String typ = dr.getType().name();
                            System.debug('typ**'+typ);
                            if(String.valueOf(typ) == 'PICKLIST'){
                                
                                for( Schema.PicklistEntry ple : dr.getPicklistValues()){
                                    if(ple.getValue()== newSobject.get(fieldApi)){
                                        
                                        auditLog.New_Value__c = ple.getLabel(); 
                                        
                                    }
                                    else if (oldSobjectMap == null || oldSobjectMap.get(newSobject.Id)==null){
                                        auditLog.Old_Value__c = null;
                                    }
                                    else if(ple.getValue()== oldSobjectMap.get(newSobject.Id).get(fieldApi)){
                                        auditLog.Old_Value__c = ple.getLabel(); 
                                    }
                                } 
                            }
                            else if(String.valueOf(typ) == 'DATE'){
                                Date dToday = Date.valueOf(newSobject.get(fieldApi));
                                String dateStr;
                                if(dToday==null){
                                    dateStr = '';
                                }
                                else{
                                    DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
                                    dateStr = dt.format('yyyy-MM-dd');   
                                }
                                auditLog.New_Value__c = dateStr;
                                
                                Date oldToday = null ;
                                if (oldSobjectMap == null || oldSobjectMap.get(newSobject.Id)==null){
                                    oldToday  = null;
                                }else{
                                    oldToday  = Date.valueOf(oldSobjectMap.get(newSobject.Id).get(fieldApi));
                                }
                                String dateOldStr;
                                if(oldToday==null){
                                    dateOldStr = '';
                                }
                                else{
                                    DateTime dtOld = DateTime.newInstance(oldToday.year(), oldToday.month(),oldToday.day());
                                    dateOldStr = dtOld.format('yyyy-MM-dd');
                                }
                                auditLog.Old_Value__c = dateOldStr;
                            }
                            else if(String.valueOf(typ) == 'BOOLEAN'){
                                
                                String oldVal = '';
                                if (oldSobjectMap == null || oldSobjectMap.get(newSobject.Id)==null){
                                    oldVal = null;
                                }else{
                                    oldVal = String.valueOf(oldSobjectMap.get(newSobject.Id).get(fieldApi));
                                }
                                String newVal = String.valueOf(newSobject.get(fieldApi));
                                System.debug('line 106');
                                System.debug('oldVal**'+oldVal);
                                System.debug('newVal**'+newVal);
                                String finalOldVal;
                                String finalNewVal;
                                if(oldVal==''){
                                    finalOldVal = '';
                                }
                                else{
                                    if(oldVal == 'true'){
                                        finalOldVal = 'True';
                                    }
                                    else{
                                        finalOldVal = 'False';
                                    }
                                }
                                
                                if(newVal==''){
                                    finalNewVal = '';
                                }
                                else{
                                    if(newVal == 'true'){
                                        finalNewVal = 'True';
                                    }
                                    else{
                                        finalNewVal = 'False';
                                    }
                                }
                                
                                auditLog.Old_Value__c = finalOldVal;
                                auditLog.New_Value__c = finalNewVal;
                                
                            }
                            else{
                                auditLog.New_Value__c = String.valueOf(newSobject.get(fieldApi));
                                if (oldSobjectMap == null || oldSobjectMap.get(newSobject.Id)==null){
                                    auditLog.Old_Value__c = null;
                                }else{
                                    auditLog.Old_Value__c = String.valueOf(oldSobjectMap.get(newSobject.Id).get(fieldApi));
                                }
                            }
                            auditList.add(auditLog);
                        }   
                    }
                }
            }
            if(auditList!=null && auditList.size()>0){
                DMLManager.insertAsUser(auditList);
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
}