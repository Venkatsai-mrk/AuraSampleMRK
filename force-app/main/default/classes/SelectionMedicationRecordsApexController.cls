/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-25-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SelectionMedicationRecordsApexController {
   
    @AuraEnabled
    public static wrapper fetchData(List<Id> keys){
        List<String> picklistValues = new List<String>();
        Map<String,Map<String,List<String>>> mapOfNameToField = new  Map<String,Map<String,List<String>>>();
        Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> object_fields_map = global_describe.get('ElixirSuite__Prescription_Order__c').getDescribe().fields.getMap();
        wrapper wrapperObj = new wrapper();
        try{
        for(Schema.SObjectField sfield : object_fields_map.values()){
            Schema.DescribeFieldResult dfield = sfield.getDescribe();
            if(String.valueof(dfield.getType())=='PICKLIST'){
                picklistValues = new List<String>();
                for(Schema.PicklistEntry pickListVal : dfield.getPicklistValues()){
                    picklistValues.add(String.valueOf(pickListVal.getLabel()));
                }             
                Map<String,List<String>> mapOfPicklist = new Map<String,List<String>>();
                mapOfPicklist.put(dfield.getName(),picklistValues);
                if(mapOfNameToField.containsKey('ElixirSuite__Prescription_Order__c')){
                    mapOfNameToField.get('ElixirSuite__Prescription_Order__c').put(dfield.getName(),picklistValues);
                }else{
                    mapOfNameToField.put('ElixirSuite__Prescription_Order__c',mapOfPicklist);
                }
            }
        }
        Map<String, Schema.SObjectField> obj_fields_map = global_describe.get('ElixirSuite__Frequency__c').getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : obj_fields_map.values()){
            Schema.DescribeFieldResult dfield = sfield.getDescribe();
            if(String.valueof(dfield.getType())=='PICKLIST'){
                picklistValues = new List<String>();
                for(Schema.PicklistEntry pickListVal : dfield.getPicklistValues()){
                    picklistValues.add(String.valueOf(pickListVal.getLabel()));
                }
                
                Map<String,List<String>> mapOfPicklist = new Map<String,List<String>>();
                mapOfPicklist.put(dfield.getName(),picklistValues);
                if(mapOfNameToField.containsKey('ElixirSuite__Frequency__c')){
                    mapOfNameToField.get('ElixirSuite__Frequency__c').put(dfield.getName(),picklistValues);
                }else{
                    mapOfNameToField.put('ElixirSuite__Frequency__c',mapOfPicklist);
                }
                
            }
        }
        List<Prescription_Order__c> listOfRecords =[SELECT Id,Drug_Name__c,Reason_new__c,MAR_display__c,PRN__c,Owner.Name, CreatedDate,LastModifiedDate,
                                                                          Type__c,Start_Date__c,Number_of_Times_Days_Weeks__c,Notes__c,Justification__c,
                                                                          After_Discharge__c,Route__c,Warning_new__c,Route_New__c,Dosage_Form__c,Account__c, Prescription_Order__c,
                                                                          (SELECT Id,Frequency_Unit__c,Frequency_Value__c ,
                                                                           Strength__c,Strength_1__c,
                                                                           Strength_2__c,Strength_3__c,Strength_4__c,Strength_5__c,
                                                                           Strength_6__c,Strength_7__c,Strength_8__c,Strength_9__c,
                                                                           Strength_10__c,Strength_11__c,Strength_12__c,Strength_13__c,Strength_14__c,Strength_15__c,
                                                                           Strength_16__c,Strength_17__c,Strength_18__c,Strength_19__c,
                                                                           Strength_20__c,Strength_21__c,Strength_22__c,Strength_23__c, Strength_24__c,       
                                                                           Unit_1__c,Unit_2__c,Unit_3__c,Unit_4__c,Unit_5__c,
                                                                           Unit_6__c,Unit_7__c,Unit_8__c,Unit_9__c,
                                                                           Unit_10__c,Unit_11__c,Unit_12__c,Unit_13__c,Unit_14__c,Unit_15__c,
                                                                           Unit_16__c,Unit_17__c,Unit_18__c,Unit_19__c,
                                                                           Unit_20__c,Unit_21__c,Unit_22__c,Unit_23__c, Unit_24__c,                        
                                                                           Start_Time_1__c,Start_Time_2__c,Start_Time_3__c,Start_Time_4__c,Start_Time_5__c,
                                                                           Start_Time_6__c,Start_Time_7__c,Start_Time_8__c,Start_Time_9__c,
                                                                           Start_Time_10__c,Start_Time_11__c,Start_Time_12__c,Start_Time_13__c,Start_Time_14__c,Start_Time_15__c,
                                                                           Start_Time_16__c,Start_Time_17__c,Start_Time_18__c,Start_Time_19__c,
                                                                           Start_Time_20__c,Start_Time_21__c,Start_Time_22__c,Start_Time_23__c,Start_Time_24__c,
                                                                           Quantity_1__c,Quantity_2__c,Quantity_3__c,Quantity_4__c,Quantity_5__c,
                                                                           Quantity_6__c,Quantity_7__c,Quantity_8__c,Quantity_9__c,
                                                                           Quantity_10__c,Quantity_11__c,Quantity_12__c,Quantity_13__c,Quantity_14__c,Quantity_15__c,
                                                                           Quantity_16__c,Quantity_17__c,Quantity_18__c,Quantity_19__c,
                                                                           Quantity_20__c,Quantity_21__c,Quantity_22__c,Quantity_23__c,Quantity_24__c,
                                                                           Repeat__c,Dosage_Instruction__c FROM  Frequency__r)
                                                                           FROM Prescription_Order__c WHERE Id IN: keys WITH SECURITY_ENFORCED LIMIT 5000];
        List<User> users = [SELECT Id, Name FROM User 
                        WHERE IsActive=TRUE
                        WITH SECURITY_ENFORCED LIMIT 5000];
        //wrapper wrapperObj = new wrapper();
        wrapperObj.listOfRecs = listOfRecords;
        wrapperObj.picklistValues = mapOfNameToField;
        wrapperObj.listOfUsers = users;
        wrapperObj.nameSpace = Elixir_Utility.getNamespace();
       
        //return wrapperObj;
    }
         catch(Exception e){
         ExceptionLog.logError(e);
        }
          return wrapperObj;
    }
    //added by Anmol for LX3-5770
    @AuraEnabled 
    public static String fetchUser(){
       User u = [select id,Name from User where id =: userInfo.getUserId() WITH SECURITY_ENFORCED];
        String userName = u.Name;
        return userName;
    }
    //end by Anmol for LX3-5770
    
    public class wrapper{
        @AuraEnabled
        public List<Prescription_Order__c> listOfRecs;
        @AuraEnabled
        public Map<String,Map<String,List<String>>> picklistValues;
        @AuraEnabled
        public List<User> listOfUsers;
        @AuraEnabled
        public string nameSpace;
        
    }

    @AuraEnabled
    public static void attachApprovalDataToParentPrescription(String parentPrescriptionId, String approvedValues){
        try {
            ElixirSuite__Prescription_Order__c parentPrescription = new ElixirSuite__Prescription_Order__c(Id=parentPrescriptionId);
            List<OrderSignatureSave.SignAndAprroveData> approvedValuesDeserialized = (List<OrderSignatureSave.SignAndAprroveData>)JSON.deserializeStrict(approvedValues, List<OrderSignatureSave.SignAndAprroveData>.class);
			Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId();
            Integer defaultCount = [SELECT COUNT() FROM Master_Object__c 
                                	WHERE Approval_Level_For__c = 'Prescription Order' 
                                	AND recordTypeId =:recordTypeId WITH SECURITY_ENFORCED];

            for (OrderSignatureSave.SignAndAprroveData i : approvedValuesDeserialized) {
                switch on i.approvalLevel {
                    when 1 {
                        parentPrescription.ElixirSuite__Date_Of_Approval_1__c = i.dateOfApproval;
                        parentPrescription.ElixirSuite__Comment_1__c = i.comments;
                        parentPrescription.ElixirSuite__User_1__c = i.userId;
                        switch on defaultCount {
                            when 1 {
                                parentPrescription.status__c = 'Completed';
                            }
                            when else {
                                parentPrescription.status__c = 'In progress';
                            }
                        }
                    }
                    when 2 {
                        parentPrescription.ElixirSuite__Date_Of_Approval_2__c = i.dateOfApproval;
                        parentPrescription.ElixirSuite__Comment_2__c = i.comments;
                        parentPrescription.ElixirSuite__User_2__c = i.userId;
                        switch on defaultCount {
                            when 2 {
                                parentPrescription.status__c = 'Completed';
                            }
                            when else {
                                parentPrescription.status__c = 'In progress';
                            }
                        }
                    }

                    when 3 {
                        parentPrescription.ElixirSuite__Date_Of_Approval_3__c = i.dateOfApproval;
                        parentPrescription.ElixirSuite__Comment_3__c = i.comments;
                        parentPrescription.ElixirSuite__User_3__c = i.userId;
                        switch on defaultCount {
                            when 3 {
                                parentPrescription.status__c = 'Completed';
                            }
                        }
                    }
                }
            }

            DMLManager.updateAsUser(parentPrescription);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Method to save the Prescription order.
    @AuraEnabled
    public static List<Id> saveData(String jsonList, String selectedUser,String selectedVia, String accId ,String starttimeProcedure , String endtimeProcedure, String formUnId) {
      
        Id recordTypeIdForOrder = Schema.SObjectType.Prescription_Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        Id recordTypeIdForMedication = Schema.SObjectType.Prescription_Order__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
        
          Id devRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();
        
              //added by Anmol for LX3-7236
        Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
        if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
        String careStatus = 'Active';

        string querystr = '';
        querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED order by ';
        querystr += careFilter ;
        List<ElixirSuite__Visits__c> lst_visits = database.query(querystr);
        //end by Anmol for LX3-7236
          
   		String CareId = 'no careid';

           String formId = formUnId;
        Prescription_Order__c ordr = new Prescription_Order__c();
        try{
        ordr.Status__c= 'Open';
        ordr.Account__c = accId;
        ordr.RecordTypeId = recordTypeIdForOrder;
        ordr.ElixirSuite__Ordered_Via__c   = selectedVia;
         if(!lst_visits.isEmpty())
          {
               ordr.ElixirSuite__Care_Episode__c =lst_visits[0].Id;
              CareId = lst_visits[0].Id;
          }
         /*    if (Schema.sObjectType.Prescription_Order__c.fields.Status__c.isCreateable() && 
              Schema.sObjectType.Prescription_Order__c.fields.Account__c.isCreateable() && 
              Schema.sObjectType.Prescription_Order__c.fields.RecordTypeId.isCreateable() &&
               Schema.sObjectType.Prescription_Order__c.fields.ElixirSuite__Care_Episode__c.isCreateable() ) {*/
     //   insert ordr;
     DMLManager.insertAsUser(ordr);//added by Anmol for LX3-6500
     //  }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
                                                if(Elixir_Utility.fetchCreateProcedureReturnValue()==true){
                                                              Procedure__c newProcedure = new Procedure__c();
                                                           newProcedure.Account__c=accId; 
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
                                                            newProcedure.Name = 'Prescription procedure';
                                                          if(!lst_visits.isEmpty())
                                                           {
                                                               newProcedure.ElixirSuite__Visits__c =lst_visits[0].Id;
                                                           }
        													  if (Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() && 
                                                                 Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() && 
                                                                 Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() && 
                                                                 Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
                                                                  Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
                                                                  Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable() &&
                                                                  Schema.sObjectType.Procedure__c.fields.Name.isCreateable() && Schema.sObjectType.Procedure__c.isCreateable()) {
                                                                       DMLManager.insertAsUser(newProcedure);
                                                                  }
                                                          // if (Schema.sObjectType.Procedure__c.isCreateable()) {   
                                                             //  insert newProcedure;
                                                             //DMLManager.insertAsUser(newProcedure);//added by Anmol for LX3-6500
                                                        //   }
                                                                }
                                                            
		 //Creation of default procedure which will be related to latest encounter present for that account.                            
      /* HealthCloudGA__EHRProcedure__c defaultProcedure = new HealthCloudGA__EHRProcedure__c();
       defaultProcedure.HealthCloudGA__Account__c= accId; 
       defaultProcedure.Ehr_Prescription_Order__c=  ordr.Id;  
       //Elixir_utility.attachProcedureEncounter(defaultProcedure, accId, ordr.Id,starttimeProcedure,endtimeProcedure );   */     
               
        root rootJson = (root)JSON.deserialize(jsonList,root.class);
        List <Prescription_Order__c> newRecs = new List<Prescription_Order__c>();
       
        List<JSON2Apex> listOfJson = (List<JSON2Apex>)rootJson.jsonListForTaper;
           if(listOfJson != null & listOfJson.size()>0){
       SelectionMedicationRecordsApexController.saveAllDataAsSameUtility(selectedUser,selectedVia,accId ,starttimeProcedure ,endtimeProcedure,listOfJson,ordr,CareId,formId);
		 	}
       
        /*if(listOfJson != null & listOfJson.size()>0){
        for(JSON2Apex rec : listOfJson){
            System.debug('Inside first for');
            Prescription_Order__c newRec = new Prescription_Order__c(
                Drug_Name__c = rec.medicationName,
                Number_of_Times_Days_Weeks__c = String.valueOf(rec.dispenseExpectedSupplyDuration),
                Reason_new__c = rec.reasonLabel,
                Route_New__c = rec.Route,
                Dosage_Form__c = rec.dosageForm,
                Start_Date__c = Date.valueOf(rec.startDate),
                Warning_new__c = rec.Warning,
                Type__c = rec.types,
                After_Discharge__c = rec.afterDischarge,
                Account__c = accId,
                RecordTypeId = recordTypeIdForMedication,
                Prescription_Order__c = ordr.id
            );
            System.debug('Inside first for before addition to list');
            newRecs.add(newRec);
        }
        Database.insert(newRecs,false);
        System.debug('After insert');
        integer i = 0;
        List<Frequency__c> listOfDosage = new List<Frequency__c>();
        for(JSON2Apex rec	: listOfJson){
            Integer count = 0;
            System.debug('Dosage insertion first if');
            for(Days d	:	rec.Days){
                System.debug('Dosage insertion if Days');
                Frequency__c newRec = new Frequency__c(); 
                newRec.Dosage_Instruction__c = String.valueOf(d.Dosage_Instruction);
                newRec.Repeat__c = d.Repeat;
                newRec.Prescription_Order__c = newRecs[i].Id;
                Integer dte = newRecs[i].Start_Date__c.day();
                Integer mo = newRecs[i].Start_Date__c.month();
                Integer yr = newRecs[i].Start_Date__c.year();
                newRec.Frequency_Timing__c =  DateTime.newInstance(yr,mo,dte).addDays(count+1);
                for(Integer c=1;c<=d.Strength.size();c++){
                    System.debug('Dosage insertion deepest if');
                    String index = String.valueOf(c);
                    String strength = 'Strength_'+index+'__c';
                    String unit = 'Unit_'+index+'__c';
                    String quantity = 'Quantity_'+index+'__c';
                    String timings = 'Start_Time_'+index+'__c';
                    
                    newRec.put(strength,d.Strength[c-1]);
                    newRec.put(unit,d.Units[c-1]);
                    newRec.put(quantity,Double.valueOf(d.Dosage[c-1]));
                    System.debug('After putting dosage');
                    String[] strTimeSplit = d.times[c-1].split(':');
                    Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                       ,Integer.valueOf(strTimeSplit[1]) //min
                                                       ,0                                //sec
                                                       ,0);                 
                    System.debug('Dosage insertion deepest if 1');
                    newRec.put(timings,timeChange);
                    
                }
                count++;
                listOfDosage.add(newRec);
            }
            i++;
        }
        System.debug('inserted');
        insert listOfDosage;
        }*/
        //For PRN
        List<JSON2Apex> listOfJsonPRN = (List<JSON2Apex>)rootJson.jsonListForPRN;
        if(listOfJsonPRN != null && listOfJsonPRN.size()>0){
          SelectionMedicationRecordsApexController.saveAllDataAsSameUtility(selectedUser,selectedVia,accId ,starttimeProcedure ,endtimeProcedure,listOfJsonPRN,ordr,CareId,formId);  
        }
       /* if(listOfJsonPRN != null && listOfJsonPRN.size()>0){
        List <Prescription_Order__c> newRecsPrn = new List<Prescription_Order__c>();
        for(JSONprn rec : listOfJsonPRN){
            System.debug('Inside first for');
            Prescription_Order__c newRec = new Prescription_Order__c(
                Drug_Name__c = rec.medicationName,               
                Reason_new__c = rec.reasonLabel,
                Route_New__c = rec.Route,
                Dosage_Form__c = rec.dosageForm,
                Start_Date__c = Date.valueOf(rec.startDate),
                Warning_new__c = rec.Warning,
                Type__c = rec.types,
                After_Discharge__c = rec.afterDischarge,
                Account__c = accId,
                Number_of_Times_Days_Weeks__c = String.valueOf(rec.dispenseExpectedSupplyDuration),
                End_Date__c = Date.valueOf(rec.startDate).addDays(rec.dispenseExpectedSupplyDuration),
                RecordTypeId = recordTypeIdForMedication,
                Prescription_Order__c = ordr.id
            );
            System.debug('Inside first for before addition to list'+accId);
            newRecsPrn.add(newRec);
        }
        Database.insert(newRecsPrn,false);
        integer i = 0;
        List<Frequency__c> listOfDosagePRN = new List<Frequency__c>();
            for(JSONprn rec : listOfJsonPRN){                
                System.debug('listOfJsonPRN--'+listOfJsonPRN);
                System.debug(rec.singleRecForPrn);
                for(singleRecPRN record	:	rec.singleRecForPrn){            
                    Frequency__c newRec = new Frequency__c();
                    newRec.Prescription_Order__c = newRecsPrn[i].Id;
                    newRec.Frequency_Unit__c = record.UnitsForPrn;
                    newRec.Strength__c =record.StrengthForPrn;
                    newRec.Frequency_Value__c = record.DosageForPrn;
                    newRec.Repeat__c = record.Repeat;
                    newRec.Dosage_Instruction__c = String.valueOf(record.Dosage_Instruction);
                    listOfDosagePRN.add(newRec);            
                }
                  i++;
            }
            Database.insert(listOfDosagePRN,false);
            System.debug(listOfDosagePRN);
        }*/
        //Action Order
        List<JSON2Apex> listOfActOrders = (List<JSON2Apex>) rootJson.jsonListForAOrder;
         if(listOfActOrders != null && listOfActOrders.size()>0){
          SelectionMedicationRecordsApexController.saveAllDataAsSameUtility(selectedUser,selectedVia,accId ,starttimeProcedure ,endtimeProcedure,listOfActOrders,ordr,CareId,formId);  
        }
        return new List<Id>{ordr.Id};
       /* if(listOfActOrders!=null && listOfActOrders.size()>0){
           	 List <Prescription_Order__c> newRecsActionOrders = new List<Prescription_Order__c>();
        for(actionOrder rec : listOfActOrders){
            System.debug('Inside first for');
            Prescription_Order__c newRec = new Prescription_Order__c(
                Drug_Name__c = rec.medicationName,                
                Start_Date__c = Date.valueOf(rec.startDate),
                Type__c = rec.types,
                After_Discharge__c = rec.afterDischarge,
                Account__c = accId,
                Number_of_Times_Days_Weeks__c = String.valueOf(rec.dispenseExpectedSupplyDuration),
                Justification__c = rec.Justification,
                MAR_Display__c = rec.MARdisplay,
                End_Date__c =  Date.valueOf(rec.startDate).addDays(rec.dispenseExpectedSupplyDuration),
                PRN__c = rec.PRNdisplay ,
                RecordTypeId = recordTypeIdForMedication,
                Prescription_Order__c = ordr.id
            );
            System.debug('Inside first for before addition to list'+accId);
            newRecsActionOrders.add(newRec);
        }
        Database.insert(newRecsActionOrders,false);
        integer i = 0;
        List<Frequency__c> listOfDosageActionOrders = new List<Frequency__c>();
            for(actionOrder rec : listOfActOrders){                             
                for(SingleRecForActionOrder record	:	rec.SingleRecForActionOrder){            
                    Frequency__c newRec = new Frequency__c();
                    newRec.Prescription_Order__c = newRecsActionOrders[i].Id;                
                    newRec.Repeat__c = record.Repeat;
                    newRec.Dosage_Instruction__c = String.valueOf(record.Dosage_Instruction);
                    Integer idx = 1;
                    for(String timeRec : record.StartTime){
                    String timings = 'Start_Time_'+idx+'__c';
                    String[] strTimeSplit = timeRec.split(':');
                    Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                       ,Integer.valueOf(strTimeSplit[1]) //min
                                                       ,0                                //sec
                                                       ,0);                 
                    System.debug('Dosage insertion deepest if 1');
                    newRec.put(timings,timeChange);
                        idx++;
                    }
                    
                    listOfDosageActionOrders.add(newRec);            
                }
                  i++;
            }
            Database.insert(listOfDosageActionOrders,false);
            System.debug(listOfDosageActionOrders);
            
        }*/
      
    }
    //JSON Structure
   /* public class root{
        @AuraEnabled
        public List<JSON2Apex> jsonListForTaper{get;set;}
        @AuraEnabled
        public List<JSONprn> jsonListForPRN{get;set;}
        @AuraEnabled
        public List<actionOrder> jsonListForAOrder{get;set;}
    }*/
    public class root{
        @AuraEnabled
        public List<JSON2Apex> jsonListForTaper{get;set;}
        @AuraEnabled
        public List<JSON2Apex> jsonListForPRN{get;set;}
        @AuraEnabled
        public List<JSON2Apex> jsonListForAOrder{get;set;}
    }
    public class JSONprn{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String medicationName {get;set;}
        @AuraEnabled
        public Integer dispenseExpectedSupplyDuration {get;set;}
        @AuraEnabled
        public String types {get;set;}
        @AuraEnabled
        public String startDate {get;set;}
        @AuraEnabled
        public Boolean afterDischarge {get;set;}
        @AuraEnabled
        public String dosageForm {get;set;}
        @AuraEnabled
        public String reasonLabel {get;set;}
        @AuraEnabled
        public String Route {get;set;}
        @AuraEnabled
        public String Warning {get;set;}
      
        @AuraEnabled
        public List<singleRecPRN> singleRecForPrn {get;set;}
    }
    public class singleRecPRN{
        public String UnitsForPrn  {get;set;}
        public String StrengthForPrn  {get;set;}                          
        public String DosageForPrn  {get;set;}
        public String Repeat  {get;set;} 
        public String Dosage_Instruction  {get;set;}
        
    }
    
    
   
    
    
    public class JSON2Apex {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String medicationName {get;set;}
        @AuraEnabled
        public String types {get;set;}
        @AuraEnabled
        public String startDate {get;set;}
        @AuraEnabled
        public Integer dispenseExpectedSupplyDuration {get;set;}
        @AuraEnabled
        public Boolean afterDischarge {get;set;}
        @AuraEnabled
        public String dosageForm {get;set;}
        @AuraEnabled
        public String reasonLabel {get;set;}
        @AuraEnabled
        public String Route {get;set;}
        @AuraEnabled
        public String Warning {get;set;}
       	@AuraEnabled
        public Boolean MARdisplay {get;set;}
          @AuraEnabled
        public Boolean PRNdisplay {get;set;}
        @AuraEnabled
        public List<Days> Days {get;set;}
        
    } 
    public class Days {
        @AuraEnabled
        public List<String> times;
        @AuraEnabled
        public List<String> Units;
        @AuraEnabled
        public List<String> Dosage;
        @AuraEnabled
        public List<String> Strength;
        @AuraEnabled
        public Integer indexOfDay;
        @AuraEnabled
        public String Repeat;
        @AuraEnabled
        public Integer Dosage_Instruction;
    }
    //Action Order
    public class actionOrder {
        
        public String Id;
        public String medicationName;
        public String types;
        public String startDate;
        public Boolean afterDischarge;
        public String endDate;
        public Integer dispenseExpectedSupplyDuration;
        public Boolean PRNdisplay;
        public Boolean MARdisplay;
        public String Justification;
        public List<SingleRecForActionOrder> singleRecForActionOrder;     
    }
    public class SingleRecForActionOrder {
		public List<String> StartTime;
		public String Repeat;
		public String Dosage_Instruction;
		public String textMessage;
	}
    public static void saveAllDataAsSameUtility(String selectedUser,String selectedVia, String accId ,String starttimeProcedure , String endtimeProcedure,
                                                List<JSON2Apex> listOfJson,Prescription_Order__c ordr,String careId , String formUniqId) {
       Id recordTypeIdForMedication = Schema.SObjectType.Prescription_Order__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
        List <Prescription_Order__c> newRecs = new List<Prescription_Order__c>();
                                                    try{
        for(JSON2Apex rec : listOfJson){
            if(String.isBlank(String.valueOf(rec.PRNdisplay))){
                rec.PRNdisplay = false ; 
            }
             if(String.isBlank(String.valueOf(rec.MARdisplay))){
                rec.MARdisplay = false ; 
            }
           
             Prescription_Order__c newRec = new Prescription_Order__c();
            if(careId=='no careid'){
                 newRec.ElixirSuite__Drug_Name__c = rec.medicationName;
                newRec.Number_of_Times_Days_Weeks__c = String.valueOf(rec.dispenseExpectedSupplyDuration);
                newRec.Reason_new__c = rec.reasonLabel;
                newRec.Route_New__c = rec.Route;
                newRec.Dosage_Form__c = rec.dosageForm;
                newRec.Start_Date__c = Date.valueOf(rec.startDate);
                newRec.Warning_new__c = rec.Warning;
                newRec.Type__c = rec.types;
                newRec.MAR_Display__c = rec.MARdisplay;
                newRec.End_Date__c =  Date.valueOf(rec.startDate).addDays(rec.dispenseExpectedSupplyDuration);
                newRec.PRN__c = rec.PRNdisplay;
                newRec.RecordTypeId = recordTypeIdForMedication;
                newRec.After_Discharge__c = rec.afterDischarge;
                newRec.Account__c = accId;
                newRec.Prescription_Order__c = ordr.id;
                newRec.Form_Unique_Id__c = formUniqId;
                newRec.Ordered_Via__c = selectedVia;
            }
            else{
                newRec.ElixirSuite__Drug_Name__c = rec.medicationName;
                newRec.Number_of_Times_Days_Weeks__c = String.valueOf(rec.dispenseExpectedSupplyDuration);
                newRec.Reason_new__c = rec.reasonLabel;
                newRec.Route_New__c = rec.Route;
                newRec.Dosage_Form__c = rec.dosageForm;
                newRec.Start_Date__c = Date.valueOf(rec.startDate);
                newRec.Warning_new__c = rec.Warning;
                newRec.Type__c = rec.types;
                newRec.MAR_Display__c = rec.MARdisplay;
                newRec.End_Date__c =  Date.valueOf(rec.startDate).addDays(rec.dispenseExpectedSupplyDuration);
                newRec.PRN__c = rec.PRNdisplay;
                newRec.RecordTypeId = recordTypeIdForMedication;
                newRec.After_Discharge__c = rec.afterDischarge;
                newRec.Account__c = accId;
                newRec.Prescription_Order__c = ordr.id;
                newRec.Care_Episode__c = careId;
                newRec.Form_Unique_Id__c = formUniqId;
                newRec.Ordered_Via__c = selectedVia;
            }
           
           
            newRecs.add(newRec);
        }
       // Database.insert(newRecs,false);
        // insert newRecs;
        DMLManager.insertAsUser(newRecs);//added by Anmol for LX3-6500
        
        integer i = 0;
        List<Frequency__c> listOfDosage = new List<Frequency__c>();
        for(JSON2Apex rec	: listOfJson){
            Integer count = 0;
            
            for(Days d	:	rec.Days){
               
                Frequency__c newRec = new Frequency__c(); 
                newRec.Dosage_Instruction__c = String.valueOf(d.Dosage_Instruction);
                newRec.Repeat__c = d.Repeat;
                newRec.Prescription_Order__c = newRecs[i].Id;
                Integer dte = newRecs[i].Start_Date__c.day();
                Integer mo = newRecs[i].Start_Date__c.month();
                Integer yr = newRecs[i].Start_Date__c.year();
                newRec.Frequency_Timing__c =  DateTime.newInstance(yr,mo,dte).addDays(count+1);
                for(Integer c=1;c<=d.Strength.size();c++){
                    
                    String index = String.valueOf(c);
                    String strength = 'ElixirSuite__Strength_'+index+'__c';
                    String unit = 'ElixirSuite__Unit_'+index+'__c';
                    String quantity = 'ElixirSuite__Quantity_'+index+'__c';
                    String timings = 'ElixirSuite__Start_Time_'+index+'__c';
                    
                    newRec.put(strength,d.Strength[c-1]);
                    newRec.put(unit,d.Units[c-1]);
                    newRec.put(quantity,Double.valueOf(d.Dosage[c-1]));
                   
                    String[] strTimeSplit = d.times[c-1].split(':');
                    Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                       ,Integer.valueOf(strTimeSplit[1]) //min
                                                       ,0                                //sec
                                                       ,0);                 
                  
                    newRec.put(timings,timeChange);
                    
                }
                count++;
                listOfDosage.add(newRec);
            }
            i++;
        }
       
                                                   
           //  if(
             //  Schema.sObjectType.Frequency__c.fields.Frequency_Timing__c.isCreateable() &&
              // Schema.sObjectType.Frequency__c.fields.Dosage_Instruction__c.isCreateable()  ){                                                                                   
        //  insert listOfDosage;
        DMLManager.insertAsUser(listOfDosage);//added by Anmol for LX3-6500
           //  }
        }
            catch(Exception e){
            ExceptionLog.logError(e);
        }

      }
}