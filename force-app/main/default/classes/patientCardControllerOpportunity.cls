public with sharing class patientCardControllerOpportunity {
    
    @AuraEnabled
    public static  opportunity patientCardMethod(Id oppId){
        Opportunity patient = new Opportunity(); 
        try{
        if(Schema.sobjecttype.Opportunity.isAccessible() 
                          && Schema.sObjectType.Opportunity.fields.Patient_s_DOB__c.isAccessible() && Schema.sObjectType.Opportunity.fields.Profile_Picture__c.isAccessible() )
        
        {
            patient=[select Name,Patient_s_DOB__c,Profile_Picture__c,ElixirSuite__Patient_First_Name__c,ElixirSuite__Patient_Middle_Name__c, ElixirSuite__Patient_Last_Name__c from Opportunity where Id=:oppId limit 1];
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
            return patient;       
    }
    @AuraEnabled
    public static void handlingAfterUpload(Id oppId){
        Integer var = 0;
        var++;
        
        var ++;
        ContentVersion cv = new ContentVersion();
        ContentDocument cd=new ContentDocument();
        ContentDocumentLink cdl=new ContentDocumentLink();
        try{
            if(schema.sobjecttype.ContentVersion.isAccessible()
               && schema.sobjecttype.ContentVersion.fields.FIRSTPUBLISHLOCATIONID.isAccessible()
               && schema.sobjecttype.ContentVersion.fields.Title.isAccessible() && schema.sobjecttype.ContentVersion.fields.ContentDocumentId.isAccessible())
            {
                cv = [select id,Title,ContentDocumentId from ContentVersion WHERE FIRSTPUBLISHLOCATIONID=:oppId WITH SECURITY_ENFORCED order by createdDate desc limit 1];
                system.debug('oatiebt val ' + cv);
                if(cv.Id!=null){
                    cv.Title=cv.Title+'_profilePic';
                }
                Opportunity opp = new Opportunity();
                if(Schema.sobjecttype.Opportunity.isAccessible() 
                          && Schema.sObjectType.Opportunity.fields.Profile_Picture__c.isAccessible())
                {
                      opp =[select id,Profile_Picture__c from Opportunity where id =:oppId]; 
                }
             
                opp.Profile_Picture__c = cv.id;
                if(schema.sobjecttype.Opportunity.isUpdateable() && schema.sobjecttype.Opportunity.isAccessible() && Schema.sObjectType.Opportunity.fields.Profile_Picture__c.isUpdateable())
                
                {
                    update opp;
                }
            }
            if (Schema.sObjectType.ContentVersion.isUpdateable() && schema.sobjecttype.ContentVersion.isAccessible() &&
               Schema.sObjectType.ContentVersion.fields.Title.isUpdateable())
            {
                
                update cv;  
            }
             
        }
        catch(Exception e)
        {
            System.debug('ERROR:' + e);
        }
    }
     @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name from User where Id =:currentUid].ElixirSuite__License_Type__c;
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
    public static Opportunity getTileConfigFieldsOrder(Id oppId){
        System.debug('*opportunity id '+oppId);
        Opportunity patient = new Opportunity();
        try {
            if(schema.sobjecttype.Opportunity.isAccessible()
               && schema.sobjecttype.Opportunity.fields.Name.isAccessible())
            {
                List<ElixirSuite__Master_Object__c> masterRec = [SELECT ElixirSuite__Field_Label__c, 
                                                                ElixirSuite__Field_Api__c, 
                                                                ElixirSuite__Patient_Tile_Entity__c, 
                                                                ElixirSuite__Patient_Tile_Order__c 
                                                                FROM ElixirSuite__Master_Object__c 
                                                                WHERE ElixirSuite__Patient_Tile_Entity__c ='Opportunity' 
                                                                AND RecordType.DeveloperName='Patient_Info_Card_Configuration' WITH SECURITY_ENFORCED
                                                                ORDER BY ElixirSuite__Patient_Tile_Order__c];
                List<String> masterRecFields = new List<String>{'ElixirSuite__Gender__c', 'ElixirSuite__DOB__c'}; 
                String finalQuery = '';
               /* for(ElixirSuite__Master_Object__c itr : masterRec){       
                    String fieldapiname = itr.ElixirSuite__Field_Api__c;
                    if(!masterRecFields.contains(fieldapiname)){
                        masterRecFields.add(fieldapiname);
                    }
                }*/
                Map<String,String> apiAndLabelMap = new Map<String,String>();
                Map<String,Integer> apiOrderMap = new Map<String,Integer>();
                String[] queryFields = new List<String>();
                for(ElixirSuite__Master_Object__c sObj : masterRec){
                    apiAndLabelMap.put(sObj.ElixirSuite__Field_Api__c,sObj.ElixirSuite__Field_Label__c);
                    queryFields.add(sObj.ElixirSuite__Field_Api__c);
                    apiOrderMap.put(sObj.ElixirSuite__Field_Label__c,Integer.valueOf(sObj.ElixirSuite__Patient_Tile_Order__c));
                    System.debug('order fields '+sObj.ElixirSuite__Field_Api__c);
                } 
                finalQuery = 'SELECT ' + String.join(queryFields,',') +' FROM Opportunity where Id=:oppId limit 1' ;
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
            if(schema.sobjecttype.Opportunity.isAccessible()
               && schema.sobjecttype.Opportunity.fields.Name.isAccessible())
            {
                List<ElixirSuite__Master_Object__c> masterRec = [select ElixirSuite__Field_Label__c, ElixirSuite__Field_Api__c, ElixirSuite__Patient_Tile_Entity__c, ElixirSuite__Patient_Tile_Order__c FROM ElixirSuite__Master_Object__c where ElixirSuite__Patient_Tile_Entity__c ='Opportunity' and RecordType.DeveloperName='Patient_Info_Card_Configuration' WITH SECURITY_ENFORCED order by ElixirSuite__Patient_Tile_Order__c];
                for(ElixirSuite__Master_Object__c itr : masterRec){
                    //masterRecFields.add(itr.ElixirSuite__Field_Label__c);
                
                        fieldLabelMap.put(String.valueof(itr.ElixirSuite__Field_Api__c), String.valueof(itr.ElixirSuite__Field_Label__c));
                   
                }
               /* fieldLabelMap.put('Name','Name');
              	  fieldLabelMap.put('ElixirSuite__Gender__c','Gender');
                  fieldLabelMap.put('ElixirSuite__DOB__c','DOB');*/
            }
            System.debug('FiledLabelMap '+fieldLabelMap);
            return fieldLabelMap;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
       
    }
    
    public class PatientWrapper{
        @AuraEnabled public opportunity patient;
        @AuraEnabled public opportunity getTileConfigFieldsOrder;
        @AuraEnabled public Map<String,String> getlabelsforFields;
        
    }
    @AuraEnabled
    public static patientWrapper patientWrapperMethod(Id oppId){
        try {
            PatientWrapper pw = new PatientWrapper();
            pw.patient = patientCardMethod(oppId);
            pw.getTileConfigFieldsOrder =  getTileConfigFieldsOrder(oppId);
            pw.getlabelsforFields = getlabelsforFields();
            System.debug('patient wrapper patient '+pw.patient);
            System.debug('patient wrapper getTileConfigFieldsOrder '+pw.getTileConfigFieldsOrder);
            System.debug('patient wrapper getlabelsforFields '+pw.getlabelsforFields);
            return pw;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  
    
    
}