public with sharing class MedicationListViewApexController {
  
    //Added by Ashwini
    @AuraEnabled
    public static string fetchAccountName(string accountId){
        List<Account> acc=[SELECT Id, name FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
        string accName = acc[0].name;
        return accName;
    }
    //End
 
    @AuraEnabled
    public static List<Prescription_Order__c> fetchMedications(String accountId) {
         List<Prescription_Order__c> parentOrder =[Select id, Prescription_Order__c 
         from Prescription_Order__c  WHERE Account__c= :accountId
         WITH SECURITY_ENFORCED];
         Set<string> ids = new Set<string>();
        for(Prescription_Order__c p : parentOrder ){ 
            if(p.Prescription_Order__c !=null){
                ids.add(p.Prescription_Order__c);
            }
        }
        List<Prescription_Order__c> medicationlst = [SELECT Id,Drug_Name__c,Reason__c,PRN__c,Medication__r.Name,Route_New_1__r.Name,
                                                                           Type__c,Start_Date__c,Number_of_Times_Days_Weeks__c,MAR_display__c,Prescription_Order__r.Name,
                                                                           After_Discharge__c,Route__c,Warning__c,Route_New__c,Dosage_Form__c,Account__c,CreatedDate,LastModifiedDate,
                                                    					   ElixirSuite__Reason_new__c,ElixirSuite__Warning_new__c,
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
                                                                            Repeat__c,Dosage_Instruction__c FROM  Frequency__r)  FROM Prescription_Order__c WHERE Prescription_Order__c IN: ids   
                                                                            WITH SECURITY_ENFORCED
                                                                           ORDER BY CreatedDate DESC];
        return medicationlst;
    }
    
    @AuraEnabled
    public static List<PrescWrapper> fetchPrescription(String accountId) {
        List<PrescWrapper> wrapper = new List<PrescWrapper>();
        List<String> columns = new List<String>();
        
        Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
        String prescColumns = mc.Prescription_Columns__c;
        if(String.isNotBlank(prescColumns)){
            columns = prescColumns.split(';');
        }
        
        list<Prescription_Order__c> orderList = [Select id, name, Status__c,Account__c,lastmodifieddate,createddate,Date_Of_Approval_1__c,Date_Of_Approval_2__c,Date_Of_Approval_3__c 
        FROM Prescription_Order__c
         WHERE Account__c= :accountId AND RecordType.Name = 'Order' 
         WITH SECURITY_ENFORCED
                                                 ORDER BY CreatedDate DESC];
        
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId();
        //Default count logic
        Integer defaultCount = [SELECT COUNT() FROM Master_Object__c 
                                WHERE Approval_Level_For__c = 'Prescription Order' 
                                AND recordTypeId =:recordTypeId
                                WITH SECURITY_ENFORCED];
        
        //build datatable wrapper
        for(Prescription_Order__c order : orderList){
            Integer approvedCount = 0;            
            if(order.Date_Of_Approval_1__c!=null){
                approvedCount = approvedCount + 1;
    }
            if(order.Date_Of_Approval_2__c!=null){
                approvedCount = approvedCount + 1;
            }
            if(order.Date_Of_Approval_3__c!=null){
                approvedCount = approvedCount + 1;
            }
            String formattedLastModified = '';
            if(order.lastmodifieddate != NULL){
                formattedLastModified = order.lastmodifieddate.format('yyyy-MM-dd, hh:mm a');
            }
            PrescWrapper wrp = new PrescWrapper(
                String.valueOf(order.get('Id')),
                String.valueOf(order.get('Name')),
                String.valueOf(order.get('ElixirSuite__Status__c')),
                formattedLastModified,
                String.valueOf(order.get('createddate'))
            );
            wrp.approvedLevelsCount = approvedCount;
            wrp.defaultLevelCount = defaultCount;
            wrp.columns = columns;
            wrapper.add(wrp);
        }
        return wrapper;
    }
    
    public class PrescWrapper{

        @AuraEnabled public Integer approvedLevelsCount;
        @AuraEnabled public Integer defaultLevelCount;
        @AuraEnabled public List<String> columns;

        @AuraEnabled public String presId{get;set;}
        @AuraEnabled public String presName{get;set;}
        @AuraEnabled public String presStatus{get;set;}
        @AuraEnabled public String lastModifiedDate{get;set;}
        @AuraEnabled public String createdDate{get;set;}

        
        public PrescWrapper(String presId, String presName, String presStatus, String lastModifiedDate, String createdDate){
            this.presId = presId;
            this.presName = presName;
            this.presStatus = presStatus;
            this.lastModifiedDate = lastModifiedDate;
            this.createdDate = createdDate;
        }
        
    }
    
      @AuraEnabled
    public static String fetchNameSpace() {
         String namespace = Elixir_Utility.getNamespace() ;
        return namespace;
    }
    @AuraEnabled
    public static List <String> deleteAllOrder(List < String > lstRecordId) {
        // for store Error Messages  
        List < String > oErrorMsg = new List < String > ();
        try{
        List < Prescription_Order__c > lstDeleteRec = [select Id from Prescription_Order__c 
        where id IN: lstRecordId
        WITH SECURITY_ENFORCED];
        if(lstDeleteRec != NULL && lstDeleteRec.size() > 0){
            DMLManager.deleteAsUser(lstDeleteRec);
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return oErrorMsg;
    }
    @AuraEnabled
    public static boolean checkCareEpisode(string patientId){      
        
         //added by Anmol for LX3-7236
         Boolean result = Elixir_Utility.checkCareEpisodeUtility(patientId);
         return result;
         //end by Anmol for LX3-7236
       
    }
}