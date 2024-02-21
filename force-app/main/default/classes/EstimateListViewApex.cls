public with sharing class EstimateListViewApex {
    @AuraEnabled
    public static estimatesWrapper BringData(String patientIds, String VOBId){
        
        system.debug('patientIds'+patientIds);
        Integer totalCount = 0;
        String ids;
        if(VOBId!=Null){
            try{
                if(Schema.sObjectType.VOB__c.isAccessible() 
                   && Schema.sObjectType.VOB__c.fields.Account__c.isAccessible()
                   && Schema.sObjectType.VOB__c.fields.Id.isAccessible()){  
                       List<VOB__c> vob = new List<VOB__c>([select id,Account__c from VOB__c where Id=:VOBId]);
                       if(!vob.isEmpty())
                       {
                           if(vob[0].Account__c!=Null)
                               ids= vob[0].Account__c;
                       }
                   }
            }catch(Exception e){
            ExceptionLog.logError(e);
        }
        }
        else if(patientIds!=Null){
 			ids= patientIds;
        }
        list<Estimates__c> ClaimToPost = new list<Estimates__c>();
        if(Schema.sObjectType.Estimates__c.isAccessible() 
           && Schema.sObjectType.Estimates__c.fields.Id.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Name.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Co_Insurance__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.In_Use__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Account__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Status__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Co_Pay__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Deductible__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.OOP_Max__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Insurer_Responsibility__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.Patient_responsibility__c.isAccessible()
           && Schema.sObjectType.Estimates__c.fields.CreatedDate.isAccessible()){ 
               ClaimToPost=[select id,Name,Co_Insurance__c,In_Use__c,Account__c,Status__c ,Co_Pay__c,Deductible__c,OOP_Max__c ,Insurer_Responsibility__c,Patient_responsibility__c,CreatedDate 
                            from Estimates__c where Account__c =:ids ORDER  BY CreatedDate DESC LIMIT 5];
           }
        List<AggregateResult> claimsCount = [SELECT count(Id) c from Estimates__c where Account__c =:ids];
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
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name from User where Id =:currentUid].ElixirSuite__License_Type__c;
        List<String> lst_availLicense = new List<String>();
        if(AvailLicense != '' && AvailLicense != null)
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
    public static estimatesWrapper BringDataViewAll(String patientIds, String VOBId){
        Integer totalCount = 0;
         String ids;
        if(VOBId!=Null){
            if(Schema.sObjectType.VOB__c.isAccessible() 
               && Schema.sObjectType.VOB__c.fields.Account__c.isAccessible()
               && Schema.sObjectType.VOB__c.fields.Id.isAccessible()){ 
                   List<VOB__c> vob = new List<VOB__c>([select id,Account__c from VOB__c where Id=:VOBId]);
                   if(!vob.isEmpty())
                   {
                       if(vob[0].Account__c!=Null)
                           ids= vob[0].Account__c;
                   }
               }
        }
        else if(patientIds!=Null){
 			ids= patientIds;
        }
        list<Estimates__c> ClaimToPost = new list<Estimates__c>();
        ClaimToPost=[select id,Name,Co_Insurance__c,In_Use__c,Account__c,Status__c ,Co_Pay__c,Deductible__c,OOP_Max__c ,Insurer_Responsibility__c,Patient_responsibility__c,CreatedDate 
                     from Estimates__c where Account__c =:ids ORDER  BY CreatedDate DESC LIMIT 40000];
        List<AggregateResult> claimsCount = [SELECT count(Id) c from Estimates__c where Account__c =:ids];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        estimatesWrapper claimsToReturn = new estimatesWrapper(ClaimToPost, totalCount);
        return claimsToReturn;  
        
    }
    @AuraEnabled
    public static estimatesWrapper BringFilterData(string fromDate , string toDate , String patientIds, String VOBId){
        Integer totalCount = 0;
        String recId;
        if(VOBId!=Null){
            if(Schema.sObjectType.VOB__c.isAccessible() 
               && Schema.sObjectType.VOB__c.fields.Account__c.isAccessible()
               && Schema.sObjectType.VOB__c.fields.Id.isAccessible()){ 
                   List<VOB__c> vob = new List<VOB__c>([select id,Account__c from VOB__c where Id=:VOBId]);
                   if(!vob.isEmpty())
                   {
                       if(vob[0].Account__c!=Null)
                           recId= vob[0].Account__c;
                   }
               }
        }
        else if(patientIds!=Null){
 			recId= patientIds;
        }
        list<Estimates__c> ClaimToPost = new list<Estimates__c>();
        ClaimToPost=[SELECT Account__c,Co_Insurance__c,Co_Pay__c,CreatedById,CreatedDate,Deductible__c,Id,Insurance_Name__c,Insurer_Responsibility__c,
                     In_Use__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OOP_Max__c,OwnerId,
                     Patient_responsibility__c,Procedure_Total__c,Status__c FROM Estimates__c
                     where Account__c=: recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate) 
                     WITH SECURITY_ENFORCED
                     ORDER  BY CreatedDate DESC LIMIT 5];
        List<AggregateResult> claimsCount = [SELECT count(Id) c from Estimates__c  where Account__c=: recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate)];
        if(claimsCount!=null && claimsCount.size()>0){
            totalCount = Integer.valueOf(claimsCount[0].get('c'));
        }
        estimatesWrapper claimsToReturn = new estimatesWrapper(ClaimToPost, totalCount);
        return claimsToReturn; 
        
    }
    @AuraEnabled
    public static estimatesWrapper BringFilterDataViewAll(string fromDate , string toDate , String patientIds, String VOBId){
        Integer totalCount = 0;
        String recId;
        if(VOBId!=Null){
            if(Schema.sObjectType.VOB__c.isAccessible() 
               && Schema.sObjectType.VOB__c.fields.Account__c.isAccessible()
               && Schema.sObjectType.VOB__c.fields.Id.isAccessible()){ 
                   List<VOB__c> vob = new List<VOB__c>([select id,Account__c from VOB__c where Id=:VOBId]);
                   if(!vob.isEmpty())
                   {
                       if(vob[0].Account__c!=Null)
                           recId= vob[0].Account__c;
                   }
               }
        }
        else if(patientIds!=Null){
 			recId= patientIds;
        }
        list<Estimates__c> ClaimToPost = new list<Estimates__c>();
         if(String.isNotBlank(fromDate) && String.isNotBlank(toDate) && recId != null){
             ClaimToPost=[SELECT Account__c,Co_Insurance__c,Co_Pay__c,CreatedById,CreatedDate,Deductible__c,Id,Insurance_Name__c,Insurer_Responsibility__c,
                          In_Use__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OOP_Max__c,OwnerId,
                          Patient_responsibility__c,Procedure_Total__c,Status__c FROM Estimates__c
                          where Account__c=: recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate) LIMIT 40000];
             List<AggregateResult> claimsCount = [SELECT count(Id) c from Estimates__c where Account__c =:recId And createddate>=:Date.valueOf(fromDate) And createddate<=:Date.valueOf(toDate)
             WITH SECURITY_ENFORCED];
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