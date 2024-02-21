public with sharing class inlineEditCareEpisodeController {
    
    @AuraEnabled
    public static String updateCareEpisode(String careId,String accId,String formUnId){  
        
        List<Form_Value__c> formCare = [SELECT Id, Form_Id__c,Status__c,
                                        Care_Episode__c,Is_CareEpisode__c,Episode_Id__c 
                                        FROM Form_Value__c
                                        WHERE Is_CareEpisode__c=true AND Form_Id__c =:formUnId
                                        WITH SECURITY_ENFORCED];
        
        if(formCare!=null && formCare.size()>0){
            if(careId==null || careId==''){
                formCare[0].Care_Episode__c = null;
                formCare[0].Episode_Id__c = null;
            }
            else{
                formCare[0].Care_Episode__c = careId;
                formCare[0].Episode_Id__c = careId;
            }
            
            DMLManager.updateAsUser(formCare);
            
        }
        else{
            
            String formValueName = '';
            formValueName = 'Form -' + system.now().format();
            Form_value__c formValue = new Form_Value__C(
                Name = formValueName,
                Form_Name__c= formValueName,
                Form_Id__c = formUnId,
                Account__c = accId,
                Is_CareEpisode__c = true,
                Care_Episode__c = careId,
                Episode_Id__c = careId
            );
            DMLManager.insertAsUser(formValue);
        }
        
        
        String result = 'completed';
        
        return result; 
    }

    @AuraEnabled
    public static String updateProcCareEpisode(String careId,String accId,String procId){  
        
        List<ElixirSuite__Procedure__c> procLst = [SELECT Id, Name,ElixirSuite__Visits__c
                                                   FROM ElixirSuite__Procedure__c
                                                   WHERE Id =:procId
                                                   WITH SECURITY_ENFORCED];
        
        if(procLst!=null && procLst.size()>0){
            if(careId==null || careId==''){
                procLst[0].ElixirSuite__Visits__c = null;
            }
            else{
                procLst[0].ElixirSuite__Visits__c = careId;
            }
            
            DMLManager.updateAsUser(procLst);
            
        }
        
        
        String result = 'completed';
        
        return result; 
    }
}