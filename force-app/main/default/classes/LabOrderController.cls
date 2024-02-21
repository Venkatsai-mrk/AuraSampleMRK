/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class LabOrderController {
    @AuraEnabled
    public static List<Map<String, String>> getLabNames() {
        List<Map<String, String>> labNames = new List<Map<String, String>>();
        
        List<ElixirSuite__Lab__c> labList = [select id,name,ElixirSuite__Lab_Id__c from ElixirSuite__Lab__c WITH SECURITY_ENFORCED];
        for (ElixirSuite__Lab__c lab : labList) {
            labNames.add(new Map<String, String>{'value' => lab.ElixirSuite__Lab_Id__c, 'label' => lab.Name});
      
        }
        
        return labNames;
    }
    @AuraEnabled
    public static List<Map<String, String>> getAvailableTestName() {
        List<Map<String, String>> availableTestName = new List<Map<String, String>>();
        
        List<ElixirSuite__Procedure__c> labTestNameList = [select id,Name from ElixirSuite__Procedure__c where recordtype.name='Template Lab Test' WITH SECURITY_ENFORCED];
        for (ElixirSuite__Procedure__c lab : labTestNameList) {
            availableTestName.add(new Map<String, String>{'value' => lab.id, 'label' => lab.Name});
      
            }
        
        return availableTestName;
    }
    
    @AuraEnabled
    public static string fetchAccountName(string accountId){
        List<Account> acc=[SELECT Id, name FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
        string accName = acc[0].name;
        return accName;
    }
    @AuraEnabled
    public static Map<String,List<String>> getAllPicklistValues() {
        Map<String,List<String>> allPickListValues = new  Map<String,List<String>>();
        try{
        List<string> options = new List<string>();
        Schema.DescribeFieldResult allTests = UA_Sample_Details__c.Available_Test__c.getDescribe();
        List<Schema.PicklistEntry> testVal = allTests.getPicklistValues();
        for( Schema.PicklistEntry sch : testVal)
        { 
            options.add( sch.getValue());
            
        }    
        allPickListValues.put('AvailableTest', options);
        
        List<string> freqVal = new List<string>();
        Schema.DescribeFieldResult allFrequencies = UA_Sample_Details__c.Frequency__c.getDescribe();
        List<Schema.PicklistEntry> fVal = allFrequencies.getPicklistValues();
        for( Schema.PicklistEntry f : fVal)
        { 
            freqVal.add( f.getValue());
            
        }    
        allPickListValues.put('FrequencyValues', freqVal);
        
        
        
        List<string> orderVal = new List<string>();
        Schema.DescribeFieldResult allValues = UA_Sample_Details__c.Ordered_Via__c.getDescribe();        
        List<Schema.PicklistEntry> orderViaVal = allValues.getPicklistValues();
        for( Schema.PicklistEntry v : orderViaVal)
        { 
            orderVal.add( v.getValue());
            
        }    
        allPickListValues.put('OrderViaValues', orderVal);
        
        
        
        //  return options;
        
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return allPickListValues;
        
        
        
    }
    
    @AuraEnabled
    public static List<user> getAllUser() {
        List<User> lstUsers = [SELECT Id,Name FROM User 
                                WHERE IsActive=TRUE
                                WITH SECURITY_ENFORCED];        
        return lstUsers;
    }
    
    @AuraEnabled
    public static void deleteLabOrderRecord(String recordToDelete) {
        //System.debug('del details '+recordToDelete);
        if(!String.isEmpty(recordToDelete)) {
        delete [SELECT Id,Name FROM UA_Sample_Details__c where id=:recordToDelete WITH SECURITY_ENFORCED];
        } 
    }
    
    @AuraEnabled
    public static List < String > deleteRecords(List < String > lstRecordId) {
        // for store Error Messages  
        List < String > oErrorMsg = new List < String > ();
        try{
        // Query Records for delete where id in lstRecordId [which is pass from client side controller] 
        List < UA_Sample_Details__c > lstDeleteRec = [select Id from UA_Sample_Details__c 
        where id IN: lstRecordId
        WITH SECURITY_ENFORCED];
      
        Database.DeleteResult[] drDels = Database.delete(lstDeleteRec, false);
        // Iterate through each returned result
        for (Database.DeleteResult dr: drDels) {
            if (!dr.isSuccess()) {
                oErrorMsg.add('');
                for (Database.Error err: dr.getErrors()) {
                    // add Error message to oErrorMsg list and return the list
                    oErrorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
               // system.debug('successful delete contact');
            } 
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return oErrorMsg;  
    }
    
     @AuraEnabled
    public static List < String > updateRecords(List < String > lstRecordId) {
        // for store Error Messages  
        List < String > oErrorMsg = new List < String > ();
        try{
        // Query Records for delete where id in lstRecordId [which is pass from client side controller] 
        List < UA_Sample_Details__c > lstDeleteRec = [select id,Status__c from UA_Sample_Details__c 
        where id IN: lstRecordId
        WITH SECURITY_ENFORCED];
        for(UA_Sample_Details__c i : lstDeleteRec){
            i.Status__c='Sent To Lab';
        }
        if(lstDeleteRec.size() > 0 &&
        Schema.sObjectType.UA_Sample_Details__c.fields.Status__c.isUpdateable()){
            update lstDeleteRec;
        }
 
        //system.debug('dd'+oErrorMsg);
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return oErrorMsg;  
    }

    public class GetLabOrderWrapper {
        @AuraEnabled public List<UA_Sample_Details__c> labOrders;
        @AuraEnabled public Integer totalApprovalLevels;
        @AuraEnabled public List<String> columns;
    }

    @AuraEnabled
    public static GetLabOrderWrapper getRelatedLabOrder(String patient) {
        List<UA_Sample_Details__c> lstOfRelatedLabOrders = [SELECT Id,Name,Medical_Test__c,Start_Date__c,Fax__c,On_Admission__c, LastModifiedDate,Status__c, ElixirSuite__Date_Of_Approval_1__c,
        ElixirSuite__Date_Of_Approval_2__c, ElixirSuite__Date_Of_Approval_3__c FROM UA_Sample_Details__c where Account__c=:patient AND RecordType.Name = 'Lab Order'
                                                                             WITH SECURITY_ENFORCED
                                                                             order by LastModifiedDate desc];
        
        GetLabOrderWrapper labOrderWrapper = new GetLabOrderWrapper();
        labOrderWrapper.labOrders = lstOfRelatedLabOrders;
        labOrderWrapper.totalApprovalLevels = getNumberOfLabOrderApprovalLevelsDefined();
        labOrderWrapper.columns = getLabOrderColumns();
        return labOrderWrapper;
    }

    @AuraEnabled
    public static List<String> getLabOrderColumns(){
        try {
            List<String> columns = new List<String>();

            String columnText = Elixir_Custom_Setting__c.getOrgDefaults().ElixirSuite__LabOrder_Columns__c;
            if (columnText != null) {
                columns = columnText.split(';');
            }

            return columns;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Integer getNumberOfLabOrderApprovalLevelsDefined(){
        try {
            // query master object for custom label
            String approvalRecordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Approval_Configuration').getRecordTypeId();
            List<ElixirSuite__Master_Object__c> labOrderApprovalConfiguration = [
                SELECT Id
                  FROM ElixirSuite__Master_Object__c
                 WHERE ElixirSuite__Approval_Level__c != null
                   AND ElixirSuite__Approval_Level_For__c = 'Lab Order'
                   AND RecordTypeId = :approvalRecordTypeId
                   WITH SECURITY_ENFORCED
            ORDER BY ElixirSuite__Approval_Level__c];

            if (labOrderApprovalConfiguration == null) {
                return 0;
            }

            return labOrderApprovalConfiguration.size();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static wrapGetLabOrder getLabOrder(String record) {
        
        UA_Sample_Details__c uaSampleDetailsList= [SELECT Id,Name,Medical_Test__c,Start_Date__c,Fax__c,On_Admission__c,
        Signature_Link__c,Signature_Comments__c,Ordered_Via__c,Ordered_By__r.Name,
        Order_By__r.Id,ElixirSuite__Order_By__c,Necessity_Details__c,Status__c
                ,Frequency__c , Account__r.Name , Signed_Date__c
                FROM UA_Sample_Details__c where Id=:record WITH SECURITY_ENFORCED];
        WrapGetLabOrder wrpr = new WrapGetLabOrder();
        wrpr.uaSampleDetails=uaSampleDetailsList;
        wrpr.nameSpace=Elixir_Utility.getNamespace();
       return wrpr;
    }
    
    public class WrapGetLabOrder{
        @AuraEnabled  public UA_Sample_Details__c uaSampleDetails;
       @AuraEnabled  public String nameSpace; 
    }
  @AuraEnabled
    
    //Methos to save the lab order.
    public static UA_Sample_Details__c saveRecord(List<UA_Sample_Details__c> procReq,String necessityDetails,
                                                                   String acct,String medVal ,String starttimeProcedure , String endtimeProcedure) {
       List<UA_Sample_Details__c> toInsertRecords   = new List<UA_Sample_Details__c>(); 
        try{                                                               
                                                                       
       //Id recordTypeIdAsFetched = [SELECT RecordTypeID from UA_Sample_Details__c where RecordType.Name = 'Lab Order'].Id;
       //
      
    //added by Anmol for LX3-7236
    Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
    String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
    if(string.isBlank(careFilter)){
        careFilter = 'createddate desc';
    }
    String careStatus = 'Active';

    string querystr = '';
    querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: acct WITH SECURITY_ENFORCED order by ';
    querystr += careFilter ;
    List<ElixirSuite__Visits__c> lstVisits = database.query(querystr);
    //end by Anmol for LX3-7236                                                               
                                                                       
       Id recordTypeIdAsFetched = Schema.SObjectType.UA_Sample_Details__c.getRecordTypeInfosByName().get('Lab Order').getRecordTypeId();
                                                                       if(procReq!=null && procReq.size()>0){
                                                                             procReq[0].RecordTypeId = recordTypeIdAsFetched;      
       procReq[0].Medical_Test__c=medVal; 
       procReq[0].Status__c='Open'; // Whenever a Laborder is created it's status will be Open.
       procReq[0].Account__c=acct;
                                                                         				
                                                                       
       if(!lstVisits.isEmpty()){
       procReq[0].ElixirSuite__Care_Episode__c= lstVisits[0].Id;  
       }
       procReq[0].Necessity_Details__c=NecessityDetails;
                                                                       }                                                                
     
      toInsertRecords.addAll(procReq);// Lab order inserted
                                                                       Id devRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();
                                                                       if(Elixir_Utility.fetchCreateProcedureReturnValue()==true){
                                                                       Procedure__c newProcedure = new Procedure__c();
                                                                       newProcedure.Account__c=acct; 
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
                                                                       
                                                                       newProcedure.Name = medVal+' LabOrder procedure';
                                                                       if(!lstVisits.isEmpty())
                                                                       {
                                                                           newProcedure.ElixirSuite__Visits__c =lstVisits[0].Id;
                                                                       }            
                                                                       if( Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.Name.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.Visits__c.isCreateable()){
                                                                        insert newProcedure;
                                                                                    }   
                                                                       }                                                                    
       //NULL;EMPTY CHECKS                                                                 
        if(toInsertRecords.size()>0 && toInsertRecords!=null) {
            //if(Schema.sObjectType.UA_Sample_Details__c.isCreateable()){
            //insert toInsertRecords;  
            DMLManager.insertAsUser(toInsertRecords);
           // }
             //Creation of default procedure which will be related to latest encounter present for that account.                                  
        /* HealthCloudGA__EHRProcedure__c defaultProcedure = new HealthCloudGA__EHRProcedure__c();
         defaultProcedure.Account__c=acct; 
         defaultProcedure.Ehr_LabOrder__c=  toInsertRecords[0].Id;   
         system.debug(acct);
         Elixir_utility.attachProcedureEncounter(defaultProcedure, String.valueOf(acct), toInsertRecords[0].Id,starttimeProcedure,endtimeProcedure );*/
        } 

            
        //Below Code is written by Shubham Vishwakarma

        

            ElixirSuite__ERA_Generation__c mc = ElixirSuite__ERA_Generation__c.getOrgDefaults();

           

            String typOfPayment;

           

            if(mc.ElixirSuite__Private_Payments__c == true && mc.ElixirSuite__Insurance_Payments__c ==true){

            typOfPayment = 'Insurance Payment';

            }

            if(mc.ElixirSuite__Private_Payments__c == false && mc.ElixirSuite__Insurance_Payments__c ==true){

                typOfPayment = 'Insurance Payment';

            }

            if(mc.ElixirSuite__Private_Payments__c == true && mc.ElixirSuite__Insurance_Payments__c ==false){

                typOfPayment = 'Private Payment';

            }

            Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();

            ElixirSuite__Procedure__c objProcedure = new ElixirSuite__Procedure__c();

                objProcedure.Name = medVal; //code from template lab record --> name field

                objProcedure.ElixirSuite__Account__c = acct;

                objProcedure.RecordTypeId = recordTypeId; // patient procedure recordtype

                objProcedure.ElixirSuite__Type_of_Procedure__c = typOfPayment;

                objProcedure.ElixirSuite__From_Date_of_Service__c =  system.today();      // start date/time of lab  

                objProcedure.ElixirSuite__To_Date_of_Service__c =  system.today();        // end date/time of lab

                objProcedure.ElixirSuite__Is_Billable__c = true;

                objProcedure.ElixirSuite__Days_Units__c =1;

                
                DMLManager.insertAsUser(objProcedure);


            
            
            
            
            
            
            
            
            
            
            
            
            
        }
           catch(Exception e){
            ExceptionLog.logError(e);
        }
       return toInsertRecords[0];    
    }
 
    @AuraEnabled
    public static  Map<String,list<sObject>> fetchCusomMetadataRecord()
    {
        Map<String,list<sObject>> mastermdt = new Map<String,list<sObject>>();
        try{
        List<Medical_Necessity__mdt> mdt  = [select id,Picklist_Label__c,Picklist_Value__c from Medical_Necessity__mdt WITH SECURITY_ENFORCED]; 
        List<Available_Test_LAB_ORDERS__mdt> testsmdt = [select Available_Tests__c from Available_Test_LAB_ORDERS__mdt WITH SECURITY_ENFORCED];
        mastermdt.put('MedicalNecessity',mdt);
        mastermdt.put('AvailableTest',testsmdt);
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
  		return mastermdt;
    }
    
    /*  @AuraEnabled
    public static  String fetchNameSpace(){
      return  Elixir_utility.getnamespace(); 
    }*/
    
    @AuraEnabled
    public static UA_Sample_Details__c saveRecordAfterEdit(UA_Sample_Details__c procReq, String orderByID,
                                                                            String acct ,String starttimeProcedure , 
                                                                            String endtimeProcedure,String attachId,
                                                                            String commentSign,String signedDate,string labOrderID) {
                                                               UA_Sample_Details__c updtRec = new UA_Sample_Details__c();
                                                               try{
                                                                   List<ElixirSuite__Visits__c> lstVisits = [Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c='Active' AND ElixirSuite__Account__c =:acct WITH SECURITY_ENFORCED LIMIT 1];                                                               
                                                                       Id devRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();
                                                                       Procedure__c newProcedure = new Procedure__c();
                                                                       newProcedure.Account__c=procReq.Account__c;
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
                                                                       
                                                                       newProcedure.Name = procReq.Medical_Test__c+' LabOrder procedure';
                                                                       if(!lstVisits.isEmpty())
                                                                       {
                                                                           newProcedure.ElixirSuite__Visits__c =lstVisits[0].Id;
                                                                       }            
                                                                       if( Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.Name.isCreateable() &&
                                                                       Schema.sObjectType.Procedure__c.fields.Visits__c.isCreateable()){
                                                                       insert newProcedure;
                                                                       }
                                                                                
                                                                   updtRec =  [SELECT Id,Name,Medical_Test__c,Account__c,Start_Date__c,
    Fax__c,On_Admission__c,Ordered_By__r.Id,Ordered_Via__c,Ordered_By__r.Name,Necessity_Details__c ,Frequency__c,Status__c
                                                         FROM UA_Sample_Details__c where Id=:acct
                                                         WITH SECURITY_ENFORCED];            
      updtRec.Ordered_By__c = orderByID;
      if(updtRec!=null &&
      UA_Sample_Details__c.sObjectType.getDescribe().isCreateable()){   
        DMLManager.updateAsUser(procReq);                                                                    
     //  update procReq;
      }
          if(attachId !=null){
           UA_Sample_Details__c  po= new UA_Sample_Details__c();
            po=[select id,Signature_Comments__c,Signed_Date__c, Signature_Link__c,Status__c 
            from UA_Sample_Details__c where id =:labOrderID WITH SECURITY_ENFORCED];
            //system.debug('po'+po);
               po.Signature_Link__c=attachId;
               po.Signature_Comments__c=commentSign;
               po.Status__c='Approved';
               po.Signed_Date__c=signedDate;   
               if(Schema.sObjectType.UA_Sample_Details__c.fields.Signature_Link__c.isUpdateable() &&
               Schema.sObjectType.UA_Sample_Details__c.fields.Signature_Comments__c.isUpdateable() &&
               Schema.sObjectType.UA_Sample_Details__c.fields.Status__c.isUpdateable() &&
               Schema.sObjectType.UA_Sample_Details__c.fields.Signed_Date__c.isUpdateable()){
                update po;
            }            
        }
                                                               }
                                                               catch(Exception e){
                                                                   ExceptionLog.logError(e);
                                                               }
       return updtRec;
                                                                            }
     @AuraEnabled	
    public static UA_Sample_Details__c saveSign(String attachId,String commentSign,String signedDate,string labOrderID){	
        UA_Sample_Details__c  po= new UA_Sample_Details__c();
        try{
        if(attachId !=null){	
            po=[select id,Signature_Comments__c,Signed_Date__c,Signature_Link__c,Status__c
             from UA_Sample_Details__c where id =:labOrderID WITH SECURITY_ENFORCED];	
            //system.debug('po'+po);	
                po.Signature_Link__c=attachId;	
                po.Signature_Comments__c=commentSign;	
                po.Status__c='Approved';	
            	po.Signed_Date__c=signedDate;	
                if(Schema.sObjectType.UA_Sample_Details__c.fields.Signature_Link__c.isUpdateable() &&
                Schema.sObjectType.UA_Sample_Details__c.fields.Signature_Comments__c.isUpdateable() &&
                Schema.sObjectType.UA_Sample_Details__c.fields.Status__c.isUpdateable() &&
                Schema.sObjectType.UA_Sample_Details__c.fields.Signed_Date__c.isUpdateable()){
                 update po;
             }           
            	
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return po;	
    }	
    	
     @AuraEnabled	
    public static string getCode(string accId){	
        List<Account> listOfAcc = [SELECT Id , Verification_Code__c , Name, parent.Name 
        FROM Account WHERE Id= : accId WITH SECURITY_ENFORCED];	
        string code = listofAcc[0].Verification_Code__c;	
        //system.debug('Code'+code);	
        return code;	
    }	
    @AuraEnabled
    public static boolean checkCareEpisode(string patientId){      
        
         //added by Anmol for LX3-7236
         Boolean result = Elixir_Utility.checkCareEpisodeUtility(patientId);
         return result;
         //end by Anmol for LX3-7236
       
    }

    @AuraEnabled
    public static String attachApprovalDataToLabOrder(String labOrderId, String approvedValues){
        try {            
            labOrderId = String.escapeSingleQuotes(labOrderId);
            List<ElixirSuite__UA_Sample_Details__c> allLabOrder = [
                SELECT Id, Status__c
                  FROM ElixirSuite__UA_Sample_Details__c
                 WHERE Id = :labOrderId
                 WITH SECURITY_ENFORCED
            ];

            if (allLabOrder == null || allLabOrder.size() == 0) {
                throw new AuraHandledException('No lab order found with given id');
            }

            ElixirSuite__UA_Sample_Details__c labOrder = allLabOrder[0];
            List<OrderSignatureSave.SignAndAprroveData> approvedValuesDeserialized = (List<OrderSignatureSave.SignAndAprroveData>)JSON.deserializeStrict(approvedValues, List<OrderSignatureSave.SignAndAprroveData>.class);

            Set<String> doNotChangeStatusAfterThese = new Set<String>{'Sent To Lab', 'Result Received'};

            for (OrderSignatureSave.SignAndAprroveData i : approvedValuesDeserialized) {
                switch on i.approvalLevel {
                    when 1 {
                        labOrder.ElixirSuite__Date_Of_Approval_1__c = i.dateOfApproval;
                        labOrder.ElixirSuite__Comment_1__c = i.comments;
                        labOrder.ElixirSuite__User_1__c = i.userId;
                        if (!doNotChangeStatusAfterThese.contains(labOrder.Status__c)) {
                            labOrder.Status__c = 'In Progress';
                        }
                    }
                    when 2 {
                        labOrder.ElixirSuite__Date_Of_Approval_2__c = i.dateOfApproval;
                        labOrder.ElixirSuite__Comment_2__c = i.comments;
                        labOrder.ElixirSuite__User_2__c = i.userId;
                        if (!doNotChangeStatusAfterThese.contains(labOrder.Status__c)) {
                            labOrder.Status__c = 'In Progress';
                        }
                    }

                    when 3 {
                        labOrder.ElixirSuite__Date_Of_Approval_3__c = i.dateOfApproval;
                        labOrder.ElixirSuite__Comment_3__c = i.comments;
                        labOrder.ElixirSuite__User_3__c = i.userId;
                        if (!doNotChangeStatusAfterThese.contains(labOrder.Status__c)) {
                            labOrder.Status__c = 'In Progress';
                        }
                    }
                }
            }

            DMLManager.updateAsUser(labOrder);
            return labOrderId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveColumnsApex(String columnsText){
        Elixir_Custom_Setting__c elixirCustomSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        elixirCustomSetting.ElixirSuite__LabOrder_Columns__c = columnsText;
        DMLManager.upsertAsUser(elixirCustomSetting);
    }
}