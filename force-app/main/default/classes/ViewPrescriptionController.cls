/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-15-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class  ViewPrescriptionController {
    @AuraEnabled
    public static string getCode(string accId){
        List<Account> listOfAcc = [SELECT Id , Verification_Code__c , Name, parent.Name
         FROM Account WHERE Id= : accId WITH SECURITY_ENFORCED];
        string code = listofAcc[0].Verification_Code__c;
      
        return code;
    }
    @AuraEnabled
    Public static wrapper getOrder(String OrderId){
         Wrapper wrpr = new Wrapper();
        try{
        List<Prescription_Order__c> allData = new List<Prescription_Order__c>();
        List<Id> keys = new List<Id>();
        // po is parent prescription
        Prescription_Order__c  po= new Prescription_Order__c();
        po=[select id,Signature_Comments__c,Signature_Link__c,Signed_Date__c,Status__c,Account__r.Name from Prescription_Order__c where id =:orderId WITH SECURITY_ENFORCED];
        allData =[select id,Prescription_Order__c from Prescription_Order__c  where Prescription_Order__c =:OrderId
        WITH SECURITY_ENFORCED];
         for(Prescription_Order__c i : allData){
            if(i.id != null)
                keys.add(i.id);
        }
        
        List<Prescription_Order__c> listOfRecords =[SELECT Id,ElixirSuite__Drug_Name__c,ElixirSuite__Reason_new__c,ElixirSuite__MAR_Display__c,
                                                    ElixirSuite__PRN__c,Owner.Name, CreatedDate,LastModifiedDate,ElixirSuite__Reason__c,
                                                    ElixirSuite__Type__c,ElixirSuite__Medication__c, ElixirSuite__Medication__r.Name, 
                                                    ElixirSuite__Dosage1__c, ElixirSuite__Dosage1__r.Name, ElixirSuite__Route_New_1__c, 
                                                    ElixirSuite__Route_New_1__r.Name, ElixirSuite__Start_Date__c,ElixirSuite__Warning__c,
                                                    ElixirSuite__Number_of_Times_Days_Weeks__c,ElixirSuite__Notes__c,ElixirSuite__Justification__c,
                                                    ElixirSuite__After_Discharge__c,  ElixirSuite__Warning_new__c,ElixirSuite__Route_New__c,
                                                    ElixirSuite__Dosage_Form__c, ElixirSuite__Account__c,ElixirSuite__End_Date__c,
                                                    (SELECT Id,ElixirSuite__Frequency_Unit__c,ElixirSuite__Frequency_Value__c,
                                                     ElixirSuite__Strength__c,ElixirSuite__Strength_1__c,
                                                     ElixirSuite__Strength_2__c,ElixirSuite__Strength_3__c,ElixirSuite__Strength_4__c,ElixirSuite__Strength_5__c,
                                                     ElixirSuite__Strength_6__c,ElixirSuite__Strength_7__c,ElixirSuite__Strength_8__c,ElixirSuite__Strength_9__c,
                                                     ElixirSuite__Strength_10__c,ElixirSuite__Strength_11__c,ElixirSuite__Strength_12__c,ElixirSuite__Strength_13__c,ElixirSuite__Strength_14__c,ElixirSuite__Strength_15__c,
                                                     ElixirSuite__Strength_16__c,ElixirSuite__Strength_17__c,ElixirSuite__Strength_18__c,ElixirSuite__Strength_19__c,
                                                     ElixirSuite__Strength_20__c,ElixirSuite__Strength_21__c,ElixirSuite__Strength_22__c,ElixirSuite__Strength_23__c, ElixirSuite__Strength_24__c,       
                                                     ElixirSuite__Unit_1__c,ElixirSuite__Unit_2__c,ElixirSuite__Unit_3__c,ElixirSuite__Unit_4__c,ElixirSuite__Unit_5__c,
                                                     ElixirSuite__Unit_6__c,ElixirSuite__Unit_7__c,ElixirSuite__Unit_8__c,ElixirSuite__Unit_9__c,
                                                     ElixirSuite__Unit_10__c,ElixirSuite__Unit_11__c,ElixirSuite__Unit_12__c,ElixirSuite__Unit_13__c,ElixirSuite__Unit_14__c,ElixirSuite__Unit_15__c,
                                                     ElixirSuite__Unit_16__c,ElixirSuite__Unit_17__c,ElixirSuite__Unit_18__c,ElixirSuite__Unit_19__c,
                                                     ElixirSuite__Unit_20__c,ElixirSuite__Unit_21__c,ElixirSuite__Unit_22__c,ElixirSuite__Unit_23__c, ElixirSuite__Unit_24__c,                        
                                                     ElixirSuite__Start_Time_1__c,ElixirSuite__Start_Time_2__c,ElixirSuite__Start_Time_3__c,ElixirSuite__Start_Time_4__c,ElixirSuite__Start_Time_5__c,
                                                     ElixirSuite__Start_Time_6__c,ElixirSuite__Start_Time_7__c,ElixirSuite__Start_Time_8__c,ElixirSuite__Start_Time_9__c,
                                                     ElixirSuite__Start_Time_10__c,ElixirSuite__Start_Time_11__c,ElixirSuite__Start_Time_12__c,ElixirSuite__Start_Time_13__c,ElixirSuite__Start_Time_14__c,ElixirSuite__Start_Time_15__c,
                                                     ElixirSuite__Start_Time_16__c,ElixirSuite__Start_Time_17__c,ElixirSuite__Start_Time_18__c,ElixirSuite__Start_Time_19__c,
                                                     ElixirSuite__Start_Time_20__c,ElixirSuite__Start_Time_21__c,ElixirSuite__Start_Time_22__c,ElixirSuite__Start_Time_23__c,ElixirSuite__Start_Time_24__c,
                                                     ElixirSuite__Quantity_1__c,ElixirSuite__Quantity_2__c,ElixirSuite__Quantity_3__c,ElixirSuite__Quantity_4__c,ElixirSuite__Quantity_5__c,
                                                     ElixirSuite__Quantity_6__c,ElixirSuite__Quantity_7__c,ElixirSuite__Quantity_8__c,ElixirSuite__Quantity_9__c,
                                                     ElixirSuite__Quantity_10__c,ElixirSuite__Quantity_11__c,ElixirSuite__Quantity_12__c,ElixirSuite__Quantity_13__c,ElixirSuite__Quantity_14__c,ElixirSuite__Quantity_15__c,
                                                     ElixirSuite__Quantity_16__c,ElixirSuite__Quantity_17__c,ElixirSuite__Quantity_18__c,ElixirSuite__Quantity_19__c,
                                                     ElixirSuite__Quantity_20__c,ElixirSuite__Quantity_21__c,ElixirSuite__Quantity_22__c,ElixirSuite__Quantity_23__c,ElixirSuite__Quantity_24__c,
                                                     ElixirSuite__Repeat__c, ElixirSuite__Dosage_Instruction__c FROM  ElixirSuite__Frequency__r)
                                                     FROM ElixirSuite__Prescription_Order__c WHERE Id IN: keys 
                                                     WITH SECURITY_ENFORCED
                                                     LIMIT 5000];
       
        String namespace = '';
     
        wrpr.listOfRecords = listOfRecords;
        wrpr.listOforder = po;
        wrpr.namespace = namespace;
        
         }
        
          catch(Exception e){
           ExceptionLog.logError(e);
            }
                                   
         return wrpr;
                                              
        
    }

    public class Wrapper{
        @AuraEnabled public String namespace;
        @AuraEnabled public List<Prescription_Order__c> listOfRecords;
        @AuraEnabled public Prescription_Order__c listOforder;
    }
    @AuraEnabled
    public static Void kkk(Id medicationID){
        
        Prescription_Order__c[] delMedication = [select Id from Prescription_Order__c
         where Id =:medicationID 
         WITH SECURITY_ENFORCED];
       
        if(delMedication.size() > 0){
            if(Prescription_Order__c.sObjectType.getDescribe().isDeletable()){
            delete delMedication; 
            }
        }
        
    }
    
    
    @AuraEnabled
    public static void saveOrder(String accId, String orderId,String jsonList,
                                 String toInsertjsonList,Integer sizeOfOldDays,String attachId,String commentSign,String signedDate, String starttimeProcedure , String endtimeProcedure,
                                 List<String> orderToDel ) {
                                   
                                   
                                     if(orderToDel!=null && orderToDel.size()>0){
                                        if(Prescription_Order__c.sObjectType.getDescribe().isDeletable()){
                                         delete [SELECT ID FROM  Prescription_Order__c where Id in : orderToDel WITH SECURITY_ENFORCED];
                                        }
                                     }
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
                                     
                                     Procedure__c newProcedure = new Procedure__c();
                                     try{
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
                                     
                                     if(Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() &&
                                     Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() &&
                                     Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() &&
                                     Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
                                     Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
                                     Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable() &&
                                     Schema.sObjectType.Procedure__c.fields.Visits__c.isCreateable()){
                                     insert newProcedure;
                                     }
                                     }
                                     catch(Exception e){
                                     ExceptionLog.logError(e);
                                              }
                                     
                                     if(attachId !=null){
                                         Prescription_Order__c  po= new Prescription_Order__c();
                                         try{
                                         po=[select id,Signature_Comments__c,Signature_Link__c,Status__c,Signed_Date__c 
                                         from Prescription_Order__c 
                                         where id =:orderId
                                         WITH SECURITY_ENFORCED];
                                         
                                         po.Signature_Link__c=attachId;
                                         po.Signature_Comments__c=commentSign;
                                         po.Status__c='Approved';
                                         po.Signed_Date__c=signedDate;
                                         if(Schema.sObjectType.Prescription_Order__c.fields.Signature_Link__c.isUpdateable() &&
                                        Schema.sObjectType.Prescription_Order__c.fields.Signature_Comments__c.isUpdateable() &&
                                        Schema.sObjectType.Prescription_Order__c.fields.Status__c.isUpdateable() &&
                                        Schema.sObjectType.Prescription_Order__c.fields.Signed_Date__c.isUpdateable()){
                                         update po;
                                        }
                                         }
                                         catch(Exception e){
                                         ExceptionLog.logError(e);
                                            }
                                         String userId = UserInfo.getUserId();  
                                     }
                                     
                                     list<Prescription_Order__c> AllMedication =new list<Prescription_Order__c>();
                                     list<Prescription_Order__c> AllMedicationTaper =new list<Prescription_Order__c>();
                                     list<Prescription_Order__c> AllMedicationAction =new list<Prescription_Order__c>();
                                     AllMedication=[SELECT Id,Drug_Name__c,Reason_new__c,MAR_display__c,PRN__c,
                                                    Type__c,Start_Date__c,Number_of_Times_Days_Weeks__c,ElixirSuite__Reason__c,
                                                    After_Discharge__c,Route__c,Warning_new__c,Route_New__c,Dosage_Form__c,
                                                    ElixirSuite__Medication__c, ElixirSuite__Medication__r.Name,ElixirSuite__Warning__c, 
                                                    ElixirSuite__Dosage1__c, ElixirSuite__Dosage1__r.Name, ElixirSuite__Route_New_1__c, 
                                                    ElixirSuite__Route_New_1__r.Name,Account__c, 
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
                                                    from Prescription_Order__c where Prescription_Order__c=:orderId AND Type__c=:'PRN' 
                                                    WITH SECURITY_ENFORCED];
                                     AllMedicationTaper=[SELECT Id,Drug_Name__c,Reason_new__c,MAR_display__c,PRN__c,
                                                         Type__c,Start_Date__c,Number_of_Times_Days_Weeks__c,ElixirSuite__Reason__c,
                                                         After_Discharge__c,Route__c,Warning_new__c,Route_New__c,Dosage_Form__c,
                                                         ElixirSuite__Medication__c, ElixirSuite__Medication__r.Name,ElixirSuite__Warning__c, 
                                                    ElixirSuite__Dosage1__c, ElixirSuite__Dosage1__r.Name, ElixirSuite__Route_New_1__c, 
                                                    ElixirSuite__Route_New_1__r.Name,Account__c, 
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
                                                         from Prescription_Order__c where Prescription_Order__c=:orderId AND Type__c=:'Taper' 
                                                         WITH SECURITY_ENFORCED];
                                     
                                     AllMedicationAction=[SELECT Id,Drug_Name__c,Reason_new__c,MAR_display__c,PRN__c,
                                                          Type__c,Start_Date__c,Number_of_Times_Days_Weeks__c,ElixirSuite__Reason__c,ElixirSuite__Warning__c,
                                                          After_Discharge__c,Route__c,Warning_new__c,Route_New__c,Dosage_Form__c,ElixirSuite__Medication__c, ElixirSuite__Medication__r.Name, 
                                                    ElixirSuite__Dosage1__c, ElixirSuite__Dosage1__r.Name, ElixirSuite__Route_New_1__c, 
                                                    ElixirSuite__Route_New_1__r.Name,Account__c, 
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
                                                          from Prescription_Order__c where Prescription_Order__c=:orderId AND Type__c=:'Action Order' 
                                                          WITH SECURITY_ENFORCED];
                                     
                                        
                                     
                                     root rootJson = (root)JSON.deserialize(jsonList,root.class);
                                     
                                     rootclass rootJson1 = (rootclass)JSON.deserialize(toInsertjsonList,rootclass.class);
                                    
                                     List <Prescription_Order__c> newRecs = new List<Prescription_Order__c>();
                                   
                                     List<JSON2Apex> listOfJson = (List<JSON2Apex>)rootJson.jsonListForTaper;
                                     List<JSON2Apex> InsertTaper = (List<JSON2Apex>)rootJson1.toInsertjsonListForTaper;
                                     //  List<JSON2Apex> UpdateTaper = new List<JSON2Apex>();
                                     if(listOfJson != null & listOfJson.size()>0){ // TAPER
                                         updateAllMedicationsUtility( accId,  orderId, jsonList,
                                                                     toInsertjsonList, sizeOfOldDays, attachId, commentSign, signedDate,
                                                                     starttimeProcedure ,  endtimeProcedure, listOfJson,AllMedicationTaper,InsertTaper);
                                     }
                                     List<JSON2Apex> listOfJsonPRN = (List<JSON2Apex>)rootJson.jsonListForPRN;
                                     List<JSON2Apex> InsertPrn = (List<JSON2Apex>)rootJson1.toInsertjsonListForPRN; 
                                    
                                     if(listOfJsonPRN != null && listOfJsonPRN.size()>0){ // PRN
                                         updateAllMedicationsUtility( accId,  orderId, jsonList,
                                                                     toInsertjsonList, sizeOfOldDays, attachId, commentSign, signedDate,
                                                                     starttimeProcedure ,  endtimeProcedure, listOfJsonPRN,AllMedication,InsertPrn);
                                     }  
                                     
                                     List<JSON2Apex> listOfActOrders = (List<JSON2Apex>) rootJson.jsonListForAOrder;
                                     List<JSON2Apex> InsertAction = (List<JSON2Apex>)rootJson1.toInsertjsonListForAOrder;
                                     List<JSON2Apex> UpdateAction = new List<JSON2Apex>();
                                     if(listOfActOrders!=null && listOfActOrders.size()>0){ // ACTION ORDER
                                         updateAllMedicationsUtility( accId,  orderId, jsonList,
                                                                     toInsertjsonList, sizeOfOldDays, attachId, commentSign, signedDate,
                                                                     starttimeProcedure ,  endtimeProcedure, listOfActOrders,AllMedicationAction,InsertAction);
                                     }
                                     
                                     
                                     
                                 }
    
    
    public static void updateAllMedicationsUtility( String accId, String orderId,String jsonList,
                                                   String toInsertjsonList,Integer sizeOfOldDays,String attachId,String commentSign,String signedDate,
                                                   String starttimeProcedure , String endtimeProcedure, List<JSON2Apex> listOfJson,List<Prescription_Order__c> AllMedicationTaper,
                                                   List<JSON2Apex> InsertTaper){
                                                      List <Prescription_Order__c> newRecs = new List<Prescription_Order__c>();
                                                       List<JSON2Apex> UpdateTaper = new List<JSON2Apex>();
                                                       if(listOfJson != null & listOfJson.size()>0){
                                                           for(JSON2Apex rec : listOfJson){
                                                               for(Prescription_Order__c s : AllMedicationTaper){
                                                                   if(rec.medicationId == s.Medication__c){
                                                                       UpdateTaper.add(rec);                        
                                                                   }                    
                                                               }
                                                           }
                                                           set<id> TaperdosageId = new set<Id>();
                                                           for(Prescription_Order__c mpt : AllMedicationTaper){
                                                               if(mpt.id !=null)
                                                                   TaperdosageId.add(mpt.id);
                                                           }
                                                           
                                                           for(JSON2Apex rec : UpdateTaper){    
                                                               for(Prescription_Order__c s : AllMedicationTaper){
                                                                   if(s.Medication__c == rec.medicationId){
                                                                       s.Medication__c = rec.medicationId;
                                                                       s.Number_of_Times_Days_Weeks__c = String.valueOf(rec.dispenseExpectedSupplyDuration);
                                                                       s.Reason_new__c = rec.reasonLabel;
                                                                       s.Route_New_1__c = rec.RouteId;
                                                                       s.Dosage1__c = rec.dosageFormId;
                                                                       s.Start_Date__c = Date.valueOf(rec.startDate);
                                                                       s.Warning__c = rec.Warning;
                                                                       s.Justification__c = rec.Justification;
                                                                       if(String.isNotBlank(String.valueOf(rec.MARdisplay))){
                                                                           s.MAR_Display__c = Boolean.valueOf(rec.MARdisplay);
                                                                       }
                                                                       
                                                                       s.Type__c = rec.types;
                                                                       s.After_Discharge__c = rec.afterDischarge;
                                                                       s.End_Date__c = Date.valueOf(rec.startDate).addDays(rec.dispenseExpectedSupplyDuration);
                                                                       s.Account__c = accId;
                                                                       if(String.isNotBlank(String.valueOf(rec.PRNdisplay))){
                                                                           s.PRN__c = Boolean.valueOf(rec.PRNdisplay);
                                                                       }
                                                                       
                                                                       s.Prescription_Order__c = orderId;
                                                                       
                                                                       
                                                                       
                                                                       
                                                                   }
                                                               }
                                                           }
                                                           
                                                           List<Frequency__c> TaperDosage = [SELECT Id,Frequency_Unit__c,Frequency_Value__c,
                                                                                             Strength__c,Strength_1__c,Prescription_Order__c,
                                                                                             Strength_2__c,Strength_3__c,Strength_4__c,Strength_5__c,
                                                                                             Strength_6__c,Strength_7__c,Strength_8__c,Strength_9__c,
                                                                                             Strength_10__c,Strength_11__c,Strength_12__c,Strength_13__c,Strength_14__c,Strength_15__c,
                                                                                             Strength_16__c,Strength_17__c,Strength_18__c,Strength_19__c,
                                                                                             Strength_20__c,Strength_21__c,Strength_22__c,Strength_23__c, Strength_24__c,       
                                                                                             Unit_1__c,Unit_2__c,Unit_3__c,Unit_4__c,Unit_5__c,
                                                                                             Unit_6__c,Unit_7__c,Unit_8__c,Unit_9__c,
                                                                                             Unit_10__c,Unit_11__c,Unit_12__c,Unit_13__c,Unit_14__c,Unit_15__c,
                                                                                             Unit_16__c,Unit_17__c,Unit_18__c,Unit_19__c,
                                                                                             Unit_20__c,Unit_21__c,Unit_22__c,Unit_23__c,Unit_24__c,                        
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
                                                                                             Repeat__c,Dosage_Instruction__c FROM  Frequency__c WHERE Prescription_Order__c In :TaperdosageId 
                                                                                             WITH SECURITY_ENFORCED];
                                                           
                                                           Map <Id,Frequency__c> mapOfNewRecRecs = new Map <Id,Frequency__c>(TaperDosage);
                                                           List<Frequency__c> toAddDosagesToExistingPrescriptions ; 
                                                           List<Frequency__c> listOfDosage1 ; 
                                                           List<Frequency__c> finalDosageToUpsert = new  List<Frequency__c>(); 
                                                           List<Frequency__c> finalDosageToInsert = new  List<Frequency__c>(); 
                                                           Set<Id> newIds = mapOfNewRecRecs.keySet();
                                                          
                                                           for(JSON2Apex rec : UpdateTaper){    
                                                               
                                                               for(Prescription_Order__c s : AllMedicationTaper){
                                                                   
                                                                   if(s.Medication__c == rec.medicationId){
                                                                       List<Days> listOfDays =  (List<Days>)rec.Days;
                                                                       toAddDosagesToExistingPrescriptions = new List<Frequency__c>();
                                                                       listOfDosage1 = new List<Frequency__c>();
                                                                       //For updating the existing records
                                                                      
                                                                       //For updating the existing records
                                                                       if(sizeOfOldDays <= rec.Days.size()){    
                                                                           
                                                                           //  utilityTaper(listOfDays , newIds, mapOfNewRecRecs ,listOfDosage1,s);
                                                                           // For new Records to be inserted in Dosage
                                                                           Integer newDaysSize = rec.Days.size();
                                                                           Integer oldDaysSize = sizeOfOldDays;
                                                                           
                                                                           Integer i = 0;
                                                                           Set<Id> dosageRecordIds = new Set<Id>();
                                                                           
                                                                           for(Days d : listOfDays){
                                                                               
                                                                              
                                                                               if(d.Id != null){
                                                                                   
                                                                                   dosageRecordIds.add(d.Id);  
                                                                                   
                                                                                   Frequency__c newRec = new Frequency__c(); 
                                                                                   newRec.Id = d.Id;
                                                                                   newRec.Dosage_Instruction__c = String.valueOf(d.Dosage_Instruction);
                                                                                   newRec.Repeat__c = d.Repeat;
                                                                                   newRec.Prescription_Order__c = s.Id;
                                                                                   Integer dte = s.Start_Date__c.day();
                                                                                   Integer mo = s.Start_Date__c.month();
                                                                                   Integer yr = s.Start_Date__c.year();
                                                                                   newRec.Frequency_Timing__c =  DateTime.newInstance(yr,mo,dte).addDays(AllMedicationTaper.size()+i+1);
                                                                                   for(Integer c=1;c<=d.Strength.size();c++){
                                                                                     
                                                                                       String index = String.valueOf(c);
                                                                                       String strength = 'Strength_'+index+'__c';
                                                                                       
                                                                                       String quantity = 'Quantity_'+index+'__c';
                                                                                       String timings = 'Start_Time_'+index+'__c';
                                                                                       
                                                                                       newRec.put(strength,d.Strength[c-1]);
                                                                                       
                                                                                       newRec.put(quantity,Double.valueOf(d.Dosage[c-1]));
                                                                                       
                                                                                       String[] strTimeSplit = d.times[c-1].split(':');
                                                                                       Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                                                                                          ,Integer.valueOf(strTimeSplit[1]) //min
                                                                                                                          ,0                                //sec
                                                                                                                          ,0);                 
                                                                                       
                                                                                       newRec.put(timings,timeChange);
                                                                                       
                                                                                   }
                                                                                   for(Integer m = 1 ; m<=d.Units.size();m++){
                                                                                       String indexForUnit = String.valueOf(m);
                                                                                       String unit = 'Unit_'+indexForUnit+'__c';
                                                                                       
                                                                                       newRec.put(unit,d.Units[m-1]);
                                                                                   }
                                                                                   Integer maxStrength = d.Strength.size();
                                                                                   Integer toEmptyIndex =  24 - maxStrength;
                                                                                 
                                                                                   for(Integer k=24; k >d.Strength.size(); k--){
                                                                                       String index = String.valueOf(k);
                                                                                       String strength = 'Strength_'+index+'__c';
                                                                                       
                                                                                       String quantity = 'Quantity_'+index+'__c';
                                                                                       String timings = 'Start_Time_'+index+'__c';
                                                                                       
                                                                                       newRec.put(strength,null);
                                                                                       newRec.put(quantity,null);
                                                                                       
                                                                                       newRec.put(timings,null);                                                                 
                                                                                   }
                                                                                   listOfDosage1.add(newRec);
                                                                                   
                                                                               }
                                                                               else {        
                                                                                  Frequency__c newRec = new Frequency__c();                                                                                    
                                                                                   newRec.Dosage_Instruction__c = String.valueOf(d.Dosage_Instruction);
                                                                                   newRec.Repeat__c = d.Repeat;
                                                                                   newRec.Prescription_Order__c = s.Id;
                                                                                   Integer dte = s.Start_Date__c.day();
                                                                                   Integer mo = s.Start_Date__c.month();
                                                                                   Integer yr = s.Start_Date__c.year();
                                                                                   newRec.Frequency_Timing__c =  DateTime.newInstance(yr,mo,dte).addDays(AllMedicationTaper.size()+i+1);
                                                                                   for(Integer c=1;c<=d.Strength.size();c++){
                                                                                      
                                                                                       String index = String.valueOf(c);
                                                                                       String strength = 'Strength_'+index+'__c';
                                                                                       
                                                                                       String quantity = 'Quantity_'+index+'__c';
                                                                                       String timings = 'Start_Time_'+index+'__c';
                                                                                       
                                                                                       newRec.put(strength,d.Strength[c-1]);
                                                                                       
                                                                                       newRec.put(quantity,Double.valueOf(d.Dosage[c-1]));
                                                                                       
                                                                                       String[] strTimeSplit = d.times[c-1].split(':');
                                                                                       Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                                                                                          ,Integer.valueOf(strTimeSplit[1]) //min
                                                                                                                          ,0                                //sec
                                                                                                                          ,0);                 
                                                                                      
                                                                                       newRec.put(timings,timeChange);
                                                                                       
                                                                                   }
                                                                                   for(Integer m = 1 ; m<=d.Units.size();m++){
                                                                                       String indexForUnit = String.valueOf(m);
                                                                                       String unit = 'Unit_'+indexForUnit+'__c';
                                                                                     
                                                                                       newRec.put(unit,d.Units[m-1]);
                                                                                   }
                                                                                   
                                                                                   toAddDosagesToExistingPrescriptions.add(newRec);
                                                                               }
                                                                           }
                                                                          
                                                                           List<Frequency__c> d=  [SELECT id from Frequency__c 
                                                                           where id not in : dosageRecordIds AND Prescription_Order__c = : rec.Id
                                                                           WITH SECURITY_ENFORCED];
                                                                           
                                                                           if(Frequency__c.sObjectType.getDescribe().isDeletable()){
                                                                            delete [SELECT id from Frequency__c where id not in : dosageRecordIds AND Prescription_Order__c = : rec.Id
                                                                            WITH SECURITY_ENFORCED];
                                                                           }  
                                                                       }
                                                                   }
                                                               }
                                                               finalDosageToUpsert.addAll(listOfDosage1);
                                                               finalDosageToInsert.addAll(toAddDosagesToExistingPrescriptions);
                                                           }
                                                           
                                                           if(AllMedicationTaper.size()>0){
                                                               if(Prescription_Order__c.sObjectType.getDescribe().isCreateable()
                                                               && Prescription_Order__c.sObjectType.getDescribe().isUpdateable()){
                                                                upsert AllMedicationTaper;
                                                               }
                                                           }
                                                           if(finalDosageToUpsert.size()>0){
                                                            if(Schema.sObjectType.Frequency__c.fields.Dosage_Instruction__c.isUpdateable()
                                                            && Schema.sObjectType.Frequency__c.fields.Repeat__c.isUpdateable()
                                                            && Schema.sObjectType.Frequency__c.fields.Prescription_Order__c.isUpdateable()
                                                            && Schema.sObjectType.Frequency__c.fields.Frequency_Timing__c.isUpdateable() &&
                                                            Schema.sObjectType.Frequency__c.fields.Dosage_Instruction__c.isCreateable()
                                                            && Schema.sObjectType.Frequency__c.fields.Repeat__c.isCreateable()
                                                            && Schema.sObjectType.Frequency__c.fields.Prescription_Order__c.isCreateable()
                                                            && Schema.sObjectType.Frequency__c.fields.Frequency_Timing__c.isCreateable()){
                                                               upsert finalDosageToUpsert;
                                                            }
                                                           }
                                                           if(finalDosageToInsert.size()>0 && finalDosageToInsert!=null){
                                                               if(Schema.sObjectType.Frequency__c.fields.Dosage_Instruction__c.isUpdateable()
                                                               && Schema.sObjectType.Frequency__c.fields.Repeat__c.isUpdateable()
                                                               && Schema.sObjectType.Frequency__c.fields.Prescription_Order__c.isUpdateable()
                                                               && Schema.sObjectType.Frequency__c.fields.Frequency_Timing__c.isUpdateable()){
                                                                insert finalDosageToInsert;
                                                               }
                                                           }
                                                           if(InsertTaper !=null){    
                                                               for(JSON2Apex rec : InsertTaper){
                                                                   
                                                                   Prescription_Order__c newRec = new Prescription_Order__c(
                                                                       Medication__c = rec.medicationId,
                                                                       Number_of_Times_Days_Weeks__c = String.valueOf(rec.dispenseExpectedSupplyDuration),
                                                                       Reason_new__c = rec.reasonLabel,
                                                                       Route_New_1__c = rec.RouteId,
                                                                       Dosage1__c = rec.dosageFormId,
                                                                       Start_Date__c = Date.valueOf(rec.startDate),
                                                                       Warning__c = rec.Warning,
                                                                       Type__c = rec.types,
                                                                       After_Discharge__c = rec.afterDischarge,
                                                                       Account__c = accId,
                                                                       Prescription_Order__c = orderId
                                                                   );
                                                                  
                                                                   newRecs.add(newRec);
                                                               }
                                                           }
                                                           if(Schema.sObjectType.Prescription_Order__c.fields.Medication__c.isCreateable()
                                                           && Schema.sObjectType.Prescription_Order__c.fields.Number_of_Times_Days_Weeks__c.isCreateable()
                                                           && Schema.sObjectType.Prescription_Order__c.fields.Reason__c.isCreateable()
                                                           && Schema.sObjectType.Prescription_Order__c.fields.Route_New_1__c.isCreateable()
                                                           && Schema.sObjectType.Prescription_Order__c.fields.Dosage1__c.isCreateable()
                                                           && Schema.sObjectType.Prescription_Order__c.fields.Reason_new__c.isCreateable()
                                                           && Schema.sObjectType.Prescription_Order__c.fields.Start_Date__c.isCreateable()
                                                           && Schema.sObjectType.Prescription_Order__c.fields.Warning__c.isCreateable()
                                                           && Schema.sObjectType.Prescription_Order__c.fields.Type__c.isCreateable()
                                                           && Schema.sObjectType.Prescription_Order__c.fields.After_Discharge__c.isCreateable()
                                                           && Schema.sObjectType.Prescription_Order__c.fields.Account__c.isCreateable()
                                                           && Schema.sObjectType.Prescription_Order__c.fields.Prescription_Order__c.isCreateable()){
                                                           insert newRecs;
                                                           }
                                                             Database.insert(newRecs,false);
                                                          //insert newRecs;
                                                           integer i = 0;
                                                           List<Frequency__c> listOfDosage = new List<Frequency__c>();
                                                           try{
                                                           if(InsertTaper !=null){     
                                                               for(JSON2Apex rec    : InsertTaper){
                                                                   Integer count = 0;
                                                                  
                                                                   for(Days d   :   rec.Days){
                                                                     
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
                                                               //Comminted
                                                           }
                                                          
                                                           if(Schema.sObjectType.Frequency__c.fields.Dosage_Instruction__c.isCreateable()
                                                           && Schema.sObjectType.Frequency__c.fields.Repeat__c.isCreateable()
                                                           && Schema.sObjectType.Frequency__c.fields.Prescription_Order__c.isCreateable()
                                                           && Schema.sObjectType.Frequency__c.fields.Frequency_Timing__c.isCreateable()){
                                                           insert listOfDosage;
                                                           }
                                                           //insert listOfDosage;
                                                           }
                                                           catch(Exception e){
                                                               ExceptionLog.logError(e);
                                                               }
                                                       }
                                                   }    

    public class root{
        @AuraEnabled
        public List<JSON2Apex> jsonListForTaper{get;set;}
        @AuraEnabled
        public List<JSON2Apex> jsonListForPRN{get;set;}
        @AuraEnabled
        public List<JSON2Apex> jsonListForAOrder{get;set;}
    }

    public class rootclass{
        @AuraEnabled
        public List<JSON2Apex> toInsertjsonListForTaper{get;set;}
        @AuraEnabled
        public List<JSON2Apex> toInsertjsonListForPRN{get;set;}
        @AuraEnabled
        public List<JSON2Apex> toInsertjsonListForAOrder{get;set;}
    }
    public class JSONprn{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String medicationName {get;set;}
        @AuraEnabled
        public String medicationId {get;set;}
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
        public String dosageFormId {get;set;}
        @AuraEnabled
        public String reasonLabel {get;set;}
        @AuraEnabled
        public String Route {get;set;}
        @AuraEnabled
        public String RouteId {get;set;}
        @AuraEnabled
        public String Warning {get;set;}
        
        @AuraEnabled
        public List<singleRecPRN> singleRecForPrn {get;set;}
    }
    public class singleRecPRN{
        public String Id  {get;set;}
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
        public String medicationId {get;set;}
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
        public String dosageFormId {get;set;}
        @AuraEnabled
        public String reasonLabel {get;set;}
        @AuraEnabled
        public String Route {get;set;}
        @AuraEnabled
        public String RouteId {get;set;}
        @AuraEnabled
        public String Warning {get;set;}
        @AuraEnabled
        public String Justification {get;set;}
        @AuraEnabled
        public Boolean MARdisplay {get;set;}
        @AuraEnabled
        public Boolean PRNdisplay {get;set;}
        
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
        public String medicationId;
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
        public String Id;
        public List<String> StartTime;
        public String Repeat;
        public String Dosage_Instruction;
        public String textMessage;
    }
    
  
}