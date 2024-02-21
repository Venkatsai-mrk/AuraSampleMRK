public with sharing class ElixirOEM_ReferralAsyncPDFGenerator {
    public static void getFormsDataForPDF(Id accId, Id episodeId, String otherAttributes,List<String> formUniqueIDSet,String parentReferralId,
                                          String acctId)
    {  
        try{                              
            
            String nspc;  
            if(String.isNotBlank(Elixir_Utility.getNamespace())){ 
                nspc = Elixir_Utility.getNamespace() + '__';
            }
            else { 
                nspc = '';
            }   
           List<String> fieldApiToExist = new List<String>{nspc+'Form_unique_id__c',nspc+'Form_RecordType_Name__c',nspc+'Form_Name__c',
            nspc+'Form_Category__c'};
                    Form_Object__mdt[] objectNames =  PatientChartController.fetchAllObjectsInCS();
            String[] nameArrObj;
            if(objectNames!=null && objectNames.size()>0){
                nameArrObj =  objectNames[0].Object_Name__c.split(';');
            }
            
            if(nameArrObj!=null && nameArrObj.size()>0){
                Boolean doesObjectHasField = true;
                for(String objName : nameArrObj){
                    for(String rec : fieldApiToExist){
                        doesObjectHasField = PatientChartController.doesFieldExist(objName,rec);
                    } 
                }
                if(doesObjectHasField){
                    Map<String, String> sObjMap = new Map<String, String>();                     
                    for(String objName : nameArrObj){
                        String localNamespace = '';
                        if(objName.contains('ElixirSuite__Object_2__c')){
                            localNamespace = nspc;
                        }                    
                        String fieldQuery = 'SELECT Id,'+localNamespace+'Form_RecordType_Name__c,'+localNamespace+'Form_unique_id__c,'+localNamespace+'Form_Name__c,'+
                            localNamespace+'Form_Category__c FROM ';
                        fieldQuery+=objName+' ';
                        fieldQuery+='where '+localNamespace+'Form_unique_id__c IN: formUniqueIDSet';         
                        
                        List<sObject> sobjList = Database.query(fieldQuery);  // QUERY TO BE MADE INSIDE FOR LOOPS FOR NUMBER OF OBJECTS MENTIONED IN METADATA
                        
                        if(sobjList!=null && sobjList.size()>0){                             
                            for (SObject record : sobjList){ 
                                String fName = String.valueOf(record.get(localNamespace+'Form_RecordType_Name__c'));
                                String fCName = String.valueOf(record.get(localNamespace+'Form_Name__c'));
                                String formUniqueID = String.valueOf(record.get(localNamespace+'Form_unique_id__c'));
                                Object value = record.get(localNamespace+'Form_unique_id__c');   // FORMUNIQUE ID
                                
                                sObjMap.put(String.valueOf(value),String.valueOf(value)+'&'+fName+'&'+fCName+'&'+String.valueOf(accId)); // PUT IN A MAP BECAUSE SAME FORMUNIQUEID CAN BE PRESENT ON THE 2 DIFFERENT OBJECTS   
                                
                            }                                                        
                        }
                    }        
                    if(sObjMap.keySet().size()>0){ 
                        System.enqueueJob(new SaveReferralPdfQueueable(sObjMap, accId, 1, new Set<Id>{}, episodeId, otherAttributes,parentReferralId));
                    }
                    else{
                        ElixirOEM_ReferralUtility.sendReferralFormAsAttachmentOnEmail(new Set<Id>{},parentReferralId);
                    }
                }
            }                                             
            }//try end
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }    
}