/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-08-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CMS1500ClaimFormApex {
    public static list<ElixirSuite__VOB__c> fetchVOBRecord(String recordId){
        String additionFieldsPrefix = ' where Id = : recordId';
        String otherFieldsAddition = ' ,RecordType.DeveloperName,ElixirSuite__Payer__r.ElixirSuite__Claim_Processing_via__c'; 
        String vobQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__VOB__c',otherFieldsAddition,additionFieldsPrefix+'');
        return Database.query(vobQuery);
        
    }
    
    @AuraEnabled
    public static careWrapper getPatientDetails(String careId) {
        careWrapper wrpr = new careWrapper();
        try{
            ElixirSuite__Visits__c care = [SELECT Id,ElixirSuite__Pre_Authorization_Number__c, 
                                           Name,ElixirSuite__Care_Episode_Location__c,ElixirSuite__Account__c,
                                           ElixirSuite__Billing_Provider__c,ElixirSuite__Rendering_Provider__c
                                           FROM ElixirSuite__Visits__c 
                                           where Id=:careId
                                           WITH SECURITY_ENFORCED];
            
            if(care.ElixirSuite__Account__c != null){
                wrpr.patientRecId = care.ElixirSuite__Account__c;
            }
            if(care.ElixirSuite__Pre_Authorization_Number__c != null){
                wrpr.preAuthNumber = care.ElixirSuite__Pre_Authorization_Number__c;
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpr;
    }
    
    @AuraEnabled
    public static careWrapper getCareEpisodeDetails(String careId) {
        careWrapper wrpr = new careWrapper();
        try{
            
            ElixirSuite__Visits__c care = [SELECT Id,ElixirSuite__Pre_Authorization_Number__c, 
                                           Name,ElixirSuite__Care_Episode_Location__c,ElixirSuite__Account__c,
                                           ElixirSuite__Billing_Provider__c,ElixirSuite__Rendering_Provider__c
                                           FROM ElixirSuite__Visits__c 
                                           where Id=:careId
                                           WITH SECURITY_ENFORCED];
            Map<Id,Provider__c> billingProvIdVsBillingProv;
            Map<Id,Provider__c> serviceProvIdVsServiceProv;
            Map<Id,Contact> renderingProvIdVsRenderingProv;
            List<VOB__c> vobLst = new List<VOB__c>();
            if(String.isNotBlank(care.ElixirSuite__Billing_Provider__c) && String.isNotEmpty(care.ElixirSuite__Billing_Provider__c)){
                billingProvIdVsBillingProv = new Map<Id,Provider__c>([Select Id,
                                                                      Name,ElixirSuite__Address__c,
                                                                      ElixirSuite__Address_2__c,
                                                                      ElixirSuite__Provider_Code__c,
                                                                      ElixirSuite__Provider_TaxId_Type__c,
                                                                      ElixirSuite__Provider_Tax_Id__c,
                                                                      ElixirSuite__Provider_City__c,
                                                                      ElixirSuite__Provider_State__c,
                                                                      ElixirSuite__Provider_Phone__c,
                                                                      ElixirSuite__Provider_Zip__c,
                                                                      ElixirSuite__Tax_Id_Type__c,
                                                                      ElixirSuite__Provider_Taxonomy__c
                                                                      FROM Provider__c 
                                                                      WHERE Id=:care.ElixirSuite__Billing_Provider__c
                                                                      WITH SECURITY_ENFORCED]);
            }
            
            if(String.isNotBlank(care.ElixirSuite__Care_Episode_Location__c) && String.isNotEmpty(care.ElixirSuite__Care_Episode_Location__c)){
                serviceProvIdVsServiceProv = new Map<Id,Provider__c>([Select Id,
                                                                      Name,ElixirSuite__Address__c,
                                                                      ElixirSuite__Address_2__c,
                                                                      ElixirSuite__Provider_Code__c,
                                                                      ElixirSuite__Provider_TaxId_Type__c,
                                                                      ElixirSuite__Provider_Tax_Id__c,
                                                                      ElixirSuite__Provider_City__c,
                                                                      ElixirSuite__Provider_State__c,
                                                                      ElixirSuite__Provider_Zip__c,
                                                                      ElixirSuite__Tax_Id_Type__c,
                                                                      ElixirSuite__Provider_Taxonomy__c
                                                                      FROM Provider__c 
                                                                      WHERE Id=:care.ElixirSuite__Care_Episode_Location__c
                                                                      WITH SECURITY_ENFORCED]);
            }
            
            if(String.isNotBlank(care.ElixirSuite__Rendering_Provider__c) && String.isNotEmpty(care.ElixirSuite__Rendering_Provider__c)){
                renderingProvIdVsRenderingProv = new Map<Id,Contact>([Select Id,firstName,LastName,MiddleName,
                                                                      Name,MailingStreet,MailingCity,MailingState,
                                                                      MailingPostalCode,ElixirSuite__Practitioner_NPI__c,
                                                                      ElixirSuite__ID_Number__c,ElixirSuite__Taxonomy__c,ElixirSuite__Tax_Id__c
                                                                      FROM Contact 
                                                                      WHERE Id=:care.ElixirSuite__Rendering_Provider__c
                                                                      WITH SECURITY_ENFORCED]);
            }
            if(String.isNotBlank(care.ElixirSuite__Account__c) && String.isNotEmpty(care.ElixirSuite__Account__c)){
                vobLst=[Select Id,ElixirSuite__Set_Default_VOB__c,
                        Name,ElixirSuite__Account__c
                        FROM VOB__c 
                        WHERE ElixirSuite__Account__c=:care.ElixirSuite__Account__c
                        AND ElixirSuite__Set_Default_VOB__c = 'Yes'
                        WITH SECURITY_ENFORCED];
            }
            
            if(billingProvIdVsBillingProv != null){
                wrpr.billingProvider = billingProvIdVsBillingProv.values();
            }
            if(serviceProvIdVsServiceProv != null){
                wrpr.serviceProvider = serviceProvIdVsServiceProv.values();
            }
            if(renderingProvIdVsRenderingProv != null){
                wrpr.renderingProvider = renderingProvIdVsRenderingProv.values();
            }
            if(care.ElixirSuite__Account__c != null){
                wrpr.patientRecId = care.ElixirSuite__Account__c;
            }
            if(care.ElixirSuite__Pre_Authorization_Number__c != null){
                wrpr.preAuthNumber = care.ElixirSuite__Pre_Authorization_Number__c;
            }
            if(vobLst.size() >0 && vobLst != null){
                wrpr.patientVob = vobLst;
            }
            ClaimTypeSelectionApex.PayerWrapper pw = new ClaimTypeSelectionApex.PayerWrapper();
            pw = ClaimTypeSelectionApex.fetchRecords(care.ElixirSuite__Account__c,'Primary','CMS_1500');
            
            wrpr.patientVob = vobLst;
            
            wrpr.payerList = pw.payerList;
            wrpr.vobList = pw.vobList;
            wrpr.recTypeid = pw.recTypeid;
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpr;
    }
    
    
    @AuraEnabled
    public static wrapper getAccountDetails( Id patientId,String vobId) {
        Wrapper wrpr = new Wrapper();
        try{
            
            Schema.DescribeSObjectResult res1 = Account.sObjectType.getDescribe();
            List<String> apiNames1 =  new List<String>(res1.fields.getMap().keySet());
            String query1 = 'SELECT ' +String.escapeSingleQuotes(String.join(apiNames1,',')) +' FROM Account ';
            query1+= 'WHERE Id = :patientId ';
            List<Account> allAccounts = (List<Account>)Database.query(query1);  
            Boolean territory = Account.getSobjectType().getDescribe().fields.getMap().keySet().contains('billingcountrycode');
            Account accDetails = allAccounts[0];
            
            /*Account accDetails = [SELECT Id, Name, ElixirSuite__Admit_Date__c,ElixirSuite__dischargeDateNew__c,CreatedDate, First_Name__c, Last_Name__c, Gender__c,ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,ShippingCountry
,birthdate__c,ElixirSuite__Patient_s_Birth_Date__c,ElixirSuite__DOB__c,ElixirSuite__MRN_Number_New__c , BillingStreet, BillingCity, ElixirSuite__Account_Number__c,BillingState, BillingPostalCode,BillingCountry,Phone
FROM Account where Id =: patientId
WITH SECURITY_ENFORCED];*/
            
            wrpr.plugDataPresent = false;
            Elixir_Custom_Setting__c elixirCustom = Elixir_Custom_Setting__c.getOrgDefaults();
            if(elixirCustom != null && elixirCustom.ElixirSuite__Send_Claim_To_ClaimMd__c){
                wrpr.plugDataPresent = true;
            }
            
            List<VOB__c> relatedData = new List<VOB__c>();
            relatedData = [SELECT Account__c,ElixirSuite__Insurance_Type__c,ElixirSuite__Insurance_Providers__c,ElixirSuite__Patient_Relationship_With_Insured__c,ElixirSuite__Telephone__c //added ElixirSuite__Telephone__c by Anusha
                           ,ElixirSuite__Insured_First_Name__c,ElixirSuite__Auto_Accident__c,ElixirSuite__Insured_Last_Name__c,ElixirSuite__Insured_Middle_Name__c,ElixirSuite__Employment__c,ElixirSuite__Is_there_another_Health_Benefit_Plan__c,
                           ElixirSuite__Other_Accident__c,Name,ElixirSuite__Insured_Address__c,ElixirSuite__Insured_State__c,ElixirSuite__Insured_City__c,/*ElixirSuite__Insured_Country__c,*/ElixirSuite__Insured_Zipcode__c, ElixirSuite__Insurance_Plan_Name__c //added ElixirSuite__Insured_Country__c by Anusha
                           ,ElixirSuite__Other_Insured_Policy_Group_FECA_Number__c,ElixirSuite__Insured_Policy_Group_FECA_Number__c,ElixirSuite__Other_Insured_s_Name__c,ElixirSuite__OtherInsurancePlanName__c,ElixirSuite__Gender__c
                           FROM VOB__c WHERE Account__c =: accDetails.Id AND  status__c='Active' and type__c='Primary' 
                           WITH SECURITY_ENFORCED
                           ORDER BY CreatedDate DESC LIMIT 1]; 
            List<ElixirSuite__Result__c> relatedResult = new List<ElixirSuite__Result__c>();
            if(relatedData!=null && relatedData.size()>0){
                relatedResult  = [SELECT ID,ElixirSuite__Insurance_Plan__c FROM ElixirSuite__Result__c
                                  WHERE VOB__c = : relatedData[0].Id  WITH SECURITY_ENFORCED
                                  ORDER BY CreatedDate DESC LIMIT 1];
            }
            wrpr.relatedResult = relatedResult;
            List<String> fields = new List<String>();
            fields.addAll((Claim__c.SObjectType.getDescribe().fields.getMap().keySet()));
            
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
            wrpr.territory = territory;
            wrpr.mapOfNameToField = mapOfNameToField;
            wrpr.mapOfNameToFieldAcc = mapOfNameToFieldAcc;
            wrpr.mapOfNameToFieldInsType = mapOfNameToFieldInsType;
            wrpr.accDetails = accDetails;
            wrpr.vobData = fetchVOBRecord(vobId) ;
            wrpr.claimFields = fields ;
            wrpr.acctRelatedProcData = fetchProcedureData(patientId); // xxx
            wrpr.patientDecision = fetchPatientDecision(); // xxx
            wrpr.allPickListPlaceOfService_ValuesIntoList = getPickListValuesIntoList(); 
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
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
                ' ElixirSuite__Procedure__r.ElixirSuite__Days_Units__c,ElixirSuite__Procedure__r.Name,ElixirSuite__Procedure__r.ElixirSuite__Place_Of_Service_Picklist__c,ElixirSuite__Procedure__r.ElixirSuite__CPT_HCPCS_Code__c '
                + ',ElixirSuite__Procedure__r.ElixirSuite__Surgeon__c,ElixirSuite__Procedure__r.ElixirSuite__Surgeon__r.ElixirSuite__Practitioner_NPI__c,ElixirSuite__Procedure__r.ElixirSuite__Surgeon__r.ElixirSuite__Tax_Id__c,ElixirSuite__Procedure__r.ElixirSuite__Surgeon__r.ElixirSuite__ID_Number__c,ElixirSuite__Procedure__r.ElixirSuite__Status__c,ElixirSuite__Procedure__r.ElixirSuite__Ready_for_Billing__c,ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c'
                ; 
            String procedureQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__Procedure_Diagnosis__c',otherFieldsAddition,additionFieldsPrefix+' order by CreatedDate ASC ');
            
            ElixirOEM_TimelineHelper.mDebugUntruncated(procedureQuery);
            wrprReturn.fetchProcedureForSpecifiedDates =  Database.query(procedureQuery);
            if(wrprReturn.fetchProcedureForSpecifiedDates.size()>0){
                wrprReturn.procedureCharge = wrprReturn.fetchProcedureForSpecifiedDates[0].ElixirSuite__Procedure__r.ElixirSuite__Charges__c;
            }
            
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
    public static list<ElixirSuite__ICD_Codes__c> fetchRelatedICDCode(Set<Id> recordIdLst){
        String additionFieldsPrefix = ' where Id IN : recordIdLst';
        String otherFieldsAddition = ''; 
        String icdCodeQuery = ElixirOEM_AddEraHelper.formulateQueryString('ElixirSuite__ICD_Codes__c',otherFieldsAddition,additionFieldsPrefix+'');
        //  ElixirOEM_TimelineHelper.mDebugUntruncated(icdCodeQuery);
        return Database.query(icdCodeQuery);
        
    }
    public class PointerHandleWrapper {
        @AuraEnabled public List<ElixirSuite__Procedure_Diagnosis__c> fetchProcedureForSpecifiedDates; 
        @AuraEnabled  public List<ElixirSuite__ICD_Codes__c> relatedICDCodes ;
        @AuraEnabled  public List<ElixirSuite__Provider__c> relatedRenderingProvider ;
        @AuraEnabled public Decimal procedureCharge ;
    }
    // [Select o.CreatedDate, o.Id, o.LastModifiedDate  from Opportunity o where   o.CreatedDate >: myDate and o.CreatedDate <:  myDate2 order by  o.LastModifiedDate] ;
    @AuraEnabled
    public static wrapper getDataForRangeApex(String fromDate, String toDate, String recordVal , String transId){
        Date fDate = Date.valueOf(fromDate);
        Date tDate = Date.valueOf(toDate);
        Map<String,VOB__c> map_vobData = new Map<String,VOB__c>();
        
        for(VOB__c objVob : [Select Id,Payer__c,Account__c from VOB__c where Account__c =:recordVal  WITH SECURITY_ENFORCED])
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
        List<Payor__c> relatedPayer = [SELECT Address__c, Id, Name, CreatedDate,Payer_Code__c, PayerType__c, State__c, City__c,Zip_Code__c, PhoneNumber__c, Procedure__c 
                                       FROM Payor__c WHERE Id IN: map_vobData.keySet() 
                                       WITH SECURITY_ENFORCED
                                       order by lastmodifieddate desc];
        
        Set<String> payerCode = new Set<String>();
        for(Payor__c pay : relatedPayer){
            payerCode.add(pay.Payer_Code__c);
        }
        
        //get patient's provider info
        List<Provider__c> relatedProvider = [SELECT Id, Name, CreatedDate,  Account__c, Provider_Code__c FROM Provider__c 
                                             where  Account__c=: recordVal WITH SECURITY_ENFORCED
                                             order by lastmodifieddate desc];
        
        Set<String> providerCode = new Set<String>();
        for(Provider__c pro : relatedProvider){
            providerCode.add(pro.Provider_Code__c);
        }
        List<Actual_Price__c> ActualListPrice = [SELECT id,Name , List_Price__c,Procedure__c,Provider__c,Procedure__r.Name, Procedure__r.CPT_HCPCS_Code__c,Provider__r.Provider_Code__c
                                                 from Actual_Price__c where Provider__r.Provider_Code__c IN : providerCode
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
        
        wrapper obj = new wrapper();
        obj.provider = relatedProvider ;
        obj.payer = relatedPayer ;
        obj.procedure = relatedProc ;
        obj.codeandPricelist = newMap ;
        obj.codeandPricelistForProvider = newMapForProvider ;
        return obj;
    }
    
    @AuraEnabled
    public static wrapper saveData(String jsonListData , String tabelListData , String recordVal ,String totalAmount , String transId, String vobId,
                                   String payorName,String dropDownOptions,String selectedClaimCodes,boolean sendToInsurance,List<String> ProcIDs){ //Anusha Added parameter- 'boolean sendToInsurance,' -03/11/22
                                       System.debug('json'+JSON.serialize(jsonListData));
                                       System.debug('table'+JSON.serialize(tabelListData));
                                       System.debug('drop down'+JSON.serialize(dropDownOptions));
                                       wrapper wrp = new wrapper();
                                       Map<String,Integer> procVsDaysUnit = new Map<String,Integer>();
                                       ElixirSuite__VOB__c vobRec = [SELECT Id,Name, ElixirSuite__Account__c,ElixirSuite__Payer__r.ElixirSuite__Claim_Processing_via__c
                                                                     FROM ElixirSuite__VOB__c 
                                                                     WHERE id=:vobId WITH SECURITY_ENFORCED order by CreatedDate desc limit 1];
                                       
                                       if(sendToInsurance){
                                           List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
                                           String virtualClassName;
                                           pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='NewClaimMDIntegration' WITH SECURITY_ENFORCED];
                                           if(pluggableClass != null && !pluggableClass.isEmpty()){
                                               
                                               virtualClassName = pluggableClass[0].Virtual_Class__c;
                                               
                                           }
                                           if(virtualClassName == '' && virtualClassName ==null && !Test.isRunningTest()){
                                               throw new AuraHandledException('Please configure a clearing house to send this claim.'); 
                                           }
                                           if(vobRec!=null && vobRec.ElixirSuite__Payer__r.ElixirSuite__Claim_Processing_via__c !='Clearing House' && !Test.isRunningTest()){
                                               throw new AuraHandledException('Claim for this payor can’t be send out to clearing house.');   
                                           }
                                       }
                                       Map<String, String> patientSex = new Map<String, String> {
                                           'female' => 'F',
                                               'male' => 'M',
                                               'f' => 'F',
                                               'm' => 'M'};
                                                   
                                                   Map<String, Object> lstOfDropDownOptions =(Map<String, Object>) JSON.deserializeUntyped(dropDownOptions);
                                       List<Object> obj_lstOfDropDownOptions = (List<Object>) lstOfDropDownOptions.get('keysToSave');
                                       
                                       
                                       List<Claim__c> claimData = new  List<Claim__c>();
                                       Boolean valTrue ,valTrue1 ,valTrue2,valTrue3 ;
                                       List<Claim_Line_Items__c> claimLineItemData = new List<Claim_Line_Items__c>();
                                       if(jsonListData!=null && !String.isEmpty(jsonListData)){
                                           system.debug('the string is' + jsonListData);
                                           List<masterWrapper> rootJson = (List<masterWrapper>)JSON.deserialize(jsonListData, List<masterWrapper>.class);
                                           system.debug('the string is' + rootJson);
                                           if(rootJson != null & rootJson.size()>0){
                                               for(masterWrapper masterRec : rootJson){
                                                   for(root rec : masterRec.Record){
                                                       Claim__c newClaim = new Claim__c(
                                                           ElixirSuite__Claim_Code_Options__c = JSON.serialize(obj_lstOfDropDownOptions),
                                                           Account__c = recordVal,                           
                                                           Patient_Name__c = rec.patientName ,
                                                           Insured_s_Name__c = rec.insuredName ,
                                                           Patient_s_Address__c = rec.patientAddress,
                                                           Patient_s_City__c = rec.patientCity ,
                                                           Patient_s_State__c = rec.patientState,
                                                           Patient_Zip_Code__c = rec.patientZipcode, //Anusha
                                                           Patient_s_Phone__c = rec.patientPhone ,
                                                           //ElixirSuite__Patient_Sex__c = rec.patiSex =='Female'? 'F' : 'M', //Anusha
                                                           Patient_Relationship_to_Insured__c = rec.relationWithInsured,
                                                           Insured_Address__c = rec.insuredAddress , 
Insured_Address_2__c = rec.insuredAddress2 ,
                                                           Patient_Address_2__c = rec.patientAddress2 ,
                                                           Insured_State__c = rec.insuredState ,
                                                           Insured_City__c = rec.insuredCity ,
                                                           Insured_Zip_Code__c = rec.insuredZipcode, //Anusha
                                                           Insured_Country_Code__c = rec.insuredCountry, //Anusha
                                                           Insured_Telephone__c = rec.insuredTelephone ,
                                                           Insured_s_ID_Number__c = rec.insuredIdNumber,
                                                           Other_Insured_s_Name__c = rec.otherInsuredName , 
                                                           Other_Insured_s_Policy_Group_Number__c = rec.otherInsuredPolicyNumber , 
                                                           Other_Insurance_Plan_Name__c = rec.otherInsurancePlanName , 
                                                           Insured_Policy__c = rec.insuredPolicyNumber , 
                                                           Other_Claim_Id__c = rec.otherClaimId , 
                                                           Claim_Codes__c = selectedClaimCodes , 
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
                                                           ElixirSuite__Service_Facility_Loc_City__c = rec.serviceFacilityLocationCity,
                                                           ElixirSuite__Service_Facility_Loc_State__c = rec.serviceFacilityLocationState,
                                                           ElixirSuite__Service_Facility_Loc_Zip__c = rec.serviceFacilityLocationZip,
                                                           Referring_Physician_Signature__c = rec.signOfPhysician,
                                                           ElixirSuite__Billing_Provider_Other_ID__c = rec.billingProviderInfoID,
                                                           Insured_Authorized_Person_Signature__c = rec.insuredSign ,
                                                           Patient_Signature__c = rec.patientSign ,
                                                           ElixirSuite__Billing_Provider_Info__c = rec.billingProviderInfoNpi,
                                                           ElixirSuite__Billing_Provider_Name__c =rec.billingProviderName, //Anusha - start -07/11/22   
                                                           Billing_Provider_Address_1__c=rec.billingProviderAddress1,
                                                           Billing_Provider_Address_2__c=rec.billingProviderAddress2,
                                                           ElixirSuite__Billing_Provider_City__c=rec.billingProviderCity,
                                                           ElixirSuite__Billing_Provider_State__c=rec.billingProviderState,
                                                           ElixirSuite__Billing_Provider_Zip__c=rec.billingProviderzipCode,
                                                           ElixirSuite__Bill_Phone__c=rec.billingProviderPhone,
                                                           ElixirSuite__Billing_Provider_Tax_ID__c=rec.billingProviderTaxId,
                                                           ElixirSuite__Billing_Provider_Taxonomy__c=rec.billingProviderTaxonomy, //Anusha - end -07/11/22
                                                           ElixirSuite__Billing_Provider_Info_NPI__c = rec.billingProviderInfoNpi,
                                                           Accept_Assignment__c = rec.acceptAssignment,
                                                           ElixirSuite__Patient_Account_Number__c = rec.PatientAccNo,
                                                           ElixirSuite__Reserved_For_NUCC_Use3__c = rec.reservedforNUCCuse4,
                                                           ElixirSuite__Sign_of_Phy_or_Supplier_Signature__c = rec.SupsignOfPhysician,
                                                           ElixirSuite__Auto_Accident_Related__c = rec.autoAccPlaceOrState,
                                                           ElixirSuite__Insured_DOB__c = Date.valueOf(rec.insuredDOB),
                                                           ElixirSuite__VOB_lookup__c =  vobId, //Anusha
                                                           ElixirSuite__Patient_Country_Code__c = rec.patientCountry,
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
                                                           ElixirSuite__Diagnosis_A__c = rec.diagnosis_A.length()>8? rec.diagnosis_A.substring(0,8) :rec.diagnosis_A, //xxx //Anusha-substring-start
                                                           ElixirSuite__Diagnosis_B__c = rec.diagnosis_B.length()>8? rec.diagnosis_B.substring(0,8) :rec.diagnosis_B, //xxx
                                                           ElixirSuite__Diagnosis_C__c = rec.diagnosis_C.length()>8? rec.diagnosis_C.substring(0,8) :rec.diagnosis_C, //xxx
                                                           ElixirSuite__Diagnosis_D__c = rec.diagnosis_D.length()>8? rec.diagnosis_D.substring(0,8) :rec.diagnosis_D, //xxx
                                                           ElixirSuite__Diagnosis_E__c = rec.diagnosis_E.length()>8? rec.diagnosis_E.substring(0,8) :rec.diagnosis_E, //xxx
                                                           ElixirSuite__Diagnosis_F__c = rec.diagnosis_F.length()>8? rec.diagnosis_F.substring(0,8) :rec.diagnosis_F, //xxx
                                                           ElixirSuite__Diagnosis_G__c = rec.diagnosis_G.length()>8? rec.diagnosis_G.substring(0,8) :rec.diagnosis_G, //xxx
                                                           ElixirSuite__Diagnosis_H__c = rec.diagnosis_H.length()>8? rec.diagnosis_H.substring(0,8) :rec.diagnosis_H, //xxx
                                                           ElixirSuite__Diagnosis_I__c = rec.diagnosis_I.length()>8? rec.diagnosis_I.substring(0,8) :rec.diagnosis_I, //xxx
                                                           ElixirSuite__Diagnosis_J__c = rec.diagnosis_J.length()>8? rec.diagnosis_J.substring(0,8) :rec.diagnosis_J, //xxx
                                                           ElixirSuite__Diagnosis_K__c = rec.diagnosis_K.length()>8? rec.diagnosis_K.substring(0,8) :rec.diagnosis_K, //xxx
                                                           ElixirSuite__Diagnosis_L__c = rec.diagnosis_L.length()>8? rec.diagnosis_L.substring(0,8) :rec.diagnosis_L, //xxx //Anusha-substring-end
                                                           ElixirSuite__Prior_Authorization_Number__c = rec.priorAuthNumber, //XXX
                                                           ElixirSuite__Resubmission_Code__c = rec.resubmissionCode,//XXX
                                                           ElixirSuite__Original_Ref_No__c = rec.orignalRefNumber,//XXX
                                                           ElixirSuite__Payer_Order__c = 'Primary',
                                                           // Insured_DOB__c = rec. ,
                                                           //Insured_Sex__c = rec.insuredSex =='Female'? 'F' : 'M' //Anusha
                                                           ElixirSuite__Rendering_Provider_First_Name__c = rec.RenderingProvider_FirstName, // added by Jami, syncing with claim.md for rendering provider
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
                                                       if(!String.isBlank(rec.careId)){
                                                           newClaim.Visits__c = rec.careId ;
                                                       }
                                                       if(!String.isBlank(rec.insuredSex) && patientSex.containsKey((rec.insuredSex).toLowerCase())){
                                                           newClaim.ElixirSuite__Insured_Sex__c = patientSex.get((rec.insuredSex).toLowerCase());
                                                       }else{
                                                           newClaim.ElixirSuite__Insured_Sex__c = 'U';  
                                                       }
                                                       
                                                       if(!String.isBlank(rec.patiSex) && patientSex.containsKey((rec.patiSex).toLowerCase())){
                                                           newClaim.ElixirSuite__Patient_Sex__c = patientSex.get((rec.patiSex).toLowerCase());
                                                       }else{
                                                           newClaim.ElixirSuite__Patient_Sex__c = 'U';  
                                                       }
                                                       
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
                                                       if(!String.isBlank(rec.employmentPicklistValues)){
                                                           if(rec.employmentPicklistValues == 'YES')
                                                               newClaim.Patient_Condition_Related_To_Employment__c = true ;
                                                           else
                                                               newClaim.Patient_Condition_Related_To_Employment__c = false ;
                                                       }
                                                       if(!String.isBlank(rec.autoAccidentPicklistValues)){
                                                           if(rec.autoAccidentPicklistValues == 'YES')
                                                               newClaim.Patient_Condition_Related_To_Accident__c = true ;
                                                           else
                                                               newClaim.Patient_Condition_Related_To_Accident__c = false ;
                                                       }
                                                       if(!String.isBlank(rec.otherAccidentPicklistValues)){
                                                           if(rec.otherAccidentPicklistValues == 'YES')
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
                                                       if(!String.isBlank(rec.patientZipcode)) 
                                                           newClaim.Patient_Zip_Code__c = string.valueOf(rec.patientZipcode)  ; //Anusha
                                                       if(!String.isBlank(rec.insuredZipcode)) 
                                                           newClaim.Insured_Zip_Code__c = string.valueOf(rec.insuredZipcode) ; //Anusha
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
                                                           newClaim.Total_Charge__c = Decimal.valueOf(rec.TotalCharges) ;
                                                       if(String.isNotBlank(rec.otherDate_InsuredPersonAuth)){
                                                           newClaim.ElixirSuite__Insured_Or_Auth_Persn_Date__c = date.valueOf(rec.otherDate_InsuredPersonAuth);
                                                       }
                                                       claimData.add(newClaim); 
                                                   }
                                               }
                                               system.debug('hhh' + claimData);
                                               if(Schema.sObjectType.Claim__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Claim_Code_Options__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Account__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Insurance_Type__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_Name__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Insured_s_Name__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_s_Address__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_s_City__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_s_State__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_s_Phone__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_Sex__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_Relationship_to_Insured__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Insured_Address__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Insured_State__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Insured_City__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Insured_Country_Code__c.isCreateable() && //Anusha
                                                  Schema.sObjectType.Claim__c.fields.Insured_Telephone__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Insured_s_ID_Number__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Other_Insured_s_Name__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Other_Insured_s_Policy_Group_Number__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Other_Insurance_Plan_Name__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Insured_Policy__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Other_Claim_Id__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Claim_Codes__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Claim_Status__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Billing_Provider_Tax_ID_Type__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Additional_Claim_Information__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Federal_Tax_Id_Number__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Name_of_referring_provider_Other_sourc__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Service_Facility_Location_Information__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Service_Facility_Location_NPI__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Referring_Physician_Signature__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Billing_Provider_Other_ID__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Insured_Authorized_Person_Signature__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_Signature__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Billing_Provider_Info__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Billing_Provider_Info_NPI__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Accept_Assignment__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Patient_Account_Number__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Reserved_For_NUCC_Use3__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Sign_of_Phy_or_Supplier_Signature__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Auto_Accident_Related__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Servic_Fcility_Loc_Informaton_OtherID__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Insured_DOB__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Reserved_For_NUCC_Use1__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Reserved_For_NUCC_Use2__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.NPI__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__QUAL_For_Date_current_illness_injury__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__QUAL_For_Other_Dates__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__NUCC__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__NUCC_Description__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Outside_Lab_new__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Outside_Lab_Charges__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__QUAL_For_Name_of_referring_provider__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__First_Name_NAME_OF_REFERRING_PROVIDER__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Last_Name_NAME_OF_REFERRING_PROVIDER__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__MiddleName_NAME_OF_REFERRING_PROVIDER__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_A__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_B__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_C__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_D__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_E__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_F__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_G__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_H__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_I__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_J__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_K__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Diagnosis_L__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Prior_Authorization_Number__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Resubmission_Code__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Original_Ref_No__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Insured_Sex__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Hospitalization_From_Date__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Hospitalization_To_Date__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Payor__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Sign_of_Phy_or_Supplier_Date__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__From_Date_Patient_Unable_To_Work__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__To_Date_Patient_Unable_To_Work__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_Condition_Related_To_Employment__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_Condition_Related_To_Accident__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_Condition_to_Other_Accident__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Any_Other_Health_Benefit_Plan__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_DOB__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Patient_Zip_Code__c.isCreateable() && //Anusha
                                                  Schema.sObjectType.Claim__c.fields.Insured_Zip_Code__c.isCreateable() && //Anusha
                                                  Schema.sObjectType.Claim__c.fields.Date_Of_Current_Illness__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Hospitalization_Dates__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Other_Date__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Dates_Patient_Unable_To_Work__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Amount_Paid__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.Total_Charge__c.isCreateable() &&
                                                  Schema.sObjectType.Claim__c.fields.ElixirSuite__Insured_Or_Auth_Persn_Date__c.isCreateable()){
                                                      insert claimData;
                                                      wrp.newClaimId = claimData[0].Id;
                                                  }
                                           }
                                       }
                                       integer i = 0;
                                       Set<Id> procId = new Set<Id>();
                                       if(tabelListData!=null && !String.isEmpty(tabelListData)){
                                           List<masterWrapperRelated> relatedRootJson = (List<masterWrapperRelated>)JSON.deserialize(tabelListData, List<masterWrapperRelated>.class);
                                           
                                           if(relatedRootJson != null & relatedRootJson.size()>0){
                                               for(masterWrapperRelated masterRec : relatedRootJson){
                                                   for(relatedRoot rec : masterRec.Record){
                                                       if(String.isNotBlank(rec.Id)){
                                                           String CPT_HCPCS_Code = fetchCodeName(rec.cptCode_Procedure);
                                                           procId.add(rec.Id);
                                                           String icdLookupId = '';
                                                           if(String.isNotBlank(String.valueOf(rec.cptCode_Procedure))){
                                                               icdLookupId = String.valueOf(rec.cptCode_Procedure);                      
                                                           }
                                                           //ElixirSuite__ICD_Codes__c = icdLookupId,
                                                           Claim_Line_Items__c newClaimLineItem = new  Claim_Line_Items__c(
                                                               Claim__c = claimData[i].Id ,
                                                               ElixirSuite__EMG__c = rec.emergency_Procedure,
                                                               ElixirSuite__Place_of_Service__c = rec.placeOfService_Procedure,
                                                               ElixirSuite__Place_of_Service_Code_s__c = rec.placeOfService_Procedure!=null ? rec.placeOfService_Procedure.substring(0,2) : '', //Anusha
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
                                                               ElixirSuite__CPT_HCPCS_Code__c =  rec.cptCodeName_Procedure,                                                           
                                                               Procedure__c= rec.Id
                                                               
                                                           );
                                                           procVsDaysUnit.put(rec.Id,Integer.valueOf(rec.daysOrUnit_Procedure));
                                                           if(!String.isBlank(rec.fromDate_Procedure)) 
                                                               newClaimLineItem.ElixirSuite__From_Date_Of_Service__c =date.valueOf(rec.fromDate_Procedure) ;
                                                           if(!String.isBlank(rec.toDate_Procedure)) 
                                                               newClaimLineItem.ElixirSuite__To_Date_Of_Service__c = date.valueOf(rec.toDate_Procedure) ;
                                                           if( rec.cptCodeName_Procedure!=''){
                                                               claimLineItemData.add(newClaimLineItem);
                                                           }
                                                       }
                                                   }
                                               }
                                               if(Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__To_Date_Of_Service__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__From_Date_Of_Service__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Place_of_Service_Name__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Place_of_Service_Code_s__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.Procedure__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__CPT_HCPCS_Code__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Rendering_Provider_NPI__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Rendering_Provider_Non_NPI__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__ID_Qual__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__EPSTD__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Family_Plan__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Days_Units__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__ID_Qual__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__EPSTD__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Family_Plan__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Procedure_Charge__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Modifier_1__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Modifier_2__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Modifier_3__c.isCreateable() &&
                                                  Schema.sObjectType.Claim_Line_Items__c.fields.ElixirSuite__Modifier_4__c.isCreateable()){
                                                      insert claimLineItemData;
                                                  }
                                               List<Procedure__c> relatedProc = [SELECT Id, Name,Claim__c, CreatedDate, From_Date__c, To_Date__c, CPT_HCPCS_Code__c, Account__c, Code_Description__c,ElixirSuite__Days_Units__c
                                                                                 FROM Procedure__c
                                                                                 WHERE id IN : procId AND Account__c=: recordVal WITH SECURITY_ENFORCED];
                                               for(Procedure__c proc : relatedProc){
                                                   if(procVsDaysUnit != null && procVsDaysUnit.size() >0 && procVsDaysUnit.containsKey(proc.id) && proc.ElixirSuite__Days_Units__c != procVsDaysUnit.get(proc.Id)){
                                                       proc.ElixirSuite__Days_Units__c = procVsDaysUnit.get(proc.Id);
                                                   }
                                                   proc.Claim__c = claimData[i].Id ;
                                                   proc.ElixirSuite__Claim_Generation__c = true;
                                               }
                                               if(Schema.sObjectType.Procedure__c.fields.Claim__c.isUpdateable()){
                                                   update relatedProc;
                                               }
                                           }
                                       }
                                       if(sendToInsurance){ //Anusha - start -03/11/22
                                           String claimIds=''; 
                                           for(Claim__c eachRec:claimData){    
                                               eachRec.Claim_Status__c='Ready to Submit';
                                               claimIds+=(eachRec.id+','); 
                                           }   
                                           DMLManager.updateAsUser(claimData);
                                           SendClaimController.updateClaims(claimIds); 
                                           
                                       } //Anusha - End -03/11/22
                                       return wrp;
                                   }
    public static String fetchCodeName(String icdCode){
        String toReturnName = '';
        ElixirSuite__ICD_Codes__c[] lst =  [SELECT ID,Name from ElixirSuite__ICD_Codes__c where ID = : icdCode
                                            WITH SECURITY_ENFORCED];
        if(lst!=null && lst.size()>0){
            toReturnName = lst[0].Name;
        }
        return toReturnName;
    }
    @AuraEnabled
    public static List<String> fetchICDCodes(){
        List<String> lstOfICDCodes = new List<String>();
        for(ElixirSuite__ICD_Codes__c sObj :  [SELECT ID,Name FROM ElixirSuite__ICD_Codes__c
                                               WHERE Name!=NULL  WITH SECURITY_ENFORCED]){
                                                   lstOfICDCodes.add(sObj.Name);
                                               }
        return lstOfICDCodes;
    }
    @AuraEnabled
    public static  Map<String,list<sObject>> fetchCusomMetadataRecord()
    {
        Map<String,list<sObject>> Mastermdt = new Map<String,list<sObject>>();
        List<ElixirSuite__ClaimCodesMetaDataType__mdt> mdt  = [select id,ElixirSuite__Code__c,ElixirSuite__Description__c from 
                                                               ElixirSuite__ClaimCodesMetaDataType__mdt WHERE ElixirSuite__Code__c!=null WITH SECURITY_ENFORCED]; 
        Mastermdt.put('ClaimCodes',mdt);
        return Mastermdt;
    }
    string custtr;
    public class wrapper{
        @AuraEnabled public List<ElixirSuite__Result__c> relatedResult ;
        @AuraEnabled public Boolean isVobPresent = true;
        @AuraEnabled public Boolean territory = false;
        @AuraEnabled public Map<String,List<String>> mapOfNameToField ;
        @AuraEnabled public Map<String, Map<String, String>> mapOfNameToFieldInsType ;
        @AuraEnabled public Map<String,List<String>> mapOfNameToFieldAcc ;
        @AuraEnabled public Account accDetails ;
        @AuraEnabled public List<VOB__c> vobData ;
        @AuraEnabled public List<Provider__c> provider ;
        @AuraEnabled public Boolean plugDataPresent;
        @AuraEnabled public List<Payor__c> payer ;
        @AuraEnabled public List<Procedure__c> procedure ;
        @AuraEnabled public List<String> claimFields ;
        @AuraEnabled public Map<String , Contracted_Price__c> codeandPricelist ;
        @AuraEnabled public Map<String , Actual_Price__c> codeandPricelistForProvider ;
        @AuraEnabled public String patientDecision ;
        @AuraEnabled public List<ElixirSuite__Procedure__c> acctRelatedProcData;
        @AuraEnabled public List<String> allPickListPlaceOfService_ValuesIntoList;
        @AuraEnabled public ElixirSuite__CMS_1500_Claim_Generation__c claimCustomSettingValues =  ElixirSuite__CMS_1500_Claim_Generation__c.getInstance();
        @AuraEnabled public String newClaimId;
    }
    
    public class careWrapper{
        @AuraEnabled public Provider__c billingProvider;
        @AuraEnabled public Provider__c serviceProvider;
        @AuraEnabled public Contact renderingProvider;
        @AuraEnabled public String patientRecId;
        @AuraEnabled public String preAuthNumber;
        @AuraEnabled public List<VOB__c> patientVob;
        @auraEnabled public List<Sobject> payerList;
        @AuraEnabled public List<ElixirSuite__VOB__c> vobList;
        @auraEnabled public Id  recTypeid;
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
        public String patiSex {get;set;}
        @AuraEnabled  
        public String insuredSex {get;set;}
        @AuraEnabled  
        public String id {get;set;}
        @AuraEnabled   
        public String careId {get;set;}
        @AuraEnabled   
public String insuredAddress2 {get;set;}
        @AuraEnabled   
        public String patientAddress2 {get;set;}
        @AuraEnabled   
        public String billingProviderInfoID {get;set;}
        @AuraEnabled   
        public Date insuredDOB {get;set;}
        @AuraEnabled   
        public Id insuredId {get;set;}
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
        public String autoAccidentPicklistValues {get;set;}
        @AuraEnabled
        public String employmentPicklistValues {get;set;}
        @AuraEnabled
        public String IsthereanotherHealthBenefitPlan {get;set;}
        @AuraEnabled
        public String otherAccidentPicklistValues {get;set;}
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
        public String  serviceFacilityLocationAddress {get;set;}
        @AuraEnabled
        public String  serviceFacilityLocationAddress2 {get;set;}
        @AuraEnabled
        public String  serviceFacilityLocationCity {get;set;}
        @AuraEnabled
        public String  serviceFacilityLocationState {get;set;}
        @AuraEnabled
        public String  serviceFacilityLocationZip {get;set;}
        @AuraEnabled 
        public String  billingProviderInfoNpi {get;set;}
        @AuraEnabled 
        public String  billingProviderInfo {get;set;}
        @AuraEnabled
        public String  billingProviderInfoOtherId {get;set;}
        @AuraEnabled //Anusha -start - 07/11/22 
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
        //Anusha -end - 07/11/22
        //Anusha -start
        @AuraEnabled    
        public String  patientCountry {get;set;}
        //Anusha -end
        @AuraEnabled
        public String  PatientAccNo {get;set;}
        @AuraEnabled
        public String  signOfPhysician {get;set;}
        @AuraEnabled
        public String  claimCodes {get;set;}
        @AuraEnabled
        public String  insuredAddress {get;set;}
        @AuraEnabled
        public String  insuredState {get;set;}
        @AuraEnabled
        public String  insuredCity {get;set;}
        @AuraEnabled        
        public String  insuredCountry {get;set;}
        //Anusha
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
    
}