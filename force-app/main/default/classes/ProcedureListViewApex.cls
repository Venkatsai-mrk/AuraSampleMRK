public with sharing class ProcedureListViewApex {
 @AuraEnabled
    public static procedureWrapper BringDataFirst( String recId){
        List<ElixirSuite__Procedure__c> procList = new list<ElixirSuite__Procedure__c>();
        Integer totalCount = 0; 
        procList = [SELECT Id, Name, CreatedDate, CreatedById, ElixirSuite__Claim_Generation__c, ElixirSuite__Ready_for_Claim_Processing__c, ElixirSuite__Code_Description__c, ElixirSuite__CPT_HCPCS_Code__c, 
                    ElixirSuite__Claim__c, ElixirSuite__Days_Units__c, ElixirSuite__End_Time__c, ElixirSuite__From_Date__c, ElixirSuite__Visits__r.Name, 
                    ElixirSuite__From_Date_of_Service__c,ElixirSuite__Claim_type__c, ElixirSuite__Is_Patient_Procedure__c, ElixirSuite__Billable__c, ElixirSuite__Place_of_Service_Code__c, 
                    ElixirSuite__To_Date_of_Service__c, ElixirSuite__To_Date__c, ElixirSuite__Start_Time__c, ElixirSuite__Account__c, ElixirSuite__Is_Billed__c, 
                    ElixirSuite__Type_of_Procedure__c, ElixirSuite__Pre_auth_Code__c,ElixirSuite__Is_Billable__c, ElixirSuite__Code_Category__c, ElixirSuite__Long_Description__c, 
                    ElixirSuite__Diagnosis_Pointer__c, ElixirSuite__Related_Procedure_Code_Category__c, ElixirSuite__Active__c ,ElixirSuite__Modifier1__c,
                    ElixirSuite__Modifier2__c,ElixirSuite__Modifier3__c , ElixirSuite__Modifier4__c,ElixirSuite__Place_Of_Service_Picklist__c,
                    ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c,ElixirSuite__Ready_for_Billing__c,ElixirSuite__Is_Processed__c,
                    ElixirSuite__Description_1__c,ElixirSuite__Description_2__c,ElixirSuite__Description_3__c,ElixirSuite__Description_4__c,
                    ElixirSuite__Notes_1__c,ElixirSuite__Notes_2__c,ElixirSuite__Notes_3__c,ElixirSuite__Notes_4__c,
                    (SELECT id, name,ElixirSuite__Description__c, ElixirSuite__Notes__c , ElixirSuite__ICD_Codes__r.Name FROM ElixirSuite__Procedure_Diagnosis__r) 
                    FROM ElixirSuite__Procedure__c 
                    WHERE account__c =: recId AND RecordType.developerName = 'Patient_Procedure'
                    WITH SECURITY_ENFORCED
                    order by CreatedDate desc LIMIT 5];
        List<AggregateResult> procCount = [SELECT count(Id) c FROM ElixirSuite__Procedure__c WHERE Account__c=: recId AND RecordType.developerName = 'Patient_Procedure' WITH SECURITY_ENFORCED];
        if(procCount!=null && procCount.size()>0){
            totalCount = Integer.valueOf(procCount[0].get('c'));
        }
        procedureWrapper procToReturn = new procedureWrapper(procList, totalCount);
        return procToReturn;
    }
    public class procedureWrapper{
        @AuraEnabled public Integer totalCount ;
        @AuraEnabled public List<ElixirSuite__Procedure__c> procToPost;
        procedureWrapper(List<ElixirSuite__Procedure__c> procToPost, Integer totalCount){
            this.procToPost = procToPost;
            this.totalCount = totalCount;
        }
    }
    @AuraEnabled
    public static procedureWrapper BringDataViewAll( String recId){
        List<ElixirSuite__Procedure__c> procList = new list<ElixirSuite__Procedure__c>();
        Integer totalCount = 0; 
        procList = [SELECT Id, Name, CreatedDate, CreatedById, ElixirSuite__Claim_Generation__c, ElixirSuite__Ready_for_Claim_Processing__c, ElixirSuite__Code_Description__c, ElixirSuite__CPT_HCPCS_Code__c, 
                    ElixirSuite__Claim__c, ElixirSuite__Days_Units__c, ElixirSuite__End_Time__c, ElixirSuite__From_Date__c, ElixirSuite__Visits__r.Name, 
                    ElixirSuite__From_Date_of_Service__c,ElixirSuite__Claim_type__c, ElixirSuite__Is_Patient_Procedure__c, ElixirSuite__Billable__c, ElixirSuite__Place_of_Service_Code__c, 
                    ElixirSuite__To_Date_of_Service__c, ElixirSuite__To_Date__c, ElixirSuite__Start_Time__c, ElixirSuite__Account__c, ElixirSuite__Is_Billed__c, 
                    ElixirSuite__Type_of_Procedure__c, ElixirSuite__Pre_auth_Code__c,ElixirSuite__Is_Billable__c, ElixirSuite__Code_Category__c, ElixirSuite__Long_Description__c, 
                    ElixirSuite__Diagnosis_Pointer__c, ElixirSuite__Related_Procedure_Code_Category__c, ElixirSuite__Active__c ,ElixirSuite__Modifier1__c,
                    ElixirSuite__Modifier2__c,ElixirSuite__Modifier3__c , ElixirSuite__Modifier4__c,ElixirSuite__Place_Of_Service_Picklist__c,
                    ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c,ElixirSuite__Ready_for_Billing__c,ElixirSuite__Is_Processed__c,
                    ElixirSuite__Description_1__c,ElixirSuite__Description_2__c,ElixirSuite__Description_3__c,ElixirSuite__Description_4__c,
                    ElixirSuite__Notes_1__c,ElixirSuite__Notes_2__c,ElixirSuite__Notes_3__c,ElixirSuite__Notes_4__c,
                    (SELECT id, name,ElixirSuite__Description__c, ElixirSuite__Notes__c , ElixirSuite__ICD_Codes__r.Name FROM ElixirSuite__Procedure_Diagnosis__r) 
                    FROM ElixirSuite__Procedure__c 
                    WHERE account__c =: recId AND RecordType.developerName = 'Patient_Procedure' WITH SECURITY_ENFORCED
                    order by CreatedDate desc LIMIT 40000];
        List<AggregateResult> procCount = [SELECT count(Id) c FROM ElixirSuite__Procedure__c WHERE Account__c=: recId AND RecordType.developerName = 'Patient_Procedure' WITH SECURITY_ENFORCED];
        if(procCount!=null && procCount.size()>0){
            totalCount = Integer.valueOf(procCount[0].get('c'));
        }
        procedureWrapper procToReturn = new procedureWrapper(procList, totalCount);
        return procToReturn;
    }
    
    @AuraEnabled
    public static Boolean deleteRec(String recId){
        Boolean message;
        try{
       if(String.isNotBlank(recId)){
            ElixirSuite__Procedure__c[] arr = [SELECT ID,ElixirSuite__Claim__c FROM ElixirSuite__Procedure__c WHERE ID =: recId AND ElixirSuite__Claim__c =: null
                                               WITH SECURITY_ENFORCED ];
       
            if(arr!=null && arr.size()>0){
                if(Schema.sObjectType.ElixirSuite__Procedure__c.isDeletable()){
                delete arr;    
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
    
    @AuraEnabled
    public static procedureWrapper BringFilterData(string fromDate , string toDate , String recId){
        
		List<ElixirSuite__Procedure__c> procList = new list<ElixirSuite__Procedure__c>();
        Integer totalCount = 0; 
        procList = [SELECT Id, Name, CreatedDate, CreatedById, ElixirSuite__Claim_Generation__c, ElixirSuite__Ready_for_Claim_Processing__c, ElixirSuite__Code_Description__c, ElixirSuite__CPT_HCPCS_Code__c, 
                    ElixirSuite__Claim__c, ElixirSuite__Days_Units__c, ElixirSuite__End_Time__c, ElixirSuite__From_Date__c, 
                    ElixirSuite__From_Date_of_Service__c,ElixirSuite__Claim_type__c, ElixirSuite__Is_Patient_Procedure__c, ElixirSuite__Billable__c, ElixirSuite__Place_of_Service_Code__c, 
                    ElixirSuite__To_Date_of_Service__c, ElixirSuite__To_Date__c, ElixirSuite__Start_Time__c, ElixirSuite__Account__c, ElixirSuite__Is_Billed__c, 
                    ElixirSuite__Type_of_Procedure__c, ElixirSuite__Pre_auth_Code__c,ElixirSuite__Is_Billable__c, ElixirSuite__Code_Category__c, ElixirSuite__Long_Description__c, 
                    ElixirSuite__Diagnosis_Pointer__c, ElixirSuite__Related_Procedure_Code_Category__c, ElixirSuite__Active__c ,ElixirSuite__Modifier1__c,
                    ElixirSuite__Modifier2__c,ElixirSuite__Modifier3__c , ElixirSuite__Modifier4__c,ElixirSuite__Place_Of_Service_Picklist__c,
                    ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c,ElixirSuite__Ready_for_Billing__c,ElixirSuite__Is_Processed__c,
                    ElixirSuite__Description_1__c,ElixirSuite__Description_2__c,ElixirSuite__Description_3__c,ElixirSuite__Description_4__c,
                    ElixirSuite__Notes_1__c,ElixirSuite__Notes_2__c,ElixirSuite__Notes_3__c,ElixirSuite__Notes_4__c,
                    (SELECT id, name,ElixirSuite__Description__c, ElixirSuite__Notes__c , ElixirSuite__ICD_Codes__r.Name FROM ElixirSuite__Procedure_Diagnosis__r) 
                    FROM ElixirSuite__Procedure__c 
                    WHERE account__c =: recId And ElixirSuite__From_Date_of_Service__c>=:Date.valueOf(fromDate) And ElixirSuite__From_Date_of_Service__c<=:Date.valueOf(toDate)
					AND RecordType.developerName = 'Patient_Procedure'
                    WITH SECURITY_ENFORCED
                    order by CreatedDate desc LIMIT 5];
        List<AggregateResult> procCount = [SELECT count(Id) c FROM ElixirSuite__Procedure__c WHERE Account__c=: recId AND RecordType.developerName = 'Patient_Procedure' WITH SECURITY_ENFORCED];
        if(procCount!=null && procCount.size()>0){
            totalCount = Integer.valueOf(procCount[0].get('c'));
        }
        procedureWrapper procToReturn = new procedureWrapper(procList, totalCount);
        return procToReturn;


    }
    
    @AuraEnabled
    public static procedureWrapper BringFilterDataViewAll(string fromDate , string toDate , String recId){
		
		List<ElixirSuite__Procedure__c> procList = new list<ElixirSuite__Procedure__c>();
        Integer totalCount = 0; 
        procList = [SELECT Id, Name, CreatedDate, CreatedById, ElixirSuite__Claim_Generation__c, ElixirSuite__Ready_for_Claim_Processing__c, ElixirSuite__Code_Description__c, ElixirSuite__CPT_HCPCS_Code__c, 
                    ElixirSuite__Claim__c, ElixirSuite__Days_Units__c, ElixirSuite__End_Time__c, ElixirSuite__From_Date__c, 
                    ElixirSuite__From_Date_of_Service__c,ElixirSuite__Claim_type__c, ElixirSuite__Is_Patient_Procedure__c, ElixirSuite__Billable__c, ElixirSuite__Place_of_Service_Code__c, 
                    ElixirSuite__To_Date_of_Service__c, ElixirSuite__To_Date__c, ElixirSuite__Start_Time__c, ElixirSuite__Account__c, ElixirSuite__Is_Billed__c, 
                    ElixirSuite__Type_of_Procedure__c, ElixirSuite__Pre_auth_Code__c,ElixirSuite__Is_Billable__c, ElixirSuite__Code_Category__c, ElixirSuite__Long_Description__c, 
                    ElixirSuite__Diagnosis_Pointer__c, ElixirSuite__Related_Procedure_Code_Category__c, ElixirSuite__Active__c ,ElixirSuite__Modifier1__c,
                    ElixirSuite__Modifier2__c,ElixirSuite__Modifier3__c , ElixirSuite__Modifier4__c,ElixirSuite__Place_Of_Service_Picklist__c,
                    ElixirSuite__Claim__r.ElixirSuite__Claim_Status__c,ElixirSuite__Ready_for_Billing__c,ElixirSuite__Is_Processed__c,
                    ElixirSuite__Description_1__c,ElixirSuite__Description_2__c,ElixirSuite__Description_3__c,ElixirSuite__Description_4__c,
                    ElixirSuite__Notes_1__c,ElixirSuite__Notes_2__c,ElixirSuite__Notes_3__c,ElixirSuite__Notes_4__c,
                    (SELECT id, name,ElixirSuite__Description__c, ElixirSuite__Notes__c , ElixirSuite__ICD_Codes__r.Name FROM ElixirSuite__Procedure_Diagnosis__r) 
                    FROM ElixirSuite__Procedure__c 
                    WHERE account__c =: recId And ElixirSuite__From_Date_of_Service__c>=:Date.valueOf(fromDate) And ElixirSuite__From_Date_of_Service__c<=:Date.valueOf(toDate)
					AND RecordType.developerName = 'Patient_Procedure'
                    WITH SECURITY_ENFORCED
                    order by CreatedDate desc LIMIT 40000];
        List<AggregateResult> procCount = [SELECT count(Id) c FROM ElixirSuite__Procedure__c WHERE Account__c=: recId AND RecordType.developerName = 'Patient_Procedure' WITH SECURITY_ENFORCED];
        if(procCount!=null && procCount.size()>0){
            totalCount = Integer.valueOf(procCount[0].get('c'));
        }
        procedureWrapper procToReturn = new procedureWrapper(procList, totalCount);
        return procToReturn;
		
    }
  
}