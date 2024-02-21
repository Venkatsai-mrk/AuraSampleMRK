public with sharing class EditMedicationApexController {
    @AuraEnabled
    public static wrapper fetchData(List<Id> keys){
        List<String> picklistValues = new List<String>();
        Map<String,Map<String,List<String>>> mapOfNameToField = new  Map<String,Map<String,List<String>>>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> object_fields_map = globalDescribe.get('ElixirSuite__Prescription_Order__c').getDescribe().fields.getMap();
        
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
      //   Map<String, Schema.SObjectField> obj_fields_map = globalDescribe.get('Frequency__c').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> obj_fields_map = globalDescribe.get('ElixirSuite__Frequency__c').getDescribe().fields.getMap();
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
        List<Prescription_Order__c> listOfRecords =[SELECT Id,ElixirSuite__Drug_Name__c,ElixirSuite__Reason_new__c,ElixirSuite__MAR_Display__c,PRN__c,Type__c,Start_Date__c,Number_of_Times_Days_Weeks__c,Notes__c,Justification__c,
                                                                          After_Discharge__c,Route__c,Warning__c,Route_New__c,Dosage_Form__c,Account__c,
                                                    					  ElixirSuite__Medication__c, ElixirSuite__Medication__r.Name,ElixirSuite__Warning_new__c, 
                                                    						ElixirSuite__Dosage1__c, ElixirSuite__Dosage1__r.Name, ElixirSuite__Route_New_1__c, 
                                                    						ElixirSuite__Route_New_1__r.Name,
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
        List<User> users = [SELECT Id, Name FROM User WITH SECURITY_ENFORCED LIMIT 5000];
        wrapper wrapperObj = new wrapper();
        wrapperObj.listOfRecs = listOfRecords;
        wrapperObj.picklistValues = mapOfNameToField;
        wrapperObj.listOfUsers = users;
        
        return wrapperObj;
    }
    
    public class wrapper{
        @AuraEnabled
        public List<Prescription_Order__c> listOfRecs;
        @AuraEnabled
        public Map<String,Map<String,List<String>>> picklistValues;
        @AuraEnabled
        public List<User> listOfUsers;
        
    }
    @AuraEnabled
    public static void saveData(String jsonList, String selectedUser,String selectedVia, String accId ,String starttimeProcedure , String endtimeProcedure) {
        system.debug(selectedUser+selectedVia+accId);
        System.debug('Starting SaveData');
        Id recordTypeIdForOrder = Schema.SObjectType.Prescription_Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        Id recordTypeIdForMedication = Schema.SObjectType.Prescription_Order__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
        Prescription_Order__c ordr = new Prescription_Order__c();
        ordr.Status__c= 'Open';
        ordr.Account__c = accId;
        ordr.RecordTypeId = recordTypeIdForOrder;
         /* if(Schema.sObjectType.Prescription_Order__c.fields.Status__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Account__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.RecordTypeId.isCreateable() 
             
              	){
        insert ordr;
                }*/
                //insert ordr;
                DMLManager.insertAsUser(ordr);
          
               
        root rootJson = (root)JSON.deserialize(jsonList,root.class);
        List <Prescription_Order__c> newRecs = new List<Prescription_Order__c>();
        System.debug('Start SaveData'+rootJson);
        List<JSON2Apex> listOfJson = (List<JSON2Apex>)rootJson.jsonListForTaper;
        if(listOfJson != null & listOfJson.size()>0){
        for(JSON2Apex rec : listOfJson){
            System.debug('Inside first for');
            Prescription_Order__c newRec = new Prescription_Order__c(
                Medication__c = rec.medicationName,
                Number_of_Times_Days_Weeks__c = String.valueOf(rec.dispenseExpectedSupplyDuration),
                Reason_new__c = rec.reasonLabel,
                Route_New_1__c = rec.Route,
                Dosage1__c = rec.dosageForm,
                Start_Date__c = Date.valueOf(rec.startDate),
                Warning__c = rec.Warning,
                Type__c = rec.types,
                After_Discharge__c = rec.afterDischarge,
                Account__c = accId,
                RecordTypeId = recordTypeIdForMedication,
                Prescription_Order__c = ordr.id
            );
            System.debug('Inside first for before addition to list');
            newRecs.add(newRec);
        }
        /* if(
                Schema.sObjectType.Prescription_Order__c.fields.Drug_Name__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Number_of_Times_Days_Weeks__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Reason_new__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Route_New_1__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Dosage_Form__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Start_Date__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Warning__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Type__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.After_Discharge__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Account__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.RecordTypeId.isCreateable() &&
            Schema.sObjectType.Prescription_Order__c.fields.Prescription_Order__c.isCreateable()){   
        Database.insert(newRecs,false);
                }*/
           // insert newRecs;
            DMLManager.insertAsUser(newRecs);
        System.debug('After insert');
        integer i = 0;
        List<Frequency__c> listOfDosage = new List<Frequency__c>();
            try{
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
       /* if (Schema.sObjectType.Frequency__c.isCreateable()) {
            insert listOfDosage;
         }*/
         DMLManager.insertAsUser(listOfDosage);
                }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
       
        
        }
        //For PRN
        List<JSONprn> listOfJsonPRN = (List<JSONprn>)rootJson.jsonListForPRN;
        if(listOfJsonPRN != null && listOfJsonPRN.size()>0){
        List <Prescription_Order__c> newRecsPrn = new List<Prescription_Order__c>();
        for(JSONprn rec : listOfJsonPRN){
            System.debug('Inside first for');
            Prescription_Order__c newRec = new Prescription_Order__c(
                Medication__c = rec.medicationName,               
                Reason_new__c = rec.reasonLabel,
                Route_New_1__c = rec.Route,
                Dosage1__c = rec.dosageForm,
                Start_Date__c = Date.valueOf(rec.startDate),
                Warning__c = rec.Warning,
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
              if(
                Schema.sObjectType.Prescription_Order__c.fields.Drug_Name__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Number_of_Times_Days_Weeks__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Reason_new__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Route_New_1__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Dosage_Form__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Start_Date__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Warning__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Type__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.After_Discharge__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Account__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.RecordTypeId.isCreateable() &&
            Schema.sObjectType.Prescription_Order__c.fields.Prescription_Order__c.isCreateable()){   
        Database.insert(newRecsPrn,false);
            }
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
              if(
                Schema.sObjectType.Frequency__c.fields.Prescription_Order__c.isCreateable() &&
                Schema.sObjectType.Frequency__c.fields.Frequency_Unit__c.isCreateable() &&
                Schema.sObjectType.Frequency__c.fields.Strength__c.isCreateable() &&
                Schema.sObjectType.Frequency__c.fields.Frequency_Value__c.isCreateable() &&
                Schema.sObjectType.Frequency__c.fields.Repeat__c.isCreateable() &&
                Schema.sObjectType.Frequency__c.fields.Dosage_Instruction__c.isCreateable() 
               ){   
            Database.insert(listOfDosagePRN,false);
            }
            System.debug(listOfDosagePRN);
        }
        //Action Order
        List<actionOrder> listOfActOrders = (List<actionOrder>) rootJson.jsonListForAOrder;
        if(listOfActOrders!=null && listOfActOrders.size()>0){
           	 List <Prescription_Order__c> newRecsActionOrders = new List<Prescription_Order__c>();
        for(actionOrder rec : listOfActOrders){
            System.debug('Inside first for');
            Prescription_Order__c newRec = new Prescription_Order__c(
                Medication__c = rec.medicationName,                
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
           if(
                Schema.sObjectType.Prescription_Order__c.fields.Drug_Name__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Number_of_Times_Days_Weeks__c.isCreateable() &&
                
                Schema.sObjectType.Prescription_Order__c.fields.PRN__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Dosage_Form__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Start_Date__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.End_Date__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Type__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.After_Discharge__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.Account__c.isCreateable() &&
                Schema.sObjectType.Prescription_Order__c.fields.RecordTypeId.isCreateable() &&
                 Schema.sObjectType.Prescription_Order__c.fields.Number_of_Times_Days_Weeks__c.isCreateable() &&
                 Schema.sObjectType.Prescription_Order__c.fields.MAR_Display__c.isCreateable() &&
            Schema.sObjectType.Prescription_Order__c.fields.Prescription_Order__c.isCreateable()){        
        Database.insert(newRecsActionOrders,false);
            }
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
           // Database.insert(listOfDosageActionOrders,false);
            DMLManager.insertAsUser(listOfDosageActionOrders);
            System.debug(listOfDosageActionOrders);
            
        }
      
    }
    //JSON Structure
    public class root{
        @AuraEnabled
        public List<JSON2Apex> jsonListForTaper{get;set;}
        @AuraEnabled
        public List<JSONprn> jsonListForPRN{get;set;}
        @AuraEnabled
        public List<actionOrder> jsonListForAOrder{get;set;}
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
        public List<Days> Days {get;set;}
        
    } 
    public class Days {
        @AuraEnabled
        public String Id {get;set;}
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
	// Updating already existng JSON records
    public static void utilityTaper(List<Days> listOfDays,Set<Id> newIds,Map <Id,Frequency__c> mapOfNewRecRecs ,List<Frequency__c> listOfDosage,Prescription_Order__c taperRec){
         	System.debug(listOfDosage);
                //Integer i=0;
                for(Id ids : newIds){ 
                    
                    Frequency__c editRecord;
                    for(Days d : listOfDays){
                        System.debug('d Id '+d.Id);
                        if(d.Id !=null && d.Id== ids){
                            if(mapOfNewRecRecs.containsKey(d.Id)){
                                editRecord = mapOfNewRecRecs.get(d.Id);
                                
                                System.debug('Inside loop');
                                
                                editRecord.Dosage_Instruction__c = String.valueOf(d.Dosage_Instruction);
                                editRecord.Repeat__c = d.Repeat;
                                
                                editRecord.Prescription_Order__c = taperRec.Id;
                                Integer dte = taperRec.Start_Date__c.day();
                                Integer mo = taperRec.Start_Date__c.month();
                                Integer yr = taperRec.Start_Date__c.year();
                                //editRecord.HealthCloudGA__Timing__c =  DateTime.newInstance(yr,mo,dte).addDays(i);
                                
                                for(Integer c=1;c<=24;c++){
                                    System.debug('Dosage insertion deepest if');
                                    String index = String.valueOf(c);
                                    String strength = 'Strength_'+index+'__c';
                                    String unit = 'Unit_'+index+'__c';
                                    String quantity = 'Quantity_'+index+'__c';
                                    String timings = 'Start_Time_'+index+'__c';
                                    if(d.Strength.size()>=c){
                                    editRecord.put(strength,d.Strength[c-1]);
                                    editRecord.put(unit,d.Units[c-1]);
                                    editRecord.put(quantity,Double.valueOf(d.Dosage[c-1]));
                                    System.debug('After putting dosage');
                                    String[] strTimeSplit = d.times[c-1].split(':');
                                    Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                                       ,Integer.valueOf(strTimeSplit[1]) //min
                                                                       ,0                                //sec
                                                                       ,0);                 
                                    System.debug('Dosage insertion deepest if 1');
                                    editRecord.put(timings,timeChange);
                                    
                                }
                                    else{
                                        editRecord.put(strength,null);
                                        editRecord.put(unit,null);
                                        editRecord.put(quantity,null);
                                        System.debug('After putting dosage');                                    
                                        editRecord.put(timings,null);
                                    }
                                }
                            }
                            break;
                        }
                       
                    }
                 
                    listOfDosage.add(editRecord);
                }
    }

    
}