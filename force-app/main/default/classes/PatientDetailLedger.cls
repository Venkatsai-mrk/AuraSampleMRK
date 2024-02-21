public with sharing class PatientDetailLedger {
    @AuraEnabled
    public static WrapperData getAllData(String accountId){
        Account patient = new Account();
WrapperData wrpr = new WrapperData();
        if(accountId != null && !string.isBlank(accountId)){
        patient = [SELECT id, 	
                   Name,	
                   Age__c,DOB__c,
                   AccountNumber,	
                   First_Name__c,	
                   Gender__c,	
                   Last_Name__c,	
                   MRN_Number_New__c,	
                   Outstanding_Amount__c,
                   Patient_s_Birth_Date__c,	
                   Phone,
                   Email_Id__c,
                   Unallocated_Amount__c,
                   Profile_Picture__c,
                   Total_Patient_Responsibility__c
                   FROM  Account 
                   where id=: accountId 
                   WITH SECURITY_ENFORCED
                   limit 1];
        
        AggregateResult[] groupedResults = [SELECT SUM(Total_Amount_Paid_By_Insurance__c)totalInsurPaid From Claim__c Where Account__c =:accountId WITH SECURITY_ENFORCED];
        Object sumAmount = groupedResults[0].get('totalInsurPaid');
        
        //List<Claim__c> claimList = [Select SUM(Total_Amount_Paid_By_Insurance__c) From Claim__c Where Account__c =:accountId];
        
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
                                                          where Account__c=: patient.id AND Status__c='Active' AND ElixirSuite__Set_Default_VOB__c='Yes'
                                                          WITH SECURITY_ENFORCED
                                                          order by CreatedDate DESC LIMIT 1]);
        
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
        
                wrpr.patData = patient ;
        wrpr.vobData = allVobData.values();
        wrpr.vobResultData = vobResult ;
        wrpr.totalInsuranceResp = (Decimal)sumAmount ;
        wrpr.getTileConfigFieldsOrder = getTileConfigFieldsOrder(accountId);
}
        wrpr.getlabelsforFields = getlabelsforFields();
        return wrpr ;
    }
    
    @AuraEnabled
    public static License_Class licensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String availLicense = [Select Id,License_Type__c,Username,Name from User where Id =:currentUid
                               WITH SECURITY_ENFORCED].License_Type__c;
        List<String> lstAvailLicense = new List<String>();
        lstAvailLicense = availLicense.split(';');
        License_Class lCls = new License_Class();
        for(String str : lstAvailLicense)
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
                if (Schema.sObjectType.Account.fields.Profile_Picture__c.isUpdateable()){
                    update acc;
                }   
            }
            if (Schema.sObjectType.ContentVersion.fields.Title.isUpdateable()){
                update cv;
            }
        }
        catch(Exception e)
        {
             ExceptionLog.logError(e);
        }
    }
    
    public class WrapperData{
        @AuraEnabled Public Account patData; 
        @AuraEnabled Public List<VOB__c> vobData;
        @AuraEnabled Public List<Result__c> vobResultData ;
        @AuraEnabled Public Decimal totalInsuranceResp ;
         //AddedForPatientTileCard
        @AuraEnabled public Account getTileConfigFieldsOrder;
        @AuraEnabled public Map<String,String> getlabelsforFields;
    }
    //AK
    @AuraEnabled
   public static InsuranceDataWrapper fetchInsuanceType(String acctId) {
       InsuranceDataWrapper wrapper = new InsuranceDataWrapper();
        List<AggregateResult> vobList = [select RecordType.Name from ElixirSuite__VOB__c where (ElixirSuite__Account__c=:acctId AND ElixirSuite__Payer__c != null AND (ElixirSuite__Member_Id__c != null OR ElixirSuite__Group_Number__c != null)) WITH SECURITY_ENFORCED Group by RecordType.Name];
        List<String> recordTypeList = new List<String>();
        for(AggregateResult vob:vobList){
           String recordTypeName = string.valueOf(vob.get('Name'));
           String recordType = recordTypeName; 
           recordTypeList.add(recordType);
        }
        list<ElixirSuite__Insurance_Type__mdt> mdt= [ SELECT Label,ElixirSuite__Order__c FROM ElixirSuite__Insurance_Type__mdt where Label in : recordTypeList WITH SECURITY_ENFORCED ORDER BY ElixirSuite__Order__c ];
        list<string> mdtList = new list<string>();
        for(ElixirSuite__Insurance_Type__mdt elixList:mdt){
            mdtList.add(elixList.Label);
        }
       if(mdtList.size()>0){
       String fieldName = fetchIdField(mdtList[0]);
       wrapper.insuranceTypes = mdtList;
       wrapper.insuranceListMap = fetchInsuranceList(mdtList[0],acctId,fieldName);
       }
        return wrapper;
    }
    @AuraEnabled
    public static Map <String,List<String>> fetchInsuranceList(String recordTypeName, String acctId, String fieldName) {
        Map<String,List<String>> vobMap = new Map<String,List<String>>();
        String query = 'SELECT Id, Name, ElixirSuite__Group_Number__c,ElixirSuite__Set_Default_VOB__c,ElixirSuite__VOB_Verification_Status__c, ElixirSuite__Member_Id__c, ElixirSuite__Insurance_ID_Number__c, CreatedDate, ElixirSuite__Payer__r.Name FROM ElixirSuite__VOB__c where ElixirSuite__Account__c=: acctId AND ElixirSuite__Status__c=\'Active\' AND ElixirSuite__Set_Default_VOB__c=\'Yes\' and RecordType.Name=\''+String.escapeSingleQuotes(RecordTypeName)+'\' WITH SECURITY_ENFORCED order by CreatedDate DESC';
        List<ElixirSuite__VOB__c> vobList = Database.query(query);
        for(ElixirSuite__VOB__c vob : vobList){
            List<String> idList = vobMap.get(vob.ElixirSuite__Payer__r.Name);
            if(idList !=null ){
                idList.add(String.valueOf(vob.get(fieldName)));
                vobMap.put(vob.ElixirSuite__Payer__r.Name, idList);
            }
            else{
                List<String> newIdList = new List<String>();
                newIdList.add(String.valueOf(vob.get(fieldName)));
                vobMap.put(vob.ElixirSuite__Payer__r.Name, newIdList);
            }
        }
        return vobMap;
    }
    @AuraEnabled
    public static ElixirSuite__VOB__c fetchVOBData(String recordTypeName, String acctId, String fieldName, String policyNo, String payerName) {
        String query ='SELECT Id, Name, ElixirSuite__Group_Number__c,ElixirSuite__Set_Default_VOB__c,ElixirSuite__VOB_Verification_Status__c, ElixirSuite__Member_Id__c, ElixirSuite__Insurance_ID_Number__c, ElixirSuite__Date_of_Accident__c,ElixirSuite__State_of_Occurrence__c,ElixirSuite__Group_Name__c, ElixirSuite__Payer__r.name, ElixirSuite__Payer_Name__c, ElixirSuite__Auto_Accident__c, ElixirSuite__Status__c, ElixirSuite__Account__c, ElixirSuite__Insurance_Group_Number_Sec__c, ElixirSuite__Last_Verified_Date__c  FROM ElixirSuite__VOB__c where ElixirSuite__Account__c=: acctId AND ElixirSuite__Status__c=\'Active\' and RecordType.Name=\''+String.escapeSingleQuotes(RecordTypeName)+'\' and '+String.escapeSingleQuotes(fieldname)+' =:policyNo and ElixirSuite__Payer__r.name =:payerName AND ElixirSuite__Set_Default_VOB__c=\'Yes\' WITH SECURITY_ENFORCED order by CreatedDate DESC LIMIT 1';
        ElixirSuite__VOB__c vob = Database.query(query);
        return vob;
    }
     @AuraEnabled
    public static ElixirSuite__Elixir_Custom_Setting__c getPaymentSetting(){
        return ElixirSuite__Elixir_Custom_Setting__c.getInstance();
    }

    @AuraEnabled
    public static Account getTileConfigFieldsOrder(Id accountId){
        
        Account patient = new Account();
        try {
            if(schema.sobjecttype.Account.isAccessible()
               && schema.sobjecttype.Account.fields.Name.isAccessible())
            {
                List<ElixirSuite__Master_Object__c> masterRec = [SELECT ElixirSuite__Field_Label__c, 
                                                                ElixirSuite__Field_Api__c, 
                                                                ElixirSuite__Patient_Tile_Entity__c, 
                                                                ElixirSuite__Patient_Tile_Order__c 
                                                                FROM ElixirSuite__Master_Object__c 
                                                                WHERE ElixirSuite__Patient_Tile_Entity__c ='Account' 
                                                                AND RecordType.DeveloperName='Patient_Info_Card_Configuration' 
                                                                WITH SECURITY_ENFORCED
                                                                ORDER BY ElixirSuite__Patient_Tile_Order__c];
                List<String> masterRecFields = new List<String>{'ElixirSuite__Age__c', 'ElixirSuite__Gender__c','BillingCity','BillingState','BillingCountry','ElixirSuite__MRN_Number_New__c'}; 
                String finalQuery = '';
                for(ElixirSuite__Master_Object__c itr : masterRec){       
                    String fieldapiname = itr.ElixirSuite__Field_Api__c;
                    if(!masterRecFields.contains(fieldapiname) && fieldapiname!='ElixirSuite__DOB__c'){
                        masterRecFields.add(fieldapiname);
                } 
                }
                finalQuery = 'SELECT ' + String.join(masterRecFields,',') +' FROM Account where Id=:accountId limit 1' ;
                String sanitisedQuery = String.escapeSingleQuotes(finalQuery);
                patient = Database.query(sanitisedQuery);
            }
            return patient;

        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        

    }


        @AuraEnabled
    public static Map<String,String> getlabelsforFields(){
        Map<String, String> fieldLabelMap = new Map<String, String>();
        try {
            if(schema.sobjecttype.Account.isAccessible()
               && schema.sobjecttype.Account.fields.Name.isAccessible())
            {
                List<ElixirSuite__Master_Object__c> masterRec = [SELECT ElixirSuite__Field_Label__c, 
                                                                ElixirSuite__Field_Api__c, 
                                                                ElixirSuite__Patient_Tile_Entity__c, 
                                                                ElixirSuite__Patient_Tile_Order__c 
                                                                FROM ElixirSuite__Master_Object__c 
                                                                WHERE ElixirSuite__Patient_Tile_Entity__c ='Account' 
                                                                AND RecordType.DeveloperName='Patient_Info_Card_Configuration' 
                                                                WITH SECURITY_ENFORCED
                                                                ORDER BY ElixirSuite__Patient_Tile_Order__c];
                for(ElixirSuite__Master_Object__c itr : masterRec){

                        fieldLabelMap.put(String.valueof(itr.ElixirSuite__Field_Api__c), String.valueof(itr.ElixirSuite__Field_Label__c));

                }
                fieldLabelMap.put('ElixirSuite__MRN_Number_New__c','MRN');
                fieldLabelMap.put('ElixirSuite__Gender__c','Gender');
                fieldLabelMap.put('ElixirSuite__Age__c','Age');
                fieldLabelMap.put('ElixirSuite__DOB__c','Birth Date');
                fieldLabelMap.put('BillingCity','Billing City');
                fieldLabelMap.put('BillingState','Billing State');
                fieldLabelMap.put('BillingCountry','Billing Country');
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return fieldLabelMap;
    }
    public class InsuranceDataWrapper {
    @AuraEnabled
    public List<String> insuranceTypes { get; set; }
    
    @AuraEnabled
    public Map<String, List<String>> insuranceListMap { get; set; }
}
    @AuraEnabled
    public static String fetchIdField(String recordTypeName) {
        if (recordTypeName == 'Auto-accident' || recordTypeName == 'Primary Insurance' || recordTypeName == 'Secondary Insurance' || recordTypeName == 'Tertiary Insurance' || recordTypeName == 'Durable Medical Equipment') {
            return 'ElixirSuite__Member_Id__c';
        }
        if (recordTypeName == 'Workers Comp') {
            return 'ElixirSuite__Group_Number__c';
        }
        return null; 
    }
}