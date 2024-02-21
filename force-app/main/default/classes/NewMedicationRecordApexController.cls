public with sharing class NewMedicationRecordApexController {
    @AuraEnabled
    public static wrapper fetchData(){
        List<String> picklistValues = new List<String>();
        Map<String,Map<String,List<String>>> mapOfNameToField = new  Map<String,Map<String,List<String>>>();
        try{
        Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> object_fields_map = global_describe.get('ElixirSuite__Prescription_Order__c').getDescribe().fields.getMap();
        
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
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        wrapper wrapperObj = new wrapper();
        wrapperObj.picklistValues = mapOfNameToField;    
        return wrapperObj;
    }
    
    public class wrapper{
        @AuraEnabled
        public Map<String,Map<String,List<String>>> picklistValues;      
    }
     @AuraEnabled
    public static void saveData(String jsonList, String accId) {
      //(selectedUser+selectedVia+accId);
       System.debug('Inside first for Starting SaveData');
        
        Id recordTypeIdForOrder = Schema.SObjectType.Prescription_Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        Id recordTypeIdForMedication = Schema.SObjectType.Prescription_Order__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
       
        root rootJson = (root)JSON.deserialize(jsonList,root.class);
        List <Prescription_Order__c> newRecs = new List<Prescription_Order__c>();
        System.debug('rootJson=='+rootJson);
        List<JSON2Apex> listOfJson = (List<JSON2Apex>)rootJson.jsonListForTaper;
        System.debug('listOfJson=='+listOfJson);
        if(listOfJson != null & listOfJson.size()>0){
         insertNewRecordForAllMedicationsUtility(listOfJson, accId);   
        }
        //For PRN
        List<JSON2Apex> listOfJsonPRN = (List<JSON2Apex>)rootJson.jsonListForPRN;
        System.debug('143 linr number =='+listOfJsonPRN);
        if(listOfJsonPRN!=null && listOfJsonPRN.size()>0){
               insertNewRecordForAllMedicationsUtility(listOfJsonPRN, accId); 
         }
        //Action Order
        List<JSON2Apex> listOfActOrders = (List<JSON2Apex>) rootJson.jsonListForAOrder;
          System.debug('before null');
         if(listOfActOrders!=null && listOfActOrders.size()>0){
               insertNewRecordForAllMedicationsUtility(listOfActOrders, accId); 
         }
    }
    
    public static void insertNewRecordForAllMedicationsUtility(List<JSON2Apex> listOfJson, String patientId){
           List <Prescription_Order__c> newRecs = new List<Prescription_Order__c>();
           List<Prescription_Order__c> prescriptionRecords = new List<Prescription_Order__c>();
           Id recordTypeIdForOrder = Schema.SObjectType.Prescription_Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
            Prescription_Order__c prescriptionLst = new Prescription_Order__c();
            prescriptionLst.Account__c = patientId;
            prescriptionLst.RecordTypeId=recordTypeIdForOrder;
            prescriptionRecords.add(prescriptionLst);
            //insert prescriptionRecords;
            DMLManager.insertAsUser(prescriptionRecords);
        try{
            
          // Create a set to hold unique medication IDs
            Set<String> medicationIds = new Set<String>();
            
            // Populate the set with medication IDs from JSON records
            for (JSON2Apex rec : listOfJson) {
                medicationIds.add(rec.medicationName);
            }
            
            // Query the ElixirSuite__Master_Object__c records outside the loop
            Map<String, ElixirSuite__Master_Object__c> medicationMap = new Map<String, ElixirSuite__Master_Object__c>();
            for (ElixirSuite__Master_Object__c medRec : [SELECT Id, Name, ElixirSuite__Coding_System__c, ElixirSuite__Coding_System_Value__c 
                                                         FROM ElixirSuite__Master_Object__c 
                                                         WHERE Id IN :medicationIds WITH SECURITY_ENFORCED]) {
                medicationMap.put(medRec.Id, medRec);
            }
         for(JSON2Apex rec : listOfJson){
         //  ('Inside first for');
             if(String.isBlank(String.valueOf(rec.MARdisplay))){
                 rec.MARdisplay = false;
             }
             if(String.isBlank(String.valueOf(rec.PRNdisplay))){
                 rec.PRNdisplay = false;
             }
             /* System.debug('Drug Id'+rec.medicationName);
             List<ElixirSuite__Master_Object__c> recList=[select id, Name, ElixirSuite__Coding_System__c, 
                                                   ElixirSuite__Coding_System_Value__c from ElixirSuite__Master_Object__c 
                                                   Where id=:rec.medicationName LIMIT 1];
             System.debug('Drug'+recList[0].Name);*/
             System.debug('Drug--medicationName'+rec.medicationName);
            Id recordTypeIdForMedication = Schema.SObjectType.Prescription_Order__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
             

            Prescription_Order__c newRec = new Prescription_Order__c(
                Number_of_Times_Days_Weeks__c = String.valueOf(rec.dispenseExpectedSupplyDuration),
                Reason_new__c = rec.reasonLabel,
                ElixirSuite__Medication__c=rec.medicationName,
                ElixirSuite__Route_New_1__c = rec.Route,
                ElixirSuite__Dosage1__c = rec.dosageForm,
                Start_Date__c = Date.valueOf(rec.startDate),
                Warning__c = rec.Warning,
                Type__c = rec.types,
                After_Discharge__c = rec.afterDischarge,
				 Justification__c = rec.Justification,
                MAR_Display__c = Boolean.valueOf(rec.MARdisplay),
                End_Date__c =  Date.valueOf(rec.startDate).addDays(rec.dispenseExpectedSupplyDuration),
                PRN__c = rec.PRNdisplay,
                Status__c= 'Open',
        		Account__c = patientId,
                ElixirSuite__Prescription_Order__c=prescriptionRecords[0].Id,
        		RecordTypeId = recordTypeIdForMedication
                
            );
             // Use the queried medication record from the map
                if (medicationMap.containsKey(rec.medicationName)) {
                    ElixirSuite__Master_Object__c medRecord = medicationMap.get(rec.medicationName);
                    newRec.Drug_Name__c = medRecord.Name;
                }
             newRecs.add(newRec);
        }
        
       
        if(Schema.sObjectType.Prescription_Order__c.isCreateable()){
        insert newRecs;
        }
       
        
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        System.debug('after AO Insert');
        integer i = 0;
        List<Frequency__c> listOfDosage = new List<Frequency__c>();
        try{
        for(JSON2Apex rec	: listOfJson){
            Integer count = 0;
          // ('Dosage insertion first if');
            if(rec.Days == null){
                continue;
            }
            for(Days d	:	rec.Days){
            //   ('Dosage insertion if Days');
                Frequency__c newRec = new Frequency__c(); 
                newRec.Dosage_Instruction__c = String.valueOf(d.Dosage_Instruction);
                newRec.Repeat__c = d.Repeat;
                newRec.Prescription_Order__c = newRecs[i].Id;
                Integer dte = newRecs[i].Start_Date__c.day();
                Integer mo = newRecs[i].Start_Date__c.month();
                Integer yr = newRecs[i].Start_Date__c.year();
                newRec.Frequency_Timing__c =  DateTime.newInstance(yr,mo,dte).addDays(count+1);
                for(Integer c=1;c<=d.Strength.size();c++){
                //   ('Dosage insertion deepest if');
                   newRec.Frequency_Unit__c = d.Strength[0];
                   newRec.Frequency_Value__c = String.valueOf(d.Dosage[0]);
                    String index = String.valueOf(c);
                    String strength = 'Strength_'+index+'__c';
                    String unit = 'Unit_'+index+'__c';
                    String quantity = 'Quantity_'+index+'__c';
                    String timings = 'Start_Time_'+index+'__c';
                    
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
     if(Schema.sObjectType.Frequency__c.isCreateable()){
        insert listOfDosage;
     }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    //JSON Structure
    public class root{
        @AuraEnabled
        public List<JSON2Apex> jsonListForTaper{get;set;}
        @AuraEnabled
        public List<JSON2Apex> jsonListForPRN{get;set;}
         @AuraEnabled
        public List<JSON2Apex> jsonListForAOrder{get;set;}
    }
   /* public class JSONprn{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String medicationName {get;set;}
        @AuraEnabled
        public String types {get;set;}
        @AuraEnabled
        public String startDate {get;set;}
        @AuraEnabled
        public Boolean afterDischarge {get;set;}
        @AuraEnabled
        public Integer dispenseExpectedSupplyDuration {get;set;}
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
      public class JSONActionOrder{
         @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String MARDisplay {get;set;}
           @AuraEnabled
        public String PRNdisplay {get;set;}
          
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
        public List<Days> Days {get;set;}
        @AuraEnabled
        public String endDate {get;set;}
        @AuraEnabled
        public List<SingleRecForActionOrder> singleRecForActionOrder {get;set;}
        @AuraEnabled
        public String Notes {get;set;}
    }*/
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
    public class singleRecPRN{
        public String UnitsForPrn  {get;set;}
        public String StrengthForPrn  {get;set;}                          
        public String DosageForPrn  {get;set;}
        public String Repeat  {get;set;} 
        public Integer Dosage_Instruction{get;set;}
        
    }
   

   public class SingleRecForActionOrder {
       public List<String> times; 
		public List<String> StartTime;
		public String Repeat;
		public String Dosage_Instruction;
		public String textMessage;
	}
    public class JSON2Apex {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public Boolean MARDisplay {get;set;}
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
        public List<Days> Days {get;set;}
        @AuraEnabled
        public String endDate {get;set;}
        @AuraEnabled
        public List<SingleRecForActionOrder> singleRecForActionOrder {get;set;}
        @AuraEnabled
        public String Notes {get;set;}
          @AuraEnabled
        public String Justification {get;set;}
          @AuraEnabled
        public Boolean PRNdisplay {get;set;}
        
       
        
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
         @AuraEnabled
        public String textMessage;
    }   
}