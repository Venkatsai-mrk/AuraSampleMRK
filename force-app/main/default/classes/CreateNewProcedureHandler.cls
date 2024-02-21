public with sharing class CreateNewProcedureHandler {
    @AuraEnabled
    public static WrapperForNewScreen newScreenProcedureDomain(String accountId){
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
        sObj.mapPickListValues_status = MasterProblemListController.fetchClaimTypePickListValue('ElixirSuite__Procedure__c','ElixirSuite__Status__c');
        sObj.mapPickListValues_defaultStatus = MasterProblemListController.fetchDefaultPickListValue('ElixirSuite__Procedure__c','ElixirSuite__Status__c');
        sObj.mapPickListValues_defaultClaimType = MasterProblemListController.fetchDefaultPickListValue('ElixirSuite__Procedure__c','ElixirSuite__Claim_type__c');
        sObj.mapPickListValues_paymentType = MasterProblemListController.fetchPickListValue('ElixirSuite__Procedure__c','ElixirSuite__Type_of_Procedure__c');
        sObj.paymentType  = PaymentController.getERASetting(); 
        sObj.activeCareEpisode = getActiveCareEpisode(accountId);
        String patientName = '';
        Account[] accRec = [SELECT Name FROM Account WHERE ID = : accountId WITH SECURITY_ENFORCED];
        try{
            if(accRec!=null && accRec.size()>0){
                patientName = accRec[0].Name;
            }
            sObj.patientName = patientName;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
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

    @AuraEnabled
    public static DefWrapper getPlaceOfServiceAndCodeCategory(){
        
        DefWrapper def = new DefWrapper();
        String defaultVal;
        Schema.DescribeFieldResult F = ElixirSuite__Procedure__c.ElixirSuite__Place_Of_Service_Picklist__c.getDescribe();
        List <Schema.PicklistEntry> pickVals = F.getPicklistValues();        
        for (Schema.PicklistEntry pv: pickVals) {
            if (pv.isDefaultValue()) {
                defaultVal = pv.getValue();
            }    
        }
        
        String defaultVal1;
        Schema.DescribeFieldResult F1 = ElixirSuite__Procedure__c.ElixirSuite__Code_Category__c.getDescribe();
        List <Schema.PicklistEntry> pickVals1 = F1.getPicklistValues();        
        for (Schema.PicklistEntry pv: pickVals1) {
            if (pv.isDefaultValue()) {
                defaultVal1 = pv.getValue();
            }    
        }
        
        def.defPlaceOfServiceValue = defaultVal;
        def.defCodeCategoryValue = defaultVal1;
        
        return def;
        
    }
    
    public class DefWrapper{
        @AuraEnabled public String defPlaceOfServiceValue;
        @AuraEnabled public String defCodeCategoryValue;
    }
    
    public class WrapperForNewScreen{
        @AuraEnabled public Map<String, String> mapPickListValues = new Map<String, String>();
        @AuraEnabled public String defValue;
        @AuraEnabled public String patientName;
        @AuraEnabled public ElixirSuite__ICD_Codes__c[] patientICDs;
        @AuraEnabled public Map<String, String> mapPickListValues_placeOfService;
        @AuraEnabled public Map<String, String> mapPickListValues_claimType;
        @AuraEnabled public Map<String, String> mapPickListValues_status;
        @AuraEnabled public Map<String, String> mapPickListValues_defaultStatus;
        @AuraEnabled public Map<String, String> mapPickListValues_defaultClaimType;
        @AuraEnabled public Map<String, String> mapPickListValues_paymentType;
        @AuraEnabled public ElixirSuite__ERA_Generation__c paymentType;
        @AuraEnabled public String procedureRecordTypeId;
        @AuraEnabled public String practitionerRecTypeId;
        @AuraEnabled public String bedRecordTypeId;
        @AuraEnabled public String roomRecordTypeId;
        @AuraEnabled public String suiteRecordTypeId;
        @AuraEnabled public ElixirSuite__Visits__c activeCareEpisode;
    }
    public static ElixirSuite__Visits__c getActiveCareEpisode(String accountId){
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
        if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
        String careStatus = 'Active';
        
        string querystr = '';
        querystr += 'Select Id,Name,ElixirSuite__Account__c,ElixirSuite__Status__c,ElixirSuite__Rendering_Provider__r.Id,ElixirSuite__Rendering_Provider__r.Name from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c = : accountId WITH SECURITY_ENFORCED order by ';
        querystr += careFilter ;
        ElixirSuite__Visits__c[] activeCP = database.query(querystr);
        if(activeCP.size()>0 && activeCP != null){
            return activeCP[0];
        }else{
            return null;
        }
    }
    public static ElixirSuite__ICD_Codes__c[] fetchAllDiagnosisForPatient(String accountId){
        ElixirSuite__Diagnosis_Code__c[] junctionRecords = [SELECT ID,ElixirSuite__Diagnosis_Code__c FROM ElixirSuite__Diagnosis_Code__c
                                                            WHERE (ElixirSuite__Problem__r.ElixirSuite__Account__c =: accountId OR ElixirSuite__Diagnosis_Code__r.ElixirSuite__Account__c =:accountId) WITH SECURITY_ENFORCED];
        Set<Id> diagnosisLst = new Set<Id>();
        for(ElixirSuite__Diagnosis_Code__c sObj : junctionRecords){
            diagnosisLst.add(sObj.ElixirSuite__Diagnosis_Code__c);
        }
        ElixirSuite__ICD_Codes__c[] patientICDs = [SELECT ID,Name,ElixirSuite__Code_Description1__c FROM ElixirSuite__ICD_Codes__c WHERE ID IN : diagnosisLst WITH SECURITY_ENFORCED];
        return patientICDs;
    }
    @AuraEnabled
    public static Boolean checkForExistingModifiers(){
        Elixir_Custom_Setting__c mcs = Elixir_Custom_Setting__c.getOrgDefaults();
        if(mcs.ElixirSuite__Add_Modifiers_Feature__c==true){
            return true;
        }
        else{
            return false;
        }
    }
    @AuraEnabled
    public static ReturnWrapper saveProcedure(String payload,String accountId,String diagnosisData,String modifierData) {
        
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
        Map<String, Object> lstOfPayload =(Map<String, Object>) JSON.deserializeUntyped(payload);
        Map<String, Object> obj_Record = ( Map<String, Object>) lstOfPayload.get('keysToSave');  
        
        
        //added by Anmol for LX3-7236
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
        if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
        String careStatus = 'Active';
        
        string querystr = '';
        querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c = : accountId WITH SECURITY_ENFORCED order by ';
        querystr += careFilter ;
        ElixirSuite__Visits__c[] activeCP = database.query(querystr);
        List<ElixirSuite__Procedure__c> procedureList = new List<ElixirSuite__Procedure__c>();
        ElixirSuite__Procedure__c sObj = new ElixirSuite__Procedure__c(
            Name = String.valueOf(obj_Record.get('procedureSelected')),
            ElixirSuite__Account__c = accountId,
            RecordTypeId = devRecordTypeId,
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
            ElixirSuite__Type_of_Procedure__c = String.valueOf(obj_Record.get('typeOfPayment')),
            ElixirSuite__Reference_CPT_Code__c = String.valueOf(obj_Record.get('referenceCPTCode'))
        );
        //added by jami LX3-11839
        if (String.isNotBlank(String.valueOf(obj_Record.get('Status')))) {
            sObj.ElixirSuite__Status__c = String.valueOf(obj_Record.get('Status'));
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('cancelationReason')))) {
            sObj.ElixirSuite__Cancelation_Reason__c = String.valueOf(obj_Record.get('cancelationReason'));
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('surgeonValue')))) {
            sObj.ElixirSuite__Surgeon__c = String.valueOf(obj_Record.get('surgeonValue'));
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('parentProcedureValue')))) {
            sObj.ElixirSuite__Parent_Procedure__c = String.valueOf(obj_Record.get('parentProcedureValue'));
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('anesthesiaCode')))) {
            sObj.ElixirSuite__Anesthesia_code__c = String.valueOf(obj_Record.get('anesthesiaCode'));
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('consentCode')))) {
            sObj.ElixirSuite__Consent_code__c = String.valueOf(obj_Record.get('consentCode'));
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('bedValue')))) {
            sObj.ElixirSuite__Bed_1__c = String.valueOf(obj_Record.get('bedValue'));
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('roomValue')))) {
            sObj.ElixirSuite__Room_1__c = String.valueOf(obj_Record.get('roomValue'));
        }
        if (String.isNotBlank(String.valueOf(obj_Record.get('facilityValue')))) {
            sObj.ElixirSuite__Facility_1__c = String.valueOf(obj_Record.get('facilityValue'));
        }
        
        if(String.isNotBlank(String.valueOf(obj_Record.get('careIdVal')))){
            System.debug('line213***');
            sObj.ElixirSuite__Visits__c = String.valueOf(obj_Record.get('careIdVal'));
        }
        else if(!activeCP.isEmpty()){
            sObj.ElixirSuite__Visits__c = activeCP[0].id;
        }
        try{
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
                formulateModfierData(modifierData,sObj); 
            } 
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        procedureList.add(sObj);
        if(procedureList != NULL && procedureList.size() > 0){
            DMLManager.insertAsUser(procedureList); 
        }
        
        
        /* if(String.isNotBlank(diagnosisData)){
            List<Object> lstOfDiagnosisData = (List<Object>) JSON.deserializeUntyped(diagnosisData);
            ElixirSuite__Procedure_Diagnosis__c[] dataToInsert = new List<ElixirSuite__Procedure_Diagnosis__c>();
            try{
                for(Object diagnosisObject : lstOfDiagnosisData){
                    Map<String, Object> mapOfDiagnosis = (Map<String, Object>) diagnosisObject;
                    ElixirSuite__Procedure_Diagnosis__c rec = new ElixirSuite__Procedure_Diagnosis__c();
                    rec.ElixirSuite__Procedure__c = sObj.Id;
                    rec.ElixirSuite__ICD_Codes__c = String.valueOf(mapOfDiagnosis.get('Id'));
                    rec.ElixirSuite__Account__c = accountId;
                    rec.ElixirSuite__Description__c = String.valueOf(mapOfDiagnosis.get('description'));
                    rec.ElixirSuite__Notes__c = String.valueOf(mapOfDiagnosis.get('notes'));
                    dataToInsert.add(rec);
                }
            }
            catch(Exception e){
                ExceptionLog.logError(e);
            }
            if(Schema.sObjectType.ElixirSuite__Procedure_Diagnosis__c.isCreateable()){
                insert dataToInsert;
            }
}*/
        if(String.isNotBlank(diagnosisData)){
    		List<Object> lstOfDiagnosisData = (List<Object>) JSON.deserializeUntyped(diagnosisData);
    		ElixirSuite__Procedure_Diagnosis__c[] dataToInsert = new List<ElixirSuite__Procedure_Diagnosis__c>();
    		List<String> daignosisIdLst = new List<String>();
    		Map<String, String> templateTransactionalDiagnosismap = new Map<String, String>(); // Declare the map

    	try{

        	for(Object diagnosisObject : lstOfDiagnosisData){
            Map<String, Object> mapOfDiagnosis = (Map<String, Object>) diagnosisObject;
  		
            daignosisIdLst.add(String.valueOf(mapOfDiagnosis.get('Id')));
        }

         List<ElixirSuite__ICD_Codes__c> allPatientDiagnosis = new List<ElixirSuite__ICD_Codes__c>();
        	allPatientDiagnosis= [SELECT ID, Name, ElixirSuite__Template_Diagnosis_Code__c, ElixirSuite__Code_Description1__c
         FROM ElixirSuite__ICD_Codes__c WHERE ElixirSuite__Template_Diagnosis_Code__c IN :daignosisIdLst WITH SECURITY_ENFORCED];

    
        for(ElixirSuite__ICD_Codes__c patientDiagnosis : allPatientDiagnosis){
            templateTransactionalDiagnosismap.put(patientDiagnosis.ElixirSuite__Template_Diagnosis_Code__c, patientDiagnosis.Id);
        }
       

        for(Object diagnosisObject : lstOfDiagnosisData){
            Map<String, Object> mapOfDiagnosis = (Map<String, Object>) diagnosisObject;
			ElixirSuite__Procedure_Diagnosis__c rec = new ElixirSuite__Procedure_Diagnosis__c();
            rec.ElixirSuite__Procedure__c = sObj.Id;

            // Corrected the condition to use mapOfDiagnosis.get('Id') instead of mapOfDiagnosis1.get('Id')
            if(templateTransactionalDiagnosismap.containsKey(String.valueOf(mapOfDiagnosis.get('Id')))){
                rec.ElixirSuite__ICD_Codes__c = templateTransactionalDiagnosismap.get(String.valueOf(mapOfDiagnosis.get('Id')));
            }
            else {
                rec.ElixirSuite__ICD_Codes__c = String.valueOf(mapOfDiagnosis.get('Id')); // it always links to template
            }

            rec.ElixirSuite__Account__c = accountId;
            rec.ElixirSuite__Description__c = String.valueOf(mapOfDiagnosis.get('description'));
            rec.ElixirSuite__Notes__c = String.valueOf(mapOfDiagnosis.get('notes'));
            dataToInsert.add(rec);
        }

       
    }
    catch(Exception e){
        ExceptionLog.logError(e);
    }

    if(Schema.sObjectType.ElixirSuite__Procedure_Diagnosis__c.isCreateable()){
        DMLManager.insertAsUser(dataToInsert);
    }

        }
        ReturnWrapper retobj = new ReturnWrapper();
        retobj.procRecord =  UpdateProcedureHandler.fetchProcedureRecord(sObj.Id);
        retobj.diagnosisLst = fetchDiagnosis(sObj.Id);
        return retobj;
    }
    public class ReturnWrapper{
        @AuraEnabled public ElixirSuite__Procedure__c[] procRecord;
        @AuraEnabled public ElixirSuite__Procedure_Diagnosis__c[] diagnosisLst;
    }
    public static ElixirSuite__Procedure_Diagnosis__c[] fetchDiagnosis(String recId){
        return [SELECT ID,ElixirSuite__ICD_Codes__r.Name,ElixirSuite__Description__c,ElixirSuite__Notes__c
                FROM ElixirSuite__Procedure_Diagnosis__c WHERE ElixirSuite__Procedure__c = : recId with security_enforced];
    }
    public static void formulateModfierData(String modifierData, ElixirSuite__Procedure__c sObj) {
        
        List<Object> lstOfModifierData = (List<Object>) JSON.deserializeUntyped(modifierData);
        Integer i = 1;
        Integer count = 0;
        try{
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
            
            sObj.ElixirSuite__Count_of_total_modifiers_used__c = count;
            /*if(String.isBlank(String.valueOf(sObj.get('ElixirSuite__Modifier1__c')))){
sObj.ElixirSuite__Count_of_total_modifiers_used__c = 0;  
}*/
        }
        catch(Exception e){
            ExceptionLog.logError(e);
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
            Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
            Boolean templateDiagnosis = customSetting.ElixirSuite__Allow_Patient_Diagnosis_On_RCM_Proceduer__c;

            if (accountId == null || accountId.trim() == '') {
                return false;
            }
            
            // Check for diagnosis codes related to the specified account
            List<ElixirSuite__ICD_Codes__c> allDiagnosisCodesForThisAccount =new List<ElixirSuite__ICD_Codes__c>();
        allDiagnosisCodesForThisAccount =[
                SELECT Id FROM ElixirSuite__ICD_Codes__c WHERE ElixirSuite__Account__c = :accountId WITH SECURITY_ENFORCED
            ];
            
            if (allDiagnosisCodesForThisAccount != null && !allDiagnosisCodesForThisAccount.isEmpty()) {
                return true;
            } else if (allDiagnosisCodesForThisAccount.size() ==0 && templateDiagnosis) {
            // Check for template diagnosis codes
            Id objectRecordTypeId = Schema.SObjectType.ElixirSuite__ICD_Codes__c
                    .getRecordTypeInfosByDeveloperName().get('Template_Diagnosis_Code').getRecordTypeId();

            List<ElixirSuite__ICD_Codes__c> allDiagnosisCodesForTemplate = new List<ElixirSuite__ICD_Codes__c>();
            allDiagnosisCodesForTemplate = [
                SELECT Id FROM ElixirSuite__ICD_Codes__c WHERE RecordTypeId = :objectRecordTypeId WITH SECURITY_ENFORCED Limit 1
            ];

            return allDiagnosisCodesForTemplate != null && !allDiagnosisCodesForTemplate.isEmpty();
        } else {
            return false;
}
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<DataWrapper> getFieldData(String ObjectName, String fieldSetName){
        try{
            List<DataWrapper> dataWrapList = new List<DataWrapper>();
            DataWrapper dataWrap = new DataWrapper();
            List<FieldSetHelper.WrapperOption> fieldSetOptions = FieldSetHelper.getFieldSetLabelValues(ObjectName,fieldSetName);
            Map<String,List<PicklistHelper.PicklistOptionWrapper>> fieldPicklistMap = new Map<String,List<PicklistHelper.PicklistOptionWrapper>>();
            for(FieldSetHelper.WrapperOption option : fieldSetOptions){
                if(option.fieldType == 'PICKLIST'){
                    fieldPicklistMap.put(option.value,PicklistHelper.getPicklistOptions(ObjectName,option.value));
                }
            }
            if(!fieldSetOptions.isEmpty()){
                dataWrap.fieldSetOptions = fieldSetOptions;
            }
            if(!fieldPicklistMap.isEmpty()){
                dataWrap.fieldPicklistOptionsMap = fieldPicklistMap;
            }
            dataWrapList.add(dataWrap);
            return dataWrapList;
        }catch(Exception e){
            ExceptionLog.logError(e);
            return NULL;
        }
        
    }
    public class DataWrapper {
        @AuraEnabled public List<FieldSetHelper.WrapperOption> fieldSetOptions;
        @AuraEnabled public Map<String,List<PicklistHelper.PicklistOptionWrapper>> fieldPicklistOptionsMap;
    }
}