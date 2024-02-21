public with sharing class PatientChartController {
    
    public PatientChartController(){
        
    }
    
    @AuraEnabled   
    public static ElixirSuite__Elixir_Custom_Setting__c getPDFData(){
        //System.debug('ElixirSuite__Elixir_Custom_Setting__c.getInstance() => '+ElixirSuite__Elixir_Custom_Setting__c.getInstance());
        return ElixirSuite__Elixir_Custom_Setting__c.getInstance();
    }
    @AuraEnabled
    public static List<ElixirSuite__Elixir_Custom_Setting__c> fetchValuesForCSSetting() {
        /*    return [SELECT ElixirSuite__Allergies_Medical_Alerts__c,ElixirSuite__Clinician_Notes__c,ElixirSuite__Discharge_Notes__c,
ElixirSuite__Doctor_Notes__c,ElixirSuite__Forms_Columns__c,ElixirSuite__Form_Label__c,ElixirSuite__Inpatient__c,
ElixirSuite__Lab_Order__c,ElixirSuite__MOR_MAR__c,ElixirSuite__Namespace__c,ElixirSuite__Nurse_Notes__c,
ElixirSuite__Outpatient__c,ElixirSuite__Prescriptions__c,ElixirSuite__Problem_List__c,ElixirSuite__UR_Notes__c,Id,Name 
FROM ElixirSuite__Elixir_Custom_Setting__c];*/
        return [SELECT Id, ElixirSuite__Allergies_Medical_Alerts__c,ElixirSuite__Lab_Order__c,ElixirSuite__MOR_MAR__c,
                ElixirSuite__Prescriptions__c,ElixirSuite__Problem_List__c, ElixirSuite__Vital_Signs__c, ElixirSuite__Procedure_Code__c, ElixirSuite__Diagnosis_Code__c
                FROM ElixirSuite__Elixir_Custom_Setting__c WHERE ID!=NULL WITH SECURITY_ENFORCED];
    }
    @AuraEnabled
    public static List<ElixirSuite__Form_Category__c> fetchValuesForCategoriesSetting() {
        
        return [
            SELECT
                Id, ElixirSuite__Category__c,
                Category1__c, Category2__c, Category3__c, Category4__c, Category5__c, 
                Category6__c, Category7__c, Category8__c, Category9__c, Category10__c, 
                Category11__c, Category12__c, Category13__c, Category14__c, Category15__c, 
                Category16__c, Category17__c, Category18__c, Category19__c
            FROM
                ElixirSuite__Form_Category__c
            WHERE
                ID!=NULL
            AND
                SetupOwnerId=:Userinfo.getProfileId()
            WITH
                SECURITY_ENFORCED
        ];
    }
    
    @AuraEnabled
    public static  Map<String,String> fetchFieldsForSelectedObject() {       
        return new Map<String, String>{        
            'ElixirSuite__Allergies_Medical_Alerts__c' => 'Allergies',
            'ElixirSuite__Diagnosis_Code__c' => 'Diagnosis Code',
            'ElixirSuite__Lab_Order__c' => 'Lab Order',
            'ElixirSuite__MOR_MAR__c' => 'MOR/MAR',
            'ElixirSuite__Prescriptions__c' => 'Prescriptions',
            'ElixirSuite__Problem_List__c' => 'Problem List',
            'ElixirSuite__Procedure_Code__c' => 'Procedure Code',
            'ElixirSuite__Vital_Signs__c' => 'Vital Signs'
        };
        
    }
    @AuraEnabled
    public static void generatePdf(List<String> episodeIds, String formAttributes, String otherAttributes){
        if (episodeIds != null && episodeIds.size() > 0 && formAttributes != null) {
            String sampleVisitId = episodeIds[0];
            List<ElixirSuite__Visits__c> sampleVisitToGetAccountId = [
                SELECT Id, Account__c
                  FROM Visits__c
                 WHERE Id= :sampleVisitId
                  WITH SECURITY_ENFORCED];
            
            if (sampleVisitToGetAccountId != null && sampleVisitToGetAccountId.size() > 0) {
                String accId = sampleVisitToGetAccountId[0].Account__c;
                
                // Call getFormsDataForPDF with first episodeId
                // Once ZIP for this episodeId is generated, This function will be called again with first careEpisode id removed
                // and we will keep getting called until no episodeId remains
                Set<String> episodeIdsSet = new Set<String>(episodeIds);
                Set<Id> emptyZipIdSet = new set<Id>();
                getFormsDataForPDF(accId, formAttributes, episodeIds[0], otherAttributes, episodeIdsSet, emptyZipIdSet);
                // System.debug('C0: ' + episodeIds[0]);
                // System.debug('C1: ' + episodeIds[1]);
            }
        }
    }

    public static void getFormsDataForPDF(Id accId,String formsCategoryBundle, Id episodeId, String otherAttributes, Set<String> allEpisodeIds, Set<Id> zipIds){  
        String nspc;
        if(String.isNotBlank(Elixir_Utility.getNamespace())){
            nspc = Elixir_Utility.getNamespace() + '__';
        }
        else { 
            nspc = '';
        }        
        if(String.isNotBlank(formsCategoryBundle)){
            Set<String> formIds = new Set<String>();
            List<Form_Value__c> episodes = [SELECT Id, Form_Id__c FROM Form_Value__c
                                            WHERE Episode_Id__c= :episodeId AND Form_Id__c!=NULL
                                            WITH SECURITY_ENFORCED];
            if(episodes!=null && episodes.size()>0){
                for(Form_Value__c episode :episodes){
                    formIds.add(episode.Form_Id__c);
                }
            }
            formsCategoryBundle = formsCategoryBundle.toLowerCase();
            String[] formCategories = formsCategoryBundle.split(';'); 
            List<String> fieldApiToExist = new List<String>{nspc+'Form_unique_id__c',nspc+'Form_RecordType_Name__c',nspc+'Form_Name__c',
                nspc+'Form_Category__c'};
                    Form_Object__mdt[] objectNames =  fetchAllObjectsInCS();
            String[] nameArrObj;
            if(objectNames!=null && objectNames.size()>0){
                nameArrObj =  objectNames[0].Object_Name__c.split(';');
            }
            if(nameArrObj!=null && nameArrObj.size()>0){
                Boolean doesObjectHasField = true;
                for(String objName : nameArrObj){
                    for(String rec : fieldApiToExist){
                        doesObjectHasField = doesFieldExist(objName,rec) || doesFieldExist(objName, rec.removeStart(nspc));
                    } 
                }
                system.debug(doesObjectHasField);
                if(doesObjectHasField){
                    Map<String, String> sObjMap = new Map<String, String>();                     
                    for(String objName : nameArrObj){
                        String fieldQuery = 'SELECT Id, Form_RecordType_Name__c, Form_unique_id__c, Form_Name__c, Form_Category__c FROM ';
                        fieldQuery+=objName+' ';
                        // fieldQuery+='where '+nspc+'AccountId__c = '+ '\''+String.escapeSingleQuotes(accId)+'\'';
                        String accIdEscaped = String.escapeSingleQuotes(accId);
                        fieldQuery+='where AccountId__c = :accIdEscaped';
                        List<sObject> sobjList = Database.query(String.escapeSingleQuotes(fieldQuery));  // QUERY TO BE MADE INSIDE FOR LOOPS FOR NUMBER OF OBJECTS MENTIONED IN METADATA
                        system.debug('sobjList size '+sobjList.size()+' data is '+sobjList);
                        if(sobjList!=null && sobjList.size()>0){                             
                            for (SObject record : sobjList){ 
                                String fName = String.valueOf(record.get('Form_RecordType_Name__c'));
                                String fCName = String.valueOf(record.get('Form_Name__c'));
                                String formUniqueID = String.valueOf(record.get('Form_unique_id__c'));
                                Object value = record.get('Form_unique_id__c');   // FORMUNIQUE ID
                                if(!formIds.contains(formUniqueID)){
                                    continue;
                                }                                                       
                                System.debug('form category '+record.get('Form_Category__c'));
                                if(formCategories.contains(String.valueOf(record.get('Form_Category__c')).toLowerCase())){ // allow only selected form categories to be rendered as pdf
                                    sObjMap.put(String.valueOf(value),String.valueOf(value)+'&'+fName+'&'+fCName+'&'+String.valueOf(accId)); // PUT IN A MAP BECAUSE SAME FORMUNIQUEID CAN BE PRESENT ON THE 2 DIFFERENT OBJECTS   
                                }
                            }                                                        
                        }
                    }    
                    //system.debug('sobjMap size '+sobjMap.size()+' data is '+sobjMap);    
                    if(sObjMap.keySet().size()>0){
                        System.enqueueJob(new SavePatientChartPdfQueueable(sObjMap, accId, 1, new Set<Id>{}, episodeId, otherAttributes, allEpisodeIds, formsCategoryBundle, zipIds));
                        //System.debug('started SavePatientChartPdfQueueable');
                    }else if(String.isNotBlank(otherAttributes)){
                        System.enqueueJob(new zipPatientChart(new Map<String,String>{},accId,new Set<Id>{},episodeId,otherAttributes, allEpisodeIds, formsCategoryBundle, zipIds));
                        //System.debug('started zipPatientChart');
                        //ZipPatientChart.startZip(new Map<String,String>{},accId,new Set<Id>{},episodeId,otherAttributes, allEpisodeIds, formsCategoryBundle);
                    }           
                }
            }
        }else if(String.isNotBlank(otherAttributes)){
            System.enqueueJob(new zipPatientChart(new Map<String,String>{},accId,new Set<Id>{},episodeId,otherAttributes, allEpisodeIds, formsCategoryBundle, zipIds));
            //ZipPatientChart.startZip(new Map<String,String>{},accId,new Set<Id>{},episodeId,otherAttributes, allEpisodeIds, formsCategoryBundle);
        }
    }
    @AuraEnabled
    public static  Map<String,String> fetchFieldsForCategoryObject() {
        
        String objectName='ElixirSuite__Form_Category__c';
        system.debug('objectName'+objectName);
        //  List<String> labelArr =  new List<string>();
        Map<String,String> labelApicombo = new Map<String,String>();
        try{
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        
        Map <String, Schema.SObjectField> newfieldMap = new Map <String, Schema.SObjectField>(fieldMap);//created new map since above fieldMap collection is read-only
        newfieldMap.remove('createdbyid');
        newfieldMap.remove('id'); //record id
        newfieldMap.remove('isdeleted');  //deleted
        newfieldMap.remove('name');
        
        newfieldMap.remove('setupownerid');   //location
        newfieldMap.remove('createddate');
        newfieldMap.remove('lastmodifieddate');
        newfieldMap.remove('lastmodifiedbyid');
        newfieldMap.remove('systemmodstamp');
        
        
        for(Schema.SObjectField sfield : newfieldMap.Values())
            
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            labelApicombo.put(String.valueOf(dfield.getname()),String.valueOf(dfield.getLabel()));
            //   labelArr.add(String.valueOf(dfield.getname()));
            
            
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        return labelApicombo;
    }
    public static List<Form_Object__mdt> fetchAllObjectsInCS(){ 
        return [select Object_Name__c from Form_Object__mdt WHERE Object_Name__c!=NULL WITH SECURITY_ENFORCED];
    }
    public static Boolean doesFieldExist(String objName, string fieldName){
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        }
        catch(Exception e) {
            ExceptionLog.logError(e);
        }
        
        return false;
    }
    public class wrapperAcc {
        
        public String apiName {get;set;} 
        public String labelName {get;set;}
        public Boolean value {get;set;}
    }
    
}