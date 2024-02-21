public with sharing class UpdateProcedureHandler {
    @AuraEnabled
    public static WrapperForNewScreen fetchRecordInView(String accountId,String recordId){
        WrapperForNewScreen sObj = new WrapperForNewScreen();
        Id procedureRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
        sObj.procedureRecordTypeId = procedureRecordTypeId;
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
        Id practitionerRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        sObj.practitionerRecTypeId = practitionerRecTypeId;
        Id bedRecordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByDeveloperName().get('Bed').getRecordTypeId();
        sObj.bedRecordTypeId = bedRecordTypeId;
        Id roomRecordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByDeveloperName().get('Room').getRecordTypeId();
        sObj.roomRecordTypeId = roomRecordTypeId;
        Id suiteRecordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByDeveloperName().get('Suite').getRecordTypeId();
        sObj.suiteRecordTypeId = suiteRecordTypeId;
        sObj.mapPickListValues = MasterProblemListController.fetchPickListValue('ElixirSuite__Procedure__c','ElixirSuite__Code_Category__c');
        sObj.patientICDs = fetchAllDiagnosisForPatient(accountId);
        sObj.mapPickListValues_placeOfService = MasterProblemListController.fetchPickListValue('ElixirSuite__Procedure__c','ElixirSuite__Place_Of_Service_Picklist__c');
        sObj.mapPickListValues_claimType = MasterProblemListController.fetchClaimTypePickListValue('ElixirSuite__Procedure__c','ElixirSuite__Claim_type__c');
        sObj.mapPickListValues_status = MasterProblemListController.fetchPickListValue('ElixirSuite__Procedure__c','ElixirSuite__Status__c');
        sObj.mapPickListValues_defaultStatus = MasterProblemListController.fetchDefaultPickListValue('ElixirSuite__Procedure__c','ElixirSuite__Status__c');
        sObj.mapPickListValues_defaultClaimType = MasterProblemListController.fetchDefaultPickListValue('ElixirSuite__Procedure__c','ElixirSuite__Claim_type__c');
        sObj.mapPickListValues_paymentType = MasterProblemListController.fetchPickListValue('ElixirSuite__Procedure__c','ElixirSuite__Type_of_Procedure__c');
        sObj.procedureRecords = fetchProcedureRecord(recordId);
        sObj.junctionData = fetchDiagnosisData(recordId);
        sObj.obj = claimStatusCheck(sObj.procedureRecords);
        list<string> claimWithERA = new list<string>{'Paid and Patient Responsibility','Paid and resolved','Paid with Patient Responsibility – Ready to submit secondary Insurance','Clearing house accepted',' Paid and patient responsibility with Secondary'};
            if(claimWithERA.contains(sObj.obj.ElixirSuite__Claim_Status__c)){
                sObj.isProcessed = true;      
            }
        String patientName = '';
        Account[] accRec = [SELECT Name FROM Account WHERE ID = : accountId WITH SECURITY_ENFORCED];
        if(accRec!=null && accRec.size()>0){
            patientName = accRec[0].Name;
        }
        sObj.patientName = patientName;
        return sObj;
    }
    
    @AuraEnabled
    public static String getTypeOfPament(String recordId){
        
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();       
        ElixirSuite__Procedure__c[] recordLst = [SELECT Id,Name,ElixirSuite__Type_of_Procedure__c 
                                                 FROM ElixirSuite__Procedure__c 
                                                 WHERE RecordTypeId = : devRecordTypeId 
                                                 AND Id = : recordId  
                                                 WITH SECURITY_ENFORCED];
        
        String res = recordLst[0].ElixirSuite__Type_of_Procedure__c;
        return res;
        
    }
    public static ElixirSuite__Claim__c claimStatusCheck(ElixirSuite__Procedure__c[] procedureRecords){
        ElixirSuite__Claim__c obj;
        if(procedureRecords!=null && procedureRecords.size()>0){           
            if(String.isNotBlank(procedureRecords[0].ElixirSuite__Claim__c)){
                obj = [SELECT ID,Name,ElixirSuite__Claim_Status__c FROM ElixirSuite__Claim__c WHERE ID =: 
                       procedureRecords[0].ElixirSuite__Claim__c WITH SECURITY_ENFORCED];
                
            }
        }
        return obj;
    }
    public static ElixirSuite__Procedure__c[] fetchProcedureRecord(String recId){
        // String query =  ElixirOEM_TimelineHelper.getAllFieldsNameOfObject('ElixirSuite__Procedure__c')+
        String query = 'SELECT Id,OwnerId,IsDeleted,Name,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastViewedDate,LastReferencedDate,ElixirSuite__Account__c,ElixirSuite__Active__c,ElixirSuite__Notes__c,'+
            'ElixirSuite__Place_Of_Service_Picklist__c, ElixirSuite__Billable__c,ElixirSuite__CPT_HCPCS_Code__c,ElixirSuite__Charges__c,ElixirSuite__Claim_Generation__c,ElixirSuite__Claim__c,ElixirSuite__Claim_type__c,ElixirSuite__Code_Category__c,'+
            'ElixirSuite__Code_Description__c,ElixirSuite__Count_of_total_modifiers_used__c,ElixirSuite__From_Date_of_Service__c,ElixirSuite__Generate_Claim__c,ElixirSuite__Is_Billable__c,ElixirSuite__Is_Billed__c,ElixirSuite__Is_Processed__c,'+
            'ElixirSuite__Ready_for_Billing__c,ElixirSuite__Ready_for_Claim_Processing__c,ElixirSuite__To_Date_of_Service__c,ElixirSuite__Type_of_Procedure__c,ElixirSuite__Is_Patient_Procedure__c,ElixirSuite__Reference_CPT_Code__c,ElixirSuite__Days_Units__c,'+
            'ElixirSuite__Modifier1__r.Name,ElixirSuite__Modifier2__r.Name,ElixirSuite__Modifier3__r.Name,ElixirSuite__Modifier4__r.Name,'+
            'ElixirSuite__Notes_1__c,ElixirSuite__Notes_2__c,ElixirSuite__Notes_3__c,ElixirSuite__Notes_4__c, ElixirSuite__Visits__r.Name,ElixirSuite__Visits__c,'+
            'ElixirSuite__Anesthesia_code__c,ElixirSuite__Consent_code__c,ElixirSuite__Parent_Procedure__c,ElixirSuite__Parent_Procedure__r.Name,ElixirSuite__Surgeon__c,ElixirSuite__Surgeon__r.Name,'+
            'ElixirSuite__Room_1__c, ElixirSuite__Room_1__r.Name,ElixirSuite__Bed_1__c, ElixirSuite__Bed_1__r.Name,ElixirSuite__Facility_1__c, ElixirSuite__Facility_1__r.Name,'+
            'ElixirSuite__Status__c,ElixirSuite__Cancelation_Reason__c'+
            ' FROM '+ String.escapeSingleQuotes('ElixirSuite__Procedure__c') 
            + ' WHERE ' + String.escapeSingleQuotes('Id') + ' = '+ '\''+
            String.escapeSingleQuotes(recId)+'\'';
        return Database.query(query);
        
    }
    public static ElixirSuite__Procedure_Diagnosis__c[]  fetchDiagnosisData(String recId){
        return [SELECT ID,ElixirSuite__Procedure__c,ElixirSuite__ICD_Codes__c,ElixirSuite__Notes__c,ElixirSuite__ICD_Codes__r.Name,
                ElixirSuite__Description__c FROM ElixirSuite__Procedure_Diagnosis__c 
                WHERE ElixirSuite__Procedure__c = : recId WITH SECURITY_ENFORCED];   
    }
    public class WrapperForNewScreen{
        @AuraEnabled public Map<String, String> mapPickListValues = new Map<String, String>();
        @AuraEnabled public String defValue;
        @AuraEnabled public String patientName;
        @AuraEnabled public ElixirSuite__ICD_Codes__c[] patientICDs;
        @AuraEnabled public Map<String, String> mapPickListValues_placeOfService;
        @AuraEnabled public ElixirSuite__Procedure_Diagnosis__c[] junctionData;
        @AuraEnabled public  ElixirSuite__Procedure__c[] procedureRecords;
        @AuraEnabled public  ElixirSuite__Claim__c obj;
        @AuraEnabled public  Boolean isProcessed = false;
        @AuraEnabled public Map<String, String> mapPickListValues_status;
        @AuraEnabled public Map<String, String> mapPickListValues_defaultStatus;
        @AuraEnabled public Map<String, String> mapPickListValues_claimType;
        @AuraEnabled public Map<String, String> mapPickListValues_defaultClaimType;
        @AuraEnabled public Map<String, String> mapPickListValues_paymentType;
        @AuraEnabled public String procedureRecordTypeId;
        @AuraEnabled public String practitionerRecTypeId;
        @AuraEnabled public String bedRecordTypeId;
        @AuraEnabled public String roomRecordTypeId;
        @AuraEnabled public String suiteRecordTypeId;
    }
    public static ElixirSuite__ICD_Codes__c[] fetchAllDiagnosisForPatient(String accountId){
        ElixirSuite__Diagnosis_Code__c[] junctionRecords = [SELECT ID,ElixirSuite__Diagnosis_Code__c FROM ElixirSuite__Diagnosis_Code__c
                                                            WHERE (ElixirSuite__Problem__r.ElixirSuite__Account__c =: accountId OR ElixirSuite__Diagnosis_Code__r.ElixirSuite__Account__c =:accountId) WITH SECURITY_ENFORCED];
        Set<Id> diagnosisLst = new Set<Id>();
        for(ElixirSuite__Diagnosis_Code__c sObj : junctionRecords){
            diagnosisLst.add(sObj.ElixirSuite__Diagnosis_Code__c);
        }
        ElixirSuite__ICD_Codes__c[] patientICDs = [SELECT ID,Name,ElixirSuite__Code_Description1__c FROM ElixirSuite__ICD_Codes__c 
                                                   WHERE ID IN : diagnosisLst WITH SECURITY_ENFORCED];
        return patientICDs;
    }
    @AuraEnabled
    public static Boolean getCareEpisodeCustomSetting(){
        Elixir_Custom_Setting__c mcs = Elixir_Custom_Setting__c.getOrgDefaults();
        if(mcs.ElixirSuite__Care_Episode_Update_on_Medical_Coding__c==true){
            return true;
        }
        else{
            return false;
        }
    }
    /*  @AuraEnabled
public static Boolean checkForExistingModifiers(String procedureCode){
ElixirSuite__Procedure__c[] records =  ProcedureSearchHelper.modfierList(procedureCode);
if(records.isEmpty()){
return true;
}
else{
return false;
}
}

@AuraEnabled
public static void deleteProcedureDiagnosis(String deleterecordId){
system.debug('1inside deleteProcedureDiagnosis '+deleterecordId );
if(deleterecordId != null){
system.debug('2name '+[Select name from ElixirSuite__ICD_Codes__c where id =: deleterecordId]);
Delete [Select id from ElixirSuite__ICD_Codes__c where id =: deleterecordId]; 
}
}

@AuraEnabled
public static void updateDiagnosis(String updaterecordId){
system.debug('1inside updateDiagnosis '+updaterecordId );
if(updaterecordId != null){
system.debug('3name '+[Select ElixirSuite__Description__c, ElixirSuite__Notes__c from ElixirSuite__Procedure_Diagnosis__c where id =: updaterecordId]);
Update [Select ElixirSuite__Description__c, ElixirSuite__Notes__c from ElixirSuite__Procedure_Diagnosis__c where id =: updaterecordId]; 
}
}
*/
    /*
@AuraEnabled
public static void updateProcedure(String payload,String accountId,String diagnosisData,String modifierData,String procedureId){

updateProcedure(payload,accountId,diagnosisData,modifierData); 

}*/
    @AuraEnabled
    public static void updateProcedure(String payload,String accountId,String diagnosisData,String modifierData,String procedureId, String deletediagnosisData) {
        
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
        Map<String, Object> lstOfPayload =(Map<String, Object>) JSON.deserializeUntyped(payload);
        Map<String, Object> obj_Record = ( Map<String, Object>) lstOfPayload.get('keysToSave');  
        
        List<ElixirSuite__Procedure__c> procedureList = new List<ElixirSuite__Procedure__c>();
        ElixirSuite__Procedure__c sObj = new ElixirSuite__Procedure__c(
            Name = String.valueOf(obj_Record.get('procedureSelected')),
            ElixirSuite__Account__c = accountId,
            RecordTypeId = devRecordTypeId,
            Id = String.valueOf(obj_Record.get('Id')),
            ElixirSuite__Code_Description__c = String.valueOf(obj_Record.get('procedureDescription')),
            ElixirSuite__Place_Of_Service_Picklist__c =  String.valueOf(obj_Record.get('placeOfService')),         
            ElixirSuite__Diagnosis_Pointer__c  = String.valueOf(obj_Record.get('diagnosisPointer')),
            ElixirSuite__Pre_auth_Code__c =  String.valueOf(obj_Record.get('preAuthCode')),
            ElixirSuite__Notes__c = String.valueOf(obj_Record.get('Notes')),
            ElixirSuite__Ready_for_Billing__c = Boolean.valueOf(obj_Record.get('isReadyForBilling')),
            ElixirSuite__Claim_Generation__c = Boolean.valueOf(obj_Record.get('claimGenerated')),
            ElixirSuite__Is_Billable__c = Boolean.valueOf(obj_Record.get('isBillable')),
            ElixirSuite__Code_Category__c =  String.valueOf(obj_Record.get('codeCategorySelected')),        
            ElixirSuite__Claim_type__c = String.valueOf(obj_Record.get('claimType')),
            ElixirSuite__Is_Processed__c  = Boolean.valueOf(obj_Record.get('isProcessed')),
            ElixirSuite__Type_of_Procedure__c = String.valueOf(obj_Record.get('typeOfPayment'))
            
        );
        //added by jami LX3-11839
         if (String.isNotBlank(String.valueOf(obj_Record.get('Status')))) {
            sObj.ElixirSuite__Status__c = String.valueOf(obj_Record.get('Status'));
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('cancelationReason')))) {
            sObj.ElixirSuite__Cancelation_Reason__c = String.valueOf(obj_Record.get('cancelationReason'));
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('surgeonValue'))) && String.valueOf(obj_Record.get('surgeonValue'))!='') {
            sObj.ElixirSuite__Surgeon__c = String.valueOf(obj_Record.get('surgeonValue'));
        }else{
            sObj.ElixirSuite__Surgeon__c =null;  
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('parentProcedureValue')))  && String.valueOf(obj_Record.get('parentProcedureValue'))!='') {
            sObj.ElixirSuite__Parent_Procedure__c = String.valueOf(obj_Record.get('parentProcedureValue'));
        }else{
            sObj.ElixirSuite__Parent_Procedure__c =null;  
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('bedValue'))) && String.valueOf(obj_Record.get('bedValue'))!='') {
            sObj.ElixirSuite__Bed_1__c = String.valueOf(obj_Record.get('bedValue'));
        }else{
            sObj.ElixirSuite__Bed_1__c =null;  
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('roomValue')))  && String.valueOf(obj_Record.get('roomValue'))!='') {
            sObj.ElixirSuite__Room_1__c = String.valueOf(obj_Record.get('roomValue'));
        }else{
            sObj.ElixirSuite__Room_1__c =null;  
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('facilityValue')))  && String.valueOf(obj_Record.get('facilityValue'))!='') {
            sObj.ElixirSuite__Facility_1__c = String.valueOf(obj_Record.get('facilityValue'));
        }else{
            sObj.ElixirSuite__Facility_1__c =null;  
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('anesthesiaCode')))  && String.valueOf(obj_Record.get('anesthesiaCode'))!='') {
            sObj.ElixirSuite__Anesthesia_code__c = String.valueOf(obj_Record.get('anesthesiaCode'));
        }else{
            sObj.ElixirSuite__Anesthesia_code__c =null;  
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('consentCode'))) && String.valueOf(obj_Record.get('consentCode'))!='') {
            sObj.ElixirSuite__Consent_code__c = String.valueOf(obj_Record.get('consentCode'));
        }else{
            sObj.ElixirSuite__Consent_code__c =null;  
        }
        if(String.isNotBlank(String.valueOf(obj_Record.get('careEpisode'))) && String.valueOf(obj_Record.get('careEpisode'))!=''){ 
            sObj.ElixirSuite__Visits__c = String.valueOf(obj_Record.get('careEpisode'));
        }else{
            sObj.ElixirSuite__Visits__c =null;
            sObj.ElixirSuite__Provider__c = null;
        }
        if(String.isNotBlank(String.valueOf(obj_Record.get('procedureStart')))){   
            String formatDateTime = String.valueOf(obj_Record.get('procedureStart')).trim();
            formatDateTime = formatDateTime.replace('T', ' ');
            Datetime now = DateTime.valueOf(formatDateTime);
            Integer offset = UserInfo.getTimezone().getOffset(now);
            Datetime local = now.addSeconds(offset/1000);           
            sObj.ElixirSuite__From_Date_of_Service__c =  local;
            
        }
        if(String.isNotBlank(String.valueOf(obj_Record.get('procedureEnd')))){
            String formatDateTime = String.valueOf(obj_Record.get('procedureEnd')).trim();
            formatDateTime = formatDateTime.replace('T', ' ');
            Datetime now = DateTime.valueOf(formatDateTime);
            Integer offset = UserInfo.getTimezone().getOffset(now);
            Datetime local = now.addSeconds(offset/1000);           
            sObj.ElixirSuite__To_Date_of_Service__c =  local;
        }
        
        if(String.isNotBlank(String.valueOf(obj_Record.get('unitsDuration')))){
            sObj.ElixirSuite__Days_Units__c = Integer.valueOf(obj_Record.get('unitsDuration'));
        }
        if(String.isNotBlank(modifierData)){
            
            List<Object> lstOfModifierData = (List<Object>) JSON.deserializeUntyped(modifierData);
            Integer i = 1;
            Integer count = 0;
            
            for(Object recsObj : lstOfModifierData){           
                Map<String, Object> mapOfModfier = (Map<String, Object>) recsObj;      
                sObj.put('ElixirSuite__Modifier'+i+'__c',String.valueOf(mapOfModfier.get('modfierId')));    
                sObj.put('ElixirSuite__Description_'+i+'__c',String.valueOf(mapOfModfier.get('description')));    
                sObj.put('ElixirSuite__Notes_'+i+'__c',String.valueOf(mapOfModfier.get('notes')));
                i++;     
                if(!(String.isBlank(String.valueOf(mapOfModfier.get('modfierId'))))){
                    count++;  
                }
            }  
            if(lstOfModifierData.size()==0){
                sObj.put('ElixirSuite__Modifier1__c','');
                sObj.put('ElixirSuite__Notes_1__c','');
                sObj.put('ElixirSuite__Modifier2__c','');
                sObj.put('ElixirSuite__Notes_2__c','');
                sObj.put('ElixirSuite__Modifier3__c','');
                sObj.put('ElixirSuite__Notes_3__c','');
                sObj.put('ElixirSuite__Modifier4__c','');
                sObj.put('ElixirSuite__Notes_4__c','');
            }
            else if(lstOfModifierData.size()==1){
                sObj.put('ElixirSuite__Modifier2__c','');
                sObj.put('ElixirSuite__Notes_2__c','');
                sObj.put('ElixirSuite__Modifier3__c','');
                sObj.put('ElixirSuite__Notes_3__c','');
                sObj.put('ElixirSuite__Modifier4__c','');
                sObj.put('ElixirSuite__Notes_4__c','');
                
            }else if(lstOfModifierData.size()==2){
                sObj.put('ElixirSuite__Modifier3__c','');
                sObj.put('ElixirSuite__Notes_3__c','');
                sObj.put('ElixirSuite__Modifier4__c','');
                sObj.put('ElixirSuite__Notes_4__c','');
            }else if(lstOfModifierData.size()==3){
                sObj.put('ElixirSuite__Modifier4__c','');
                sObj.put('ElixirSuite__Notes_4__c','');
            }
            sObj.ElixirSuite__Count_of_total_modifiers_used__c = count;
            /*if(String.isBlank(String.valueOf(sObj.get('ElixirSuite__Modifier1__c')))){
sObj.ElixirSuite__Count_of_total_modifiers_used__c = 0;  
}*/
            
        }   
        procedureList.add(sObj);
        if(procedureList != NULL && procedureList.size() > 0){
            DMLManager.updateAsUser(sObj);
        }
        
        
      /*  if(String.isNotBlank(diagnosisData)){
            List<Object> lstOfDiagnosisData = (List<Object>) JSON.deserializeUntyped(diagnosisData);
            
            ElixirSuite__Procedure_Diagnosis__c[] dataToInsert = new List<ElixirSuite__Procedure_Diagnosis__c>();
            List<ElixirSuite__Procedure_Diagnosis__c> dataToUpdate = new List<ElixirSuite__Procedure_Diagnosis__c>();
            try{
                for(Object diagnosisObject : lstOfDiagnosisData){
                    Map<String, Object> mapOfDiagnosis = (Map<String, Object>) diagnosisObject;
                    string diagnosisId = String.valueOf(mapOfDiagnosis.get('Id'));
                    string insertRec = String.valueOf(mapOfDiagnosis.get('type'));
                    if(insertRec == 'New'){
                        ElixirSuite__Procedure_Diagnosis__c rec = new ElixirSuite__Procedure_Diagnosis__c();
                        rec.ElixirSuite__Procedure__c = sObj.Id;
                        rec.ElixirSuite__ICD_Codes__c = String.valueOf(mapOfDiagnosis.get('Id'));
                        rec.ElixirSuite__Account__c = accountId;
                        rec.ElixirSuite__Description__c = String.valueOf(mapOfDiagnosis.get('description'));
                        rec.ElixirSuite__Notes__c = String.valueOf(mapOfDiagnosis.get('notes'));
                        dataToInsert.add(rec);  
                    }
                    else{
                        ElixirSuite__Procedure_Diagnosis__c proList = [SELECT Id, ElixirSuite__Procedure__c, ElixirSuite__ICD_Codes__c,
                                                                       ElixirSuite__Description__c,ElixirSuite__Notes__c
                                                                       FROM ElixirSuite__Procedure_Diagnosis__c 
                                                                       where ElixirSuite__ICD_Codes__c =: diagnosisId and ElixirSuite__Procedure__c =:procedureId 
                                                                       WITH SECURITY_ENFORCED LIMIT 1];
                        proList.ElixirSuite__Description__c = String.valueOf(mapOfDiagnosis.get('description'));
                        proList.ElixirSuite__Notes__c = String.valueOf(mapOfDiagnosis.get('notes'));
                        dataToUpdate.add(proList);
                    }
                }
            }
            catch(Exception e){
                ExceptionLog.logError(e);
            }
            if(dataToInsert != null && dataToInsert.size()>0)
            {
                DMLManager.insertAsUser(dataToInsert);
            }
            if(dataToUpdate != null && dataToUpdate.size()>0)
            {
                DMLManager.updateAsUser(dataToUpdate);
            }
            
        }*/
        List<ElixirSuite__ICD_Codes__c> existingDiagnosisRecords=new List<ElixirSuite__ICD_Codes__c>();
        if (String.isNotBlank(diagnosisData)) {
        List<Object> lstOfDiagnosisData = (List<Object>) JSON.deserializeUntyped(diagnosisData);
     
        ElixirSuite__Procedure_Diagnosis__c[] dataToUpsert = new List<ElixirSuite__Procedure_Diagnosis__c>();
        ElixirSuite__ICD_Codes__c[] diagnosisDataToUpdate = new List<ElixirSuite__ICD_Codes__c>();

        List<String> daignosisIdLst = new List<String>();
        Map<String, String> templateTransactionalDiagnosismap = new Map<String, String>(); // Declare the map
                
        for(Object diagnosisObject : lstOfDiagnosisData){
        Map<String, Object> mapOfDiagnosis = (Map<String, Object>) diagnosisObject;
      // Use the correct variable name mapOfDiagnosis instead of mapOfDiagnosis1
        daignosisIdLst.add(String.valueOf(mapOfDiagnosis.get('Id')));
            }
        List<ElixirSuite__ICD_Codes__c> allPatientDiagnosis = new List<ElixirSuite__ICD_Codes__c>();
        allPatientDiagnosis= [SELECT ID, Name, ElixirSuite__Template_Diagnosis_Code__c, ElixirSuite__Code_Description1__c
        FROM ElixirSuite__ICD_Codes__c WHERE ElixirSuite__Template_Diagnosis_Code__c IN :daignosisIdLst WITH SECURITY_ENFORCED];
    
        
        for(ElixirSuite__ICD_Codes__c patientDiagnosis : allPatientDiagnosis){
                templateTransactionalDiagnosismap.put(patientDiagnosis.ElixirSuite__Template_Diagnosis_Code__c, patientDiagnosis.Id);
            }
       // try {
        for (Object diagnosisObject : lstOfDiagnosisData) {
            Map<String, Object> mapOfDiagnosis = (Map<String, Object>) diagnosisObject;
            String diagnosisId = String.valueOf(mapOfDiagnosis.get('Id'));
           System.debug('diagnosisId'+diagnosisId);

            if (String.isNotBlank(diagnosisId)) {
                    existingDiagnosisRecords = [
                SELECT ID, Name, ElixirSuite__Code_Description1__c, ElixirSuite__Notes__c
                FROM ElixirSuite__ICD_Codes__c
                WHERE ID = :diagnosisId WITH SECURITY_ENFORCED
            ];

            System.debug('existingDiagnosisRecords' + existingDiagnosisRecords);

            for (ElixirSuite__ICD_Codes__c patientDiagnosis : existingDiagnosisRecords) {
                patientDiagnosis.ElixirSuite__Code_Description1__c = String.valueOf(mapOfDiagnosis.get('description'));
                patientDiagnosis.ElixirSuite__Notes__c = String.valueOf(mapOfDiagnosis.get('notes'));
            }

           
            // Query to check if the record already exists
            List<ElixirSuite__Procedure_Diagnosis__c> existingRecords = [
                SELECT Id
                FROM ElixirSuite__Procedure_Diagnosis__c
                WHERE ElixirSuite__ICD_Codes__c = :diagnosisId
                AND ElixirSuite__Procedure__c = :sObj.Id
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
 			 System.debug('existingRecords'+existingRecords);
             System.debug('sObj.Id'+sObj.Id);
             System.debug('diagnosisId'+diagnosisId);
            ElixirSuite__Procedure_Diagnosis__c rec = new ElixirSuite__Procedure_Diagnosis__c();
            rec.ElixirSuite__Procedure__c = sObj.Id;
            if(templateTransactionalDiagnosismap.containsKey(String.valueOf(mapOfDiagnosis.get('Id')))){
                rec.ElixirSuite__ICD_Codes__c = templateTransactionalDiagnosismap.get(String.valueOf(mapOfDiagnosis.get('Id')));
            }
            else {
                rec.ElixirSuite__ICD_Codes__c = String.valueOf(mapOfDiagnosis.get('Id')); // it always links to template
            }
            rec.ElixirSuite__Account__c = accountId;
            rec.ElixirSuite__Description__c = String.valueOf(mapOfDiagnosis.get('description'));
            rec.ElixirSuite__Notes__c = String.valueOf(mapOfDiagnosis.get('notes'));
 
            if (!existingRecords.isEmpty()) {
                // Record exists, so update
                rec.Id = existingRecords[0].Id;
            }
 
            dataToUpsert.add(rec);
            }
        }
   /* } catch (Exception e) {
        ExceptionLog.logError(e);
    }*/
 
    if (dataToUpsert != null && dataToUpsert.size() > 0) {
        DMLManager.upsertAsUser(dataToUpsert);
    }
    
        if (!existingDiagnosisRecords.isEmpty()) {
         DMLManager.updateAsUser(existingDiagnosisRecords);
    }
}




        if(String.isNotBlank(deletediagnosisData)){
            List<Object> lstOfDeleteData = (List<Object>) JSON.deserializeUntyped(deletediagnosisData);
            List<ElixirSuite__Procedure_Diagnosis__c> dataToDelete = new List<ElixirSuite__Procedure_Diagnosis__c>();
            Set<Id> recId = new Set<Id>();
            try{
                for(Object diagnosisObject : lstOfDeleteData){
                    Map<String, Object> mapOfDiagnosis = (Map<String, Object>) diagnosisObject;
                    string diagnosisId = String.valueOf(mapOfDiagnosis.get('Id'));
                    diagnosisId=diagnosisId.replace('(','');
                    diagnosisId=diagnosisId.replace(')','');
                    recId.add(diagnosisId);
                }
                dataToDelete = [SELECT Id, ElixirSuite__Procedure__c, ElixirSuite__ICD_Codes__c
                                FROM ElixirSuite__Procedure_Diagnosis__c 
                                where ElixirSuite__ICD_Codes__c =:recId and ElixirSuite__Procedure__c =:procedureId
                                WITH SECURITY_ENFORCED];
            }
            catch(Exception e){
                ExceptionLog.logError(e);
            } 
            if(dataToDelete != null && dataToDelete.size()>0)
            {
                DMLManager.deleteAsUser(dataToDelete);
            }
            
        }
        
    }
    
    @AuraEnabled
    public static Boolean checkForModifierCombination(List<String> lstModifiers, String strRefCPTCode){
        ElixirSuite__Procedure__c[] records =  CheckModifierController.getTemplateProcedureForModifiers(lstModifiers,strRefCPTCode);
        
        if(records.isEmpty()){
            return false;
        }
        else{
            return true;
        }
    }
    
    @AuraEnabled
    public static Boolean isDiagnosisCodeAvailableForThisAccount(String accountId){
        try {
            return CreateNewProcedureHandler.isDiagnosisCodeAvailableForThisAccount(accountId);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    
    public static List<CreateNewProcedureHandler.DataWrapper> getFieldData(String ObjectName, String fieldSetName){
        try{
            List<CreateNewProcedureHandler.DataWrapper> dataWrapList = new List<CreateNewProcedureHandler.DataWrapper>();
            dataWrapList = CreateNewProcedureHandler.getFieldData(ObjectName,fieldSetName);
            return dataWrapList;
        }catch(Exception e){
            ExceptionLog.logError(e);
            return NULL;
        }
        
    }
}