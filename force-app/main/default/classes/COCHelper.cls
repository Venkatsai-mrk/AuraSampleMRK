public with sharing class COCHelper {
    
    @AuraEnabled
    public static parentWrapperForCOC parentInit_FetchDataForCOC(String accountId){
        
        System.debug('accountId:----' + accountId);
        
        parentWrapperForCOC wrpr = new parentWrapperForCOC();
        
        List<Procedure__c> availableProcedures = new List<Procedure__c>();
        if(Schema.sObjectType.Procedure__c.isAccessible() 
           && Schema.sObjectType.Procedure__c.fields.Name.isAccessible()
           && Schema.sObjectType.Procedure__c.fields.CPT_HCPCS_Code__c.isAccessible()
           && Schema.sObjectType.Procedure__c.fields.Days_Units__c.isAccessible()
           && Schema.sObjectType.Procedure__c.fields.CreatedDate.isAccessible()
           && Schema.sObjectType.Procedure__c.fields.Account__c.isAccessible()){
           
               availableProcedures = [SELECT ID,
                               Name,
                               CPT_HCPCS_Code__c,
                               Days_Units__c,
                               CreatedDate
                               from Procedure__c 
                               WHERE Account__c= NULL 
                               Order By CreatedDate asc 
                               limit 49999]; 
        }
       	
        
        List<VOB__c> patientDetailsFromVOB = new List<VOB__c>();
        if(Schema.sObjectType.VOB__c.isAccessible() 
           && Schema.sObjectType.VOB__c.fields.Payer_Name__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.PatientFirstName__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.PatientLastName__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Patient_Birth_Date__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Account__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.VOB_Verification_Status__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Gender__c.isAccessible()
           && Schema.sObjectType.Account.fields.Name.isAccessible()
           && Schema.sObjectType.Account.fields.Patient_s_Birth_Date__c.isAccessible()
           && Schema.sObjectType.Account.fields.Gender__c.isAccessible()
          ){
           
        	patientDetailsFromVOB = [SELECT ID,
                                 Account__r.Name,
                                 Account__r.Patient_s_Birth_Date__c,
                                 Account__r.Gender__c,
                                 Payer_Name__c,
                                 PatientFirstName__c,
                                 PatientLastName__c,
                                 Patient_Birth_Date__c,
                                 VOB_Verification_Status__c,
                                 Gender__c
                                 from VOB__c 
                                 where Account__c =:accountId
                                 LIMIT 1];
           }
        List<VOB__c> insuranceDetails = new List<VOB__c>();
        if(Schema.sObjectType.VOB__c.isAccessible() 
           && Schema.sObjectType.VOB__c.fields.Type__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Out_of_Net_Co_Payment__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.In_Net_Deductible_Remaining__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.In_Net_Out_of_Pkt_Total__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Account__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.VOB_Verification_Status__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Plan_Sponsor__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Out_of_Net_Co_Insurance__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Payer_Name__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Payer__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Status__c.isAccessible()){
              insuranceDetails = [SELECT Id,
                                  Type__c,
                                  Out_of_Net_Co_Payment__c,
                                  In_Net_Deductible_Remaining__c,
                                  In_Net_Out_of_Pkt_Total__c,
                                  VOB_Verification_Status__c,
                                  Plan_Sponsor__c,
                                  Out_of_Net_Co_Insurance__c,
                                  Payer_Name__c,Payer__c,Account__c
                                  from VOB__c 
                                  where Account__c =:accountId AND Status__c='Active' ORDER BY CreatedDate DESC LIMIT 50000];
          }
        List<Payor__c> relatedPayer = new List<Payor__c>();
        
        if(insuranceDetails.size() > 0) {
        	if(Schema.sObjectType.Payor__c.isAccessible() 
               && Schema.sObjectType.Payor__c.fields.Name.isAccessible()
               && Schema.sObjectType.Payor__c.fields.CreatedDate.isAccessible()
               && Schema.sObjectType.Payor__c.fields.Payer_Code__c.isAccessible()
               && Schema.sObjectType.Payor__c.fields.PayerType__c.isAccessible()
               && Schema.sObjectType.Payor__c.fields.State__c.isAccessible()
               && Schema.sObjectType.Payor__c.fields.City__c.isAccessible()
               && Schema.sObjectType.Payor__c.fields.Zip_Code__c.isAccessible()
               && Schema.sObjectType.Payor__c.fields.PhoneNumber__c.isAccessible()
               && Schema.sObjectType.Payor__c.fields.Procedure__c.isAccessible()){  
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
                             WHERE Id=: insuranceDetails[0].Payer__c LIMIT 50000];
           }
        }
        Set<String> payerCode = new Set<String>();
        if(!relatedPayer.isEmpty())
        {
            for(Payor__c pay : relatedPayer){
                if(Schema.sObjectType.Payor__c.isAccessible() && Schema.sObjectType.Payor__c.fields.Payer_Code__c.isAccessible())
                {	payerCode.add(pay.Payer_Code__c);	}
        	}
        }
        List<Contracted_Price__c> cPrice = new List<Contracted_Price__c>();
        if(payerCode != null && payerCode.size() > 0)
        {
            if(Schema.sObjectType.Contracted_Price__c.isAccessible() 
               && Schema.sObjectType.Contracted_Price__c.fields.Name.isAccessible()
               && Schema.sObjectType.Contracted_Price__c.fields.Units__c.isAccessible()
               && Schema.sObjectType.Contracted_Price__c.fields.Contracted_Amount__c.isAccessible()
               && Schema.sObjectType.Contracted_Price__c.fields.Procedure__c.isAccessible()
               && Schema.sObjectType.Contracted_Price__c.fields.Payer__c.isAccessible()
               && Schema.sObjectType.Procedure__c.fields.Name.isAccessible()
               && Schema.sObjectType.Procedure__c.fields.CPT_HCPCS_Code__c.isAccessible()
               && Schema.sObjectType.payor__c.fields.Payer_Code__c.isAccessible()){
                   cPrice = [SELECT id,
                             Name,
                             Units__c, 
                             Contracted_Amount__c,
                             Procedure__c,
                             Payer__c,
                             Procedure__r.Name, 
                             Procedure__r.CPT_HCPCS_Code__c,
                             payer__r.Payer_Code__c
                             from Contracted_Price__c 
                             where payer__r.Payer_Code__c IN : payerCode LIMIT 50000];
               }
        }

        system.debug('cPrice '+cPrice);
        system.debug('cPrice size'+cPrice.size());
        
        Map<Id, VOB__c> insuranceDetailsAllocated;
        if(Schema.sObjectType.VOB__c.isAccessible() 
           && Schema.sObjectType.VOB__c.fields.Type__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Out_of_Net_Co_Payment__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.In_Net_Deductible_Remaining__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.In_Net_Out_of_Pkt_Total__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Account__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.VOB_Verification_Status__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Plan_Sponsor__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Out_of_Net_Co_Insurance__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.Status__c.isAccessible()
           && Schema.sObjectType.VOB__c.fields.CreatedDate.isAccessible()){
               insuranceDetailsAllocated = new Map<id, VOB__c>([SELECT ID,
                                                                Out_of_Net_Co_Payment__c,
                                                                In_Net_Deductible_Remaining__c,
                                                                In_Net_Out_of_Pkt_Total__c,
                                                                VOB_Verification_Status__c,
                                                                Plan_Sponsor__c,
                                                                Out_of_Net_Co_Insurance__c
                                                                from VOB__c 
                                                                where Account__c =:accountId AND Status__c='Active' AND Type__c='Primary' ORDER BY CreatedDate DESC LIMIT 50000]);
           }
        List<Result__c> vobResult = new List<Result__c>();
        
        Map<Id, List<Result__c>> vobIdToResultMap = new Map<Id, List<Result__c>>();
        
        if(insuranceDetailsAllocated.size() > 0) {
         if(Schema.sObjectType.Result__c.isAccessible() 
           && Schema.sObjectType.Result__c.fields.VOB__c.isAccessible()
           && Schema.sObjectType.Result__c.fields.Deduc_inNtwk_Clientperc__c.isAccessible()
           && Schema.sObjectType.Result__c.fields.Payer_Name__c.isAccessible()
           && Schema.sObjectType.Result__c.fields.Co_Insurance_Provider_Percent__c.isAccessible()
           && Schema.sObjectType.Result__c.fields.in_network_total__c.isAccessible()
           && Schema.sObjectType.Result__c.fields.In_Net_Co_Payment__c.isAccessible()
           && Schema.sObjectType.Result__c.fields.out_of_network_outOfPocket_total__c.isAccessible()
           && Schema.sObjectType.Result__c.fields.Deductible_Individual_Out_Plan_Network__c.isAccessible()
           && Schema.sObjectType.Result__c.fields.Insurance_Type__c.isAccessible()
           && Schema.sObjectType.Result__c.fields.CreatedDate.isAccessible()){   
              vobResult = [SELECT Id, 
                           CreatedDate,
                           VOB__c, 
                           Deduc_inNtwk_Clientperc__c, 
                           Payer_Name__c, 
                           Co_Insurance_Provider_Percent__c,
                           in_network_total__c,
                           In_Net_Co_Payment__c,
                           out_of_network_outOfPocket_total__c,Deductible_Individual_Out_Plan_Network__c,
                           Insurance_Type__c
                           FROM Result__c 
                           where VOB__c IN :insuranceDetailsAllocated.keySet()
                           Order by Insurance_Type__c LIMIT 50000] ;
           }
        }
       
        for(Result__c resultRec : vobResult){
            
            if(vobIdToResultMap.containsKey(resultRec.VOB__c)) {
                List<Result__c> resultList = vobIdToResultMap.get(resultRec.VOB__c);
                if(Schema.sObjectType.Result__c.isAccessible())
                {	resultList.add(resultRec);	}
                vobIdToResultMap.put(resultRec.VOB__c, resultList);
                 
            } else {
                List<Result__c> resultList = new List<Result__c>();
                if(Schema.sObjectType.Result__c.isAccessible())
                {	resultList.add(resultRec);	}
                vobIdToResultMap.put(resultRec.VOB__c, resultList);
            }
        }
        
        List<Result__c> latestVobResult = new List<Result__c>();
        Set<Id> latestVobResultSet = new Set<Id>();
        if(vobIdToResultMap != null && vobIdToResultMap.size()>0)
        {
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
        }
         for(Result__c resRec : latestVobResult) {
            latestVobResultSet.add(resRec.Id);
        }
        List<Result__c> sortedVobResult = new List<Result__c>();
        if(latestVobResultSet != null && latestVobResultSet.size()>0)
        { 
            if(Schema.sObjectType.Result__c.isAccessible() 
               && Schema.sObjectType.Result__c.fields.VOB__c.isAccessible()
               && Schema.sObjectType.Result__c.fields.Deduc_inNtwk_Clientperc__c.isAccessible()
               && Schema.sObjectType.Result__c.fields.Payer_Name__c.isAccessible()
               && Schema.sObjectType.Result__c.fields.Co_Insurance_Provider_Percent__c.isAccessible()
               && Schema.sObjectType.Result__c.fields.in_network_total__c.isAccessible()
               && Schema.sObjectType.Result__c.fields.In_Net_Co_Payment__c.isAccessible()
               && Schema.sObjectType.Result__c.fields.out_of_network_outOfPocket_total__c.isAccessible()
               && Schema.sObjectType.Result__c.fields.Deductible_Individual_Out_Plan_Network__c.isAccessible()
               && Schema.sObjectType.Result__c.fields.Insurance_Type__c.isAccessible()
               && Schema.sObjectType.Result__c.fields.CreatedDate.isAccessible()){   
                   sortedVobResult = [SELECT Id, 
                                      CreatedDate,
                                      VOB__c, 
                                      Deduc_inNtwk_Clientperc__c, 
                                      Payer_Name__c, 
                                      Co_Insurance_Provider_Percent__c,
                                      in_network_total__c,
                                      In_Net_Co_Payment__c,
                                      out_of_network_outOfPocket_total__c,Deductible_Individual_Out_Plan_Network__c,
                                      Insurance_Type__c
                                      FROM Result__c 
                                      where Id IN :latestVobResultSet
                                      Order by Insurance_Type__c LIMIT 50000] ;
               }
        }
        System.debug('sortedVobResult:----' + sortedVobResult.size());
        System.debug('insuranceDetails:----' + insuranceDetails.size());
        System.debug('### availableProcedures : ' + availableProcedures);
        wrpr.acctDetailsFromVOB = patientDetailsFromVOB;
        wrpr.allProcedures = availableProcedures;
        wrpr.insuranceDetails = insuranceDetails;
        wrpr.vobResult = sortedVobResult;
        wrpr.ContractPrice=cPrice;
        return wrpr;
    }
    
    @AuraEnabled
    public static  List<Procedure__c> getProceduresTemplates(List<String> alreadyExistingProcedures){
        System.debug('### ids '+alreadyExistingProcedures);
        List<Procedure__c> availableProcedures = new  List<Procedure__c>();
        if(Schema.sObjectType.Procedure__c.isAccessible() 
           && Schema.sObjectType.Procedure__c.fields.Name.isAccessible()
           && Schema.sObjectType.Procedure__c.fields.CPT_HCPCS_Code__c.isAccessible()
           && Schema.sObjectType.Procedure__c.fields.Days_Units__c.isAccessible()
           && Schema.sObjectType.Procedure__c.fields.Account__c.isAccessible()){   
        	availableProcedures = [SELECT ID,Name,CPT_HCPCS_Code__c,Days_Units__c from Procedure__c  WHERE Account__c= NULL AND id not in : alreadyExistingProcedures limit 49999]; 
           }
        return availableProcedures;
    }
    @AuraEnabled
    public static parentWrapperForCOC fetchIndividualRecordDetailsForView(String COCRecordId){
        
        List<Estimates__c> singleRecordQueried = new List<Estimates__c>();
        if(Schema.sObjectType.Estimates__c.isAccessible() 
           && Schema.sObjectType.Estimates__c.fields.Account__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.In_Use__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.ElixirSuite__Insurance_Name__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Procedure_Total__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Co_Insurance__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Co_Pay__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.CreatedDate.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Deductible__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Insurer_Responsibility__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Name.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.OOP_Max__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Patient_responsibility__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Status__c.isAccessible()){   
               singleRecordQueried = [SELECT Account__c,In_Use__c,ElixirSuite__Insurance_Name__c,Procedure_Total__c,Co_Insurance__c,Co_Pay__c,CreatedDate,Deductible__c,Id,Insurer_Responsibility__c,
                                      Name,OOP_Max__c,Patient_responsibility__c,Status__c FROM Estimates__c WHERE ID=:COCRecordId LIMIT 1];
           }
        List<Estimated_Procedures__c> relatedProcedures = new List<Estimated_Procedures__c>();
        if(Schema.sObjectType.Estimated_Procedures__c.isAccessible() 
           && Schema.sObjectType.Estimated_Procedures__c.fields.Contracted_Rate__c.isAccessible()
           && Schema.sObjectType.Estimated_Procedures__c.fields.Estimates__c.isAccessible()
           && Schema.sObjectType.Estimated_Procedures__c.fields.File_Content__c.isAccessible()
           && Schema.sObjectType.Estimated_Procedures__c.fields.ICT_CODE__c.isAccessible()
           && Schema.sObjectType.Estimated_Procedures__c.fields.Name.isAccessible()
           && Schema.sObjectType.Estimated_Procedures__c.fields.Procedure_Name__c.isAccessible()
           && Schema.sObjectType.Estimated_Procedures__c.fields.Total_Contracted_Price__c.isAccessible()
           && Schema.sObjectType.Estimated_Procedures__c.fields.Unit__c.isAccessible()){
               relatedProcedures = [SELECT Contracted_Rate__c,Estimates__c,File_Content__c,ICT_CODE__c,Id,
                                    Name,Procedure_Name__c,Total_Contracted_Price__c,Unit__c
                                    FROM Estimated_Procedures__c WHERE Estimates__c  = : COCRecordId LIMIT 50000];
           }
        List<Estimates__c> patientDetails = new List<Estimates__c>();
        if(Schema.sObjectType.Estimates__c.isAccessible() 
           && Schema.sObjectType.Estimates__c.fields.Account__c.isAccessible()
           && Schema.sObjectType.Account.fields.Name.isAccessible()
           && Schema.sObjectType.Account.fields.Patient_s_Birth_Date__c.isAccessible()
           && Schema.sObjectType.Account.fields.Gender__c.isAccessible()){  
               patientDetails = [SELECT ID,Account__r.Name,Account__r.Patient_s_Birth_Date__c,Account__r.Gender__c
                                 from Estimates__c where ID =:COCRecordId LIMIT 1];
           }
        parentWrapperForCOC toReturnWrapper  = new parentWrapperForCOC();
        toReturnWrapper.singleRecordQueried = singleRecordQueried.size()>0 ? singleRecordQueried[0] : null;
        toReturnWrapper.relatedProcedures = relatedProcedures;
        toReturnWrapper.patientDetails = patientDetails.size() > 0 ? patientDetails[0] : null;
        system.debug('Single query:'+singleRecordQueried);
         system.debug('Related Procedure:'+relatedProcedures);
         system.debug('patientDetails:'+patientDetails);
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
    public static  void saveCOC(String accountId,
                                Integer patientResponsibility,
                                Integer insuranceResposibility,
                                Integer procedureTotal,
                                String insuranceDetails,
                                String proceduresToSave,
                                Boolean receivedValue, 
                                Integer copay)
    {
                                    
        System.debug('accountId:----' + accountId);
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
        /*for(Object insuranceRec : listOfInsuranceRecords) {
            
            Map<String, Object> mapOfInsurance = (Map<String, Object>) insuranceRec;
            Estimates__c newEstimate = new Estimates__c();              
            if(Schema.SObjectType.Estimates__c.fields.Account__c.isCreateable()){newEstimate.Account__c = accountId;}
            if(Schema.SObjectType.Estimates__c.fields.In_Use__c.isCreateable()){newEstimate.In_Use__c = receivedValue;}
            if(Schema.SObjectType.Estimates__c.fields.Co_Insurance__c.isCreateable()){newEstimate.Co_Insurance__c = mapOfInsurance.containsKey('coinsur')?  (Decimal)mapOfInsurance.get('coinsur') : 0.0;}
            if(Schema.SObjectType.Estimates__c.fields.Co_Pay__c.isCreateable()){newEstimate.Co_Pay__c = copay != null ? Decimal.valueOf(copay) : 0.0;}
            if(Schema.SObjectType.Estimates__c.fields.Deductible__c.isCreateable()){newEstimate.Deductible__c = mapOfInsurance.containsKey('remainigDeductible')? (Decimal)mapOfInsurance.get('remainigDeductible') : 0.0;}
            if(Schema.SObjectType.Estimates__c.fields.Procedure_Total__c.isCreateable()){newEstimate.Procedure_Total__c = procedureTotal != null ? Decimal.valueOf(procedureTotal) : 0.0;}
            if(Schema.SObjectType.Estimates__c.fields.OOP_Max__c.isCreateable()){newEstimate.OOP_Max__c = mapOfInsurance.containsKey('oopMax')? (Decimal)mapOfInsurance.get('oopMax') : 0.0;}
            if(Schema.SObjectType.Estimates__c.fields.Insurance_Name__c.isCreateable()){newEstimate.Insurance_Name__c = mapOfInsurance.containsKey('ElixirSuite__Payer_Name__c')? String.valueOf(mapOfInsurance.get('ElixirSuite__Payer_Name__c')) : '';}
            if(Schema.SObjectType.Estimates__c.fields.Patient_responsibility__c.isCreateable()){newEstimate.Patient_responsibility__c = patientResponsibility;}
            if(Schema.SObjectType.Estimates__c.fields.Insurer_Responsibility__c.isCreateable()){newEstimate.Insurer_Responsibility__c = insuranceResposibility;}
            if(Schema.SObjectType.Estimates__c.isCreateable()){estimateList.add(newEstimate);}
            
        }*/
        
         for(Object insuranceRec : listOfInsuranceRecords) {
            
            Map<String, Object> mapOfInsurance = (Map<String, Object>) insuranceRec;
            Estimates__c newEstimate = new Estimates__c();              
            newEstimate.Account__c = accountId;
            newEstimate.In_Use__c = receivedValue;
            newEstimate.Co_Insurance__c = mapOfInsurance.containsKey('ElixirSuite__Deduc_inNtwk_Clientperc__c')?  (Decimal)mapOfInsurance.get('ElixirSuite__Deduc_inNtwk_Clientperc__c') : 0.0;
            newEstimate.Co_Pay__c = copay != null ? Decimal.valueOf(copay) : 0.0;
            newEstimate.Deductible__c = mapOfInsurance.containsKey('ElixirSuite__Deductible_Individual_Out_Plan_Network__c')? (Decimal)mapOfInsurance.get('ElixirSuite__Deductible_Individual_Out_Plan_Network__c') : 0.0;
            newEstimate.Procedure_Total__c = procedureTotal != null ? Decimal.valueOf(procedureTotal) : 0.0;
            newEstimate.OOP_Max__c = mapOfInsurance.containsKey('ElixirSuite__out_of_network_outOfPocket_total__c')? (Decimal)mapOfInsurance.get('ElixirSuite__out_of_network_outOfPocket_total__c') : 0.0;
            newEstimate.Insurance_Name__c = mapOfInsurance.containsKey('ElixirSuite__Payer_Name__c')? String.valueOf(mapOfInsurance.get('ElixirSuite__Payer_Name__c')) : '';
            newEstimate.Patient_responsibility__c = patientResponsibility;
            newEstimate.Insurer_Responsibility__c = insuranceResposibility;
            estimateList.add(newEstimate);
            
        }
        String estimateId ;
        if(estimateList.size()==1)
        {
            try{
                
         if(Schema.sObjectType.Estimates__c.isCreateable()){insert estimateList;}
        insert estimateList;
            }
            catch(Exception e){
                ExceptionLog.logError(e);
            }
            
        }
        else if(estimateList.size()>1)
        {
            try{
            if(Schema.SObjectType.Estimates__c.isCreateable()){insert estimateList[0];}
            }
            catch(Exception e){
                ExceptionLog.logError(e);
            }
        }
        estimateId = estimateList[0].Id;                  
        for(Object procedureRec : listOfProcedure){
            Map<String, Object> mapofProcedure = (Map<String, Object>) procedureRec;
            Estimated_Procedures__c newEstimatedProcedure = new Estimated_Procedures__c();              
            if(Schema.sObjectType.Estimated_Procedures__c.fields.Estimates__c.isCreateable()){newEstimatedProcedure.Estimates__c = estimateId;}
            if(Schema.sObjectType.Estimated_Procedures__c.fields.ICT_CODE__c.isCreateable()){newEstimatedProcedure.ICT_CODE__c = mapofProcedure.containsKey('ElixirSuite__CPT_HCPCS_Code__c') ? String.valueOf(mapofProcedure.get('ElixirSuite__CPT_HCPCS_Code__c')) : '';}
            if(Schema.sObjectType.Estimated_Procedures__c.fields.Procedure_Name__c.isCreateable()){newEstimatedProcedure.Procedure_Name__c = mapofProcedure.containsKey('Name')?  String.valueOf(mapofProcedure.get('Name')) : '';}
            if(Schema.sObjectType.Estimated_Procedures__c.fields.Unit__c.isCreateable()){newEstimatedProcedure.Unit__c =  mapofProcedure.containsKey('Unit')? String.valueOf((mapofProcedure.get('Unit'))) : '';}
            if(Schema.sObjectType.Estimated_Procedures__c.fields.Contracted_Rate__c.isCreateable()){newEstimatedProcedure.Contracted_Rate__c = mapofProcedure.containsKey('cPrice')?  (Decimal)(mapofProcedure.get('cPrice')) : 0;}
            if(Schema.sObjectType.Estimated_Procedures__c.fields.Total_Contracted_Price__c.isCreateable()){newEstimatedProcedure.Total_Contracted_Price__c = mapofProcedure.containsKey('totalContractedPrice')? Decimal.valueOf((String) mapofProcedure.get('totalContractedPrice')): 0;}
            
            if(Schema.sObjectType.Estimated_Procedures__c.isCreateable()){estimatedProcRecordsToInsert.add(newEstimatedProcedure);}
            System.debug('estimated record2 '+estimatedProcRecordsToInsert);
        }
        if(estimatedProcRecordsToInsert.size()>0)
        {
            try{
            if(Schema.sObjectType.Estimated_Procedures__c.isCreateable()){insert estimatedProcRecordsToInsert;}
            }
            catch(Exception e){
                ExceptionLog.logError(e);
            }
        }
    }
    
  /* 
    @AuraEnabled 
    public static list<Account> employerList(String searchKeyWord ){
        String searchKey = '%' + searchKeyWord + '%';
        List <Account> returnList = new List <Account> ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from Account where Name LIKE: searchKey limit 149';
        List <Account> lstOfRecords = Database.query(sQuery);
        return lstOfRecords;
    }*/
    
    @AuraEnabled 
    public static list<Account> employerList(String searchKeyWord ){
        String searchKey = '%' + searchKeyWord + '%';
        List <Account> returnList = new List <Account> ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        List <Account> lstOfRecords = [Select Id, Name from Account where Name LIKE: searchKey limit 999];
                return lstOfRecords;
    }

    @AuraEnabled 
    public static void updateUseStatusForCOCEstimateSingleRecord(String estimateID,Boolean receivedValue){
        List<Estimates__c> toUpdateRecord = new List<Estimates__c>();
        if(Schema.SObjectType.Estimates__c.fields.In_Use__c.isAccessible()
          && Schema.SObjectType.Estimates__c.fields.Id.isAccessible()){
            toUpdateRecord = [SELECT ID,In_Use__c FROM Estimates__c WHERE ID = : estimateID WITH SECURITY_ENFORCED LIMIT 1];
        }
        if(!toUpdateRecord.isEmpty())
        {
            if(Schema.SObjectType.Estimates__c.fields.In_Use__c.isUpdateable()){
                toUpdateRecord[0].In_Use__c = receivedValue;
            }
            try{
            
                if(Schema.sObjectType.Estimates__c.isUpdateable()){
                    update toUpdateRecord;
                }
            }catch(Exception e){
                ExceptionLog.logError(e);   
           }
            
        }
    }
}