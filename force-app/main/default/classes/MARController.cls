public with sharing class MARController { 
    public static List<MAR_MOR__c>  listOfMarStatements = new List<MAR_MOR__c>();
    public static Id procedureId;     
    @AuraEnabled
    public static wrapper1 getMORDetails(String accountId){
        List <MAR_MOR__c> oldRecs = new List<MAR_MOR__c>();
        oldRecs = [select id , Frequency__r.id , Index_Number__c from MAR_MOR__c
                   where  Account__c =: accountId AND Frequency__r.id != null AND Index_Number__c != null
                   WITH SECURITY_ENFORCED];
        system.debug('teh val ' + oldRecs);
        Map<Id , List<String>> mapValuesForIndex = new Map<Id , List<String>>();  
        for(MAR_MOR__c recNew : oldRecs) {
            if(mapValuesForIndex.containsKey(recNew.Frequency__r.id)) {
                List<String> indexList = mapValuesForIndex.get(recNew.Frequency__r.id);
                indexList.add(recNew.Index_Number__c);
                mapValuesForIndex.put(recNew.Frequency__r.id, indexList);
            } else {
                mapValuesForIndex.put(recNew.Frequency__r.id, new List<String> { recNew.Index_Number__c });
            }
        }
        system.debug('the map values are' + mapValuesForIndex);
        
        Boolean status ; 
        List<String> strList = new List<String>();
        List<String> strListDosage = new List<String>();
        List<String> strListVaccine = new List<String>();
        
        String taperType = 'Taper' ; 
        String prnType = 'PRN' ; 
        String actionOrderType = 'Action Order' ; 
        
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Vaccine__c.getRecordTypeInfosByDeveloperName().get('Patient_Vaccine').getRecordTypeId();
        
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('ElixirSuite__Prescription_Order__c').getDescribe().fields.getMap();
        strList = new List<String>(objectFields.keySet());
        
        Map<String, Schema.SObjectField> objectFieldsDosage = Schema.getGlobalDescribe().get('ElixirSuite__Frequency__c').getDescribe().fields.getMap();
        strListDosage = new List<String>(objectFieldsDosage.keySet());
        
        Map<String, Schema.SObjectField> objectFieldsVaccine = Schema.getGlobalDescribe().get('ElixirSuite__Vaccine__c').getDescribe().fields.getMap();
        strListVaccine = new List<String>(objectFieldsVaccine.keySet());
        
        String dateFormatString = 'yyyy-MM-dd';
        Date d = Date.today();
        Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
        String dateToCompare = dt.format(dateFormatString);
        
        System.debug('ngjken' + dateToCompare );
        Date todayDate = system.today();
        
        String vaccineResult = ' SELECT ' + String.join( strListVaccine, ',' ) + ',' + ' Owner.Name' + ' FROM Vaccine__c where Account__c = '+ '\'' + String.escapeSingleQuotes(accountId) + '\'' + ' AND RecordTypeId = ' +'\'' + recordTypeId + '\'' + 'AND Administered_Planned_On__c >=: todayDate AND Administered__c = false' ;
        
       String tapResult = ' SELECT ' + String.join( strList, ',' ) + ',' +'Medication__r.Name'+  ',' +'Route_New_1__r.Name'+  ',' +'Dosage1__r.Name'+  ',' +' Owner.Name' + ',' + '(SELECT ' + String.join( strListDosage, ',' ) + ' FROM Frequency__r )' + ' FROM Prescription_Order__c where Account__c = '+ '\'' + String.escapeSingleQuotes(accountId) + '\'' + ' AND Type__c = ' +'\'' +String.escapeSingleQuotes(taperType) + '\'' ;       
       String tapResult1 = ' SELECT ' + String.join( strList, ',' ) + ',' +'Medication__r.Name'+  ',' +'Route_New_1__r.Name'+  ',' +'Dosage1__r.Name'+  ',' + ' Owner.Name' + ',' + '(SELECT ' + String.join( strListDosage, ',' ) + ' FROM Frequency__r)' + ' FROM Prescription_Order__c where Account__c ='+ '\'' + String.escapeSingleQuotes(accountId) + '\'' + ' AND Type__c = ' +'\'' + String.escapeSingleQuotes(prnType) + '\'';/* + ' AND 	Start_Date__c <=' + dateToCompare  + ' AND 	End_Date__c >=' + dateToCompare ; */       
       String tapResult2 = ' SELECT ' + String.join( strList, ',' ) + ',' +'Medication__r.Name'+  ',' + ' Owner.Name' + ',' + '(SELECT ' + String.join( strListDosage, ',' ) + ' FROM Frequency__r)' + ' FROM Prescription_Order__c where Account__c = '+ '\'' + String.escapeSingleQuotes(accountId) + '\'' + ' AND Type__c = ' +'\'' + String.escapeSingleQuotes(actionOrderType) + '\'' + ' AND MAR_Display__c = True' + ' AND Start_Date__c <=' + dateToCompare + ' AND End_Date__c >=' + dateToCompare  ;       
        
     
        List<Prescription_Order__c> taperResult=Database.query(tapResult);
        List<Prescription_Order__c> taperResult1=Database.query(tapResult1);
        List<Prescription_Order__c> taperResult2 = Database.query(tapResult2);
        
        List<Vaccine__c> vaccineResultList = Database.query(vaccineResult);
        
        List<Medical_Examination__c> vitalData = new List<Medical_Examination__c>();
        DateTime timeNow1 = System.now(); // Get the time now
        DateTime timeNow = timeNow1.addMinutes(380);
        DateTime X30MinutesAgo = timeNow.addMinutes(-30); // Subtract 30 minutes from it
        system.debug('time is' + X30MinutesAgo);
        system.debug('time is' + X30MinutesAgo);
        vitalData = [SELECT ID FROM Medical_Examination__c WHERE createdDate <:timeNow AND createdDate >:X30MinutesAgo AND Account__c =: accountId
                     WITH SECURITY_ENFORCED];// This will return all accounts created in the last 30 minutes
        if(vitalData != null & vitalData.size()>0){ 
            status = false;
        }
        else{
            status = true ;
        }
        system.debug('the data is' + vaccineResultList);
        User u = [select id,Name from User where id =: userInfo.getUserId() WITH SECURITY_ENFORCED];
        string nameSpace = Elixir_Utility.getNamespace();
        wrapper1 obj = new wrapper1(taperResult1 , taperResult , taperResult2 , status , mapValuesForIndex , u,nameSpace, vaccineResultList,getAdminStatusOptions()); 
        return obj ;
        
    }
    
    public class wrapper1{
        @AuraEnabled public List<Prescription_Order__c> morDataPrn ; 
        @AuraEnabled public List<Prescription_Order__c> morDataTaper ; 
        @AuraEnabled public List<Prescription_Order__c> morDataActionOrder ; 
        @AuraEnabled public Boolean checkStatus ; 
        @AuraEnabled public Map<Id , List<String>> RecordToSplice;
        @AuraEnabled public User userName ;
        @AuraEnabled public string nameSpace ;
        @AuraEnabled public List<ElixirSuite__Vaccine__c> vaccineList ; 
        @AuraEnabled public List<PicklistOptionWrapper> adminStatusOptions;
        
        public wrapper1(List<Prescription_Order__c> morDataPrns , List<Prescription_Order__c> morDataTapers , 
                        List<Prescription_Order__c> morDataActionOrders , Boolean checkStatuses , Map<Id , List<String>> RecordsToSplice , User userNames, string NameSpace, List<Vaccine__c> vaccineList,List<PicklistOptionWrapper> adminStatusOptions){
                            this.morDataPrn = morDataPrns ; 
                            this.morDataTaper = morDataTapers ; 
                            this.morDataActionOrder = morDataActionOrders ;
                            this.checkStatus = checkStatuses ; 
                            this.RecordToSplice = RecordsToSplice ;
                            this.userName = userNames ;
                            this.nameSpace = NameSpace ; 
                            this.vaccineList = vaccineList;
                            this.adminStatusOptions = adminStatusOptions;
                        }
    } 
    public class PicklistOptionWrapper {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        
        public PicklistOptionWrapper(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
    
    public static List<PicklistOptionWrapper> getAdminStatusOptions() {
        List<PicklistOptionWrapper> adminStatusOptions = new List<PicklistOptionWrapper>();
        Schema.DescribeFieldResult adminStatusField = MAR_MOR__c.Administration_Status__c.getDescribe();
        List<Schema.PicklistEntry> adminStatusPicklistValues = adminStatusField.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : adminStatusPicklistValues) {
            PicklistOptionWrapper optionWrapper = new PicklistOptionWrapper(picklistEntry.getValue(), picklistEntry.getLabel());
            adminStatusOptions.add(optionWrapper);
        }
        return adminStatusOptions;
    }

    // for saving data for tapers and PRN sections and action Orders
    @AuraEnabled
    public static Map<String,Map<Id, String>> saveData(String jsonList  ,String recordPRN, String recordActionOrder, String accountId ,
                                                       String saveTimeVal,String missedMedicationJSON,String allDosageRecords,
                                                       String starttimeProcedure , String endtimeProcedure,String notRegisteredMedications) {
                                                        
                                                                                                          //added by Anmol for LX3-7236
                                            Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
                                            String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
                                            if(string.isBlank(careFilter)){
                                                careFilter = 'createddate desc';
                                            }
                                            String careStatus = 'Active';
                                    
                                            string querystr = '';
                                            querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accountId WITH SECURITY_ENFORCED order by ';
                                            querystr += careFilter ;
                                            List<ElixirSuite__Visits__c> lst_visits = database.query(querystr);
                                            //end by Anmol for LX3-7236
                                                        
                                                           system.debug('lst_visits '+lst_visits);
                                                           System.debug(saveTimeVal);
                                                           System.debug(recordActionOrder);  
                                                           Id devRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();
                                                           if(Elixir_Utility.fetchCreateProcedureReturnValue()==true){
                                                           Procedure__c newProcedure = new Procedure__c();
                                                           newProcedure.Account__c=accountId; 
                                                           newProcedure.RecordTypeId = devRecordTypeId;
                                                           newProcedure.From_Date__c = date.valueOf(starttimeProcedure) ;
                                                           newProcedure.Start_Time__c = date.valueOf(starttimeProcedure) ;
                                                           newProcedure.To_Date__c = date.valueOf(endtimeProcedure) ;
                                                           newProcedure.End_Time__c = date.valueOf(endtimeProcedure) ;
                                                           
                                                           if(Elixir_utility.dateTimeConversion(endtimeProcedure) <= Elixir_utility.dateTimeConversion(starttimeProcedure))
                                                           {
                                                               newProcedure.put('ElixirSuite__End_Time__c' , Elixir_utility.dateTimeConversion(starttimeProcedure).addMinutes(1));
                                                           }
                                                           else
                                                           {
                                                               newProcedure.put('ElixirSuite__End_Time__c' , Elixir_utility.dateTimeConversion(endtimeProcedure));
                                                           }
                                                           
                                                           newProcedure.put('ElixirSuite__Start_Time__c' , Elixir_utility.dateTimeConversion(starttimeProcedure));
                                                           
                                                           newProcedure.Name = 'MOR/MAR';
                                                           if(!lst_visits.isEmpty())
                                                           {
                                                               newProcedure.ElixirSuite__Visits__c =lst_visits[0].Id;
                                                           }
                                                           if(Schema.sObjectType.Procedure__c.isCreateable()){
                                                           insert newProcedure;
                                                           }
                                                           }
                                                           System.debug('missed medication JSON '+missedMedicationJSON);
                                                           //Email for those medications which were not registered
                                                           if(!String.isBlank(notRegisteredMedications)){
                                                               MARController.sendEmailToUR(notRegisteredMedications); 
                                                           }
                                                           //  System.debug('1-----' + jsonList + indexValue);
                                                           String multiply = 'X' ;
                                                           String comma1 = ',' ; 
                                                           String comma2 = ',' ; 
                                                           Map<Id, String> mapValuesForIndex = new Map<Id, String>();
                                                           If(jsonList != Null && jsonList != ''){
                                                               System.debug('Starting SaveData' + jsonList);
                                                               List<root> rootJson = (List<root>)JSON.deserialize(jsonList, List<root>.class);
                                                               // List<String> missedDosageRecords = new List<String>();
                                                               //            Map<String,String> missedDosageRecords = new Map<String,String>();
                                                               system.debug('the string is' + rootJson);
                                                               List <MAR_MOR__c> newRecs = new List<MAR_MOR__c>();
                                                               if(rootJson != null & rootJson.size()>0){
                                                                   for(root rec : rootJson){
                                                                       // missedDosageRecords.put(rec.dosageId,rec.indexForInspection);
                                                                       system.debug('the values are' + rec.Dosage + rec.Units + rec.Route );
                                                                       if(String.isBlank(rec.Dosage)){
                                                                           multiply = ' ' ; 
                                                                           rec.Dosage = ' ';
                                                                       }
                                                                       if(String.isBlank(rec.Units)){
                                                                           comma1 = ' ' ; 
                                                                           rec.Units = ' ';
                                                                       }
                                                                       if(String.isBlank(rec.Route)){
                                                                           comma2 = ' ' ; 
                                                                           rec.Route = ' ';
                                                                       }
                                                                       if(String.isBlank(rec.Strength)){
                                                                           rec.Strength = ' ';
                                                                       }
                                                                       System.debug('Inside first for' + rec.times);
                                                                       
                                                                       String[] strTimeSplit = saveTimeVal.split(':');
                                                                       Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                                                                          ,Integer.valueOf(strTimeSplit[1]) //min
                                                                                                          ,0                                //sec
                                                                                                          ,0); 
                                                                       String DateTimeConcantenate = rec.Start_Date + ' ' + timeChange ;
                                                                       System.debug('Inside first for' + DateTimeConcantenate);
                                                                       
                                                                       
                                                                       MAR_MOR__c newRec = new MAR_MOR__c(
                                                                           Frequency__c = rec.dosageId,
                                                                           // EHR_Procedure__c = procedureId,
                                                                           Account__c = rec.patientAccount ,
                                                                           Drug_Name__c = rec.medicationName,
                                                                           Dosage_Time__c = Datetime.valueOf(DateTimeConcantenate),
                                                                           Medication_Name__c = rec.Type ,
                                                                           Type__c = 'Dosage',
                                                                           Reasons__c = rec.comment ,
                                                                           // Scheduled_Time__c =timeForStatement,
                                                                           Index_Number__c = rec.indexOfDay , 
                                                                           Administered_By__c = rec.Owner ,
                                                                           
                                                                           Administration_Status__c =  String.valueOf(rec.MedicationNameRadio),
                                                                           Medication_Quantity__c = rec.Strength + 'X' + rec.Dosage + ',' + rec.Units + ',' + rec.Route
                                                                       );
                                                                       if(lst_visits!=null && lst_visits.size()>0){
                                                                           newRec.ElixirSuite__Care_Episode__c = lst_visits[0].Id;
                                                                       }
                                                                       // System.debug('Inside first for before addition to list');
                                                                       if(String.isNotBlank(String.valueOf(rec.MedicationNameRadio))){
                                                                           newRecs.add(newRec);
                                                                       }
                                                                       
                                                                       mapValuesForIndex.put(rec.dosageId , String.valueOf(rec.indexVar));
                                                                       system.debug('the map values are' + mapValuesForIndex);
                                                                       
                                                                   }
                                                                   system.debug('new rec is'+ newRecs);
                                                                   if(newRecs != NULL && newRecs.size() > 0){
                                                                       DMLManager.insertAsUser(newRecs);
                                                                   }
                                                                   if(newRecs.size()>0){
                                                                       listOfMarStatements.addAll(newRecs);
                                                                   }
                                                                   
                                                               }}
                                                           Map<Id,String> mapOfPrn = new Map<Id,String>();
                                                           if(recordPRN!=null && !String.isEmpty(recordPRN)){
                                                               system.debug('save time '+saveTimeVal);
                                                               system.debug('save time '+accountId);
                                                               mapOfPrn = saveMarForPRN( recordPRN, saveTimeVal, accountId,lst_visits);
                                                               
                                                           }
                                                           Map<Id,String> mapOfActionOrder = new Map<Id,String>();
                                                           if(recordActionOrder!=null && !String.isEmpty(recordActionOrder)){
                                                               mapOfActionOrder = saveMarForActionOrder( recordActionOrder, saveTimeVal, accountId,lst_visits);
                                                               
                                                           }
                                                           //this method has only debug statement
                                                           // Elixir_utility.startMarEvaluation(listOfMarStatements);// for adding procedure corresponding to this administration
                                                           if(!String.isEmpty(missedMedicationJSON)) {
                                                               MARController.updateMissedMedication(missedMedicationJSON);
                                                               
                                                           }
                                                           if(!String.isEmpty(allDosageRecords)) {
                                                               MARController.identifyNotExistingDosageRecords(allDosageRecords);
                                                           }
                                                           
                                                           Map <String,Map<Id,String>> maptoSend = new Map <String,Map<Id,String>>();
                                                           maptoSend.put('PRN',mapOfPrn);
                                                           maptoSend.put('Taper',mapValuesForIndex);
                                                           maptoSend.put('Action Order',mapOfActionOrder);
                                                           return  maptoSend;
                                                       }
    
    
    
    // for prn saving (called from above method)
    @AuraEnabled
    public static Map<Id, String> saveMarForPRN(String jsonList , String saveTimeVal,  String accountId, List<ElixirSuite__Visits__c> lst_visits ) {
        
        //  System.debug('1-----' + jsonList + indexValue + saveTimeVal);
        Map<Id, String> mapValuesForIndex = new Map<Id, String>();
        If(jsonList != Null || jsonList != ''){
            System.debug('Starting SaveData' + jsonList);
            List<root1> rootJson = (List<root1>)JSON.deserialize(jsonList, List<root1>.class);
            system.debug('the string is' + rootJson);
            List <MAR_MOR__c> newRecs = new List<MAR_MOR__c>();
            Frequency__c  dosRec = new  Frequency__c();
            if(rootJson != null & rootJson.size()>0){
                for(root1 rec : rootJson){
                    //     System.debug('Inside first for');
                    
                    String[] strTimeSplit = saveTimeVal.split(':');
                    Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                       ,Integer.valueOf(strTimeSplit[1]) //min
                                                       ,0                                //sec
                                                       ,0); 
                    String DateTimeConcantenate = rec.Start_Date + ' ' + timeChange ;
                    MAR_MOR__c newRec = new MAR_MOR__c(
                        Name =  rec.medicationName,
                        Frequency__c = rec.dosageId,
                        // EHR_Procedure__c = procedureId,
                        Account__c = rec.patientAccount ,
                        Drug_Name__c = rec.medicationName,
                        Dosage_Time__c = Datetime.valueOf(DateTimeConcantenate),
                        Medication_Name__c = rec.Type ,
                        Reasons__c = rec.comment ,
                         Type__c = 'Dosage',
                        // Scheduled_Time__c =timeForStatement,
                        Index_Number__c = rec.indexOfDay , 
                        Administered_By__c = rec.Owner ,
                        Administration_Status__c =  String.valueOf(rec.MedicationNameRadio),
                        Medication_Quantity__c = rec.allStrength
                    );
                    if(lst_visits!=null && lst_visits.size()>0){
                        newRec.ElixirSuite__Care_Episode__c = lst_visits[0].Id;
                    }
                    //newRec.ElixirSuite__Care_Episode__c = lst_visits[0].Id;
                    // System.debug('Inside first for before addition to list');
                    if(String.isNotBlank(String.valueOf(rec.MedicationNameRadio))){
                        newRecs.add(newRec);
                    }
                    
                    mapValuesForIndex.put(rec.dosageId , String.valueOf(rec.indexVar));
                    system.debug('the map values are' + mapValuesForIndex);
                    system.debug('the map values are--' + rec.dosageId);
                    // for dynamic warnings
                    dosRec = [SELECT id, Last_Activity_Time__c, Last_Activity_Date_MAR__c 
                              FROM Frequency__c where id =: rec.dosageId 
                              WITH SECURITY_ENFORCED];
                    system.debug('teh val ' + dosRec);
                    dosRec.Last_Activity_Date_MAR__c = Date.valueOf(rec.Start_Date) ; 
                    dosRec.Last_Activity_Time__c = timeChange;
                }
                if(Schema.sObjectType.Frequency__c.fields.Last_Activity_Date_MAR__c.isUpdateable() &&
                   Schema.sObjectType.Frequency__c.fields.Last_Activity_Time__c.isUpdateable()){
                       update dosRec ;
                   }
                system.debug('new rec is'+ dosRec);
                system.debug('new rec is'+ newRecs);
                if(Schema.sObjectType.MAR_MOR__c.fields.Frequency__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Account__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Drug_Name__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Dosage_Time__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Medication_Name__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Reasons__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Index_Number__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Administered_By__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Status__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Medication_Quantity__c.isCreateable()){
                    if(newRecs != NULL && newRecs.size()>0){
                        Database.insert(newRecs,false);
                    }
                       
                   }
                if(newRecs.size()>0){
                    listOfMarStatements.addAll(newRecs);
                }
                
            }
        }
        
        return mapValuesForIndex ;
    }
    
    // for saving action order (called through above method) 
    @AuraEnabled
    public static Map<Id, String> saveMarForActionOrder(String jsonListAction , String saveTimeVal,  String accountId, List<ElixirSuite__Visits__c> lst_visits) {
        //  System.debug('1-----' + jsonListAction + indexValue + saveTimeVal);
        Map<Id, String> mapValuesForIndex = new Map<Id, String>();
        If(jsonListAction != Null || jsonListAction != ''){
            System.debug('Starting SaveData' + jsonListAction);
            List<rootActionOrder> rootJson = (List<rootActionOrder>)JSON.deserialize(jsonListAction, List<rootActionOrder>.class);
            system.debug('the string is' + rootJson);
            List <MAR_MOR__c> newRecs = new List<MAR_MOR__c>();
            Frequency__c  dosRec = new  Frequency__c();
            if(rootJson != null & rootJson.size()>0){
                for(rootActionOrder rec : rootJson){
                    
                    String[] strTimeSplit = saveTimeVal.split(':');
                    Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                       ,Integer.valueOf(strTimeSplit[1]) //min
                                                       ,0                                //sec
                                                       ,0); 
                    String DateTimeConcantenate = rec.Start_Date + ' ' + timeChange ;
                    MAR_MOR__c newRec = new MAR_MOR__c(
                        Frequency__c = rec.dosageId,
                        Account__c = rec.patientAccount ,
                        //EHR_Procedure__c = procedureId,
                        Drug_Name__c = rec.medicationName,
                        Dosage_Time__c = Datetime.valueOf(DateTimeConcantenate),
                        Medication_Name__c = rec.Type ,
                        Type__c = 'Dosage',
                        Reasons__c = rec.comment ,
                        Index_Number__c = rec.indexOfDay , 
                        Administered_By__c = rec.Owner ,
                        Status__c =  Boolean.valueOf(rec.MedicationNameRadio)
                        
                    );
                    if(lst_visits!=null && lst_visits.size()>0){
                        newRec.ElixirSuite__Care_Episode__c = lst_visits[0].Id;
                    }
                    // System.debug('Inside first for before addition to list');
                    newRecs.add(newRec);
                    mapValuesForIndex.put(rec.dosageId , String.valueOf(rec.indexVar));
                    system.debug('the map values are' + mapValuesForIndex);
                    
                    // for dynamic warning
                    dosRec = [SELECT id, Last_Activity_Time__c, Last_Activity_Date_MAR__c 
                              FROM Frequency__c where id =: rec.dosageId 
                              WITH SECURITY_ENFORCED];
                    system.debug('teh val ' + dosRec);
                    
                    dosRec.Last_Activity_Date_MAR__c = Date.valueOf(rec.Start_Date) ; 
                    dosRec.Last_Activity_Time__c = timeChange;
                    
                }
                if(Schema.sObjectType.Frequency__c.fields.Last_Activity_Date_MAR__c.isUpdateable() &&
                   Schema.sObjectType.Frequency__c.fields.Last_Activity_Time__c.isUpdateable()){
                       update dosRec ;
                   }
                
                system.debug('new rec is'+ dosRec);
                system.debug('new rec is'+ newRecs);
                if(Schema.sObjectType.MAR_MOR__c.fields.Frequency__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Account__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Drug_Name__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Dosage_Time__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Medication_Name__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Reasons__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Index_Number__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Administered_By__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Status__c.isCreateable() &&
                   Schema.sObjectType.MAR_MOR__c.fields.Medication_Quantity__c.isCreateable()){
                       Database.insert(newRecs,false);
                   }
                if(newRecs.size()>0){
                    listOfMarStatements.addAll(newRecs);
                }
            }
        }
        
        return mapValuesForIndex ; 
    }
    @AuraEnabled
    public static void identifyNotExistingDosageRecords(String allDosageRecords) {
        System.debug('inside missedMedication ');
        //  List<root1> rootJson = (List<root1>)JSON.deserialize(jsonList, List<root1>.class);
        List<DesrializeMissedMedication> allDosages = (List<DesrializeMissedMedication>)JSON.deserialize(allDosageRecords, List<DesrializeMissedMedication>.class);
        Map<String,List<Integer>> allExistingDosageRecords = new Map<String,List<Integer>>();
        List<Integer> timingsNumber = new List<Integer>();
        List<Frequency__c> updateNotExistingRecords = new List<Frequency__c>();
        for(DesrializeMissedMedication recordDosageId : allDosages ){ 
            allExistingDosageRecords.put(recordDosageId.dosageID,recordDosageId.timings);
        } 
        List<Frequency__c> recordsToUpdate= [SELECT id,Picklist_For_Missed_Time_1__c,Picklist_For_Missed_Time_2__c,Picklist_For_Missed_Time_3__c,Picklist_For_Missed_Time_4__c,
                                             Picklist_For_Missed_Time_5__c,Picklist_For_Missed_Time_6__c,Picklist_For_Missed_Time_7__c,Picklist_For_Missed_Time_8__c,Picklist_For_Missed_Time_9__c,
                                             Picklist_For_Missed_Time_10__c,Picklist_For_Missed_Time_11__c,Picklist_For_Missed_Time_12__c,Picklist_For_Missed_Time_13__c,Picklist_For_Missed_Time_14__c
                                             ,Picklist_For_Missed_Time_15__c,Picklist_For_Missed_Time_16__c,Picklist_For_Missed_Time_17__c,Picklist_For_Missed_Time_18__c,Picklist_For_Missed_Time_19__c
                                             ,Picklist_For_Missed_Time_20__c,Picklist_For_Missed_Time_21__c FROM Frequency__c where id in: allExistingDosageRecords.keySet()
                                             WITH SECURITY_ENFORCED];
        String type='ElixirSuite__Frequency__c';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        Integer countNumberOfFileds = 0;
        for (String fieldName: fieldMap.keySet()) {
            //String picklist = fieldMap.get(fieldName).getDescribe().getLabel();//It provides to get the object fields label.
            if(fieldName.startsWith('Picklist_For_Missed_Time_')){
                countNumberOfFileds++;
            }
        }
        for(Frequency__c dosageRecords : recordsToUpdate){                
            timingsNumber = allExistingDosageRecords.get(dosageRecords.id);
            for(Integer i=1;i<=countNumberOfFileds;i++){
                if(!timingsNumber.contains(i)){
                    String toUpdateMissedPickList = 'Picklist_For_Missed_Time_'+i+'__c';
                    System.debug('to update not existing records  '+toUpdateMissedPickList);                     
                    dosageRecords.put(toUpdateMissedPickList,'N/A');
                    
                }
            }
            updateNotExistingRecords.add(dosageRecords);
        }
        if(Frequency__c.sObjectType.getDescribe().isUpdateable()){
            update updateNotExistingRecords;
        }
    }
    
    
    @AuraEnabled
    public static void updateMissedMedication(String missedMedicationList) {
        System.debug('inside missedMedication ');
        //  List<root1> rootJson = (List<root1>)JSON.deserialize(jsonList, List<root1>.class);
        List<DesrializeMissedMedication> missedMedications = (List<DesrializeMissedMedication>)JSON.deserialize(missedMedicationList, List<DesrializeMissedMedication>.class);
        Map<String,List<Integer>> missedDosageRecords = new Map<String,List<Integer>>();
        List<Integer> timingsNumber = new List<Integer>();
        List<Frequency__c> updateMissedDosageRecords  = new List<Frequency__c>();
        for(DesrializeMissedMedication recordMedicationId : missedMedications ){ 
            missedDosageRecords.put(recordMedicationId.dosageID,recordMedicationId.timings);
        }
        System.debug('create map '+missedDosageRecords);
        Integer i  =1;
        
        for(Frequency__c dosageRecords :[SELECT id,Picklist_For_Missed_Time_1__c,Picklist_For_Missed_Time_2__c,Picklist_For_Missed_Time_3__c,Picklist_For_Missed_Time_4__c,
                                         Picklist_For_Missed_Time_5__c,Picklist_For_Missed_Time_6__c,Picklist_For_Missed_Time_7__c,Picklist_For_Missed_Time_8__c,Picklist_For_Missed_Time_9__c,
                                         Picklist_For_Missed_Time_10__c,Picklist_For_Missed_Time_11__c,Picklist_For_Missed_Time_12__c,Picklist_For_Missed_Time_13__c,Picklist_For_Missed_Time_14__c
                                         ,Picklist_For_Missed_Time_15__c,Picklist_For_Missed_Time_16__c,Picklist_For_Missed_Time_17__c,Picklist_For_Missed_Time_18__c,Picklist_For_Missed_Time_19__c
                                         ,Picklist_For_Missed_Time_20__c,Picklist_For_Missed_Time_21__c FROM Frequency__c where id in: missedDosageRecords.keySet()
                                         WITH SECURITY_ENFORCED]) { 
                                             timingsNumber = missedDosageRecords.get(dosageRecords.id);
                                             for(Integer checkboxNumberUpdate :timingsNumber){
                                                 String toUpdateMissedCheckbox = 'Picklist_For_Missed_Time_'+checkboxNumberUpdate+'__c'; 
                                                 System.debug('to update missed medication '+toUpdateMissedCheckbox);  
                                                 dosageRecords.put(toUpdateMissedCheckbox,'Taken');
                                                 
                                             }
                                             updateMissedDosageRecords.add(dosageRecords);
                                             i++;
                                             
                                             
                                         }
        System.debug('update medication reocrd value '+updateMissedDosageRecords);
        if(Frequency__c.sObjectType.getDescribe().isUpdateable()){
            update updateMissedDosageRecords;
        }
    }    
    
    
    public class DesrializeMissedMedication {
        
        public String dosageID;
        public String parentID;
        public List<Integer> timings;
        
    }
    
    
    // for tapers
    public class root {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String dosageId {get;set;}
        @AuraEnabled
        public String medicationName {get;set;}
        @AuraEnabled
        public Id patientAccount {get;set;}
        @AuraEnabled
        public String Type {get;set;}
        @AuraEnabled
        public String Start_Date {get;set;}
        @AuraEnabled
        public Integer DispenseExpectedSupplyDuration {get;set;}
        @AuraEnabled
        public Boolean After_Discharge {get;set;}
        @AuraEnabled
        public String Dosage_Form {get;set;}
        @AuraEnabled
        public String Strength {get;set;}
        @AuraEnabled
        public String Route {get;set;}
        @AuraEnabled
        public String Units {get;set;}
        @AuraEnabled
        public String Dosage {get;set;}
        @AuraEnabled
        public String times {get;set;}
        @AuraEnabled
        public String Owner {get;set;}
        @AuraEnabled
        public String Frequency {get;set;}
        @AuraEnabled
        public Integer NoOfTimes {get;set;}
        @AuraEnabled        
        public String MedicationNameRadio {get;set;}
        @AuraEnabled
        public String commentData {get;set;}
        @AuraEnabled
        public String Warning {get;set;}
        @AuraEnabled
        public String comment {get;set;}
        @AuraEnabled
        public String indexOfDay {get;set;}
        @AuraEnabled
        public Integer indexVar {get;set;}
        @AuraEnabled
        public String indexForInspection {get;set;}
        @AuraEnabled
        public String allStrength {get;set;}
        
    } 
    
    // for action orders
    public class rootActionOrder {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String dosageId {get;set;}
        @AuraEnabled
        public String indexForInspection {get;set;}
        @AuraEnabled
        public String medicationName {get;set;}
        @AuraEnabled
        public Id patientAccount {get;set;}
        @AuraEnabled
        public String Type {get;set;}
        @AuraEnabled
        public String Start_Date {get;set;}
        @AuraEnabled
        public Integer DispenseExpectedSupplyDuration {get;set;}
        @AuraEnabled
        public Boolean After_Discharge {get;set;}
        @AuraEnabled
        public String Warning {get;set;}
        @AuraEnabled
        public String timesActionOrder {get;set;}
        @AuraEnabled
        public String comment {get;set;}
        @AuraEnabled
        public String Owner {get;set;}
        @AuraEnabled
        public Integer NoOfTimes {get;set;}
        @AuraEnabled
        public String Frequency {get;set;}
        @AuraEnabled
        public String commentData {get;set;}
        @AuraEnabled
        public String MedicationNameRadio {get;set;}
        @AuraEnabled
        public String indexOfDay {get;set;}
        @AuraEnabled
        public Integer indexVar {get;set;}
    } 
    
    public class root1 {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String indexForInspection {get;set;}
        @AuraEnabled
        public String dosageId {get;set;}
        @AuraEnabled
        public String medicationName {get;set;}
        @AuraEnabled
        public Id patientAccount {get;set;}
        @AuraEnabled
        public String Type {get;set;}
        @AuraEnabled
        public String Start_Date {get;set;}
        @AuraEnabled
        public String DispenseExpectedSupplyDuration {get;set;}
        @AuraEnabled
        public Boolean After_Discharge {get;set;}
        @AuraEnabled
        public String Route {get;set;}
        @AuraEnabled
        public String Dosage {get;set;}
        @AuraEnabled
        public String Warning {get;set;}
        @AuraEnabled
        public String Strength {get;set;}
        @AuraEnabled
        public String Units {get;set;}
        @AuraEnabled
        public String Owner {get;set;}
        @AuraEnabled
        public String NoOfTimes {get;set;}
        @AuraEnabled
        public String Frequency {get;set;}
        @AuraEnabled
        public String commentData {get;set;}
        @AuraEnabled
        public String comment {get;set;}
        @AuraEnabled
        public String MedicationNameRadio {get;set;}
        @AuraEnabled
        public String indexOfDay {get;set;}
        @AuraEnabled
        public Integer indexVar {get;set;}
        @AuraEnabled
        public String allStrength {get;set;}
        
    }
    
    @AuraEnabled
    public static Map<Id, String> saveDataVaccine(String recordToSaveVaccine , String accountId) {
        Map<Id,String> mapOfVaccine = new Map<Id,String>();
        if(recordToSaveVaccine!=null && !String.isEmpty(recordToSaveVaccine)){
            System.debug('Starting SaveData' + recordToSaveVaccine);
            List<rootVaccine> rootJson = (List<rootVaccine>)JSON.deserialize(recordToSaveVaccine, List<rootVaccine>.class);
            system.debug('the string is' + rootJson);
            List <MAR_MOR__c> newRecs = new List<MAR_MOR__c>();
            Vaccine__c  dosRec = new  Vaccine__c();
            if(rootJson != null & rootJson.size()>0){
                for(rootVaccine rec : rootJson){
                    
                    MAR_MOR__c newRec = new MAR_MOR__c(
                        Account__c = rec.patientAccount ,
                        Medication_Name__c = rec.vaccineName ,
                        Reasons__c = rec.comment ,
                        Index_Number__c = rec.indexOfDay , 
                        Administered_By__c = rec.Owner ,
                        Type__c = 'Vaccine',
                        ElixirSuite__Vaccine_Route__c = rec.route,
                        ElixirSuite__Vaccine_Site__c = rec.vaccineSite,
                        ElixirSuite__Administered_Date__c = Date.valueOf(rec.administeredOn),
                        Status__c =  Boolean.valueOf(rec.VaccineNameRadio)
                        
                    );
                    
                    newRecs.add(newRec);
                    mapOfVaccine.put(rec.Id , String.valueOf(rec.indexVar));
                    system.debug('the map values are' + mapOfVaccine);
                    
                    // for dynamic warning
                    dosRec = [SELECT id, Administered__c,ElixirSuite__Status__c
                              FROM Vaccine__c where id =: rec.Id 
                              WITH SECURITY_ENFORCED];
                    system.debug('teh val ' + dosRec);
                    
                    dosRec.Administered__c = true ;
                    if(Boolean.valueOf(rec.VaccineNameRadio) == true){
                        dosRec.ElixirSuite__Status__c = 'Complete';
                    }
                    else{
                        dosRec.ElixirSuite__Status__c = 'Refused';
                    }
                    
                }
                if(Schema.sObjectType.Vaccine__c.fields.Administered__c.isUpdateable()){
                    update dosRec ;
                }
                
                system.debug('new rec is'+ newRecs);
                
                Database.insert(newRecs,false);
                
                if(newRecs.size()>0){
                   // listOfMarStatements.addAll(newRecs);
                }
            }   
        }
        return mapOfVaccine;
    }
    
    // for Vaccine
    public class rootVaccine {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String indexForInspection {get;set;}
        @AuraEnabled
        public String vaccineName {get;set;}
        @AuraEnabled
        public Id patientAccount {get;set;}
        @AuraEnabled
        public String route {get;set;}
        @AuraEnabled
        public String vaccineSite {get;set;}
		@AuraEnabled
        public String administeredOn {get;set;}
        @AuraEnabled
        public String comment {get;set;}
        @AuraEnabled
        public String Owner {get;set;}
        @AuraEnabled
        public String VaccineNameRadio {get;set;}
        @AuraEnabled
        public String indexOfDay {get;set;}
        @AuraEnabled
        public Integer indexVar {get;set;}
    } 
    
    // THIS IS USED TO SEND EMAIL TO U-R(utilization review) USERS FOR THOSE MEDICINES WHICH ARE NOT REGISTERED
    
    @AuraEnabled
    public static void sendEmailToUR(String notregisteredMedicines){
        List<root1> recordsNotregistered = (List<root1>)JSON.deserialize(notregisteredMedicines, List<root1>.class);
        List<User> toSendEmailUsers = new list<User>();
        toSendEmailUsers = [select Id,Username,Email,profile.name,UserRole.Name,UserRole.id from user where  UserRole.Name='Doctors' WITH SECURITY_ENFORCED]; 
        System.debug('list of users '+toSendEmailUsers);                   
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(User forEmail : toSendEmailUsers) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                        
            mail.setSaveAsActivity(false);
            // mail.setTemplateId(theTemplate);
            // mail.setWhatId(poId);
            mail.setSenderDisplayName('Salesforce ELIXIR Support');
            mail.setSubject('MEDICINES NOT REGISTERED!');
            String s = 'Following medicines for the patient is not been registered. <br/>';
            Integer i = 0;
            for(root1 rec : recordsNotregistered){
                i++;
                String commentData = rec.comment;
                if(String.isBlank(commentData)) {
                    commentData= '';                        
                }
                s += String.ValueOf(i) + '. <b> Medication Name : </b>' + rec.medicationName + '<b> Reason : </b> ' + commentData + '<br/>';
                System.debug('Medicine name '+rec.medicationName);
                System.debug('comment data  name '+rec.commentData);
            }
            mail.setPlainTextBody(s);
            mail.setHtmlBody(s);                     
            mail.setTargetObjectId(forEmail.Id);
            //  mail.setToAddresses(new String[] {forEmail.Email});  //add other emails here.
            mail.setToAddresses(new String[] {forEmail.Email});  //add other emails here.
            emails.add(mail); 
            
            
            
        }
        Messaging.sendEmail(emails);    
        
    }
    
    
    
    
    
}