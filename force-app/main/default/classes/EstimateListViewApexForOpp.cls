public with sharing class EstimateListViewApexForOpp {
 @AuraEnabled
    public static estimatesWrapper BringData(String patientIds, String VOBId){
        Integer totalCount = 0;
        String ids;
        if(VOBId!=Null){
            VOB__c vob = [select id,Account__c from VOB__c where Id=:VOBId WITH SECURITY_ENFORCED];
            if(vob.Account__c!=Null)
            ids= vob.Account__c;
        }
        else if(patientIds!=Null){
 ids= patientIds;
        }
        list<Estimates__c> ClaimToPost = new list<Estimates__c>();
        ClaimToPost=[select id,Name,Co_Insurance__c,In_Use__c,Account__c,Status__c ,Co_Pay__c,Deductible__c,OOP_Max__c ,Insurer_Responsibility__c,Patient_responsibility__c,CreatedDate 
                     from Estimates__c where Account__c =:ids WITH SECURITY_ENFORCED
                     ORDER  BY CreatedDate DESC LIMIT 5];
        List<AggregateResult> claimsCount = [SELECT count(Id) c from Estimates__c where Account__c =:ids WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        estimatesWrapper claimsToReturn = new estimatesWrapper(ClaimToPost, totalCount);
        system.debug('claimsToReturn==='+claimsToReturn);
        return claimsToReturn;
    }
    public class estimatesWrapper{
        @AuraEnabled public Integer totalCount ;
        @AuraEnabled public List<Estimates__c> estimates;
        estimatesWrapper(List<Estimates__c> estimates, Integer totalCount){
            this.estimates = estimates;
            this.totalCount = totalCount;
        }
    }
    @AuraEnabled
    public static estimatesWrapper BringDataViewAll(String patientIds, String VOBId){
        Integer totalCount = 0;
         String ids;
        if(VOBId!=Null){
            VOB__c vob = [select id,Account__c from VOB__c where Id=:VOBId WITH SECURITY_ENFORCED];
            if(vob.Account__c!=Null)
           ids= vob.Account__c;
        }
        else if(patientIds!=Null){
 ids= patientIds;
        }
        list<Estimates__c> ClaimToPost = new list<Estimates__c>();
        ClaimToPost=[select id,Name,Co_Insurance__c,In_Use__c,Account__c,Status__c ,Co_Pay__c,Deductible__c,OOP_Max__c ,Insurer_Responsibility__c,Patient_responsibility__c,CreatedDate 
                     from Estimates__c where Account__c =:ids 
                     WITH SECURITY_ENFORCED
                     ORDER  BY CreatedDate DESC LIMIT 40000];
        List<AggregateResult> claimsCount = [SELECT count(Id) c from Estimates__c where Account__c =:ids WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        estimatesWrapper claimsToReturn = new estimatesWrapper(ClaimToPost, totalCount);
        return claimsToReturn;  
        
    }
    
     @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name from User
         where Id =:currentUid WITH SECURITY_ENFORCED].ElixirSuite__License_Type__c;
        List<String> lst_availLicense = new List<String>();
        lst_availLicense = AvailLicense.split(';');
        License_Class lCls = new License_Class();
        try{
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
        }
        catch(Exception e){
            ExceptionLog.logError(e);
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
    public static estimatesWrapper BringFilterData(string fromDate , string toDate , String patientIds, String VOBId){
        System.debug('toDate==='+toDate);
        System.debug('fromDate===='+fromDate);
        Integer totalCount = 0;
        String recId;
         if(VOBId!=Null){
            VOB__c vob = [select id,Account__c from VOB__c where Id=:VOBId WITH SECURITY_ENFORCED];
            if(vob.Account__c!=Null)
           recId= vob.Account__c;
        }
        else if(patientIds!=Null){
 recId= patientIds;
        }
        list<Estimates__c> ClaimToPost = new list<Estimates__c>();
        ClaimToPost=[SELECT Account__c,Co_Insurance__c,Co_Pay__c,CreatedById,CreatedDate,Deductible__c,Id,Insurance_Name__c,Insurer_Responsibility__c,
                     In_Use__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OOP_Max__c,OwnerId,
                     Patient_responsibility__c,Procedure_Total__c,Status__c FROM Estimates__c
                     where Account__c=: recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate).addDays(1) 
                     WITH SECURITY_ENFORCED
                     ORDER  BY CreatedDate DESC LIMIT 5];
        List<AggregateResult> claimsCount = [SELECT count(Id) c from Estimates__c  where Account__c=: recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate) WITH SECURITY_ENFORCED];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        system.debug('ClaimToPost==='+ClaimToPost);
        estimatesWrapper claimsToReturn = new estimatesWrapper(ClaimToPost, totalCount);
        return claimsToReturn; 
        
    }
    @AuraEnabled
    public static estimatesWrapper BringFilterDataViewAll(string fromDate , string toDate , String patientIds, String VOBId){
        Integer totalCount = 0;
        String recId;
         if(VOBId!=Null){
            VOB__c vob = [select id,Account__c from VOB__c where Id=:VOBId WITH SECURITY_ENFORCED];
            if(vob.Account__c!=Null)
           recId= vob.Account__c;
        }
        else if(patientIds!=Null){
 recId= patientIds;
        }
        list<Estimates__c> ClaimToPost = new list<Estimates__c>();
         if(String.isNotBlank(fromDate) && String.isNotBlank(toDate)){
        ClaimToPost=[SELECT Account__c,Co_Insurance__c,Co_Pay__c,CreatedById,CreatedDate,Deductible__c,Id,Insurance_Name__c,Insurer_Responsibility__c,
                     In_Use__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OOP_Max__c,OwnerId,
                     Patient_responsibility__c,Procedure_Total__c,Status__c FROM Estimates__c
                     where Account__c=: recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate).addDays(1)
                     WITH SECURITY_ENFORCED
                     ORDER  BY CreatedDate DESC LIMIT 40000];
         List<AggregateResult> claimsCount = [SELECT count(Id) c from Estimates__c where Account__c =:recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate) WITH SECURITY_ENFORCED];
            if(claimsCount!=null && claimsCount.size()>0){
                totalCount = Integer.valueOf(claimsCount[0].get('c'));
            }
            estimatesWrapper claimsToReturn = new estimatesWrapper(ClaimToPost, totalCount);
            return claimsToReturn;
        }else{
            //estimatesWrapper claimsToReturn = BringDataViewAll(recId);
            estimatesWrapper claimsToReturn = BringDataViewAll(patientIds,VOBId);
            return claimsToReturn;
        }  
    }
}