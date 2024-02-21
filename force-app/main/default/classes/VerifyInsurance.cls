public with sharing class VerifyInsurance {

     @AuraEnabled
    public static wrapperData getAllData(String accountId){
        system.debug('account id'+accountId);
        Account patient = new Account();
        patient = [SELECT id, 	
                   Name,	
                   Age__c, 
                   AccountNumber,	
                   First_Name__c,	
                   Gender__c,	
                   Last_Name__c,	
                   MRN_Number__c,	
                   Outstanding_Amount__c,
                   Patient_s_Birth_Date__c,	
                   Phone,	
                   Unallocated_Amount__c,
                   Profile_Picture__c,
                   Total_Patient_Responsibility__c
                   FROM  Account 
                   where id=: accountId 
                   WITH SECURITY_ENFORCED
                   LIMIT 1];
        
        AggregateResult[] groupedResults = [SELECT SUM(Total_Amount_Paid_By_Insurance__c)totalInsurPaid From Claim__c Where Account__c =:accountId WITH SECURITY_ENFORCED];
        Object sumAmount = groupedResults[0].get('totalInsurPaid');
      
        Map<Id, VOB__c> allVobData = new Map<Id, VOB__c>([SELECT Id, 
                                                          Name, 
                                                          type__c,
                                                          CreatedDate, 
                                                          LastModifiedDate, 
                                                          Last_Verified_Date__c,
                                                          Group_Number__c, 
                                                          Client_Member_ID__c, 
                                                          Member_Id__c, 
                                                          PatientFirstName__c, 
                                                          PatientLastName__c, 
                                                          Patient_Birth_Date__c, 
                                                          Payer_Name__c, 
                                                          VOB_Verification_Status__c, 
                                                          Account__c, Payer__r.Name
                                                          FROM VOB__c 
                                                          where Account__c=: patient.id AND Status__c='Active' AND
                                                          Type__c='Primary'
                                                          WITH SECURITY_ENFORCED
                                                          order by CreatedDate DESC limit 1]);
        system.debug('vob:'+allVobData);
        
        List<Result__c> vobResult = [SELECT Id,	
                                     VOB__c, 
                                     VOB__r.VOB_Verification_Status__c,
                                     Deduc_inNtwk_Clientperc__c , 
                                     Co_Insurance_Provider_Percent__c,
                                     in_network_total__c,
                                     In_Net_Co_Payment__c,
                                     out_of_network_outOfPocket_total__c
                                     FROM Result__c 
                                     where 	VOB__c IN :allVobData.keySet() 
                                     WITH SECURITY_ENFORCED
                                     order by createddate desc ] ; 
        
        wrapperData wrpr = new wrapperData();
        wrpr.patData = patient ;
        wrpr.vobData = allVobData.values();
        wrpr.vobResultData = vobResult ;
        wrpr.totalInsuranceResp = (Decimal)sumAmount ;
      //  wrpr.vobRecId= allVobData.values().Id;
        return wrpr ;
    }
    
    @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name from User 
        where Id =:currentUid
        WITH SECURITY_ENFORCED].ElixirSuite__License_Type__c;
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
    public static void handlingAfterUpload(Id accountId){
        ContentVersion cv = new ContentVersion();
        ContentDocument cd=new ContentDocument();
        try{
            if(schema.sobjecttype.ContentVersion.isAccessible()
               && schema.sobjecttype.ContentVersion.fields.FIRSTPUBLISHLOCATIONID.isAccessible()
               && schema.sobjecttype.ContentVersion.fields.Title.isAccessible())
            {
                cv = [select id,Title,ContentDocumentId from ContentVersion WHERE FIRSTPUBLISHLOCATIONID=:accountId WITH SECURITY_ENFORCED order by createdDate desc limit 1];
                if(cv.Id!=null){
                    cv.Title=cv.Title+'_profilePic';
                }
                Account acc = new Account();	
                acc =[select id,Profile_Picture__c from Account where id =:accountId WITH SECURITY_ENFORCED];	
                    acc.Profile_Picture__c = cv.id;	
                    if(Schema.sObjectType.Account.fields.Profile_Picture__c.isUpdateable()){
                    update acc;
                }
            }
            if(Schema.sObjectType.ContentVersion.isUpdateable()){
            update cv;
            }
        }
        catch(Exception e)
        {
            ExceptionLog.logError(e);
            System.debug('ERROR:' + e);
        }
    }
    
    public class wrapperData{
        @AuraEnabled Public Account patData; 
        @AuraEnabled Public List<VOB__c> vobData;
        @AuraEnabled Public List<Result__c> vobResultData ;
        @AuraEnabled Public Decimal totalInsuranceResp ;
        @AuraEnabled Public Id vobRecId;
    }
}
//committed