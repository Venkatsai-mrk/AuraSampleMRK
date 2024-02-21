public with sharing class COCHelperCC {
    @AuraEnabled
    public static parentWrapperForCOC parentInit_FetchDataForCOC(String recordId){
        Id ids;
        if(recordId!=Null){
    // VOB__c vob = [select id,name,elixirsuite__opportunity__r.name,elixirsuite__opportunity__r.dob,elixirsuite__opportunity__r.name from elixirsuite__vob__c where id=:recordId];
      VOB__c vob = [select id,name,elixirsuite__opportunity__c from elixirsuite__vob__c where id=:recordId
                    WITH SECURITY_ENFORCED];
              
            if(vob.elixirsuite__opportunity__c!=Null)
                ids= vob.elixirsuite__opportunity__c;
        }
        /* String ids;
        if(accountId!=Null){
             {
             VOB__c vob = [select Id, ElixirSuite__Opportunity__c from VOB__c where Id=:accountId];
            if(vob.ElixirSuite__Opportunity__c!=Null)
           ids= vob.ElixirSuite__Opportunity__c;
          }
            else
            {VOB__c vob = [select id,Account__c from VOB__c where Id=:accountId];
            if(vob.Account__c!=Null)
                ids= vob.Account__c;}
}}*/
        System.debug('VOBId:----' + recordId);
        parentWrapperForCOC wrpr = new parentWrapperForCOC();
        List<Procedure__c> availableProcedures = [SELECT ID,
                                                  Name,
                                                  CPT_HCPCS_Code__c,
                                                  Days_Units__c,
                                                  CreatedDate
                                                  from Procedure__c 
                                                  WHERE Account__c= NULL 
                                                  WITH SECURITY_ENFORCED
                                                  Order By CreatedDate asc 
                                                  limit 49999]; 
        List<VOB__c> patientDetailsFromVOB = [SELECT ID,Account__r.Name,
                                              Account__r.Patient_s_Birth_Date__c,
                                              Account__r.Gender__c,
                                              PatientFirstName__c,
                                              PatientLastName__c,
                                              Patient_Birth_Date__c,
                                              Gender__c,
                                              Payer_Name__c,ElixirSuite__Payer__c,
                                              ElixirSuite__Opportunity__c,
                                              ElixirSuite__Opportunity__r.ElixirSuite__Patient_s_DOB__c,
                                              ElixirSuite__Opportunity__r.Name,
                                              ElixirSuite__Opportunity__r.ElixirSuite__Gender__c,
                                              VOB_Verification_Status__c
                                              from VOB__c 
                                              where ElixirSuite__Opportunity__c =:ids
                                              WITH SECURITY_ENFORCED
                                              LIMIT 1];
          system.debug('RecordId:'+recordId);
        List<VOB__c> insuranceDetails = [SELECT Id,
                                         Type__c,
                                         Out_of_Net_Co_Payment__c,ElixirSuite__Insurance_Type__c,
                                         In_Net_Deductible_Remaining__c,
                                         In_Net_Out_of_Pkt_Total__c,
                                         VOB_Verification_Status__c,
                                         Plan_Sponsor__c,CreatedDate,
                                         Out_of_Net_Co_Insurance__c,
                                         Payer_Name__c,Payer__c,Account__c,Payer__r.Name
                                         from VOB__c
                                         where Id=:recordId /*ElixirSuite__Opportunity__c =:ids*/ AND Status__c='Active' AND 
                                         Type__c='Primary' 
                                         WITH SECURITY_ENFORCED
                                         ORDER BY CreatedDate DESC];
       
        system.debug('Insurance Details:'+insuranceDetails);
        List<Payor__c> relatedPayer = new List<Payor__c>();
        if(insuranceDetails.size() > 0) {
             relatedPayer = [SELECT Address__c, 
                             Id, 
                             Name, 
                             CreatedDate,
                             Payer_Code__c, 
                             PayerType__c, 
                             State__c, 
                             City__c, 
                             Zip_Code__c, 
                             PhoneNumber__c, 
                             Procedure__c 
                             FROM Payor__c  
                             WHERE Id=: insuranceDetails[0].Payer__c 
                             WITH SECURITY_ENFORCED];
        }
        Set<String> payerCode = new Set<String>();
        for(Payor__c pay : relatedPayer){
            payerCode.add(pay.Payer_Code__c);
        }
        List<Contracted_Price__c> cPrice = [SELECT id,
                                            Name,
                                            Units__c, 
                                            Contracted_Amount__c,
                                            Procedure__c,
                                            Payer__c,
                                            Procedure__r.Name, 
                                            Procedure__r.CPT_HCPCS_Code__c,
                                            payer__r.Payer_Code__c
                                            from Contracted_Price__c 
                                            where payer__r.Payer_Code__c IN : payerCode
                                            WITH SECURITY_ENFORCED];
        system.debug('cPrice '+cPrice);
        /*Map<Id, VOB__c> insuranceDetailsAllocated = new Map<id, VOB__c>([SELECT ID,
                                                                         Out_of_Net_Co_Payment__c,
                                                                         ElixirSuite__Opportunity__c,
                                                                         In_Net_Deductible_Remaining__c,
                                                                         In_Net_Out_of_Pkt_Total__c,
                                                                         VOB_Verification_Status__c,
                                                                         Plan_Sponsor__c,CreatedDate,
                                                                         Out_of_Net_Co_Insurance__c,
                                                                         ElixirSuite__Type__c,ElixirSuite__Payer__c.Name,ElixirSuite__Payer_Name__c,ElixirSuite__Payer__c,(select id,name from Payer__c where id=:insuranceDetails[0].Payer__c)  from VOB__c 
                                                                         where ElixirSuite__Opportunity__c =:ids AND Status__c='Active' AND ElixirSuite__Type__c='Primary' ORDER BY CreatedDate DESC]);*/
        Map<Id, VOB__c> insuranceDetailsAllocated = new Map<id, VOB__c>([SELECT ID,
                                                                         Out_of_Net_Co_Payment__c,
                                                                         ElixirSuite__Opportunity__c,
                                                                         In_Net_Deductible_Remaining__c,
                                                                         In_Net_Out_of_Pkt_Total__c,
                                                                         VOB_Verification_Status__c,
                                                                         Plan_Sponsor__c,CreatedDate,
                                                                         Out_of_Net_Co_Insurance__c,
                                                                         ElixirSuite__Type__c,ElixirSuite__Payer__c from VOB__c 
                                                                         where ElixirSuite__Opportunity__c =:ids AND Status__c='Active' AND ElixirSuite__Type__c='Primary' 
                                                                         WITH SECURITY_ENFORCED
                                                                         ORDER BY CreatedDate DESC]);
        
        List<Result__c> vobResult = new List<Result__c>();
        Map<Id, List<Result__c>> vobIdToResultMap = new Map<Id, List<Result__c>>();
        if(insuranceDetailsAllocated.size() > 0) {
            vobResult = [SELECT Id, 
                           VOB__c,
                           ElixirSuite__Deduc_inNtwk_Clientperc__c, CreatedDate,
                           ElixirSuite__Payer_Name__c,ElixirSuite__Insurance_Type__c,ElixirSuite__out_of_network_outOfPocket_total__c,
                           ElixirSuite__Deductible_Individual_Out_Plan_Network__c,ElixirSuite__In_Net_Co_Payment__c
                           FROM Result__c 
                           where ElixirSuite__VOB__c IN :insuranceDetailsAllocated.keySet()
                           WITH SECURITY_ENFORCED
                           Order by ElixirSuite__Insurance_Type__c] ;
        }
        //System.debug('InsuranceDetails:'+insuranceDetailsAllocated[0].ElixirSuite__Payer__r.Name);
        
        for(Result__c resultRec : vobResult){
            
            if(vobIdToResultMap.containsKey(resultRec.VOB__c)) {
                List<Result__c> resultList = vobIdToResultMap.get(resultRec.VOB__c);
                resultList.add(resultRec);
                vobIdToResultMap.put(resultRec.VOB__c, resultList);
            } else {
                List<Result__c> resultList = new List<Result__c>();
                resultList.add(resultRec);
                vobIdToResultMap.put(resultRec.VOB__c, resultList);
            }
        }
        
        List<Result__c> latestVobResult = new List<Result__c>();
        Set<Id> latestVobResultSet = new Set<Id>();
        
        for(Id vobId : vobIdToResultMap.keySet()) {
            List<Result__c> resultRecList = vobIdToResultMap.get(vobId);
            Result__c resultLatestRec;
            for(Result__c resultRec : resultRecList) {
                if(resultLatestRec == null) {
                    resultLatestRec = resultRec;
                } else {
                    if(resultLatestRec.CreatedDate < resultRec.CreatedDate) {
                        System.debug(resultRec.Id);
                        resultLatestRec = resultRec;
                    }
                }
            }
            
            latestVobResult.add(resultLatestRec);
        }
        
        for(Result__c resRec : latestVobResult) {
            latestVobResultSet.add(resRec.Id);
        }
        
        List<Result__c> sortedVobResult = [SELECT Id, 
                                           CreatedDate,
                                           VOB__c, 
                                           Deduc_inNtwk_Clientperc__c, 
                                           Payer_Name__c, 
                                           Co_Insurance_Provider_Percent__c,
                                           in_network_total__c,
                                           In_Net_Co_Payment__c,
                                           out_of_network_outOfPocket_total__c,Deductible_Individual_Out_Plan_Network__c,
                                           ElixirSuite__Insurance_Type__c
                                           FROM Result__c 
                                           where Id IN :latestVobResultSet
                                           WITH SECURITY_ENFORCED
                                           Order by ElixirSuite__Insurance_Type__c] ;
        
        System.debug('sortedVobResult:----' + sortedVobResult.size());
        System.debug('insuranceDetails:----' + insuranceDetails.size());
        wrpr.acctDetailsFromVOB = patientDetailsFromVOB;
        wrpr.allProcedures = availableProcedures;
        wrpr.insuranceDetails = insuranceDetails;
        wrpr.vobResult = sortedVobResult;
        wrpr.ContractPrice=cPrice;
        return wrpr;
    }
    
    
    
    @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name from User 
        where Id =:currentUid].ElixirSuite__License_Type__c;
        List<String> lst_availLicense = new List<String>();
        lst_availLicense = AvailLicense.split(';');
        License_Class lCls = new License_Class();
        for(String str : lst_availLicense)
        {
            if(str == 'Elixir EHR')
            {
                lCls.isEhr = True;
                continue;
            }
           
            if(str == 'Elixir Contact Center')
            {
                lCls.isContactCenter = True;
                continue;
            }
            
            if(str == 'Elixir RCM')
            {
                lCls.isRcm = True;
                continue;
            }
        }
        return lCls;
    }
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr;
        @AuraEnabled public Boolean isRcm;
        @AuraEnabled public Boolean isContactCenter;
    }
    
    
    @AuraEnabled
    public static  List<Procedure__c> getProceduresTemplates(List<String> alreadyExistingProcedures){
        System.debug('ids '+alreadyExistingProcedures);
        List<Procedure__c> availableProcedures = new  List<Procedure__c>();
        availableProcedures = [SELECT ID,Name,CPT_HCPCS_Code__c,Days_Units__c from Procedure__c  
                                WHERE Account__c= NULL AND id not in : alreadyExistingProcedures
                                WITH SECURITY_ENFORCED
                                limit 49999];  
        return availableProcedures;
    }
    @AuraEnabled
    public static parentWrapperForCOC fetchIndividualRecordDetailsForView(String COCRecordId){
      Estimates__c singleRecordQueried = [SELECT Opportunity__c,In_Use__c,Procedure_Total__c,Co_Insurance__c,Co_Pay__c,CreatedById,CreatedDate,Deductible__c,Id,Insurer_Responsibility__c,IsDeleted
                                        ,LastModifiedById,LastModifiedDate,Name,OOP_Max__c,OwnerId,
                                            Patient_responsibility__c,Status__c FROM Estimates__c WHERE ID=:COCRecordId WITH SECURITY_ENFORCED LIMIT 1];
        List<Estimated_Procedures__c> relatedProcedures = [SELECT Contracted_Rate__c,CreatedById,CreatedDate,Estimates__c,File_Content__c,ICT_CODE__c,Id,IsDeleted,
                                                           LastModifiedById,LastModifiedDate,Name,OwnerId,Procedure_Name__c,Total_Contracted_Price__c,Unit__c 
                                                           FROM Estimated_Procedures__c WHERE Estimates__c  = : COCRecordId WITH SECURITY_ENFORCED];
        Estimates__c patientDetails = [SELECT ID,Opportunity__r.Name,Opportunity__r.Patient_s_DOB__c,Opportunity__r.Gender__c
                                       from Estimates__c where ID =:COCRecordId WITH SECURITY_ENFORCED LIMIT 1];
        System.debug('patientDetails====='+patientDetails.ElixirSuite__Opportunity__r.Patient_s_DOB__c);
        parentWrapperForCOC toReturnWrapper  = new parentWrapperForCOC();
        toReturnWrapper.singleRecordQueried =singleRecordQueried;
        toReturnWrapper.relatedProcedures = relatedProcedures;
        toReturnWrapper.patientDetails = patientDetails;
        return toReturnWrapper;
    }
    public class parentWrapperForCOC{
        @AuraEnabled public List<Procedure__c> allProcedures;
        @AuraEnabled public List<Account> acctDetails;
        @AuraEnabled public List<VOB__c> insuranceDetails;
        @AuraEnabled public List<VOB__c> acctDetailsFromVOB;
        @AuraEnabled public List<Result__c> vobResult;
        @AuraEnabled public Estimates__c singleRecordQueried;
        @AuraEnabled public List<Estimated_Procedures__c> relatedProcedures;
        @AuraEnabled public Estimates__c patientDetails;
         @AuraEnabled public List<Contracted_Price__c> ContractPrice;
    }
    @AuraEnabled
    public static  void saveCOC(String recordId,
                                Integer patientResponsibility,
                                Integer insuranceResposibility,
                                Integer procedureTotal,
                                String insuranceDetails,
                                String proceduresToSave,
                                Boolean receivedValue, 
                                Integer copay){
         String ids1;
        if(recordId!=Null){
           VOB__c vob = [select id,ElixirSuite__Opportunity__c from VOB__c where Id=:recordId
           WITH SECURITY_ENFORCED];
            if(vob.ElixirSuite__Opportunity__c!=Null)
                ids1= vob.ElixirSuite__Opportunity__c;
        }
        
                                    
                                    System.debug('recordId:----' + recordId);
                                    System.debug('patientResponsibility:----' + patientResponsibility);
                                    System.debug('insuranceResposibility:----' + insuranceResposibility);
                                    System.debug('procedureTotal:----' + procedureTotal);
                                    System.debug('insuranceDetails:----' + insuranceDetails);
                                    System.debug('proceduresToSave:----' + proceduresToSave);
                                    System.debug('receivedValue:----' + receivedValue);
                                    System.debug('copay:----' + copay);
                                    
                                    Map<String, Object> mainJsonForInsurance =(Map<String, Object>) JSON.deserializeUntyped(insuranceDetails);
                                    List<Object> listOfInsuranceRecords = (List<Object>) mainJsonForInsurance.get('keysToSave');
                                    List<Estimated_Procedures__c> estimatedProcRecordsToInsert = new List<Estimated_Procedures__c>();
                                    Map<String, Object> mainJsonForProcedures =(Map<String, Object>) JSON.deserializeUntyped(proceduresToSave);
                                    List<Object> listOfProcedure = (List<Object>) mainJsonForProcedures.get('keysToSaveForPrcedures');
                                    
                                    List<Estimates__c> estimateList = new List<Estimates__c>();
                                    for(Object insuranceRec : listOfInsuranceRecords) {
                                        
                                        Map<String, Object> mapOfInsurance = (Map<String, Object>) insuranceRec;
                                        Estimates__c newEstimate = new Estimates__c();              
                                        newEstimate.ElixirSuite__Opportunity__c = ids1;
                                        newEstimate.In_Use__c = receivedValue;
                                        newEstimate.Co_Insurance__c =  (Decimal)mapOfInsurance.get('ElixirSuite__Co_Insurance_Provider_Percent__c');
                                        newEstimate.Co_Pay__c = Decimal.valueOf(copay);
                                        newEstimate.Deductible__c = (Decimal)mapOfInsurance.get('ElixirSuite__Deductible_Individual_Out_Plan_Network__c');
                                        newEstimate.Procedure_Total__c = Decimal.valueOf(procedureTotal);
                                        newEstimate.OOP_Max__c = (Decimal)mapOfInsurance.get('ElixirSuite__out_of_network_outOfPocket_total__c');
                                        newEstimate.Insurance_Name__c = String.valueOf(mapOfInsurance.get('ElixirSuite__Payer__r.Name'));
                                        newEstimate.Patient_responsibility__c = patientResponsibility;
                                        newEstimate.Insurer_Responsibility__c = insuranceResposibility;
                                        estimateList.add(newEstimate);
                                       
                                    }
                                    String estimateId ;
                                    if(estimateList.size()==1)
                                    {  system.debug('estimateList:'+estimateList);
                                    if(Schema.sObjectType.Estimates__c.isCreateable()){
                                        insert estimateList;
                                    }
                                        
                                    }
                                    else if(estimateList.size()>1)
                                    {
                                        insert estimateList[0];
                                    }
                                    if(estimateList.size()>0 && estimateList!=null)
                                    {
                                    estimateId = estimateList[0].Id;     // @Avani - If  estimateList is null or size<0 , this line will fail, please add a null check here.            
                                    }
                                    for(Object procedureRec : listOfProcedure){
                                        Map<String, Object> mapofProcedure = (Map<String, Object>) procedureRec;
                                        Estimated_Procedures__c newEstimatedProcedure = new Estimated_Procedures__c();              
                                        newEstimatedProcedure.Estimates__c = estimateId;
                                        newEstimatedProcedure.ICT_CODE__c = String.valueOf(mapofProcedure.get('ElixirSuite__CPT_HCPCS_Code__c'));
                                        newEstimatedProcedure.Procedure_Name__c = String.valueOf(mapofProcedure.get('Name'));
                                        newEstimatedProcedure.Unit__c =  String.valueOf((mapofProcedure.get('ElixirSuite__Days_Units__c')));
                                        newEstimatedProcedure.Contracted_Rate__c =  (Decimal)(mapofProcedure.get('ElixirSuite__Contracted_Price__c'));
                                        newEstimatedProcedure.Total_Contracted_Price__c = (Decimal)mapofProcedure.get('totalContractedPrice');
                                        estimatedProcRecordsToInsert.add(newEstimatedProcedure);
                                        System.debug('estimated record2 '+estimatedProcRecordsToInsert);
                                    }
                                    if(estimatedProcRecordsToInsert.size()>0 && estimatedProcRecordsToInsert!=null) //added here by Avani Jain
                                    {   if(Schema.sObjectType.Estimated_Procedures__c.isCreateable()){
                                        insert estimatedProcRecordsToInsert;
                                    }
                                        
                                    }
                                    else{
                                       system.debug('Invalid');
                                    } // @Avani - Add null and size check for list b4 insert
                                }
    
    
    
   /* @AuraEnabled 
    public static list<Opportunity> employerList(String searchKeyWord ){
        String searchKey = '%' + searchKeyWord + '%';
        List <Opportunity> returnList = new List <Opportunity> ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from Opportunity where Name LIKE: searchKey limit 149';
        List <Opportunity> lstOfRecords = Database.query(sQuery);
        return lstOfRecords;*/
    
    @AuraEnabled 
    public static list<Opportunity> employerList(String searchKeyWord ){
        String searchKey = '%' + searchKeyWord + '%';
        List <Opportunity> returnList = new List <Opportunity> ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        List <Opportunity> lstOfRecords = [select id, Name from Opportunity where Name LIKE: searchKey WITH SECURITY_ENFORCED limit 999];
           return lstOfRecords;
    }
    
    @AuraEnabled 
    public static void updateUseStatusForCOCEstimateSingleRecord(String estimateID,Boolean receivedValue){
     Estimates__c toUpdateRecord = [SELECT ID,In_Use__c FROM Estimates__c WHERE ID = : estimateID
     WITH SECURITY_ENFORCED];
     if(Schema.sObjectType.Estimates__c.fields.In_Use__c.isUpdateable()){
        toUpdateRecord.In_Use__c = receivedValue;
        update toUpdateRecord;
     }
    }
}