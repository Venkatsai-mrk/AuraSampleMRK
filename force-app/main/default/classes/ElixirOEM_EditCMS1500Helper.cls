public with sharing class ElixirOEM_EditCMS1500Helper {
    
    @AuraEnabled
    public static wrapper getAccountDetails(String claimrecordID) {
        Id patientId;
        ElixirSuite__Claim__c[] currentClaimInView = fetchClaimRecordDetails(claimrecordID); 
        if(currentClaimInView!=null && currentClaimInView.size()>0){
            patientId = currentClaimInView[0].Account__c;
        }
        
        Wrapper wrpr = new Wrapper();
        wrpr.currentViewClaimRecord = currentClaimInView;
        wrpr.relatedClaimLineItems = new List<ElixirSuite__Claim_Line_Items__c>();
        wrpr.relatedClaimLineItems = fetchClaimlLineItems(claimrecordID);
        Account accDetails = [SELECT Id, Name, ElixirSuite__Admit_Date__c,ElixirSuite__dischargeDateNew__c,CreatedDate, First_Name__c, Last_Name__c, Gender__c,ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,ShippingCountry
                              ,birthdate__c,ElixirSuite__Patient_s_Birth_Date__c,ElixirSuite__MRN_Number_New__c , BillingStreet, BillingCity, ElixirSuite__Account_Number__c,BillingState, BillingPostalCode,BillingCountry,Phone
                              FROM Account where Id =: patientId
                              WITH SECURITY_ENFORCED];
        system.debug('the patient data is' + accDetails);
        
        List<VOB__c> relatedData = new List<VOB__c>();
        relatedData = [SELECT Account__c,ElixirSuite__Member_Id__c,ElixirSuite__Insurance_Type__c,ElixirSuite__Insurance_Providers__c,ElixirSuite__Patient_Relationship_With_Insured__c,ElixirSuite__Insured_Id_Number__c
                       ,ElixirSuite__Insured_First_Name__c,ElixirSuite__Auto_Accident__c,ElixirSuite__Insured_Last_Name__c,ElixirSuite__Insured_Middle_Name__c,ElixirSuite__Employment__c,ElixirSuite__Is_there_another_Health_Benefit_Plan__c,
                       ElixirSuite__Other_Accident__c,Name,ElixirSuite__Insured_Address__c,ElixirSuite__Insured_State__c,ElixirSuite__Insured_City__c,ElixirSuite__Insured_Zipcode__c
                       ,ElixirSuite__Other_Insured_Policy_Group_FECA_Number__c,ElixirSuite__Insured_Policy_Group_FECA_Number__c,ElixirSuite__Other_Insured_s_Name__c,ElixirSuite__OtherInsurancePlanName__c
                       FROM VOB__c WHERE Account__c =: accDetails.Id AND  status__c='Active' and type__c='Primary' 
                       WITH SECURITY_ENFORCED
                       ORDER BY CreatedDate DESC LIMIT 1]; 
        List<ElixirSuite__Result__c> relatedResult = new List<ElixirSuite__Result__c>();
        if(relatedData!=null && relatedData.size()>0){
            relatedResult  = [SELECT ID,ElixirSuite__Insurance_Plan__c FROM ElixirSuite__Result__c
                              WHERE VOB__c = : relatedData[0].Id 
                              WITH SECURITY_ENFORCED
                              ORDER BY CreatedDate DESC LIMIT 1];
        }
        // added by Jami for LX3-12318
        Elixir_Custom_Setting__c elixirCustom = Elixir_Custom_Setting__c.getOrgDefaults();
        if(elixirCustom != null && elixirCustom.ElixirSuite__Send_Claim_To_ClaimMd__c){
            wrpr.saveSendCustomSetting = elixirCustom.ElixirSuite__Send_Claim_To_ClaimMd__c;
        }else{
            wrpr.saveSendCustomSetting = false; 
        }
        wrpr.relatedResult = relatedResult;
        List<String> fields = new List<String>();
        fields.addAll((Claim__c.SObjectType.getDescribe().fields.getMap().keySet()));
        System.debug('the values are' + fields);
        
        system.debug('the patient data is' + relatedData);
        
        List<String> picklistValues = new List<String>();
        List<String> picklistValuesAcc = new List<String>();
        
        Map<String,List<String>> mapOfNameToField = new  Map<String,List<String>>();
        Map<String, Map<String, String>> mapOfNameToFieldInsType = new Map<String, Map<String, String>>();
        Map<String,List<String>> mapOfNameToFieldAcc = new  Map<String,List<String>>();
        
        Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> object_fields_map = global_describe.get('ElixirSuite__VOB__c').getDescribe().fields.getMap();
        
        Map<String, Schema.SObjectField> object_fields_mapAcc = global_describe.get('Account').getDescribe().fields.getMap();
        
         for(Schema.SObjectField sfield : object_fields_map.values()){
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                 Map<String, String> labelToApiMap = new Map<String, String>();
                if(String.valueof(dfield.getType())=='PICKLIST'){
                    picklistValues = new List<String>();
                    for(Schema.PicklistEntry pickListVal : dfield.getPicklistValues()){
                        picklistValues.add(String.valueOf(pickListVal.getLabel()));
                         String label = String.valueOf(pickListVal.getLabel());
                        String apiValue = String.valueOf(pickListVal.getValue());
                        labelToApiMap.put(label, apiValue);
                    }             
                    mapOfNameToField.put(dfield.getName(),picklistValues);
                     mapOfNameToFieldInsType.put(dfield.getName(), labelToApiMap);
                }
            }
        
        for(Schema.SObjectField sfield : object_fields_mapAcc.values()){
            Schema.DescribeFieldResult dfield = sfield.getDescribe();
            if(String.valueof(dfield.getType())=='PICKLIST'){
                picklistValues = new List<String>();
                for(Schema.PicklistEntry pickListVal : dfield.getPicklistValues()){
                    picklistValuesAcc.add(String.valueOf(pickListVal.getLabel()));
                }             
                mapOfNameToFieldAcc.put(dfield.getName(),picklistValuesAcc);
            }
        }
        if(relatedData.isEmpty()){
            wrpr.isVobPresent = false;
            VOB__c emptyObj = new VOB__c();
            relatedData.add(emptyObj);
        }
        
        wrpr.mapOfNameToField = mapOfNameToField;
        wrpr.mapOfNameToFieldAcc = mapOfNameToFieldAcc;
        wrpr.mapOfNameToFieldInsType = mapOfNameToFieldInsType;
        wrpr.accDetails = accDetails;
        wrpr.vobData = relatedData ;
        wrpr.claimFields = fields ;
        wrpr.acctRelatedProcData = fetchProcedureData(patientId); // xxx
        wrpr.patientDecision = fetchPatientDecision(); // xxx
        wrpr.allPickListPlaceOfService_ValuesIntoList = getPickListValuesIntoList(); 
        return wrpr;
    }
    public static List<ElixirSuite__Procedure__c> fetchProcedureData(String acctId){
        return [SELECT ID,Name,ElixirSuite__Modifier1__c,ElixirSuite__Place_Of_Service_Picklist__c,ElixirSuite__CPT_HCPCS_Code__c,ElixirSuite__Diagnosis_Pointer__c,ElixirSuite__Days_Units__c,ElixirSuite__Charges__c,
                ElixirSuite__From_Date_of_Service__c,ElixirSuite__To_Date_of_Service__c,ElixirSuite__Place_of_Service_Code__c,ElixirSuite__Rendering_Provider_Non_NPI__c,
                ElixirSuite__ID_Qualifier__c,ElixirSuite__Rendering_Provider_NPI__c,ElixirSuite__ICD_Codes__r.Name,
                ElixirSuite__ICD_Codes__c,
                ElixirSuite__Modifier2__c,ElixirSuite__Modifier3__c,ElixirSuite__Modifier4__c
                FROM ElixirSuite__Procedure__c WHERE ElixirSuite__Account__c = : acctId
                WITH SECURITY_ENFORCED]; 
    }
    @AuraEnabled
    public static  PointerHandleWrapper fetchProcedureForSpecifiedDates(Date fromProcedure,Date toProcedure,String acctId,
                                                                        List<String> existingProcIDs,List<String> ProcIDs,
                                                                        String fetchProc)
    {
        PointerHandleWrapper wrprReturn = new PointerHandleWrapper();
        try{
            String procId = '';
            sTRING providerID;
            String PType = 'Insurance Payment';
            Boolean claimType = false;
            fromProcedure =  fromProcedure.addDays(-1);
            toProcedure = toProcedure.addDays(1);
            String recTypeID = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
            String additionFieldsPrefix =' WHERE ElixirSuite__Account__c = : acctId AND ID NOT IN : existingProcIDs '+'AND ElixirSuite__Procedure__c NOT IN : ProcIDs ' +
                'AND ( ElixirSuite__Procedure__r.ElixirSuite__From_Date_of_Service__c >=: fromProcedure AND ElixirSuite__Procedure__r.ElixirSuite__To_Date_of_Service__c <=: toProcedure AND ElixirSuite__Procedure__r.RecordTypeId =: recTypeID AND ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c =:PType AND ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c =false AND ElixirSuite__Procedure__r.ElixirSuite__Ready_for_Billing__c =true) ';
            String otherFieldsAddition = ' ,ElixirSuite__Procedure__r.ElixirSuite__Provider__c,ElixirSuite__Procedure__r.ElixirSuite__Charges__c,ElixirSuite__Procedure__r.ElixirSuite__Modifier1__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Modifier2__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Modifier3__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Modifier4__r.Name,ElixirSuite__Procedure__r.ElixirSuite__ID_Qualifier__c, '+
                ' ElixirSuite__Procedure__r.ElixirSuite__Days_Units__c,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Place_Of_Service_Picklist__c,ElixirSuite__Procedure__r.ElixirSuite__CPT_HCPCS_Code__c ,ElixirSuite__Procedure__r.ElixirSuite__Status__c,ElixirSuite__Procedure__r.ElixirSuite__Ready_for_Billing__c,ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c'; 
            String procedureQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__Procedure_Diagnosis__c',otherFieldsAddition,additionFieldsPrefix+' order by CreatedDate ASC ');
            ElixirOEM_TimelineHelper.mDebugUntruncated(procedureQuery);
            wrprReturn.fetchProcedureForSpecifiedDates =  Database.query(procedureQuery);
            wrprReturn.procedureCharge = wrprReturn.fetchProcedureForSpecifiedDates[0].ElixirSuite__Procedure__r.ElixirSuite__Charges__c;
            if(wrprReturn.fetchProcedureForSpecifiedDates!=null && wrprReturn.fetchProcedureForSpecifiedDates.size()>0){
                procId = wrprReturn.fetchProcedureForSpecifiedDates[0].ElixirSuite__Procedure__c;
                providerID = wrprReturn.fetchProcedureForSpecifiedDates[0].ElixirSuite__Procedure__r.ElixirSuite__Provider__c;
            }
            ElixirSuite__Procedure_Diagnosis__c[] junctionDataLst =  [SELECT ID,ElixirSuite__ICD_Codes__c FROM ElixirSuite__Procedure_Diagnosis__c WHERE ElixirSuite__Procedure__c = : procId WITH SECURITY_ENFORCED];
            Set<Id> icdIDSet = new Set<Id>();
            for(ElixirSuite__Procedure_Diagnosis__c pd : junctionDataLst){
                icdIDSet.add(pd.ElixirSuite__ICD_Codes__c);
            }                                                                    
            wrprReturn.relatedICDCodes = fetchRelatedICDCode(icdIDSet);
            
            if(String.isNotBlank(providerID)){
                wrprReturn.relatedRenderingProvider = [SELECT ID,Name,ElixirSuite__ID_Qualifier__c FROM ElixirSuite__Provider__c
                                                       WHERE ID = :providerID  WITH SECURITY_ENFORCED];
            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrprReturn;
    }
    
    public class PointerHandleWrapper {
        @AuraEnabled public List<ElixirSuite__Procedure_Diagnosis__c> fetchProcedureForSpecifiedDates; 
        //@AuraEnabled public List<ElixirSuite__Procedure__c> fetchProcedureForSpecifiedDates;
        @AuraEnabled  public List<ElixirSuite__ICD_Codes__c> relatedICDCodes ;
        @AuraEnabled  public List<ElixirSuite__Provider__c> relatedRenderingProvider ;
        @AuraEnabled public Decimal procedureCharge ;
    }
    public static list<ElixirSuite__ICD_Codes__c> fetchRelatedICDCode(Set<Id> recordIdLst){
        String additionFieldsPrefix = ' where Id IN : recordIdLst';
        String otherFieldsAddition = ''; 
        String icdCodeQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__ICD_Codes__c',otherFieldsAddition,additionFieldsPrefix+'');
        //  ElixirOEM_TimelineHelper.mDebugUntruncated(icdCodeQuery);
        return Database.query(icdCodeQuery);
        
    }
    // [Select o.CreatedDate, o.Id, o.LastModifiedDate  from Opportunity o where   o.CreatedDate >: myDate and o.CreatedDate <:  myDate2 order by  o.LastModifiedDate] ;
    @AuraEnabled
    public static wrapper getDataForRangeApex(String fromDate, String toDate, String recordVal , String transId){
        system.debug('new val' + fromDate + '' + toDate + '' + recordVal + '' + transId);
        Date fDate = Date.valueOf(fromDate);
        Date tDate = Date.valueOf(toDate);
        System.debug('### fDate : ' + fDate + '----### tDate  : ' + tDate);
        
        Map<String,VOB__c> map_vobData = new Map<String,VOB__c>();
        
        for(VOB__c objVob : [Select Id,Payer__c,Account__c from VOB__c where Account__c =:recordVal WITH SECURITY_ENFORCED])
        {
            map_vobData.put(objVob.Payer__c,objVob);
        }
        //String  payerId = [Select Id,Payer__c,Account__c from VOB__c where Account__c =:recordVal ].Payer__c;
        //patient procedures between those dates
        List<Procedure__c> relatedProc = [SELECT Id, Name, CreatedDate,Claim__c,Days_Units__c, ElixirSuite__Billable__c,From_Date__c, ElixirSuite__Is_Billable__c,ElixirSuite__Generate_Claim__c,To_Date__c, CPT_HCPCS_Code__c, Account__c, Code_Description__c 
                                          FROM Procedure__c
                                          WHERE From_Date__c >= :fDate AND To_Date__c <= :tDate AND Account__c=: recordVal AND Claim__c = null AND ElixirSuite__Is_Billable__c = true AND ElixirSuite__Generate_Claim__c=true 
                                          WITH SECURITY_ENFORCED];
        system.debug('the procedures are ' + relatedProc);
        //patient payer from his details
        List<Payor__c> relatedPayer = [SELECT Address__c, Id, Name, CreatedDate,Payer_Code__c, PayerType__c, State__c, City__c, Zipcode__c, Phone_Number__c, Procedure__c 
                                       FROM Payor__c WHERE Id IN: map_vobData.keySet() 
                                       WITH SECURITY_ENFORCED
                                       order by lastmodifieddate desc];
        
        Set<String> payerCode = new Set<String>();
        for(Payor__c pay : relatedPayer){
            payerCode.add(pay.Payer_Code__c);
        }
        
        system.debug('2nd is ' + relatedPayer);
        system.debug('#### payerCode : ' + payerCode);
        //get patient's provider info
        List<Provider__c> relatedProvider = [SELECT Id, Name, CreatedDate, 	Account__c,	Provider_Code__c FROM Provider__c 
                                             where 	Account__c=: recordVal 
                                             WITH SECURITY_ENFORCED
                                             order by lastmodifieddate desc];
        system.debug('3rd is ' + relatedProvider);
        
        Set<String> providerCode = new Set<String>();
        for(Provider__c pro : relatedProvider){
            providerCode.add(pro.Provider_Code__c);
        }
        system.debug('#### providerCode : ' + providerCode);
        List<Actual_Price__c> ActualListPrice = [SELECT id,Name , List_Price__c,Procedure__c,Provider__c,Procedure__r.Name, Procedure__r.CPT_HCPCS_Code__c,Provider__r.Provider_Code__c
                                                 from Actual_Price__c where Provider__r.Provider_Code__c IN : providerCode
                                                 WITH SECURITY_ENFORCED];
        system.debug('actual price ' + ActualListPrice);
        
        List<Contracted_Price__c> discountedPrice = [SELECT id,Name , Contracted_Amount__c,Procedure__c,Payer__c,Procedure__r.Name, Procedure__r.CPT_HCPCS_Code__c,payer__r.Payer_Code__c
                                                     from Contracted_Price__c where payer__r.Payer_Code__c IN : payerCode
                                                     WITH SECURITY_ENFORCED];
        system.debug('discounted price ' + discountedPrice);
        
        Map<String , Contracted_Price__c> newMap = new Map<String , Contracted_Price__c>();
        
        for (Contracted_Price__c pli : discountedPrice ){
            // if(newMap.containsKey(pli.Procedure__r.CPT_HCPCS_Code__c)) {
            newMap.put(pli.Procedure__r.CPT_HCPCS_Code__c ,pli );
            //  }
        }
        system.debug('map of contracted price' + newMap);        
        Map<String , Actual_Price__c> newMapForProvider = new Map<String , Actual_Price__c>();
        for (Actual_Price__c pliProvider : ActualListPrice ){
            newMapForProvider.put(pliProvider.Procedure__r.CPT_HCPCS_Code__c ,pliProvider );
        }
        
        system.debug('map of actual price' + newMapForProvider);
        wrapper obj = new wrapper();
        obj.provider = relatedProvider ;
        obj.payer = relatedPayer ;
        obj.procedure = relatedProc ;
        obj.codeandPricelist = newMap ;
        obj.codeandPricelistForProvider = newMapForProvider ;
        return obj;
    }
    
    @AuraEnabled
    public static void saveData(String jsonListData , String tabelListData , String recordVal ,String totalAmount , String transId,
                                String payorName,String dropDownOptions,String selectedClaimCodes,boolean sendToInsurance,List<String> ProcIDs){ // UPDATE CMS -1500 FORM
                                    
                                    Map<String,VOB__c> map_vobData = new Map<String,VOB__c>();
                                    
                                    for(VOB__c objVob : [Select Id,Payer__c,Account__c 
                                                         from VOB__c where Account__c =:recordVal WITH SECURITY_ENFORCED])
                                    {
                                        map_vobData.put(objVob.Payer__c,objVob);
                                    }
                                    
                                    List<Payor__c> relatedPayer = [SELECT Address__c, Id, Name, CreatedDate,Payer_Code__c, PayerType__c, State__c, City__c, Zipcode__c, Phone_Number__c, Procedure__c 
                                                                   FROM Payor__c
                                                                   WHERE Id IN:map_vobData.keySet()
                                                                   WITH SECURITY_ENFORCED];
                                    
                                    Set<String> payerCode = new Set<String>();
                                    for(Payor__c pay : relatedPayer){
                                        payerCode.add(pay.Payer_Code__c);
                                    }
                                                            //get patient's provider info
                                                            List<Provider__c> relatedProvider = [SELECT Id, Name, CreatedDate, 	Account__c,	Provider_Code__c FROM Provider__c 
                                                                                                 where 	Account__c=: recordVal
                                                                                                 WITH SECURITY_ENFORCED];
                                    
                                    Set<String> providerCode = new Set<String>();
                                    for(Provider__c pro : relatedProvider){
                                        providerCode.add(pro.Provider_Code__c);
                                    }
                                    
                                    List<Actual_Price__c> ActualListPrice = [SELECT id,Name , List_Price__c,Procedure__c,Provider__c,Procedure__r.Name, Procedure__r.CPT_HCPCS_Code__c,Provider__r.Provider_Code__c
                                                                             from Actual_Price__c
                                                                             where Provider__r.Provider_Code__c IN : providerCode
                                                                             WITH SECURITY_ENFORCED];
                                    
                                    List<Contracted_Price__c> discountedPrice = [SELECT id,Name , Contracted_Amount__c,Procedure__c,Payer__c,Procedure__r.Name, Procedure__r.CPT_HCPCS_Code__c,payer__r.Payer_Code__c
                                                                                 from Contracted_Price__c where payer__r.Payer_Code__c IN : payerCode
                                                                                 WITH SECURITY_ENFORCED];
                                    
                                    
                                    Map<String , Contracted_Price__c> newMap = new Map<String , Contracted_Price__c>();
                                    
                                    for (Contracted_Price__c pli : discountedPrice ){
                                        // if(newMap.containsKey(pli.Procedure__r.CPT_HCPCS_Code__c)) {
                                        newMap.put(pli.Procedure__r.CPT_HCPCS_Code__c ,pli );
                                        //  }
                                    }
                                    Map<String , Actual_Price__c> newMapForProvider = new Map<String , Actual_Price__c>();
                                    for (Actual_Price__c pliProvider : ActualListPrice ){
                                        newMapForProvider.put(pliProvider.Procedure__r.CPT_HCPCS_Code__c ,pliProvider );
                                    }
                                    Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                    List<Object> obj_lstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                    List<Claim__c> claimData = new	List<Claim__c>();
                                    Boolean valTrue ,valTrue1 ,valTrue2,valTrue3 ;
                                    List<Claim_Line_Items__c> claimLineItemData = new List<Claim_Line_Items__c>(); //TO UPDATE
                                    List<Claim_Line_Items__c> claimLineItemData_ToInsert = new List<Claim_Line_Items__c>(); //TO INSERT
                                    if(jsonListData!=null && !String.isEmpty(jsonListData)){
                                        system.debug('the string is' + jsonListData);
                                        List<masterWrapper> rootJson = (List<masterWrapper>)JSON.deserialize(jsonListData, List<masterWrapper>.class);
                                        system.debug('the string is' + rootJson);
                                        if(rootJson != null & rootJson.size()>0){
                                            for(masterWrapper masterRec : rootJson){
                                                for(root rec : masterRec.Record){
                                                    system.debug('bj' + rec.dateOfCurrentIllness);                        
                                                    Claim__c newClaim = new	Claim__c(
                                                        Id = rec.id,
                                                        ElixirSuite__Claim_Code_Options__c = JSON.serialize(obj_lstOfDropDownOptions),
                                                        //  Account__c = recordVal,                           
                                                        Patient_Name__c = rec.patientName ,
                                                        Insured_s_Name__c = rec.insuredName ,
                                                        Patient_s_Address__c = rec.patientAddress,
Patient_Address_2__c = rec.patientAddress2 ,
                                                        Insured_Address_2__c = rec.insuredAddress2 ,
                                                        Patient_s_City__c = rec.patientCity ,
                                                        Patient_s_State__c = rec.patientState,
                                                        Patient_s_Phone__c = rec.patientPhone ,
                                                        Patient_Relationship_to_Insured__c = rec.relationWithInsured ,
                                                        Insured_Address__c = rec.insuredAddress , 
                                                        Insured_State__c = rec.insuredState ,
                                                        Insured_City__c = rec.insuredCity ,
                                                        Insured_Telephone__c = rec.insuredTelephone ,
                                                        Insured_s_ID_Number__c = rec.insuredIdNumber,
                                                        Other_Insured_s_Name__c = rec.otherInsuredName , 
                                                        Other_Insured_s_Policy_Group_Number__c = rec.otherInsuredPolicyNumber , 
                                                        Other_Insurance_Plan_Name__c = rec.otherInsurancePlanName , 
                                                        Insured_Policy__c = rec.insuredPolicyNumber , 
                                                        Other_Claim_Id__c = rec.otherClaimId , 
                                                        //  Claim_Codes__c = selectedClaimCodes,
                                                        Insurance_Plan_Name__c = rec.insurancePlanName , 
                                                        Claim_Status__c = 'Saved',
                                                        ElixirSuite__Billing_Provider_Tax_ID_Type__c = rec.federalSsnEsnPick,
                                                        Additional_Claim_Information__c = rec.additionalInfo,
                                                        Federal_Tax_Id_Number__c = String.valueOf(rec.federalTaxNumber) ,
                                                        Name_of_referring_provider_Other_sourc__c = rec.nameOfReferringProvider ,
                                                        Service_Facility_Location_Information__c = rec.serviceFacilityLocationInfo,
                                                        ElixirSuite__Service_Facility_Location_NPI__c = rec.serviceFacilityLocationInfoNPI,
                                                        ElixirSuite__Servic_Fcility_Loc_Informaton_OtherID__c = rec.serviceFacilityLocationInfoID,
                                                        ElixirSuite__Service_Facility_Loc_Address__c = rec.serviceFacilityLocationAddress,
                                                        ElixirSuite__Service_Facility_Address_2__c = rec.serviceFacilityLocationAddress2,
                                                        ElixirSuite__Service_Facility_Loc_City__c= rec.serviceFacilityLocationCity,
                                                        ElixirSuite__Service_Facility_Loc_State__c= rec.serviceFacilityLocationState,
                                                        ElixirSuite__Service_Facility_Loc_Zip__c= rec.serviceFacilityLocationZip,
                                                        Referring_Physician_Signature__c = rec.signOfPhysician,
                                                        ElixirSuite__Billing_Provider_Other_ID__c = rec.billingProviderInfoID,
                                                        Insured_Authorized_Person_Signature__c = rec.insuredSign ,
                                                        Patient_Signature__c = rec.patientSign ,
                                                        ElixirSuite__Billing_Provider_Info__c = rec.billingProviderInfo,
                                                        ElixirSuite__Billing_Provider_Info_NPI__c = rec.billingProviderInfoNpi,
                                                        Accept_Assignment__c = rec.acceptAssignment,
                                                        ElixirSuite__Patient_Account_Number__c = rec.PatientAccNo,
                                                        ElixirSuite__Reserved_For_NUCC_Use3__c = rec.reservedforNUCCuse4,
                                                        ElixirSuite__Sign_of_Phy_or_Supplier_Signature__c = rec.SupsignOfPhysician,
                                                        ElixirSuite__Auto_Accident_Related__c = rec.autoAccPlaceOrState,
                                                        ElixirSuite__Patient_Sex__c = rec.patiSex =='Female'? 'F' : 'M',
                                                        //ElixirSuite__Patient_Sex__c = rec.patiSex,
                                                        //    Patient_Condition_Related_To_Employment__c = valTrue ,
                                                        //    Patient_Condition_Related_To_Accident__c = valTrue1 ,
                                                        //    Patient_Condition_to_Other_Accident__c = valTrue2 , 
                                                        //    Any_Other_Health_Benefit_Plan__c = valTrue3 ,
                                                        Reserved_For_NUCC_Use1__c = rec.reserverdforNUCCuse1,
                                                        Reserved_For_NUCC_Use2__c = rec.reserverdforNUCCuse2,
                                                        //Reserved_For_NUCC_Use3__c = rec.reservedforNUCCuse3,
                                                        NPI__c = rec.NPI ,
                                                        ElixirSuite__QUAL_For_Date_current_illness_injury__c = rec.qualifierForDateOfCurrentIllness_Value, // xxx
                                                        ElixirSuite__QUAL_For_Other_Dates__c = rec.qualifierForOtherDates_Value , //xxx
                                                        ElixirSuite__NUCC__c = rec.npi_nucc_Value, // xxx
                                                        ElixirSuite__NUCC_Description__c = rec.npi_nucc_description_Value, // xxx
                                                        Outside_Lab_new__c = Boolean.valueOf(rec.outsideLab), // xxx
                                                        ElixirSuite__Outside_Lab_Charges__c = rec.outsideLabcharges ,// xxx
                                                        ElixirSuite__QUAL_For_Name_of_referring_provider__c = rec.qualifierForNameOfReferringProvider, //xxx
                                                        ElixirSuite__First_Name_NAME_OF_REFERRING_PROVIDER__c = rec.nameOfReferringProvider_FirstName, //xxx
                                                        ElixirSuite__Last_Name_NAME_OF_REFERRING_PROVIDER__c = rec.nameOfReferringProvider_LastName, //xxx
                                                        ElixirSuite__MiddleName_NAME_OF_REFERRING_PROVIDER__c = rec.nameOfReferringProvider_MiddleName, //xxx
                                                        ElixirSuite__Diagnosis_A__c = rec.diagnosis_A, //xxx
                                                        ElixirSuite__Diagnosis_B__c = rec.diagnosis_B, //xxx
                                                        ElixirSuite__Diagnosis_C__c = rec.diagnosis_C, //xxx
                                                        ElixirSuite__Diagnosis_D__c = rec.diagnosis_D, //xxx
                                                        ElixirSuite__Diagnosis_E__c = rec.diagnosis_E, //xxx
                                                        ElixirSuite__Diagnosis_F__c = rec.diagnosis_F, //xxx
                                                        ElixirSuite__Diagnosis_G__c = rec.diagnosis_G, //xxx
                                                        ElixirSuite__Diagnosis_H__c = rec.diagnosis_H, //xxx
                                                        ElixirSuite__Diagnosis_I__c = rec.diagnosis_I, //xxx
                                                        ElixirSuite__Diagnosis_J__c = rec.diagnosis_J, //xxx
                                                        ElixirSuite__Diagnosis_K__c = rec.diagnosis_K, //xxx
                                                        ElixirSuite__Diagnosis_L__c = rec.diagnosis_L, //xxx
                                                        ElixirSuite__Prior_Authorization_Number__c = rec.priorAuthNumber, //XXX
                                                        ElixirSuite__Resubmission_Code__c = rec.ResubmissionCode,//XXX
                                                        ElixirSuite__Original_Ref_No__c = rec.orignalRefNumber,//XXX
                                                        ElixirSuite__Insured_Sex__c = rec.insuredSex =='Female'? 'F' : 'M',
                                                        ElixirSuite__Rendering_Provider_First_Name__c = rec.RenderingProvider_FirstName,
                                                        ElixirSuite__Rendering_Provider_Middle_Name__c = rec.RenderingProvider_MiddleName,
                                                        ElixirSuite__Rendering_Provider_Last_Name__c = rec.RenderingProvider_LastName,
                                                        ElixirSuite__Rendering_Provider_Taxonomy__c = rec.RenderingProvider_Taxonomy,
                                                        ElixirSuite__Rendering_Provider_NPI__c = rec.RenderingProvider_NPI,
                                                        ElixirSuite__Rendering_Provider_Tax_Id__c = rec.RenderingProvider_TaxId
                                                        
                                                    );
                                                    //added by jami for LX3-12673
                                                    if (!String.isBlank(rec.insuranceType)) {
                                                        newClaim.Insurance_Type__c = rec.insuranceType;
                                                    }else{
                                                        newClaim.Insurance_Type__c ='';
                                                    }
                                                    if (!String.isBlank(rec.insuranceType) && (rec.insuranceType == 'MA' || rec.insuranceType == 'MB')) {
                                                        newClaim.ElixirSuite__Medicare_Type_Code__c = rec.medicareTypeCode;
                                                    }else{
                                                        newClaim.ElixirSuite__Medicare_Type_Code__c = '';
                                                    }
                                                    //end
                                                    if(!String.isBlank(rec.hospitalisedFromDate)){ 
                                                        newClaim.ElixirSuite__Hospitalization_From_Date__c = Date.valueOf(rec.hospitalisedFromDate); // xxx
                                                    }
                                                    if(!String.isBlank(rec.hospitalisedToDate)){ 
                                                        newClaim.ElixirSuite__Hospitalization_To_Date__c =  Date.valueOf(rec.hospitalisedToDate); // xxx
                                                    }
                                                    
                                                    if(!String.isBlank(payorName)){ 
                                                        newClaim.Payor__c = payorName;
                                                    }
                                                    if(!String.isBlank(rec.DateOfsignOfPhysician)){ 
                                                        newClaim.ElixirSuite__Sign_of_Phy_or_Supplier_Date__c = Date.valueOf(rec.DateOfsignOfPhysician);
                                                    }
                                                    if(!String.isBlank(rec.fromdatesPatientUnableTowork)){ //xxx
                                                        newClaim.ElixirSuite__From_Date_Patient_Unable_To_Work__c = Date.valueOf(rec.fromdatesPatientUnableTowork);
                                                    }
                                                    if(!String.isBlank(rec.todatesPatientUnableTowork)){ //xxx
                                                        newClaim.ElixirSuite__To_Date_Patient_Unable_To_Work__c = Date.valueOf(rec.todatesPatientUnableTowork);
                                                    }
                                                    if(!String.isBlank(rec.employment)){
                                                        if(rec.employment == 'YES')
                                                            newClaim.Patient_Condition_Related_To_Employment__c = true ;
                                                        else
                                                            newClaim.Patient_Condition_Related_To_Employment__c = false ;
                                                    }
                                                    if(!String.isBlank(rec.autoAccident)){
                                                        if(rec.autoAccident == 'YES')
                                                            newClaim.Patient_Condition_Related_To_Accident__c = true ;
                                                        else
                                                            newClaim.Patient_Condition_Related_To_Accident__c = false ;
                                                    }
                                                    if(!String.isBlank(rec.otherAccident)){
                                                        if(rec.otherAccident == 'YES')
                                                            newClaim.Patient_Condition_to_Other_Accident__c = true ;
                                                        else
                                                            newClaim.Patient_Condition_to_Other_Accident__c = false ;
                                                    }
                                                    if(!String.isBlank(rec.IsthereanotherHealthBenefitPlan)){
                                                        if(rec.IsthereanotherHealthBenefitPlan == 'YES')
                                                            newClaim.Any_Other_Health_Benefit_Plan__c = true ;
                                                        else
                                                            newClaim.Any_Other_Health_Benefit_Plan__c = false ;
                                                    }
                                                    if(!String.isBlank(rec.patientDOB)) 
                                                        newClaim.Patient_DOB__c =  date.valueOf(rec.patientDOB) ;
                                                    if(!String.isBlank(rec.insuredDOB)) 
                                                        newClaim.ElixirSuite__Insured_DOB__c =  date.valueOf(rec.insuredDOB) ;
                                                    if(!String.isBlank(rec.patientZipcode)) 
                                                        newClaim.ElixirSuite__Patient_Zip_Code__c = String.valueOf(rec.patientZipcode)  ;
                                                    if(!String.isBlank(rec.insuredZipcode)) 
                                                        newClaim.ElixirSuite__Insured_Zip_Code__c = String.valueOf(rec.insuredZipcode) ; 
                                                    if(!String.isBlank(rec.dateOfCurrentIllness)) 
                                                        newClaim.Date_Of_Current_Illness__c = date.valueOf(rec.dateOfCurrentIllness); 
                                                    if(!String.isBlank(rec.hospitilizationDates))
                                                        newClaim.Hospitalization_Dates__c = date.valueOf(rec.hospitilizationDates);
                                                    if(!String.isBlank(rec.otherDate))
                                                        newClaim.Other_Date__c = date.valueOf(rec.otherDate) ;
                                                    if(!String.isBlank(rec.datesPatientUnableTowork ))
                                                        newClaim.Dates_Patient_Unable_To_Work__c = date.valueOf(rec.datesPatientUnableTowork);
                                                    if(!String.isBlank(rec.datesPatientUnableTowork ))
                                                        newClaim.Dates_Patient_Unable_To_Work__c = date.valueOf(rec.datesPatientUnableTowork);
                                                    if(!String.isBlank(rec.amountPaid))
                                                        newClaim.ElixirSuite__Amount_Paid__c = Decimal.valueOf(rec.amountPaid) ;
                                                    if(!String.isBlank(rec.TotalCharges))
                                                        newClaim.Total_Charge__c = Integer.valueOf(rec.TotalCharges) ;
                                                    if(String.isNotBlank(rec.otherDate_InsuredPersonAuth)){
                                                        newClaim.ElixirSuite__Insured_Or_Auth_Persn_Date__c = date.valueOf(rec.otherDate_InsuredPersonAuth);
                                                    }
                                                    if(!String.isBlank(rec.billingProviderInfo)){
                                                        //   newClaim.ElixirSuite__Billing_Provider_Info_NPI__c = rec.billingProviderInfo;
                                                    }
                                                    if(!String.isBlank(rec.billingProviderInfoID)){
                                                        newClaim.ElixirSuite__Billing_Provider_Other_ID__c = rec.billingProviderInfoID;
                                                    }
                                                    if(!String.isBlank(rec.billingProviderName)){
                                                        newClaim.ElixirSuite__Billing_Provider_Name__c = rec.billingProviderName;
                                                    }
                                                    if(!String.isBlank(rec.billingProviderAddress1)){
                                                        newClaim.ElixirSuite__Billing_Provider_Address_1__c = rec.billingProviderAddress1;
                                                    } 
                                                    if(!String.isBlank(rec.billingProviderAddress2)){
                                                        newClaim.ElixirSuite__Billing_Provider_Address_2__c = rec.billingProviderAddress2;
                                                    }
                                                    if(!String.isBlank(rec.billingProviderCity)){
                                                        newClaim.ElixirSuite__Billing_Provider_City__c = rec.billingProviderCity;
                                                    }
                                                    if(!String.isBlank(rec.billingProviderState)){
                                                        newClaim.ElixirSuite__Billing_Provider_State__c = rec.billingProviderState;
                                                    }
                                                    if(!String.isBlank(rec.billingProviderzipCode)){
                                                        newClaim.ElixirSuite__Billing_Provider_Zip__c = rec.billingProviderzipCode;
                                                    }
                                                    if(!String.isBlank(rec.billingProviderPhone)){
                                                        newClaim.ElixirSuite__Bill_Phone__c = rec.billingProviderPhone;
                                                    }
                                                    if(!String.isBlank(rec.billingProviderTaxId)){
                                                        newClaim.ElixirSuite__Billing_Provider_Tax_ID__c = rec.billingProviderTaxId;
                                                    }
                                                    if(!String.isBlank(rec.billingProviderTaxonomy)){
                                                        newClaim.ElixirSuite__Billing_Provider_Taxonomy__c = rec.billingProviderTaxonomy;
                                                    }
                                                    claimData.add(newClaim); 
                                                }
                                            }
                                            if(claimData.size() >0){
                                                DMLManager.updateAsUser(claimData);
                                            }
                                            //update claimData;
                                            //   Database.insert(claimData,false);
                                        }
                                    }
                                    integer i = 0;
                                    system.debug('abc' + claimData);
                                    Set<Id> procId = new Set<Id>();
                                    if(tabelListData!=null && !String.isEmpty(tabelListData)){
                                        List<masterWrapperRelated> relatedRootJson = (List<masterWrapperRelated>)JSON.deserialize(tabelListData, List<masterWrapperRelated>.class);
                                        system.debug('the string is' + relatedRootJson);
                                        if(relatedRootJson != null & relatedRootJson.size()>0){
                                            for(masterWrapperRelated masterRec : relatedRootJson){
                                                for(relatedRoot rec : masterRec.Record){
                                                    if(String.isNotBlank(rec.claiLineItemRecordID)){
                                                        String CPT_HCPCS_Code = fetchCodeName(rec.cptCode_Procedure);
                                                        procId.add(rec.Id);
                                                        String icdLookupId = '';
                                                        if(String.isNotBlank(String.valueOf(rec.cptCode_Procedure))){
                                                            icdLookupId = String.valueOf(rec.cptCode_Procedure);                      
                                                        }
                                                        //                            ElixirSuite__ICD_Codes__c = icdLookupId,
                                                        system.debug('cli id '+CPT_HCPCS_Code);
                                                        Claim_Line_Items__c newClaimLineItem = new	Claim_Line_Items__c(
                                                            Id = rec.claiLineItemRecordID,
                                                            Claim__c = claimData[i].Id ,
                                                            ElixirSuite__EMG__c = rec.emergency_Procedure,
                                                            ElixirSuite__Place_of_Service__c = rec.placeOfService_Procedure,
                                                            ElixirSuite__Modifier_1__c = rec.modifier_Procedure,
                                                            ElixirSuite__Modifier_2__c = rec.modifier_Procedure2,
                                                            ElixirSuite__Modifier_3__c = rec.modifier_Procedure3,
                                                            ElixirSuite__Modifier_4__c = rec.modifier_Procedure4,
                                                            ElixirSuite__Diagnosis_Pointer__c = rec.diagnosisPointer_Procedure,
                                                            ElixirSuite__Procedure_Charge__c = rec.charges_Procedure,
                                                            ElixirSuite__Days_Units__c = Integer.valueOf(rec.daysOrUnit_Procedure),
                                                            ElixirSuite__Family_Plan__c = rec.espdtSelectedValueFromText_Procedure,
                                                            ElixirSuite__EPSTD__c = rec.espdtSelectedValueFromDropDown_Procedure,
                                                            ElixirSuite__ID_Qual__c = rec.qualifier_Procedure,
                                                            ElixirSuite__Rendering_Provider_Non_NPI__c = rec.rendringProviderNonNPI_Procedure,
                                                            ElixirSuite__Rendering_Provider_NPI__c = rec.rendringProviderNPI_Procedure, 
                                                            ElixirSuite__CPT_HCPCS_Code__c =  rec.cptCodeName_Procedure
                                                            //  Procedure__c= rec.Id
                                                            
                                                        );
                                                        
                                                        if(!String.isBlank(rec.placeOfService_Procedure)) {
                                                            sYSTEM.debug('b4 678 '+rec.placeOfService_Procedure);
                                                            String toSplitData = String.valueOf(rec.placeOfService_Procedure);
                                                            List<String> arr = toSplitData.split('-');
                                                            sYSTEM.debug('ARR 678 '+arr);
                                                            if(arr!=null && arr.size()>0){
                                                                newClaimLineItem.ElixirSuite__Place_of_Service_Name__c = arr[1];
                                                                newClaimLineItem.ElixirSuite__Place_of_Service_Code_s__c = arr[0];
                                                                
                                                            }
                                                        }
                                                        if(!String.isBlank(rec.fromDate_Procedure)) 
                                                            newClaimLineItem.ElixirSuite__From_Date_Of_Service__c =date.valueOf(rec.fromDate_Procedure) ;
                                                        if(!String.isBlank(rec.toDate_Procedure)) 
                                                            newClaimLineItem.ElixirSuite__To_Date_Of_Service__c = date.valueOf(rec.toDate_Procedure) ;
                                                        
                                                        claimLineItemData.add(newClaimLineItem);
                                                    }
                                                    else { // TO INSERT CLAIM LINE ITEMS
                                                        if(String.isNotBlank(rec.fromDate_Procedure) && String.isNotBlank(rec.toDate_Procedure)){
                                                            
                                                            
                                                            String CPT_HCPCS_Code = fetchCodeName(rec.cptCode_Procedure);
                                                            procId.add(rec.Id);
                                                            String icdLookupId = '';
                                                            if(String.isNotBlank(String.valueOf(rec.cptCode_Procedure))){
                                                                icdLookupId = String.valueOf(rec.cptCode_Procedure);                      
                                                            }
                                                            
                                                            
                                                            Claim_Line_Items__c newClaimLineItem_ToInsert = new	Claim_Line_Items__c(
                                                                
                                                                Claim__c = claimData[i].Id ,
                                                                ElixirSuite__EMG__c = rec.emergency_Procedure,
                                                                ElixirSuite__Place_of_Service__c = rec.placeOfService_Procedure,
                                                                ElixirSuite__Modifier_1__c = rec.modifier_Procedure,
                                                                ElixirSuite__Modifier_2__c = rec.modifier_Procedure2,
                                                                ElixirSuite__Modifier_3__c = rec.modifier_Procedure3,
                                                                ElixirSuite__Modifier_4__c = rec.modifier_Procedure4,
                                                                ElixirSuite__Diagnosis_Pointer__c = rec.diagnosisPointer_Procedure,
                                                                ElixirSuite__Procedure_Charge__c = rec.charges_Procedure,
                                                                ElixirSuite__Days_Units__c = Integer.valueOf(rec.daysOrUnit_Procedure),
                                                                ElixirSuite__Family_Plan__c = rec.espdtSelectedValueFromText_Procedure,
                                                                ElixirSuite__EPSTD__c = rec.espdtSelectedValueFromDropDown_Procedure,
                                                                ElixirSuite__ID_Qual__c = rec.qualifier_Procedure,
                                                                ElixirSuite__Rendering_Provider_Non_NPI__c = rec.rendringProviderNonNPI_Procedure,
                                                                ElixirSuite__Rendering_Provider_NPI__c = rec.rendringProviderNPI_Procedure, 
                                                                ElixirSuite__CPT_HCPCS_Code__c =  rec.cptCodeName_Procedure
                                                                //  Procedure__c= rec.Id
                                                                
                                                            );
                                                            if(!String.isBlank(rec.placeOfService_Procedure)) {
                                                                
                                                                String toSplitData = String.valueOf(rec.placeOfService_Procedure);
                                                                List<String> arr = toSplitData.split('-');
                                                                
                                                                if(arr!=null && arr.size()>0){
                                                                    newClaimLineItem_ToInsert.ElixirSuite__Place_of_Service_Name__c = arr[1];
                                                                    newClaimLineItem_ToInsert.ElixirSuite__Place_of_Service_Code_s__c = arr[0];
                                                                    
                                                                }
                                                            }
                                                            if(!String.isBlank(rec.fromDate_Procedure)) 
                                                                newClaimLineItem_ToInsert.ElixirSuite__From_Date_Of_Service__c =date.valueOf(rec.fromDate_Procedure) ;
                                                            if(!String.isBlank(rec.toDate_Procedure)) 
                                                                newClaimLineItem_ToInsert.ElixirSuite__To_Date_Of_Service__c = date.valueOf(rec.toDate_Procedure) ;
                                                            
                                                            claimLineItemData_ToInsert.add(newClaimLineItem_ToInsert);
                                                        }
                                                    }
                                                }
                                            }
                                            //update claimLineItemData;
                                            //insert claimLineItemData_ToInsert;
                                            if(claimLineItemData.size() >0){
                                                DMLManager.updateAsUser(claimLineItemData);
                                            }
                                            if(claimLineItemData_ToInsert.size() >0){
                                                DMLManager.insertAsUser(claimLineItemData_ToInsert);
                                            }
                                            List<Procedure__c> relatedProc = [SELECT Id, Name,Claim__c, CreatedDate, From_Date__c, To_Date__c, CPT_HCPCS_Code__c, Account__c, Code_Description__c 
                                                                              FROM Procedure__c
                                                                              WHERE id IN : procId AND Account__c=: recordVal 
                                                                              WITH SECURITY_ENFORCED];
                                            system.debug('hhh' + relatedProc);
                                            system.debug('b' + claimData[i].Id);
                                            for(Procedure__c proc : relatedProc){
                                                proc.Claim__c = claimData[i].Id ;
                                            }
                                            if(relatedProc.size() >0){
                                                DMLManager.updateAsUser(relatedProc);
                                            }
                                            //update relatedProc ;
                                            system.debug('the updates ' + relatedProc);
                                        }
                                    }
                                    if(sendToInsurance){ //Anusha - start -03/11/22
                                        system.debug('api claim'+sendToInsurance);
                                        String claimIds=''; 
                                        for(Claim__c eachRec:claimData){    
                                            eachRec.Claim_Status__c='Ready to Submit';  
                                            //eachRec.ElixirSuite__Primary_Claim_Status__c='Ready to Submit'; 
                                            claimIds+=(eachRec.id+','); 
                                        }   
                                        //update claimData; 
                                        DMLManager.updateAsUser(claimData);
                                        
                                        SendClaimController.updateClaims(claimIds); 
                                    }
                                }
    public static String fetchCodeName(String icdCode){
        String toReturnName = '';
        /* ElixirSuite__ICD_Codes__c[] lst =  [SELECT ID,Code__c from ElixirSuite__ICD_Codes__c 
where ID = : icdCode WITH SECURITY_ENFORCED];
if(lst!=null && lst.size()>0){
toReturnName = lst[0].Code__c;
}*/
        return toReturnName;
    }
    @AuraEnabled
    public static List<String> fetchICDCodes(){
        List<String> lstOfICDCodes = new List<String>();
        /* for(ElixirSuite__ICD_Codes__c sObj :  [SELECT ID,Name,ElixirSuite__Code__c FROM ElixirSuite__ICD_Codes__c
WHERE ElixirSuite__Code__c!=NULL
WITH SECURITY_ENFORCED]){
lstOfICDCodes.add(sObj.ElixirSuite__Code__c);
}*/
        return lstOfICDCodes;
    }
    @AuraEnabled
    public static  Map<String,list<sObject>> fetchCusomMetadataRecord()
    {
        Map<String,list<sObject>> Mastermdt = new Map<String,list<sObject>>();
        List<ElixirSuite__ClaimCodesMetaDataType__mdt> mdt  = [select id,ElixirSuite__Code__c,ElixirSuite__Description__c from 
                                                               ElixirSuite__ClaimCodesMetaDataType__mdt WHERE ElixirSuite__Code__c!=null
                                                               WITH SECURITY_ENFORCED]; 
        Mastermdt.put('ClaimCodes',mdt);
        return Mastermdt;
    }
    
    public class wrapper{
        @AuraEnabled public List<ElixirSuite__Result__c> relatedResult ;
        @AuraEnabled public Boolean isVobPresent = true;
        @AuraEnabled public Map<String,List<String>> mapOfNameToField ;
        @AuraEnabled public Map<String,List<String>> mapOfNameToFieldAcc ;
        @AuraEnabled public Map<String, Map<String, String>> mapOfNameToFieldInsType ;
        @AuraEnabled public Account accDetails ;
        @AuraEnabled public List<VOB__c> vobData ;
        @AuraEnabled public List<Provider__c> provider ;
        @AuraEnabled public List<Payor__c> payer ;
        @AuraEnabled public List<Procedure__c> procedure ;
        @AuraEnabled public List<ElixirSuite__Claim__c> currentViewClaimRecord ;
        @AuraEnabled public List<ElixirSuite__Claim_Line_Items__c> relatedClaimLineItems ;
        @AuraEnabled public List<String> claimFields ;
        @AuraEnabled public Map<String , Contracted_Price__c> codeandPricelist ;
        @AuraEnabled public Map<String , Actual_Price__c> codeandPricelistForProvider ;
        @AuraEnabled public String patientDecision ;
        @AuraEnabled public List<ElixirSuite__Procedure__c> acctRelatedProcData;
        @AuraEnabled public List<String> allPickListPlaceOfService_ValuesIntoList;
        @AuraEnabled public ElixirSuite__CMS_1500_Claim_Generation__c claimCustomSettingValues =  ElixirSuite__CMS_1500_Claim_Generation__c.getInstance();
        @AuraEnabled public Boolean saveSendCustomSetting;
    }
    
    public class masterWrapper{
        @AuraEnabled
        public String id ;
        @AuraEnabled
        public String transactionalDataId ;
        @AuraEnabled
        public List<root> Record  ;
    }
    public class root {
        @AuraEnabled  
        public String federalSsnEsnPick {get;set;}
        @AuraEnabled  
        public String insuredSex {get;set;}
        @AuraEnabled  
        public String patiSex {get;set;}
        @AuraEnabled  
        public String id {get;set;}
        @AuraEnabled  
        public String billingProviderInfoID {get;set;}
        @AuraEnabled 
        public String serviceFacilityLocationInfoNPI {get;set;}
        @AuraEnabled      
        public String autoAccPlaceOrState{get;set;}
        @AuraEnabled
        public String otherDate_InsuredPersonAuth{get;set;}        
        @AuraEnabled
        public String resubmissionCode {get;set;}
        @AuraEnabled
        public String orignalRefNumber {get;set;}
        @AuraEnabled
        public String priorAuthNumber {get;set;}
        @AuraEnabled
        public String DateOfsignOfPhysician {get;set;}
        @AuraEnabled
        public String SupsignOfPhysician {get;set;}
        @AuraEnabled
        public String serviceFacilityLocationInfoID {get;set;}
        @AuraEnabled
        public String serviceFacilityLocationAddress {get;set;}
        @AuraEnabled
        public String  serviceFacilityLocationAddress2 {get;set;}
        @AuraEnabled
        public String serviceFacilityLocationCity {get;set;}
        @AuraEnabled
        public String serviceFacilityLocationState {get;set;}
        @AuraEnabled
        public String serviceFacilityLocationZip {get;set;}
        @AuraEnabled
        public String diagnosis_A {get;set;}
        @AuraEnabled
        public String diagnosis_B {get;set;}
        @AuraEnabled
        public String diagnosis_C {get;set;}
        @AuraEnabled
        public String diagnosis_D {get;set;}
        @AuraEnabled
        public String diagnosis_E {get;set;}
        @AuraEnabled
        public String diagnosis_F {get;set;}
        @AuraEnabled
        public String diagnosis_G {get;set;}
        @AuraEnabled
        public String diagnosis_H {get;set;}
        @AuraEnabled
        public String diagnosis_I {get;set;}
        @AuraEnabled
        public String diagnosis_J {get;set;}
        @AuraEnabled
        public String diagnosis_K {get;set;}
        @AuraEnabled
        public String diagnosis_L {get;set;} 
        @AuraEnabled
        public String nameOfReferringProvider_FirstName {get;set;} 
        @AuraEnabled
        public String nameOfReferringProvider_MiddleName {get;set;}
        @AuraEnabled
        public String nameOfReferringProvider_LastName {get;set;}
        @AuraEnabled
        public String qualifierForNameOfReferringProvider {get;set;}
        @AuraEnabled
        public String hospitalisedToDate {get;set;}
        @AuraEnabled
        public String hospitalisedFromDate {get;set;}
        @AuraEnabled 
        public String fromdatesPatientUnableTowork {get;set;}
        @AuraEnabled
        public String todatesPatientUnableTowork {get;set;}
        @AuraEnabled
        public String qualifierForOtherDates_Value {get;set;}
        @AuraEnabled
        public String npi_nucc_description_Value {get;set;}
        @AuraEnabled
        public String npi_nucc_Value {get;set;}
        @AuraEnabled
        public String qualifierForDateOfCurrentIllness_Value {get;set;}
        @AuraEnabled
        public String patientName {get;set;}
        @AuraEnabled
        public String patientDOB {get;set;}
        @AuraEnabled
        public String insuredDOB {get;set;}
        @AuraEnabled
        public String patientAddress {get;set;}
        @AuraEnabled
        public String patientCity {get;set;}
        @AuraEnabled
        public String patientState {get;set;}
        @AuraEnabled
        public String patientZipcode {get;set;}
        @AuraEnabled
        public String patientPhone {get;set;}
        @AuraEnabled
        public String insuranceType {get;set;}
        @AuraEnabled
        public String medicareTypeCode {get;set;}
        @AuraEnabled
        public String relationWithInsured {get;set;}
        @AuraEnabled
        public String insuredIdNumber {get;set;}
        @AuraEnabled
        public String insuredName {get;set;}
        @AuraEnabled
        public String insurancePlanName {get;set;}
        @AuraEnabled
        public String autoAccident {get;set;}
        @AuraEnabled
        public String employment {get;set;}
        @AuraEnabled
        public String IsthereanotherHealthBenefitPlan {get;set;}
        @AuraEnabled
        public String otherAccident {get;set;}
        @AuraEnabled
        public String reserverdforNUCCuse1  {get;set;}
        @AuraEnabled
        public String reserverdforNUCCuse2  {get;set;}
        @AuraEnabled
        public String reservedforNUCCuse3 {get;set;}
        @AuraEnabled
        public String reservedforNUCCuse4 {get;set;}
        @AuraEnabled
        public DECIMAL outsideLabcharges {get;set;} 
        @AuraEnabled
        public String otherClaimId {get;set;}
        @AuraEnabled
        public String dateOfCurrentIllness {get;set;}
        @AuraEnabled
        public String otherDate {get;set;}
        @AuraEnabled
        public String  datesPatientUnableTowork {get;set;}
        @AuraEnabled
        public String  nameOfReferringProvider {get;set;}
        @AuraEnabled
        public String  NPI {get;set;}
        @AuraEnabled
        public String  hospitilizationDates {get;set;}
        @AuraEnabled
        public String  additionalInfo {get;set;}
        @AuraEnabled
        public String  outsideLab {get;set;}
        @AuraEnabled
        public String  federalTaxNumber {get;set;}
        @AuraEnabled
        public String  acceptAssignment {get;set;}
        @AuraEnabled
        public String  amountPaid {get;set;}
        @AuraEnabled
        public String  serviceFacilityLocationInfo {get;set;}
        @AuraEnabled 
        public String  billingProviderInfoNpi {get;set;}
        @AuraEnabled 
        public String  billingProviderInfo {get;set;}
        @AuraEnabled
        public String  billingProviderInfoOtherId {get;set;}
        @AuraEnabled
        public String  PatientAccNo {get;set;}
        @AuraEnabled
        public String  signOfPhysician {get;set;}
        @AuraEnabled
        public String  claimCodes {get;set;}
        @AuraEnabled
        public String  insuredAddress {get;set;}
        @AuraEnabled
public String patientAddress2 {get;set;}
        @AuraEnabled   
        public String insuredAddress2 {get;set;}
        @AuraEnabled
        public String  insuredState {get;set;}
        @AuraEnabled
        public String  insuredCity {get;set;}
        @AuraEnabled
        public String  insuredZipcode {get;set;}
        @AuraEnabled
        public String  insuredTelephone {get;set;}
        @AuraEnabled
        public String  otherInsuredPolicyNumber {get;set;}
        @AuraEnabled
        public String  insuredPolicyNumber {get;set;}
        @AuraEnabled
        public String  otherInsuredName {get;set;}
        @AuraEnabled
        public String  otherInsurancePlanName {get;set;} 
        @AuraEnabled
        public String  patientSign {get;set;}
        @AuraEnabled
        public String  insuredSign {get;set;}
        @AuraEnabled
        public String  TotalCharges {get;set;}
        // @AuraEnabled
        // public String  billingProviderInfo {get;set;}
        // @AuraEnabled
        // public String  billingProviderInfoID {get;set;}
        @AuraEnabled
        public String  billingProviderName {get;set;}
        @AuraEnabled
        public String  billingProviderAddress1 {get;set;}
        @AuraEnabled
        public String  billingProviderAddress2 {get;set;}
        @AuraEnabled
        public String  billingProviderCity {get;set;}
        @AuraEnabled
        public String  billingProviderState {get;set;}
        @AuraEnabled
        public String  billingProviderzipCode {get;set;}
        @AuraEnabled
        public String  billingProviderPhone {get;set;}
        @AuraEnabled
        public String  billingProviderTaxId {get;set;}
        @AuraEnabled    
        public String  billingProviderTaxonomy {get;set;}
        @AuraEnabled    
        public String  RenderingProvider_FirstName {get;set;}
        @AuraEnabled    
        public String  RenderingProvider_MiddleName {get;set;}
        @AuraEnabled    
        public String  RenderingProvider_LastName {get;set;}
        @AuraEnabled    
        public String  RenderingProvider_Taxonomy {get;set;}
        @AuraEnabled    
        public String  RenderingProvider_NPI {get;set;}
        @AuraEnabled    
        public String  RenderingProvider_TaxId {get;set;}
    } 
    
    public class masterWrapperRelated {
        @AuraEnabled
        public List<relatedRoot> Record  ;
    }
    
    public class relatedRoot {
        @AuraEnabled
        public String claiLineItemRecordID {get;set;}
        
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String cptCodeName_Procedure {get;set;}
        @AuraEnabled
        public String fromDate {get;set;}
        @AuraEnabled
        public String emergency_FreeText_Procedure {get;set;}
        @AuraEnabled
        public String modifier_Procedure2 {get;set;}
        @AuraEnabled
        public String modifier_Procedure3 {get;set;}
        @AuraEnabled
        public String modifier_Procedure4 {get;set;}
        
        @AuraEnabled 
        public String fromDate_Procedure {get;set;}
        @AuraEnabled
        public String toDate_Procedure {get;set;}
        @AuraEnabled
        public String placeOfService_Procedure {get;set;}
        @AuraEnabled
        public String emergency_Procedure {get;set;}
        @AuraEnabled
        public Id cptCode_Procedure {get;set;}
        @AuraEnabled
        public String modifier_Procedure {get;set;}
        @AuraEnabled
        public String diagnosisPointer_Procedure {get;set;}
        @AuraEnabled
        public Integer daysOrUnit_Procedure {get;set;}
        @AuraEnabled
        public String espdtSelectedValueFromDropDown_Procedure {get;set;}
        @AuraEnabled
        public String espdtSelectedValueFromText_Procedure {get;set;}
        @AuraEnabled
        public String qualifier_Procedure {get;set;}
        @AuraEnabled
        public String rendringProviderNonNPI_Procedure {get;set;}
        @AuraEnabled
        public String rendringProviderNPI_Procedure {get;set;}
        @AuraEnabled
        public Decimal charges_Procedure {get;set;}
        
        @AuraEnabled
        public String todatesPatientUnableTowork {get;set;}
        @AuraEnabled
        public DECIMAL outsideLabcharges {get;set;} 
        @AuraEnabled
        public String toDate {get;set;}
        @AuraEnabled
        public String CPTcode {get;set;}
        @AuraEnabled
        public String procedureName {get;set;}
        @AuraEnabled
        public String daysUnits {get;set;}
        @AuraEnabled
        public String payerName {get;set;}
        @AuraEnabled
        public String providerName {get;set;}
        @AuraEnabled
        public String Charges {get;set;}
    } 
    
    public static String fetchPatientDecision()
    {
        String patientDecision = '';
        ElixirSuite__Elixir_Custom_Setting__c[] lstOfCsSetting =[SELECT ElixirSuite__Inpatient__c,ElixirSuite__Outpatient__c
                                                                 FROM ElixirSuite__Elixir_Custom_Setting__c WITH SECURITY_ENFORCED];
        if(lstOfCsSetting!=null && lstOfCsSetting.size()>0){
            if(lstOfCsSetting[0].ElixirSuite__Inpatient__c){
                patientDecision = 'Inpatient';
            }
            else if(lstOfCsSetting[0].ElixirSuite__Outpatient__c){
                patientDecision = 'Outpatient';
            }
        }
        return patientDecision;
    } 
    @AuraEnabled 
    public static list<ElixirSuite__ICD_Codes__c> ICDCodeRecord(String recordId){
        String additionFieldsPrefix = ' where Id = : recordId';
        String otherFieldsAddition = ''; 
        String icdCodeQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__ICD_Codes__c',otherFieldsAddition,additionFieldsPrefix+'');
        ElixirOEM_TimelineHelper.mDebugUntruncated(icdCodeQuery);
        return Database.query(icdCodeQuery);
        
    }
    
    
    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = ElixirSuite__Procedure__c.ElixirSuite__Place_Of_Service_Picklist__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    public static List<ElixirSuite__Claim__c> fetchClaimRecordDetails(String claimrecordID){
        return [SELECT ElixirSuite__Accept_Assignment__c,ElixirSuite__Account__c,ElixirSuite__Additional_Claim_Information__c,ElixirSuite__Insured_Address_2__c,
                ElixirSuite__Amount_Paid__c,ElixirSuite__Any_Other_Health_Benefit_Plan__c,ElixirSuite__Auto_Accident_Related__c,ElixirSuite__Patient_Address_2__c,
                ElixirSuite__Batch_Id__c,ElixirSuite__Billing_Provider_Address_1__c,ElixirSuite__Billing_Provider_Address_2__c,
                ElixirSuite__Billing_Provider_City__c,ElixirSuite__Billing_Provider_Info_NPI__c,ElixirSuite__Billing_Provider_Info__c,
                ElixirSuite__Billing_Provider_Legacy_ID_Provider_Lice__c,ElixirSuite__Billing_Provider_Name__c,
                ElixirSuite__Billing_Provider_Other_ID__c,ElixirSuite__Billing_Provider_State__c,ElixirSuite__Billing_Provider_Taxonomy__c,
                ElixirSuite__Billing_Provider_Tax_ID_Type__c,ElixirSuite__Billing_Provider_Tax_ID__c,ElixirSuite__Billing_Provider_Zip__c,
                ElixirSuite__Bill_Phone__c,ElixirSuite__bill_taxid__c,ElixirSuite__Charge_Amount__c,ElixirSuite__Claimid__c,
                ElixirSuite__Claim_Codes__c,ElixirSuite__Claim_Md_Id__c,ElixirSuite__Claim_Status__c,ElixirSuite__Color2__c,
                ElixirSuite__Dates_Patient_Unable_To_Work__c,ElixirSuite__Date_Of_Current_Illness__c,ElixirSuite__Diagnosis_A__c,
                ElixirSuite__Diagnosis_B__c,ElixirSuite__Diagnosis_C__c,ElixirSuite__Diagnosis_D__c,ElixirSuite__Diagnosis_E__c,
                ElixirSuite__Diagnosis_F__c,ElixirSuite__Diagnosis_G__c,ElixirSuite__Diagnosis_H__c,ElixirSuite__Diagnosis_I__c,
                ElixirSuite__Diagnosis_J__c,ElixirSuite__Diagnosis_K__c,ElixirSuite__Diagnosis_L__c,ElixirSuite__Diagnosis_Reference__c,
                ElixirSuite__Diag_1__c,ElixirSuite__Diag_2__c,ElixirSuite__Diag_3__c,ElixirSuite__Diag_4__c,ElixirSuite__Diag_5__c,
                ElixirSuite__Diag_6__c,ElixirSuite__Diag_7__c,ElixirSuite__Diag_8__c,ElixirSuite__Diag_9__c,ElixirSuite__Diag_10__c,
                ElixirSuite__Diag_11__c,ElixirSuite__Diag_12__c,ElixirSuite__Employment_Related__c,ElixirSuite__fdos__c,
                ElixirSuite__Federal_Tax_Id_Number__c,ElixirSuite__File_Id__c,ElixirSuite__File_Name__c,ElixirSuite__First_Diagnosis__c,
                ElixirSuite__First_Name_NAME_OF_REFERRING_PROVIDER__c,ElixirSuite__From_Date_Patient_Unable_To_Work__c,
                ElixirSuite__From_Date__c,ElixirSuite__Hospitalization_Dates__c,ElixirSuite__Hospitalization_From_Date__c,
                ElixirSuite__Hospitalization_To_Date__c,ElixirSuite__Insurance_Number__c,ElixirSuite__Insurance_Plan_Name__c,
                ElixirSuite__Insurance_Type__c,ElixirSuite__Insured_Address__c,ElixirSuite__Insured_Authorized_Person_Signature__c,
                ElixirSuite__Insured_City__c,ElixirSuite__Insured_Country_Code__c,ElixirSuite__Insured_DOB__c,ElixirSuite__Insured_First_name__c,
                ElixirSuite__Insured_Or_Auth_Persn_Date__c,ElixirSuite__Insured_Or_Auth_Persn_Sign__c,ElixirSuite__Insured_Policy__c,
                ElixirSuite__Insured_Sex__c,ElixirSuite__Insured_State__c,ElixirSuite__Insured_s_ID_Number__c,ElixirSuite__Insured_s_Name__c,
                ElixirSuite__Insured_Telephone__c,ElixirSuite__Insured_Zipcode__c,ElixirSuite__Insured_Zip_Code__c,
                ElixirSuite__isRecordInReadyToSubmitStatus__c,ElixirSuite__Last_Name_NAME_OF_REFERRING_PROVIDER__c,ElixirSuite__Manual_ERA__c,
                ElixirSuite__Master_ERA__c,ElixirSuite__Message__c,ElixirSuite__MiddleName_NAME_OF_REFERRING_PROVIDER__c,
                ElixirSuite__Name_of_referring_provider_Other_sourc__c,ElixirSuite__NPI__c,ElixirSuite__NUCC_Description__c,
                ElixirSuite__NUCC__c,ElixirSuite__Original_Ref_No__c,ElixirSuite__Other_Claim_Id__c,ElixirSuite__Other_Date__c,
                ElixirSuite__Other_ID__c,ElixirSuite__Other_Insurance_Plan_Name__c,ElixirSuite__Other_Insured_s_Name__c,
                ElixirSuite__Other_Insured_s_Policy_Group_Number__c,ElixirSuite__Other_Payer_Name__c,ElixirSuite__Outside_Lab_Charges__c,
                ElixirSuite__Outside_Lab_new__c,ElixirSuite__Outside_Lab__c,ElixirSuite__Patient_Account_Number__c,
                ElixirSuite__Patient_Condition_Related_To_Accident__c,ElixirSuite__Patient_Condition_Related_To_Employment__c,
                ElixirSuite__Patient_Condition_to_Other_Accident__c,ElixirSuite__Patient_Country_Code__c,ElixirSuite__Patient_DOB__c,
                ElixirSuite__Patient_First_Name__c,ElixirSuite__Patient_Last_Name__c,ElixirSuite__Patient_Name__c,
                ElixirSuite__Patient_Or_Auth_Person_Date__c,ElixirSuite__Patient_Or_Auth_Per_Sign__c,ElixirSuite__Patient_Relationship_to_Insured__c,
                ElixirSuite__Patient_Sex__c,ElixirSuite__Patient_Signature__c,ElixirSuite__Patient_s_Address__c,ElixirSuite__Patient_s_City__c,ElixirSuite__Claim_Code_Options__c,
                ElixirSuite__Patient_s_Phone__c,ElixirSuite__Patient_s_State__c,ElixirSuite__Patient_s_Zipcode__c,ElixirSuite__Patient_Zip_Code__c,
                ElixirSuite__Payerid__c,ElixirSuite__Payer_ID__c,ElixirSuite__Payer_Order__c,ElixirSuite__Payor__c,ElixirSuite__Pcn__c,ElixirSuite__Place_of_Service__c,
                ElixirSuite__Posted__c,ElixirSuite__Priority__c,ElixirSuite__Prior_Authorization_Number__c,ElixirSuite__Procedure_Code__c,ElixirSuite__Qualifier_For_Name_Of_Referring_Provider__c,
                ElixirSuite__QUAL_For_Date_current_illness_injury__c,ElixirSuite__QUAL_For_Name_of_referring_provider__c,ElixirSuite__QUAL_For_Other_Dates__c,ElixirSuite__Referring_Physician_Signature__c,
                ElixirSuite__Reserved_For_NUCC_Use1__c,ElixirSuite__Reserved_For_NUCC_Use2__c,ElixirSuite__Reserved_For_NUCC_Use3__c,ElixirSuite__Resubmission_Code__c,ElixirSuite__Sender_Icn__c,
                ElixirSuite__Sender_Id__c,ElixirSuite__Sender_Name__c,ElixirSuite__Service_Facility_Location_Information__c,ElixirSuite__Service_Facility_Location_NPI__c,ElixirSuite__Servic_Fcility_Loc_Informaton_OtherID__c,
                ElixirSuite__Sign_of_Phy_or_Supplier_Date__c,ElixirSuite__Sign_of_Phy_or_Supplier_Signature__c,ElixirSuite__status__c,ElixirSuite__Thru_Date__c,ElixirSuite__Total_Adjustment_Amount__c,ElixirSuite__Total_Allowed_Amount__c,
                ElixirSuite__Total_Amount_Paid_By_Insurance__c,ElixirSuite__Total_Charge__c,ElixirSuite__Total_Contracted_Amount__c,ElixirSuite__Total_Patient_Responsibility__c,ElixirSuite__To_Date_Patient_Unable_To_Work__c,ElixirSuite__Units__c,Id,Name,
                ElixirSuite__Rendering_Provider_First_Name__c,ElixirSuite__Rendering_Provider_Middle_Name__c,ElixirSuite__Rendering_Provider_Last_Name__c,
                ElixirSuite__Rendering_Provider_Taxonomy__c,ElixirSuite__Rendering_Provider_NPI__c,ElixirSuite__Rendering_Provider_Tax_Id__c,
                ElixirSuite__Service_Facility_Loc_Address__c,ElixirSuite__Service_Facility_Address_2__c,ElixirSuite__Medicare_Type_Code__c,ElixirSuite__Service_Facility_Loc_City__c,ElixirSuite__Service_Facility_Loc_State__c,ElixirSuite__Service_Facility_Loc_Zip__c
                FROM ElixirSuite__Claim__c
                where id = : claimrecordID WITH SECURITY_ENFORCED]; 
    }
    public static List<ElixirSuite__Claim_Line_Items__c> fetchClaimlLineItems(String claimrecordID){
        return [SELECT ElixirSuite__Amount_Paid_by_Insurance__c,ElixirSuite__Claim__c,ElixirSuite__Contracted_Amount__c,ElixirSuite__CPT_HCPCS_Code__c,
                ElixirSuite__Days_Units__c,ElixirSuite__Diagnosis_Pointer__c,ElixirSuite__Diag_Ref__c,ElixirSuite__EMG__c,
                ElixirSuite__EPSTD__c,ElixirSuite__ERA_Received__c,ElixirSuite__Family_Plan__c,ElixirSuite__From_Date_Of_Service__c,
                ElixirSuite__From_Date__c,ElixirSuite__ICD_Codes__c,ElixirSuite__ID_Qual__c,ElixirSuite__Integration_Order__c,
                ElixirSuite__Modifier_1__c,ElixirSuite__Modifier_2__c,ElixirSuite__Modifier_3__c,ElixirSuite__Modifier_4__c,
                ElixirSuite__Patient_Responsibility__c,ElixirSuite__Place_of_Service_Code_s__c,ElixirSuite__Place_of_Service_Code__c,
                ElixirSuite__Place_of_Service_Name__c,ElixirSuite__Place_of_Service__c,ElixirSuite__Procedure_Charge__c,
                ElixirSuite__Procedure__c,ElixirSuite__Proc_code__c,ElixirSuite__Rendering_Provider_Non_NPI__c,ElixirSuite__Rendering_Provider_NPI__c,
                ElixirSuite__Total_Adjustment__c,ElixirSuite__Total_Allowed_Amount__c,ElixirSuite__To_Date_Of_Service__c,ElixirSuite__To_Date__c,Id,Name FROM
                ElixirSuite__Claim_Line_Items__c WHERE ElixirSuite__Claim__c = : claimrecordID WITH SECURITY_ENFORCED];
    }
    
}