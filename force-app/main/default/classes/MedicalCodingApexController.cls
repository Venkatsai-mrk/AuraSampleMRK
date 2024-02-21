public with sharing class MedicalCodingApexController {
    
    @AuraEnabled
    public static string fetchAccountName(string accountId){
        List<Account> acc=[SELECT Id, name FROM Account WHERE Id= :accountId WITH SECURITY_ENFORCED];
        string accName = acc[0].name;
        return accName;
    }
    @AuraEnabled
    public static string getTimeZone()
    {
        String timeZone = UserInfo.getTimeZone().getID();
        return timeZone;
    }
    @AuraEnabled
    public static wrapper procedureList(String accountId ){
        List<ElixirSuite__Procedure__c> procList = new list<ElixirSuite__Procedure__c>();
        //  List<ElixirSuite__Procedure_Diagnosis__c> procDiag = new List<ElixirSuite__Procedure_Diagnosis__c>();
        
        list<string> claimWithoutERA = new list<string>{'Saved','Ready to Submit','Sent to Clearing house','Clearing house accepted','Clearing house rejected','Payer Accepted','Payer Rejected'};
            
            //  list<string> claimWithERA = new list<string>{'Paid and Patient Responsibility','Paid and resolved','Paid with Patient Responsibility – Ready to submit secondary Insurance','Clearing house accepted','	Paid and patient responsibility with Secondary'};
            
            procList = [SELECT Id, Name, CreatedDate, CreatedById, ElixirSuite__Claim_Generation__c, ElixirSuite__Ready_for_Claim_Processing__c, ElixirSuite__Code_Description__c, ElixirSuite__CPT_HCPCS_Code__c, 
                        ElixirSuite__Claim__c,ElixirSuite__Visits__c, ElixirSuite__Days_Units__c, ElixirSuite__End_Time__c, ElixirSuite__From_Date__c, ElixirSuite__Visits__r.Name, 
                        ElixirSuite__From_Date_of_Service__c,ElixirSuite__Claim_type__c, ElixirSuite__Is_Patient_Procedure__c, ElixirSuite__Billable__c, ElixirSuite__Place_of_Service_Code__c, 
                        ElixirSuite__To_Date_of_Service__c, ElixirSuite__To_Date__c, ElixirSuite__Start_Time__c, ElixirSuite__Account__c, ElixirSuite__Is_Billed__c, 
                        ElixirSuite__Type_of_Procedure__c, ElixirSuite__Pre_auth_Code__c,ElixirSuite__Is_Billable__c, ElixirSuite__Code_Category__c, ElixirSuite__Long_Description__c, 
                        ElixirSuite__Diagnosis_Pointer__c, ElixirSuite__Related_Procedure_Code_Category__c, ElixirSuite__Active__c ,ElixirSuite__Modifier1__r.Name,
                        ElixirSuite__Modifier2__r.Name,ElixirSuite__Modifier3__r.Name , ElixirSuite__Modifier4__r.Name,ElixirSuite__Place_Of_Service_Picklist__c,
                        ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c,ElixirSuite__Ready_for_Billing__c,ElixirSuite__Is_Processed__c,
                        ElixirSuite__Description_1__c,ElixirSuite__Description_2__c,ElixirSuite__Description_3__c,ElixirSuite__Description_4__c,
                        ElixirSuite__Notes_1__c,ElixirSuite__Notes_2__c,ElixirSuite__Notes_3__c,ElixirSuite__Notes_4__c,
                        ElixirSuite__Cancelation_Reason__c,toLabel(ElixirSuite__Status__c),
                        (SELECT id, name,ElixirSuite__Description__c, ElixirSuite__Notes__c , ElixirSuite__ICD_Codes__r.Name FROM ElixirSuite__Procedure_Diagnosis__r) 
                        FROM ElixirSuite__Procedure__c
                        WHERE account__c =: accountId AND RecordType.developerName = 'Patient_Procedure' AND Name!='Prescription procedure' AND
                        (ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c IN: claimWithoutERA OR ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c =:null)
                        WITH SECURITY_ENFORCED
                        order by createddate desc];
        
        // procDiag = [SELECT id,ElixirSuite__ICD_Codes__c,ElixirSuite__Account__c,ElixirSuite__Procedure__c]
        
        // String namespace = Elixir_utility.getNameSpace();
        Wrapper wrpr = new Wrapper();
        wrpr.lstOfAllProcedures = procList;
        wrpr.columns = MedicalCodingColumnConfiguration.getProcedureColumns();
        return wrpr;
        
    }
    @AuraEnabled
    public static ElixirSuite__Procedure_Diagnosis__c[] fetchRelatedDiag(String recId ){
        return UpdateProcedureHandler.fetchDiagnosisData(recId);
    }
    @AuraEnabled
    public static wrapper procedureListHistorical(String accountId ){
        List<ElixirSuite__Procedure__c> procListForHistoricalProcedures = new list<ElixirSuite__Procedure__c>();
        
        list<string> claimWithERA = new list<string>{'Paid and Patient Responsibility','Paid and resolved','Paid with Patient Responsibility – Ready to submit secondary Insurance','Clearing house accepted','	Paid and patient responsibility with Secondary'};
            
            procListForHistoricalProcedures = [SELECT Id, Name, CreatedDate, CreatedById, ElixirSuite__Claim_Generation__c, ElixirSuite__Ready_for_Claim_Processing__c, ElixirSuite__Code_Description__c, ElixirSuite__CPT_HCPCS_Code__c, 
                                               ElixirSuite__Claim__c,ElixirSuite__Visits__c,ElixirSuite__Visits__r.Name, ElixirSuite__Days_Units__c, ElixirSuite__End_Time__c, ElixirSuite__From_Date__c, 
                                               ElixirSuite__From_Date_of_Service__c, ElixirSuite__Is_Patient_Procedure__c, ElixirSuite__Billable__c, ElixirSuite__Place_of_Service_Code__c, 
                                               ElixirSuite__To_Date_of_Service__c, ElixirSuite__To_Date__c,ElixirSuite__Claim_type__c, ElixirSuite__Start_Time__c, ElixirSuite__Account__c, ElixirSuite__Is_Billed__c, 
                                               ElixirSuite__Type_of_Procedure__c, ElixirSuite__Pre_auth_Code__c,ElixirSuite__Is_Billable__c, ElixirSuite__Code_Category__c, ElixirSuite__Long_Description__c, 
                                               ElixirSuite__Diagnosis_Pointer__c, ElixirSuite__Related_Procedure_Code_Category__c, ElixirSuite__Active__c ,ElixirSuite__Modifier1__r.Name,
                                               ElixirSuite__Modifier2__r.Name,ElixirSuite__Modifier3__r.Name , ElixirSuite__Modifier4__r.Name,ElixirSuite__Place_Of_Service_Picklist__c,
                                               ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c,ElixirSuite__Ready_for_Billing__c,ElixirSuite__Is_Processed__c, ElixirSuite__Claim__r.Name,
                                               (SELECT id, name, ElixirSuite__ICD_Codes__r.Name FROM ElixirSuite__Procedure_Diagnosis__r) 
                                               FROM ElixirSuite__Procedure__c 
                                               WHERE account__c =: accountId AND RecordType.developerName = 'Patient_Procedure' AND 
                                               ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c IN: claimWithERA  WITH SECURITY_ENFORCED
                                               order by createddate desc];        
        Wrapper wrpr = new Wrapper();
        
        wrpr.lstOfHistoricalProcedures = procListForHistoricalProcedures;
        wrpr.columns = MedicalCodingColumnConfiguration.getHistoricalProcedureColumns();
        return wrpr;
        
    }
    
    
    @AuraEnabled
    public static Boolean getProblemRecords(String recId ){
        Boolean message;
        list<ElixirSuite__Dataset1__c> c = new list<ElixirSuite__Dataset1__c>();
        try{
            if(String.isNotBlank(recId)){
                
                c=[select id,ElixirSuite__Account__c from ElixirSuite__Dataset1__c where ElixirSuite__Account__c=:recId WITH SECURITY_ENFORCED];
                
                if(c!=null && c.size()>0){
                    message = true ;
                }
                else{
                    message = false ;
                }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return message ;
    }
    
    @AuraEnabled
    public static Boolean deleteRecord(String recId){
        Boolean message;
        try{
            if(String.isNotBlank(recId)){
                ElixirSuite__Procedure__c[] arr = [SELECT ID,ElixirSuite__Claim__c FROM ElixirSuite__Procedure__c WHERE ID =: recId AND ElixirSuite__Claim__c =: null
                                                   WITH SECURITY_ENFORCED ];
                
                if(arr!=null && arr.size()>0){
                    if (Schema.sObjectType.ElixirSuite__Procedure__c.isDeletable()) {
                        // delete arr;  
                        DMLManager.deleteAsUser(arr);    
                    }  
                    message =  true;
                }
                else{
                    message = false;
                }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return message ;
    }
    
    public class Wrapper{
        @AuraEnabled public String columns;
        @AuraEnabled public String namespace;
        @AuraEnabled public List<ElixirSuite__Procedure__c> lstOfAllProcedures;
        @AuraEnabled public List<ElixirSuite__Procedure__c> lstOfHistoricalProcedures;
    }
    
    @AuraEnabled
    public static boolean checkCareEpisode(string patientId){      
        
        //added by Anmol for LX3-7236
        Boolean result = Elixir_Utility.checkCareEpisodeUtility(patientId);
        return result;
        //end by Anmol for LX3-7236
        
    }
}