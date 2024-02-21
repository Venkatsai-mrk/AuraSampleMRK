public with sharing class PatientImmunizationController {

    @AuraEnabled
    public static VaccineWrapper getSelectOptions(){
        
        VaccineWrapper wrap = new VaccineWrapper();
        try{
		wrap.mapOfVaccineSeries = MasterProblemListController.fetchPickListValue('ElixirSuite__Vaccine__c','ElixirSuite__Vaccine_Series__c');   
        wrap.mapOfRoute = MasterProblemListController.fetchPickListValue('ElixirSuite__Vaccine__c','ElixirSuite__Vaccine_Route__c');
        wrap.mapOfVaccineSite = MasterProblemListController.fetchPickListValue('ElixirSuite__Vaccine__c','ElixirSuite__Vaccine_Site__c');   
        wrap.listOfUser = [select Id,Name From User where IsActive =true ];
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrap;
    }
    
    @AuraEnabled
    public static string getURL(String accountId){
        
        String url =system.URL.getSalesforceBaseUrl().toExternalForm() ;
        
        url = url + '/'+'lightning/r/'+accountId+'/'+'related/ElixirSuite__Vaccines__r/view';
        return url;

    }
    
    public static Map<Id,ElixirSuite__Vaccine__c> getTemplateVaccines(Set<String> setOfTemplateId){
        Id developerRecordId = Schema.SObjectType.ElixirSuite__Vaccine__c.getRecordTypeInfosByDeveloperName().get('Template_Vaccine').getRecordTypeId();
        Map<Id,ElixirSuite__Vaccine__c> mapOfTemplates = new Map<Id,ElixirSuite__Vaccine__c>([ Select Id,ElixirSuite__Series_of_Doses__c,ElixirSuite__Next_Dose_in_Series_After__c from ElixirSuite__Vaccine__c where Id IN:setOfTemplateId AND RecordTypeId=: developerRecordId]);
      
        return mapOfTemplates;
    }

    public static Map<String,List<Integer>> getAlreadyPresentDoses(String accountId, Set<String> setOfTemplateId){
        Id developerRecordId = Schema.SObjectType.ElixirSuite__Vaccine__c.getRecordTypeInfosByDeveloperName().get('Patient_Vaccine').getRecordTypeId();
        List<ElixirSuite__Vaccine__c> listOfPatientVaccine = new List<ElixirSuite__Vaccine__c>([ Select Id,ElixirSuite__Template_Vaccine__c,ElixirSuite__Dosage_Sequence__c,ElixirSuite__Next_Dose_in_Series_After__c from ElixirSuite__Vaccine__c where ElixirSuite__Template_Vaccine__c IN:setOfTemplateId AND RecordTypeId=: developerRecordId AND ElixirSuite__Account__c =: accountId order by createdDate desc]);
        
        system.debug('setOfTemplateId'+setOfTemplateId);
        system.debug('listOfPatientVaccine'+listOfPatientVaccine);
        string key;
        Map<String,List<Integer>> mapOfPresentVaccine = new Map<String,List<Integer>>();
        try{
        if(listOfPatientVaccine.size() >0){
            for(ElixirSuite__Vaccine__c vac: listOfPatientVaccine){
                key = vac.ElixirSuite__Template_Vaccine__c + '_'+ accountId;
                system.debug('key'+key);
                if(mapOfPresentVaccine.containsKey(key)){
                    mapOfPresentVaccine.get(key).add(Integer.valueOf(vac.ElixirSuite__Dosage_Sequence__c));
                    system.debug('mapOfPresentVaccine1'+mapOfPresentVaccine);
                }else{
                    mapOfPresentVaccine.put(key,new List<Integer>{Integer.valueOf(vac.ElixirSuite__Dosage_Sequence__c)});
                    system.debug('mapOfPresentVaccine2'+mapOfPresentVaccine);
                }
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return mapOfPresentVaccine;
    }
    public static Date setStringToDateFormat(String myDate) {
       
        String[] strDate = myDate.split('-');
        Integer myIntDate = integer.valueOf(strDate[2]);
        Integer myIntMonth = integer.valueOf(strDate[1]);
        Integer myIntYear = integer.valueOf(strDate[0]);
        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
        return d;
    }
    
    @AuraEnabled
    public static void saveVaccine(string stringifiedVaccineLst){
        system.debug('stringifiedVaccineLst'+stringifiedVaccineLst);
        String AccountId;
        
        Map<Id,ElixirSuite__Vaccine__c> mapOfTemplates = new Map<Id,ElixirSuite__Vaccine__c>();
        List<ElixirSuite__Vaccine__c> vaccineList = new List<ElixirSuite__Vaccine__c>();
        Set<String> setOfTemplateId = new Set<String>();
        Set<String> setAccountId = new Set<String>();
        List<Task> taskLst = new List<Task>();
        
        try{
        for(Object obj : utilityMapDeserialize(stringifiedVaccineLst,'key')){
            Map<String, Object> mapOfVaccineData = (Map<String, Object>) obj;
            AccountId = String.valueOf(mapOfVaccineData.get('AccountId'));
            setOfTemplateId.add(String.valueOf(mapOfVaccineData.get('Id')));
            setAccountId.add(String.valueOf(mapOfVaccineData.get('AccountId')));
            
        }
        
         //added by Anmol for LX3-7236
         Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
         String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
         if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
         String careStatus = 'Active';
 
         string querystr = '';
         querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c in : setAccountId WITH SECURITY_ENFORCED order by ';
         querystr += careFilter ;
         ElixirSuite__Visits__c[] activeCP = database.query(querystr);
         //end by Anmol for LX3-7236


        mapOfTemplates = getTemplateVaccines(setOfTemplateId);
        
        
        for(Object obj : utilityMapDeserialize(stringifiedVaccineLst,'key')){
            Map<String, Object> mapOfVaccineData = (Map<String, Object>) obj;
            if(String.valueOf(mapOfVaccineData.get('status')) != 'Complete'){
                
                ElixirSuite__Vaccine__c vac = new ElixirSuite__Vaccine__c();
                vac.ElixirSuite__Account__c = String.valueOf(mapOfVaccineData.get('AccountId'));
                vac.ElixirSuite__CVX_Code__c = String.valueOf(mapOfVaccineData.get('CvxCode'));
                if(activeCP!=null && activeCP.size()>0){
                    vac.ElixirSuite__Care_Episode__c = activeCP[0].Id;
                }
                vac.ElixirSuite__Administered_Planned_On__c =  setStringToDateFormat(String.valueOf(mapOfVaccineData.get('AdministratioDate')));
                vac.ElixirSuite__Administered_By__c = String.valueOf(mapOfVaccineData.get('AdministrationBy'));
                vac.ElixirSuite__Status__c = String.valueOf(mapOfVaccineData.get('status'));
                vac.ElixirSuite__Notes__c = String.valueOf(mapOfVaccineData.get('Notes'));
                vac.ElixirSuite__Route__c = String.valueOf(mapOfVaccineData.get('Route'));
                vac.ElixirSuite__Vaccine_Series__c = String.valueOf(mapOfVaccineData.get('VaccineSeries'));
                vac.ElixirSuite__Vaccine_Site__c = String.valueOf(mapOfVaccineData.get('VaccineSite'));
                vac.ElixirSuite__Template_Vaccine__c = String.valueOf(mapOfVaccineData.get('Id'));
                vac.Name = String.valueOf(mapOfVaccineData.get('Name'));
                vac.ElixirSuite__Dosage_Sequence__c = 1;
                vac.RecordTypeId = Schema.SObjectType.ElixirSuite__Vaccine__c.getRecordTypeInfosByDeveloperName().get('Patient_Vaccine').getRecordTypeId();
                vaccineList.add(vac);
                if(String.valueOf(mapOfVaccineData.get('status')) == 'Planned'){
                    Task record = new Task();
                    record.OwnerId =  String.valueOf(mapOfVaccineData.get('AdministrationBy'));
                    record.ActivityDate = setStringToDateFormat(String.valueOf(mapOfVaccineData.get('AdministratioDate')));
                    record.WhatId = String.valueOf(mapOfVaccineData.get('AccountId'));
                    record.Description = '';
                    record.Subject ='Scheduled ' +  String.valueOf(mapOfVaccineData.get('Name'));
                    
                    taskLst.add(record);
                }
                
                
            }            
        }
        
        if(vaccineList.size() >0){
            if(Schema.sObjectType.ElixirSuite__Vaccine__c.isCreateable()){
            insert vaccineList;
            }
        }
        if(taskLst.size() >0){
            if(Schema.sObjectType.Task.isCreateable()){
            insert taskLst;
            }
        }
        processForCompletedStatus(stringifiedVaccineLst,AccountId,setOfTemplateId,mapOfTemplates);
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    
    public static void processForCompletedStatus(string stringifiedVaccineLst,String AccountId, Set<String> setOfTemplateId, Map<Id,ElixirSuite__Vaccine__c> mapOfTemplates){
        
        Map<String,List<Integer>> mapOfPresentVaccine = new Map<String,List<Integer>>();
        mapOfPresentVaccine = getAlreadyPresentDoses( AccountId, setOfTemplateId);
        
        List<ElixirSuite__Vaccine__c> vaccineList = new List<ElixirSuite__Vaccine__c>();
        List<Task> taskLst = new List<Task>();
        
        try{
        for(Object obj : utilityMapDeserialize(stringifiedVaccineLst,'key')){
            Map<String, Object> mapOfVaccineData = (Map<String, Object>) obj;
            if(String.valueOf(mapOfVaccineData.get('status')) == 'Complete'){
                
                if(!String.isEmpty(String.valueOf(mapOfVaccineData.get('Id')))){
                    
                    Integer totalDoses = Integer.valueOf(mapOfTemplates.get(String.valueOf(mapOfVaccineData.get('Id'))).ElixirSuite__Series_of_Doses__c);
                    ElixirSuite__Vaccine__c templateVac = mapOfTemplates.get(String.valueOf(mapOfVaccineData.get('Id')));
                    system.debug('mapOfPresentVaccine'+mapOfPresentVaccine.keySet());
                    system.debug('mapOfVaccineData'+String.valueOf(mapOfVaccineData.get('Id')) + '_' + AccountId);
                    
                    String key = String.valueOf(mapOfVaccineData.get('Id')) + '_' + AccountId;
                    if(mapOfPresentVaccine.containsKey(key)){
                        
                        Integer availedDoses =0;
                        availedDoses= mapOfPresentVaccine.get(key).size();
                        availedDoses+=1;
                        Integer lastDoseSequence = 0;
                        // List<Integer> alldosesSequenceLst = new List<Integer>();
                        //    alldosesSequenceLst = mapOfPresentVaccine.get(key);
                        
                        lastDoseSequence = mapOfPresentVaccine.get(key)[0];
                        Integer days =0;
                        Integer remainingDoses = 0;
                        remainingDoses  =  totalDoses-availedDoses;      
                        if(totalDoses > availedDoses){
                            for(integer i=0;i<remainingDoses; i++){
                                lastDoseSequence+=1;
                                ElixirSuite__Vaccine__c vac = new ElixirSuite__Vaccine__c();
                                vac.Name = String.valueOf(mapOfVaccineData.get('Name'));
                                vac.ElixirSuite__Account__c = String.valueOf(mapOfVaccineData.get('AccountId'));
                                vac.ElixirSuite__CVX_Code__c = String.valueOf(mapOfVaccineData.get('CvxCode'));
                                Date dt = setStringToDateFormat(String.valueOf(mapOfVaccineData.get('AdministratioDate')));
                                if(templateVac.ElixirSuite__Next_Dose_in_Series_After__c!=null){
                                    days = Integer.valueOf(templateVac.ElixirSuite__Next_Dose_in_Series_After__c);
                                }
                                vac.ElixirSuite__Administered_Planned_On__c = dt.addDays(Integer.valueOf(days));
 
                                vac.ElixirSuite__Administered_By__c = String.valueOf(mapOfVaccineData.get('AdministrationBy'));
                                vac.ElixirSuite__Status__c = 'Planned';
                                vac.ElixirSuite__Notes__c = String.valueOf(mapOfVaccineData.get('Notes'));
                                vac.ElixirSuite__Route__c = String.valueOf(mapOfVaccineData.get('Route'));
                                vac.ElixirSuite__Vaccine_Series__c = String.valueOf(mapOfVaccineData.get('VaccineSeries'));
                                vac.ElixirSuite__Vaccine_Site__c = String.valueOf(mapOfVaccineData.get('VaccineSite'));
                                vac.ElixirSuite__Dosage_Sequence__c = lastDoseSequence;
                                vac.ElixirSuite__Template_Vaccine__c = String.valueOf(mapOfVaccineData.get('Id'));
                                vac.RecordTypeId = Schema.SObjectType.ElixirSuite__Vaccine__c.getRecordTypeInfosByDeveloperName().get('Patient_Vaccine').getRecordTypeId();
                                vaccineList.add(vac);
                                
                                Task record = new Task();
                                record.OwnerId =  String.valueOf(mapOfVaccineData.get('AdministrationBy'));
                                record.ActivityDate = dt.addDays(Integer.valueOf(days));
                                record.WhatId = String.valueOf(mapOfVaccineData.get('AccountId'));
                                record.Description = '';
                                record.Subject ='Scheduled ' +  String.valueOf(mapOfVaccineData.get('Name'));
                                
                                taskLst.add(record);
                            }
                        }
                    }else{
                        Integer days =0;
                        for(integer i=0;i<totalDoses-1; i++){
                            
                            ElixirSuite__Vaccine__c vac = new ElixirSuite__Vaccine__c();
                            vac.Name = String.valueOf(mapOfVaccineData.get('Name'));
                            vac.ElixirSuite__Account__c = String.valueOf(mapOfVaccineData.get('AccountId'));
                            vac.ElixirSuite__CVX_Code__c = String.valueOf(mapOfVaccineData.get('CvxCode'));
                            Date dt = setStringToDateFormat(String.valueOf(mapOfVaccineData.get('AdministratioDate')));
                            if(templateVac.ElixirSuite__Next_Dose_in_Series_After__c!=null){
                                days = Integer.valueOf(templateVac.ElixirSuite__Next_Dose_in_Series_After__c);
                            }
                            vac.ElixirSuite__Administered_Planned_On__c = dt.addDays(Integer.valueOf(days));
                            
                            vac.ElixirSuite__Administered_By__c = String.valueOf(mapOfVaccineData.get('AdministrationBy'));
                            vac.ElixirSuite__Status__c = 'Planned';
                            vac.ElixirSuite__Notes__c = String.valueOf(mapOfVaccineData.get('Notes'));
                            vac.ElixirSuite__Route__c = String.valueOf(mapOfVaccineData.get('Route'));
                            vac.ElixirSuite__Vaccine_Series__c = String.valueOf(mapOfVaccineData.get('VaccineSeries'));
                            vac.ElixirSuite__Vaccine_Site__c = String.valueOf(mapOfVaccineData.get('VaccineSite'));
                            vac.ElixirSuite__Dosage_Sequence__c = i+1;
                            vac.ElixirSuite__Template_Vaccine__c = String.valueOf(mapOfVaccineData.get('Id'));
                            vac.RecordTypeId = Schema.SObjectType.ElixirSuite__Vaccine__c.getRecordTypeInfosByDeveloperName().get('Patient_Vaccine').getRecordTypeId();
                            vaccineList.add(vac);
                            
                            Task record = new Task();
                            record.OwnerId =  String.valueOf(mapOfVaccineData.get('AdministrationBy'));
                            record.ActivityDate = dt.addDays(Integer.valueOf(days));
                            record.WhatId = String.valueOf(mapOfVaccineData.get('AccountId'));
                            record.Description = '';
                            record.Subject ='Scheduled ' +  String.valueOf(mapOfVaccineData.get('Name'));
                            
                            taskLst.add(record);
                        }
                    }
                    
                }
                ElixirSuite__Vaccine__c vac = new ElixirSuite__Vaccine__c();
                vac.Name = String.valueOf(mapOfVaccineData.get('Name'));
                vac.ElixirSuite__Account__c = String.valueOf(mapOfVaccineData.get('AccountId'));
                vac.ElixirSuite__CVX_Code__c = String.valueOf(mapOfVaccineData.get('CvxCode'));
                vac.ElixirSuite__Administered_Planned_On__c = setStringToDateFormat(String.valueOf(mapOfVaccineData.get('AdministratioDate')));
                vac.ElixirSuite__Administered_By__c = String.valueOf(mapOfVaccineData.get('AdministrationBy'));
                vac.ElixirSuite__Status__c = String.valueOf(mapOfVaccineData.get('status'));
                vac.ElixirSuite__Notes__c = String.valueOf(mapOfVaccineData.get('Notes'));
                vac.ElixirSuite__Route__c = String.valueOf(mapOfVaccineData.get('Route'));
                vac.ElixirSuite__Vaccine_Series__c = String.valueOf(mapOfVaccineData.get('VaccineSeries'));
                vac.ElixirSuite__Vaccine_Site__c = String.valueOf(mapOfVaccineData.get('VaccineSite'));
                vac.ElixirSuite__Template_Vaccine__c = String.valueOf(mapOfVaccineData.get('Id'));
                vac.RecordTypeId = Schema.SObjectType.ElixirSuite__Vaccine__c.getRecordTypeInfosByDeveloperName().get('Patient_Vaccine').getRecordTypeId();
                vaccineList.add(vac);
            }
        }
        
        if(vaccineList.size() >0){
            insert vaccineList;
        }
        if(taskLst.size() >0){
            insert taskLst;
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }

    public static  List<Object>  utilityMapDeserialize(String stringifiedJSON,String keyToGet){         
        Map<String, Object> tableLstJSON =(Map<String, Object>) JSON.deserializeUntyped(stringifiedJSON);
        return  (List<Object>) tableLstJSON.get(keyToGet);
    } 
     public class VaccineWrapper{
        
         @AuraEnabled public Map<String, String> mapOfVaccineSeries; 
         @AuraEnabled public Map<String, String> mapOfRoute;
         @AuraEnabled public Map<String, String> mapOfVaccineSite; 
         @AuraEnabled public List<User> listOfUser; 
        
    }
    
}