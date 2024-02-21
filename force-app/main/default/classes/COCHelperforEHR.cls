public with sharing class COCHelperforEHR{
     @AuraEnabled 
    public static  ElixirSuite__Procedure__c[] procedureList(String searchKeyWord,String codeCategory,List<String> alreadyExistingProcedures){
        String searchKey = '%' + searchKeyWord + '%';
        Id devRecordTypeId;
        if(codeCategory == 'Procedures'){
            devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();    
        }
        else if(codeCategory == 'Labs'){
            devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Lab_Test').getRecordTypeId();
        }
           
        ElixirSuite__Procedure__c[] recordLst = [SELECT ID,Name,ElixirSuite__Code_Description__c FROM ElixirSuite__Procedure__c 
                                                 where (Name LIKE: searchKey) 
                                                 AND RecordTypeId = : devRecordTypeId 
                                                 AND ElixirSuite__Active__c=true 
                                                 AND id not in : alreadyExistingProcedures 
                                                 WITH SECURITY_ENFORCED];
        return recordLst;
    }
    
    @AuraEnabled
    public static parentWrapperForCOC parentInitFetchDataForCOC(String accountId, String vobRecId){
        Map<String, String> benefitDescriptionOption = new Map<String, String>();
        Map<String, String> benefitLevelOption = new Map<String, String>();
        Set<String> providerCodeSet = new Set<String>();
        parentWrapperForCOC wrpr = new parentWrapperForCOC();
        Id tempProcRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
        Id labRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Lab_Test').getRecordTypeId();
        List<Procedure__c> availableProcedures = [SELECT ID,
                                                  Name,
                                                  ElixirSuite__Code_Description__c,
                                                  CPT_HCPCS_Code__c,
                                                  Days_Units__c,
                                                  CreatedDate
                                                  from Procedure__c 
                                                  WHERE Account__c= NULL 
                                                  AND RecordTypeId =: tempProcRecordTypeId
                                                  AND RecordTypeId =: labRecordTypeId
                                                  WITH SECURITY_ENFORCED
                                                  Order By CreatedDate asc 
                                                  limit 49999]; 
        List<VOB__c> insuranceDetails = [SELECT Id,Account__r.Name,Account__r.ElixirSuite__DOB__c, toLabel(Account__r.Gender__c),PatientFirstName__c,PatientLastName__c,
                                         Patient_Birth_Date__c,Gender__c,
                                         Type__c,
                                         Out_of_Net_Co_Payment__c,
                                         In_Net_Deductible_Remaining__c,
                                         VOB_Verification_Status__c,
                                         Plan_Sponsor__c,
                                         Out_of_Net_Co_Insurance__c,
                                         Payer_Name__c,Payer__c,Account__c,ElixirSuite__Generate_Claim_on__c
                                         from VOB__c 
                                         where Account__c =:accountId 
                                         AND Elixirsuite__Status__c=:'Active' 
                                         AND Set_Default_VOB__c = 'Yes'
                                         AND ElixirSuite__Type__c ='Primary'
                                         WITH SECURITY_ENFORCED
                                         ORDER BY LastModifiedDate DESC limit 1];

        List<Payor__c> relatedPayer = new List<Payor__c>();
		List<ElixirSuite__Provider__c> providerList = new List<ElixirSuite__Provider__c>();        
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
            	providerList = [Select id,name, ElixirSuite__Provider_Code__c 
                                from ElixirSuite__Provider__c 
                                WHERE ElixirSuite__Account__c =:accountId
                                WITH SECURITY_ENFORCED
                                ORDER BY LastModifiedDate DESC LIMIT 1]; 
               
        }
        Set<String> payerCode = new Set<String>();
        if(relatedPayer.size() >0 && relatedPayer != null){
            for(Payor__c pay : relatedPayer){
            	payerCode.add(pay.Payer_Code__c);
        	}
        }
        
        if(providerList.size() >0 && providerList != null){
            for(ElixirSuite__Provider__c providerRec : providerList) {
                if(providerRec.ElixirSuite__Provider_Code__c != null) {
                    providerCodeSet.add(providerRec.ElixirSuite__Provider_Code__c);
                }
            }
        }
        List<ElixirSuite__Provider__c> providerTemplateList = new List<ElixirSuite__Provider__c>(); // we get the template provider record for the same npi/provider code

            if(providerCodeSet.size() > 0) {
                providerTemplateList = [Select id,name,ElixirSuite__Provider_Code__c 
                                        From ElixirSuite__Provider__c 
                                        WHERE ElixirSuite__Account__c = null
                                        AND ElixirSuite__Provider_Code__c IN :providerCodeSet
                                        WITH SECURITY_ENFORCED];
            }

        List<Contracted_Price__c> cPrice = new List<Contracted_Price__c>();
        List<ElixirSuite__Actual_Price__c> aPrice = new List<ElixirSuite__Actual_Price__c>();
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
                       where payer__r.Payer_Code__c IN : payerCode
                       WITH SECURITY_ENFORCED];
        aPrice = [SELECT Id, CreatedDate, ElixirSuite__Procedure__c,
                           ElixirSuite__Provider__c, ElixirSuite__Pricing_Effective_End_Date__c, 
                           ElixirSuite__Pricing_Effective_Start_Date__c, ElixirSuite__List_Price__c, 
                           ElixirSuite__Actual_Price_After_Discount__c, ElixirSuite__Actual_Discount_Applied__c, 
                           ElixirSuite__Discount_Type__c, ElixirSuite__Discount_Percentage__c, 
                           ElixirSuite__Discount_Amount__c
                           FROM ElixirSuite__Actual_Price__c
                           WHERE ElixirSuite__Provider__c IN : providerTemplateList
                           WITH SECURITY_ENFORCED];

       
        
        Map<Id, VOB__c> insuranceDetailsAllocated = new Map<id, VOB__c>([SELECT ID,
                                                                         Out_of_Net_Co_Payment__c,
                                                                         In_Net_Deductible_Remaining__c,
                                                                         VOB_Verification_Status__c,
                                                                         Plan_Sponsor__c,
                                                                         Out_of_Net_Co_Insurance__c
                                                                         from VOB__c 
                                                                         where Account__c =:accountId AND Id =: vobRecId 
                                                                         AND Elixirsuite__Status__c=:'Active' 
                                                                         AND Set_Default_VOB__c = 'Yes'
                                                                        // AND ElixirSuite__Type__c ='Primary'
                                                                         WITH SECURITY_ENFORCED
                                                                         ORDER BY LastModifiedDate DESC limit 1]);
        
        List<Result__c> vobResult = new List<Result__c>();
        
        Map<Id, List<Result__c>> vobIdToResultMap = new Map<Id, List<Result__c>>();
        
        if(insuranceDetailsAllocated.size() > 0) {
            
              vobResult = [SELECT Id, ElixirSuite__Deductible_Family_In_Network__c,ElixirSuite__Deductible_Individual_In_Network__c,ElixirSuite__Deductible_Rem_Fam_In_Network__c,
                           CreatedDate,ElixirSuite__Deductible_Rem_Ind_In_Network__c,ElixirSuite__OOP_Family_In_Network__c,ElixirSuite__OOP_Individual_In_Network__c,
                           VOB__c, ElixirSuite__OOP_Rem_Fam_In_Network__c,ElixirSuite__OOP_Rem_Ind_In_Network__c,ElixirSuite__Deductible_Family_Out_Network__c,
                           Deduc_inNtwk_Clientperc__c, ElixirSuite__Deductible_Individual_Out_Network__c,ElixirSuite__Deductible_Rem_Fam_Out_Network__c,ElixirSuite__Deductible_Rem_Ind_Out_Network__c,
                           Payer_Name__c, ElixirSuite__OOP_Family_Out_Network__c,ElixirSuite__OOP_Individual_Out_Network__c,ElixirSuite__OOP_Rem_Fam_Out_Network__c,ElixirSuite__OOP_Rem_Ind_Out_Network__c,
                           Co_Insurance_Provider_Percent__c,ElixirSuite__Co_insurance_Sub_Abuse_In_Net__c,ElixirSuite__Co_insurance_Sub_Abuse_Inpatient_In_Net__c,
                           in_network_total__c,ElixirSuite__Co_insurance_Sub_Abuse_Outpatient_In_Net__c,ElixirSuite__Co_insurance_Sub_Abuse_Out_Net__c,
                           In_Net_Co_Payment__c,ElixirSuite__Co_insurance_Sub_Abuse_Inpatient_Out_Net__c,ElixirSuite__Co_insurance_Sub_Abuse_Outpatient_Ou_Net__c,
                           out_of_network_outOfPocket_total__c,Deductible_Individual_Out_Plan_Network__c,Co_Insurance_Fam_In_Network__c	,Co_Insurance_Fam_Out_Of_Network__c,
                           Insurance_Type__c,Co_Insurance_Ind_In_Network__c, Co_Insurance_Ind_Out_Of_Network__c
                           FROM Result__c 
                           where VOB__c IN :insuranceDetailsAllocated.keySet() 
                           WITH SECURITY_ENFORCED
                           order by createddate desc limit 1] ;
        }
       
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
                        resultLatestRec = resultRec;
                    }
                }
            }
            
            latestVobResult.add(resultLatestRec);
        }
        
        for(Result__c resRec : latestVobResult) {
            latestVobResultSet.add(resRec.Id);
        }
        
        List<Result__c> sortedVobResult = [SELECT id,ElixirSuite__Deductible_Family_In_Network__c,ElixirSuite__Deductible_Individual_In_Network__c,ElixirSuite__Deductible_Rem_Fam_In_Network__c,
                                           CreatedDate,ElixirSuite__Deductible_Rem_Ind_In_Network__c,ElixirSuite__OOP_Family_In_Network__c,ElixirSuite__OOP_Individual_In_Network__c,
                                           VOB__c, ElixirSuite__OOP_Rem_Fam_In_Network__c,ElixirSuite__OOP_Rem_Ind_In_Network__c,ElixirSuite__Deductible_Family_Out_Network__c,
                                           Deduc_inNtwk_Clientperc__c, ElixirSuite__Deductible_Individual_Out_Network__c,ElixirSuite__Deductible_Rem_Fam_Out_Network__c,ElixirSuite__Deductible_Rem_Ind_Out_Network__c,
                                           Payer_Name__c, ElixirSuite__OOP_Family_Out_Network__c,ElixirSuite__OOP_Individual_Out_Network__c,ElixirSuite__OOP_Rem_Fam_Out_Network__c,ElixirSuite__OOP_Rem_Ind_Out_Network__c,
                                           Co_Insurance_Provider_Percent__c,ElixirSuite__Co_insurance_Sub_Abuse_In_Net__c,ElixirSuite__Co_insurance_Sub_Abuse_Inpatient_In_Net__c,
                                           in_network_total__c,ElixirSuite__Co_insurance_Sub_Abuse_Outpatient_In_Net__c,ElixirSuite__Co_insurance_Sub_Abuse_Out_Net__c,
                                           In_Net_Co_Payment__c,ElixirSuite__Co_insurance_Sub_Abuse_Inpatient_Out_Net__c,ElixirSuite__Co_insurance_Sub_Abuse_Outpatient_Ou_Net__c,
                                           out_of_network_outOfPocket_total__c,Deductible_Individual_Out_Plan_Network__c,Co_Insurance_Fam_In_Network__c	,Co_Insurance_Fam_Out_Of_Network__c,
                                           Insurance_Type__c,Co_Insurance_Ind_In_Network__c, Co_Insurance_Ind_Out_Of_Network__c
                                           FROM Result__c 
                                           where Id IN :latestVobResultSet
                                           WITH SECURITY_ENFORCED
                                           Order by createddate desc limit 1] ;
        
        Schema.DescribeFieldResult fieldResult = ElixirSuite__VOB__c.ElixirSuite__Benefit__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            benefitDescriptionOption.put(p.getValue(), p.getLabel());
        }
        // get benefit level codes
        Schema.DescribeFieldResult fieldResult1 = ElixirSuite__VOB__c.ElixirSuite__Patient_Relationship_With_Insured__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues1 = fieldResult1.getPicklistValues();
        for (Schema.PicklistEntry p1: pValues1) {
            
            benefitLevelOption.put(p1.getValue(), p1.getLabel());
        }
        wrpr.acctDetailsFromVOB = insuranceDetails;
        wrpr.allProcedures = availableProcedures;
        wrpr.insuranceDetails = insuranceDetails;
        wrpr.vobResult = sortedVobResult;
        wrpr.contractPrice=cPrice;
        wrpr.benefitDescOptions = benefitDescriptionOption ;
        wrpr.benefitLevelOptions = benefitLevelOption ; 
        wrpr.actualPrice = aPrice;
        return wrpr;
    }
    
    @AuraEnabled
    public static  List<Procedure__c> getProceduresTemplates(List<String> alreadyExistingProcedures){
        List<Procedure__c> availableProcedures = new  List<Procedure__c>();
        Id tempProcRecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
        availableProcedures = [SELECT ID,Name,CPT_HCPCS_Code__c,Days_Units__c from Procedure__c  
                                WHERE Account__c= NULL AND id not in : alreadyExistingProcedures 
                               AND RecordTypeId =: tempProcRecordTypeId
                                WITH SECURITY_ENFORCED limit 49999];  
        return availableProcedures;
    }
    @AuraEnabled
    public static parentWrapperForCOC fetchIndividualRecordDetailsForView(String cocRecordId){
        Estimates__c singleRecordQueried = [SELECT Account__c,In_Use__c,ElixirSuite__Insurance_Name__c,Procedure_Total__c,Co_Insurance__c,Co_Pay__c,CreatedById,CreatedDate,Deductible__c,Id,Insurer_Responsibility__c,IsDeleted,
                                            LastModifiedById,LastModifiedDate,Name,OOP_Max__c,OwnerId,ElixirSuite__Benefit_Description__c,
                                            ElixirSuite__Insurance_Type__c,ElixirSuite__Benefit_level__c ,ElixirSuite__Type_of_Insurance__c,
                                            Patient_responsibility__c,Status__c FROM Estimates__c WHERE ID=:cocRecordId WITH SECURITY_ENFORCED LIMIT 1];
        List<Estimated_Procedures__c> relatedProcedures = [SELECT Contracted_Rate__c,CreatedById,CreatedDate,Estimates__c,File_Content__c,ICT_CODE__c,Id,IsDeleted,ElixirSuite__Code_Description__c,
                                                           LastModifiedById,LastModifiedDate,Name,OwnerId,Procedure_Name__c,Total_Contracted_Price__c,ElixirSuite__Unit__c
                                                           FROM Estimated_Procedures__c WHERE Estimates__c  = : cocRecordId WITH SECURITY_ENFORCED];
        Estimates__c patientDetails = [SELECT ID,Account__r.Name,Account__r.ElixirSuite__DOB__c,toLabel(Account__r.Gender__c)
                                       from Estimates__c where ID =:cocRecordId WITH SECURITY_ENFORCED LIMIT 1];
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
        @AuraEnabled public List<Contracted_Price__c> contractPrice;
        @AuraEnabled public Map<String, String> benefitDescOptions;
        @AuraEnabled public Map<String, String> benefitLevelOptions;
        @AuraEnabled public List<ElixirSuite__Actual_Price__c> actualPrice;
    }
    @AuraEnabled
    public static  void saveCOC(String accountId,
                                Decimal patientResponsibility,
                                Decimal insuranceResposibility,
                                Decimal procedureTotal,
                                String insuranceDetails,
                                String proceduresToSave,
                                Boolean receivedValue, 
                                Integer copay,Integer coIns,Integer dedct,Integer oopMaximn, String benDescription, String benLevel, String insValue, String selectedPayer){

                                    
                                    Map<String, Object> mainJsonForInsurance =(Map<String, Object>) JSON.deserializeUntyped(insuranceDetails);
                                    List<Object> listOfInsuranceRecords = (List<Object>) mainJsonForInsurance.get('keysToSave');
                                    List<Estimated_Procedures__c> estimatedProcRecordsToInsert = new List<Estimated_Procedures__c>();
                                    Map<String, Object> mainJsonForProcedures =(Map<String, Object>) JSON.deserializeUntyped(proceduresToSave);
                                    List<Object> listOfProcedure = (List<Object>) mainJsonForProcedures.get('keysToSaveForPrcedures');
                                    List<Estimates__c> estimateList = new List<Estimates__c>();
                                    if(listOfInsuranceRecords.size()>0){
                                    for(Object insuranceRec : listOfInsuranceRecords) {
                                        
                                        Map<String, Object> mapOfInsurance = (Map<String, Object>) insuranceRec;
                                        Estimates__c newEstimate = new Estimates__c();              
                                        newEstimate.Account__c = accountId;
                                        newEstimate.In_Use__c = receivedValue;
                                        newEstimate.Co_Insurance__c = Decimal.valueOf(coIns) ;
                                        newEstimate.Co_Pay__c = Decimal.valueOf(copay);
                                        newEstimate.Deductible__c = Decimal.valueOf(dedct);
                                        newEstimate.Procedure_Total__c = procedureTotal;
                                        newEstimate.OOP_Max__c = Decimal.valueOf(oopMaximn);
                                        newEstimate.Insurance_Name__c = selectedPayer;
                                        newEstimate.Patient_responsibility__c = patientResponsibility;
                                        newEstimate.Insurer_Responsibility__c = insuranceResposibility;
                                        newEstimate.ElixirSuite__Benefit_Description__c = benDescription;
                                        newEstimate.ElixirSuite__Benefit_level__c = benLevel;
                                        newEstimate.ElixirSuite__Insurance_Type__c = insValue;
                                        newEstimate.ElixirSuite__Type_of_Insurance__c = String.valueOf(mapOfInsurance.get('ElixirSuite__Insurance_Type__c'));
                                        estimateList.add(newEstimate);
                                    }
                                    }else if(selectedPayer == 'Private Pay'){
                                         Estimates__c newEstimate = new Estimates__c();              
                                        newEstimate.Account__c = accountId;
                                        newEstimate.Procedure_Total__c = procedureTotal;
                                        newEstimate.Insurance_Name__c = selectedPayer;
                                        newEstimate.Patient_responsibility__c = patientResponsibility;
                                        newEstimate.Insurer_Responsibility__c = insuranceResposibility;
                                        estimateList.add(newEstimate);
                                    }
                                    String estimateId ;
                                    if(estimateList.size()==1)
                                    {
                                        if(Schema.sObjectType.Estimates__c.fields.Account__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.In_Use__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Co_Insurance__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Co_Pay__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Deductible__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Procedure_Total__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.OOP_Max__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Insurance_Name__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Patient_responsibility__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Insurer_Responsibility__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.ElixirSuite__Benefit_Description__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.ElixirSuite__Benefit_level__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.ElixirSuite__Type_of_Insurance__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.ElixirSuite__Insurance_Type__c.isCreateable()){
                                        insert estimateList; 
                                        }
                                        
                                    }
                                    else if(estimateList.size()>1)
                                    {
                                        if(Schema.sObjectType.Estimates__c.fields.Account__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.In_Use__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Co_Insurance__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Co_Pay__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Deductible__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Procedure_Total__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.OOP_Max__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Insurance_Name__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Patient_responsibility__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.Insurer_Responsibility__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.ElixirSuite__Benefit_Description__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.ElixirSuite__Benefit_level__c.isCreateable() &&
                                        Schema.sObjectType.Estimates__c.fields.ElixirSuite__Insurance_Type__c.isCreateable()){
                                        insert estimateList[0];
                                        }
                                    }
                                    estimateId = estimateList[0].Id;                  
                                    for(Object procedureRec : listOfProcedure){
                                        Map<String, Object> mapofProcedure = (Map<String, Object>) procedureRec;
                                        Estimated_Procedures__c newEstimatedProcedure = new Estimated_Procedures__c();              
                                        newEstimatedProcedure.Estimates__c = estimateId;
                                        newEstimatedProcedure.ElixirSuite__Code_Description__c = String.valueOf(mapofProcedure.get('ElixirSuite__Code_Description__c'));
                                        newEstimatedProcedure.Procedure_Name__c = String.valueOf(mapofProcedure.get('Name'));
                                        newEstimatedProcedure.Unit__c =  String.valueOf((mapofProcedure.get('Unit')));
                                        newEstimatedProcedure.Contracted_Rate__c =  (Decimal)(mapofProcedure.get('cPrice'));//ElixirSuite__Contracted_Price__c'));
                                        newEstimatedProcedure.Total_Contracted_Price__c = Decimal.valueOf((String) mapofProcedure.get('totalContractedPrice'));
                                        estimatedProcRecordsToInsert.add(newEstimatedProcedure);
                                    }
                                    if(Schema.sObjectType.Estimated_Procedures__c.fields.Estimates__c.isCreateable() &&
                                    Schema.sObjectType.Estimated_Procedures__c.fields.Estimates__c.isCreateable() &&
                                    Schema.sObjectType.Estimated_Procedures__c.fields.ICT_CODE__c.isCreateable() &&
                                    Schema.sObjectType.Estimated_Procedures__c.fields.Procedure_Name__c.isCreateable() &&
                                    Schema.sObjectType.Estimated_Procedures__c.fields.Estimates__c.isCreateable() &&
                                    Schema.sObjectType.Estimated_Procedures__c.fields.Unit__c.isCreateable() &&
                                    Schema.sObjectType.Estimated_Procedures__c.fields.Contracted_Rate__c.isCreateable() &&
                                    Schema.sObjectType.Estimated_Procedures__c.fields.Total_Contracted_Price__c.isCreateable()&&
                                    Schema.sObjectType.Estimated_Procedures__c.fields.ElixirSuite__Code_Description__c.isCreateable()){
                                        insert estimatedProcRecordsToInsert;
                                    }
                                }


    @AuraEnabled 
    public static list<Account> employerList(String searchKeyWord ){
        String searchKey = '%' + searchKeyWord + '%';
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        List <Account> lstOfRecords = [Select id, Name from Account where Name LIKE: searchKey WITH SECURITY_ENFORCED limit 999];
             return lstOfRecords;
    }
    
    @AuraEnabled 
    public static void updateUseStatusForCOCEstimateSingleRecord(String estimateID,Boolean receivedValue){
     Estimates__c toUpdateRecord = [SELECT Id,In_Use__c FROM Estimates__c WHERE Id= :estimateID WITH SECURITY_ENFORCED];
     toUpdateRecord.In_Use__c = receivedValue;
        if(Schema.sObjectType.Estimates__c.fields.In_Use__c.isUpdateable()){
            update toUpdateRecord;   
        }
    }
}