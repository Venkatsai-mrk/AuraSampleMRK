public with sharing class ListViewController {
    @AuraEnabled
    public static claimsWrapper BringDataFirst( String recId){
        Integer totalCount = 0; 
        list<Claim__c> ClaimToPost = new list<Claim__c>();
        ClaimToPost=[select id,ElixirSuite__Payor__r.Name,ElixirSuite__Total_Paid__c,ElixirSuite__Total_Adjustment__c,Accept_Assignment__c,Additional_Claim_Information__c,Amount_Paid__c,Any_Other_Health_Benefit_Plan__c,Billing_Provider_Info__c,CreatedDate
                     ,Claim_Codes__c,Name,Claim_Status__c,Date_Of_Current_Illness__c,Dates_Patient_Unable_To_Work__c,Federal_Tax_Id_Number__c,payerid__c 
                     ,Hospitalization_Dates__c,Insurance_Plan_Name__c,Other_Insurance_Plan_Name__c,Insurance_Type__c,Insured_Authorized_Person_Signature__c
                     ,Insured_Address__c,Insured_City__c,Insured_DOB__c,Insured_Policy__c,Insured_Sex__c,Insured_State__c,Insured_Telephone__c,Insured_Zipcode__c
                     ,Insured_s_Name__c,Insured_s_ID_Number__c,Name_of_referring_provider_Other_sourc__c,NPI__c,Other_Claim_Id__c,Other_Date__c,Other_Insured_s_Name__c
                     ,Other_Insured_s_Policy_Group_Number__c,Outside_Lab__c,Account__c,Patient_Condition_Related_To_Accident__c,Patient_Condition_Related_To_Employment__c
                     ,Patient_Condition_to_Other_Accident__c,Patient_DOB__c,Patient_Name__c,Patient_Relationship_to_Insured__c,Patient_Sex__c,Patient_Signature__c,Patient_s_Phone__c,
                     Patient_s_City__c,Patient_s_State__c,Patient_s_Zipcode__c,Total_Charge__c,Referring_Physician_Signature__c,Reserved_For_NUCC_Use1__c,Reserved_For_NUCC_Use2__c,
                     Reserved_For_NUCC_Use3__c,Service_Facility_Location_Information__c,Billing_Provider_Name__c,Billing_Provider_City__c,Billing_Provider_Address_1__c,Billing_Provider_State__c,
                     Total_Amount_Paid_By_Insurance__c,Total_Adjustment_Amount__c
                     ,Billing_Provider_Zip__c,Bill_Phone__c,First_Diagnosis__c,Billing_Provider_Tax_ID__c,Billing_Provider_Tax_ID_Type__c,Other_Payer_Name__c,Payer_ID__c
                     FROM Claim__c WHERE Account__c= :recId WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 5];
        List<AggregateResult> claimsCount = [SELECT count(Id) c FROM Claim__c WHERE Account__c=: recId WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        claimsWrapper claimsToReturn = new claimsWrapper(ClaimToPost, totalCount);
        return claimsToReturn;
    }
    public class claimsWrapper{
        @AuraEnabled public Integer totalCount ;
        @AuraEnabled public List<Claim__c> ClaimToPost;
        claimsWrapper(List<Claim__c> ClaimToPost, Integer totalCount){
            this.ClaimToPost = ClaimToPost;
            this.totalCount = totalCount;
        }
    }
    @AuraEnabled
    public static claimsWrapper BringDataViewAll( String recId){
        Integer totalCount = 0;
        list<Claim__c> ClaimToPost = new list<Claim__c>();
        ClaimToPost=[select id,ElixirSuite__Payor__r.Name,ElixirSuite__Total_Paid__c,ElixirSuite__Total_Adjustment__c,Accept_Assignment__c,Additional_Claim_Information__c,Amount_Paid__c,Any_Other_Health_Benefit_Plan__c,Billing_Provider_Info__c,CreatedDate
                     ,Claim_Codes__c,Name,Claim_Status__c,Date_Of_Current_Illness__c,Dates_Patient_Unable_To_Work__c,Federal_Tax_Id_Number__c,payerid__c 
                     ,Hospitalization_Dates__c,Insurance_Plan_Name__c,Other_Insurance_Plan_Name__c,Insurance_Type__c,Insured_Authorized_Person_Signature__c
                     ,Insured_Address__c,Insured_City__c,Insured_DOB__c,Insured_Policy__c,Insured_Sex__c,Insured_State__c,Insured_Telephone__c,Insured_Zipcode__c
                     ,Insured_s_Name__c,Insured_s_ID_Number__c,Name_of_referring_provider_Other_sourc__c,NPI__c,Other_Claim_Id__c,Other_Date__c,Other_Insured_s_Name__c
                     ,Other_Insured_s_Policy_Group_Number__c,Outside_Lab__c,Account__c,Patient_Condition_Related_To_Accident__c,Patient_Condition_Related_To_Employment__c
                     ,Patient_Condition_to_Other_Accident__c,Patient_DOB__c,Patient_Name__c,Patient_Relationship_to_Insured__c,Patient_Sex__c,Patient_Signature__c,Patient_s_Phone__c,
                     Patient_s_City__c,Patient_s_State__c,Patient_s_Zipcode__c,Total_Charge__c,Referring_Physician_Signature__c,Reserved_For_NUCC_Use1__c,Reserved_For_NUCC_Use2__c,
                     Reserved_For_NUCC_Use3__c,Service_Facility_Location_Information__c,Billing_Provider_Name__c,Billing_Provider_City__c,Billing_Provider_Address_1__c,Billing_Provider_State__c
                     ,Billing_Provider_Zip__c,Bill_Phone__c,First_Diagnosis__c,Billing_Provider_Tax_ID__c,Billing_Provider_Tax_ID_Type__c,Other_Payer_Name__c,Payer_ID__c
                     from Claim__c where Account__c=: recId WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 40000];
        List<AggregateResult> claimsCount = [SELECT count(Id) c FROM Claim__c WHERE Account__c=: recId WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        claimsWrapper claimsToReturn = new claimsWrapper(ClaimToPost, totalCount);
        return claimsToReturn;
    }
    
    @AuraEnabled
    public static claimswrapper BringFilterData(string fromDate , string toDate , String recId){
        Integer totalCount = 0;
        list<Claim__c> ClaimToPost = new list<Claim__c>();
        ClaimToPost=[select id,ElixirSuite__Payor__r.Name,ElixirSuite__Total_Paid__c,ElixirSuite__Total_Adjustment__c,Accept_Assignment__c,Additional_Claim_Information__c,Amount_Paid__c,Any_Other_Health_Benefit_Plan__c,Billing_Provider_Info__c,CreatedDate
                     ,Claim_Codes__c,Name,Claim_Status__c,Date_Of_Current_Illness__c,Dates_Patient_Unable_To_Work__c,Federal_Tax_Id_Number__c,payerid__c 
                     ,Hospitalization_Dates__c,Insurance_Plan_Name__c,Other_Insurance_Plan_Name__c,Insurance_Type__c,Insured_Authorized_Person_Signature__c
                     ,Insured_Address__c,Insured_City__c,Insured_DOB__c,Insured_Policy__c,Insured_Sex__c,Insured_State__c,Insured_Telephone__c,Insured_Zipcode__c
                     ,Insured_s_Name__c,Insured_s_ID_Number__c,Name_of_referring_provider_Other_sourc__c,NPI__c,Other_Claim_Id__c,Other_Date__c,Other_Insured_s_Name__c
                     ,Other_Insured_s_Policy_Group_Number__c,Outside_Lab__c,Account__c,Patient_Condition_Related_To_Accident__c,Patient_Condition_Related_To_Employment__c
                     ,Patient_Condition_to_Other_Accident__c,Patient_DOB__c,Patient_Name__c,Patient_Relationship_to_Insured__c,Patient_Sex__c,Patient_Signature__c,Patient_s_Phone__c,
                     Patient_s_City__c,Patient_s_State__c,Patient_s_Zipcode__c,Total_Charge__c,Referring_Physician_Signature__c,Reserved_For_NUCC_Use1__c,Reserved_For_NUCC_Use2__c,
                     Reserved_For_NUCC_Use3__c,Service_Facility_Location_Information__c,Billing_Provider_Name__c,Billing_Provider_City__c,Billing_Provider_Address_1__c,Billing_Provider_State__c
                     ,Billing_Provider_Zip__c,Bill_Phone__c,First_Diagnosis__c,Billing_Provider_Tax_ID__c,Billing_Provider_Tax_ID_Type__c,Other_Payer_Name__c,Payer_ID__c
                     from Claim__c where Account__c=: recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate) 
                     WITH SECURITY_ENFORCED
                     ORDER BY CreatedDate DESC LIMIT 5];
        List<AggregateResult> claimsCount = [SELECT count(Id) c FROM Claim__c WHERE Account__c=: recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate) WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        claimsWrapper claimsToReturn = new claimsWrapper(ClaimToPost, totalCount);
        return claimsToReturn;
    }
    
    @AuraEnabled
    public static claimsWrapper BringFilterDataViewAll(string fromDate , string toDate , String recId){
        Integer totalCount = 0;
        list<Claim__c> ClaimToPost = new list<Claim__c>();
        if(String.isNotBlank(fromDate) && String.isNotBlank(toDate)){
            ClaimToPost=[select id,ElixirSuite__Payor__r.Name,ElixirSuite__Total_Paid__c,ElixirSuite__Total_Adjustment__c,Accept_Assignment__c,Additional_Claim_Information__c,Amount_Paid__c,Any_Other_Health_Benefit_Plan__c,Billing_Provider_Info__c,CreatedDate
                         ,Claim_Codes__c,Name,Claim_Status__c,Date_Of_Current_Illness__c,Dates_Patient_Unable_To_Work__c,Federal_Tax_Id_Number__c,payerid__c 
                         ,Hospitalization_Dates__c,Insurance_Plan_Name__c,Other_Insurance_Plan_Name__c,Insurance_Type__c,Insured_Authorized_Person_Signature__c
                         ,Insured_Address__c,Insured_City__c,Insured_DOB__c,Insured_Policy__c,Insured_Sex__c,Insured_State__c,Insured_Telephone__c,Insured_Zipcode__c
                         ,Insured_s_Name__c,Insured_s_ID_Number__c,Name_of_referring_provider_Other_sourc__c,NPI__c,Other_Claim_Id__c,Other_Date__c,Other_Insured_s_Name__c
                         ,Other_Insured_s_Policy_Group_Number__c,Outside_Lab__c,Account__c,Patient_Condition_Related_To_Accident__c,Patient_Condition_Related_To_Employment__c
                         ,Patient_Condition_to_Other_Accident__c,Patient_DOB__c,Patient_Name__c,Patient_Relationship_to_Insured__c,Patient_Sex__c,Patient_Signature__c,Patient_s_Phone__c,
                         Patient_s_City__c,Patient_s_State__c,Patient_s_Zipcode__c,Total_Charge__c,Referring_Physician_Signature__c,Reserved_For_NUCC_Use1__c,Reserved_For_NUCC_Use2__c,
                         Reserved_For_NUCC_Use3__c,Service_Facility_Location_Information__c,Billing_Provider_Name__c,Billing_Provider_City__c,Billing_Provider_Address_1__c,Billing_Provider_State__c
                         ,Billing_Provider_Zip__c,Bill_Phone__c,First_Diagnosis__c,Billing_Provider_Tax_ID__c,Billing_Provider_Tax_ID_Type__c,Other_Payer_Name__c,Payer_ID__c
                         from Claim__c where Account__c=: recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate) 
                         WITH SECURITY_ENFORCED
                         ORDER BY CreatedDate DESC LIMIT 40000];
            List<AggregateResult> claimsCount = [SELECT count(Id) c FROM Claim__c WHERE Account__c=: recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate) WITH SECURITY_ENFORCED];
            if(claimsCount!=null && claimsCount.size()>0){
                totalCount = Integer.valueOf(claimsCount[0].get('c'));
            }
            claimsWrapper claimsToReturn = new claimsWrapper(ClaimToPost, totalCount);
            return claimsToReturn;
        }else{
            claimsWrapper claimsToReturn = BringDataViewAll(recId);
            return claimsToReturn;
        }
    }
    @AuraEnabled //Anusha -start - 29/10/22
    public static string getCustomSettings(){
        return ClaimTypeSelectionApex.fetchDisplaySettings();
    } //Anusha -End - 29/10/22
    @AuraEnabled
    public Static String generateXML(list<String> claimIds){
        SYSTEM.debug('claims  '+claimIds);
        Dom.Document doc = new Dom.Document();
        
        Dom.Xmlnode rootNode = doc.createRootElement('Claims', null, null);
        Dom.Xmlnode headerNode = rootNode.addChildElement('claim', null, null);
        Dom.Xmlnode childNode = headerNode.addChildElement('Charge', null, null);
        //assign header attributes
        
        list<Claim__c> ClaimToPost = new list<Claim__c>();
        ClaimToPost=[select id,ElixirSuite__Payor__r.Name,ElixirSuite__Total_Paid__c,ElixirSuite__Total_Adjustment__c,Accept_Assignment__c,Additional_Claim_Information__c,Amount_Paid__c,Any_Other_Health_Benefit_Plan__c,Billing_Provider_Info__c
                     ,Claim_Codes__c,Name,Claim_Status__c,Date_Of_Current_Illness__c,Dates_Patient_Unable_To_Work__c,Federal_Tax_Id_Number__c
                     ,Hospitalization_Dates__c,Insurance_Plan_Name__c,Other_Insurance_Plan_Name__c,Insurance_Type__c,Insured_Authorized_Person_Signature__c
                     ,Insured_Address__c,Insured_City__c,Insured_DOB__c,Insured_Policy__c,Insured_Sex__c,Insured_State__c,Insured_Telephone__c,Insured_Zipcode__c
                     ,Insured_s_Name__c,Insured_s_ID_Number__c,Name_of_referring_provider_Other_sourc__c,NPI__c,Other_Claim_Id__c,Other_Date__c,Other_Insured_s_Name__c
                     ,Other_Insured_s_Policy_Group_Number__c,Outside_Lab__c,Account__r.Name,Patient_Condition_Related_To_Accident__c,Patient_Condition_Related_To_Employment__c
                     ,Patient_Condition_to_Other_Accident__c,Patient_DOB__c,Patient_Name__c,Patient_Relationship_to_Insured__c,Patient_Sex__c,Patient_Signature__c,Patient_s_Phone__c,
                     Patient_s_City__c,Patient_s_State__c,Patient_s_Zipcode__c,Total_Charge__c,Referring_Physician_Signature__c,Reserved_For_NUCC_Use1__c,Reserved_For_NUCC_Use2__c,
                     Reserved_For_NUCC_Use3__c,Service_Facility_Location_Information__c,Billing_Provider_Name__c,Billing_Provider_City__c,Billing_Provider_Address_1__c,Billing_Provider_State__c
                     ,Billing_Provider_Zip__c,Bill_Phone__c,First_Diagnosis__c,Billing_Provider_Tax_ID__c,Billing_Provider_Tax_ID_Type__c,Other_Payer_Name__c,Payer_ID__c,Diagnosis_Reference__c,
                     Charge_Amount__c,From_Date__c,Thru_Date__c,Units__c,Procedure_Code__c,Auto_Accident_Related__c,Employment_Related__c,Insured_Country_Code__c,Patient_Country_Code__c
                     ,Place_of_Service__c,Patient_s_Address__c,Patient_First_Name__c,Patient_Last_Name__c,Payer_Order__c,Insurance_Number__c
                     from Claim__c where id IN: claimIds
                     WITH SECURITY_ENFORCED];
        
        for(Claim__c c : ClaimToPost){
                headerNode.setAttribute('pcn', c.Account__r.Name);
                headerNode.setAttribute('pat_name_l', c.Patient_Last_Name__c);
                headerNode.setAttribute('pat_name_f', c.Patient_First_Name__c);
                headerNode.setAttribute('bill_npi', c.NPI__c);
                headerNode.setAttribute('payerid', c.Payer_ID__c);
                headerNode.setAttribute('payer_name', c.Other_Payer_Name__c);
                headerNode.setAttribute('ins_number', c.Insurance_Number__c);
                headerNode.setAttribute('pat_dob', String.Valueof(c.Patient_DOB__c));
                headerNode.setAttribute('pat_sex', c.Patient_Sex__c);
                headerNode.setAttribute('ins_name_f', c.Patient_First_Name__c);
                headerNode.setAttribute('ins_name_l', c.Patient_Last_Name__c);
                headerNode.setAttribute('payer_order', c.Payer_Order__c);
                headerNode.setAttribute('pat_addr_1', c.Patient_s_Address__c);
                headerNode.setAttribute('pat_city', c.Patient_s_City__c);
                headerNode.setAttribute('pat_country', c.Patient_Country_Code__c);
                headerNode.setAttribute('pat_state', c.Patient_s_State__c);
                headerNode.setAttribute('pat_zip', String.ValueOf(c.Patient_s_Zipcode__c));
                headerNode.setAttribute('pat_rel', c.Patient_Relationship_to_Insured__c);
                headerNode.setAttribute('ins_addr_1', c.Insured_Address__c);
                headerNode.setAttribute('ins_city', c.Insured_City__c);
                headerNode.setAttribute('ins_country', c.Insured_Country_Code__c);
                headerNode.setAttribute('ins_state', c.Insured_State__c);
                headerNode.setAttribute('ins_zip', String.ValueOf(c.Insured_Zipcode__c));
                headerNode.setAttribute('employment_related', c.Employment_Related__c);
                headerNode.setAttribute('auto_accident', c.Auto_Accident_Related__c);
                headerNode.setAttribute('ins_dob', String.ValueOf(c.Insured_DOB__c));
                headerNode.setAttribute('ins_sex', c.Insured_Sex__c);
                headerNode.setAttribute('place_of_service_1', c.Place_of_Service__c);
                headerNode.setAttribute('bill_taxid', c.Billing_Provider_Tax_ID__c);
                headerNode.setAttribute('bill_taxid_type', c.Billing_Provider_Tax_ID_Type__c);
                headerNode.setAttribute('accept_assign', c.Accept_Assignment__c);
                headerNode.setAttribute('total_charge', String.ValueOf(c.Total_Charge__c));
                headerNode.setAttribute('amount_paid',  String.ValueOf(c.Amount_Paid__c));
                headerNode.setAttribute('bill_name', c.Billing_Provider_Name__c);
                headerNode.setAttribute('bill_addr_1', c.Billing_Provider_Address_1__c);
                headerNode.setAttribute('bill_city', c.Billing_Provider_City__c);
                headerNode.setAttribute('bill_state', c.Billing_Provider_State__c);
                headerNode.setAttribute('bill_zip', c.Billing_Provider_Zip__c);
                headerNode.setAttribute('bill_phone', c.Bill_Phone__c);
                headerNode.setAttribute('diag_1', c.First_Diagnosis__c);
                childNode.setAttribute('proc_code',c.Procedure_Code__c);
                childNode.setAttribute('units',c.Units__c);
                childNode.setAttribute('from_date',String.ValueOf(c.From_Date__c));
                childNode.setAttribute('thru_date',String.ValueOf(c.Thru_Date__c));
                childNode.setAttribute('charge',c.Charge_Amount__c);
                childNode.setAttribute('diag_ref',c.Diagnosis_Reference__c);
        }
        
        
        
        SYSTEM.debug('KK'+doc.toXmlString());
        return doc.toXmlString();
    }
}