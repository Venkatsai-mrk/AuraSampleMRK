public with sharing class Census_GetAllPatient {
     public static String displayDataTypeOfField(String objectName,String fieldName){      
        Schema.DisplayType f = Schema.getGlobalDescribe() // or Schema.SOAPType
            .get(objectName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldName)
            .getDescribe()
            .getType(); 
        System.debug(f);
        return String.valueOf(f);
    }
    public static String[] filterDateFields(List<String> queryFields,List<String> dateAndDateTimeFields){
        for(String sObj : queryFields){
            System.debug('$$123 ' +sObj);
            String result = displayDataTypeOfField('Account',sObj);
            if(result == 'DATETIME'){
                dateAndDateTimeFields.add(sObj);
            }
        }
        return dateAndDateTimeFields;
    }
    @AuraEnabled
    public static  patientWrap patientCardMethod(String buttonType , Boolean flagOnInit){

        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String patAccRecType = val.ElixirSuite__Patient_Account_Recordtype__c; 
        List<String> recordTypes = new List<String>{patAccRecType,'PersonAccount'};
         Boolean isProfilePicAllowed = false;
        //code for getting dependent values
        Schema.sObjectField dependToken = Account.ElixirSuite__Stage__c;
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        // if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
            (   control.getType() == Schema.DisplayType.Boolean
             ?   null
             :   control.getPicklistValues()
            );

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                    (   controlEntries == null
                     ?   (Object) (index == 1)
                     :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                    );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null
                     ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                    ) continue;
                String controlValue1 = String.valueOf(controlValue);
                if ( !dependentPicklistValues.containsKey( controlValue1 ) )
                {
                    dependentPicklistValues.put( controlValue1, new List<String>() );
                }
                dependentPicklistValues.get( controlValue1 ).add( entry.getLabel() );
            }

        }
        system.debug('dependValuesByControlValue' + dependentPicklistValues);

        List<String> valueSet1 = new List<String>();
        List<String> valueSet2 = new List<String>();
        List<String> valueSet3 = new List<String>();
        for(String key: dependentPicklistValues.keySet()){
            if(key == 'Patients In Review'){
                valueSet1 = dependentPicklistValues.get(key);
            }
            else if(key == 'Current Patients'){
                valueSet2 = dependentPicklistValues.get(key);
            }
            else if(key =='Discharged Patients'){
                valueSet3 = dependentPicklistValues.get(key);
            }
        }
               system.debug('valueSet1' + valueSet1);
         system.debug('valueSet2' + valueSet2);
         system.debug('valueSet3' + valueSet3); 
        // code finish for getting dependent values


        system.debug('gab' + flagOnInit);
        list<Account> patient = new list<Account>();
        list<Account> patient1 = new list<Account>();
        list<Account> patient2 = new list<Account>();
        list<Account> patient3 = new list<Account>();
        Set<Id> AccId = new Set<Id>();
        String bussinessAccRecType = val.ElixirSuite__Business_Account_Recordtype__c;
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(bussinessAccRecType).getRecordTypeId();

          List<String> dateAndDateTimeFields = new List<String>();
        Id recordTypeId =
            Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName()
            .get('Patient_Tile_Configuration').getRecordTypeId();
        ElixirSuite__Master_Object__c[] fieldsArr =[SELECT ID,ElixirSuite__Field_Label__c,ElixirSuite__Field_Api__c,ElixirSuite__Patient_Tile_Order__c FROM 
                                                    ElixirSuite__Master_Object__c WHERE RecordTypeId = : recordTypeId
                                                    AND ElixirSuite__Patient_Tile_Entity__c='Account' WITH SECURITY_ENFORCED
                                                    ORDER BY ElixirSuite__Patient_Tile_Order__c];
        Map<String,String> apiAndLabelMap = new Map<String,String>();
        Map<String,Integer> apiOrderMap = new Map<String,Integer>();
        if(schema.sobjecttype.Account.isAccessible()
           &&schema.sobjecttype.Account.fields.Phone.isAccessible()
           &&schema.sobjecttype.Account.fields.ElixirSuite__Email_Id__c.isAccessible()
           &&schema.sobjecttype.Account.fields.ElixirSuite__Blood_Group__c.isAccessible()
           && schema.sobjecttype.Account.fields.Name.isAccessible()
           && schema.sobjecttype.Account.fields.Age__c.isAccessible()
           && schema.sobjecttype.Account.fields.DOB__c.isAccessible()
           && schema.sobjecttype.Account.fields.Level_Of_Care_Name__c.isAccessible()
           && schema.sobjecttype.Account.fields.MRN_Number__c.isAccessible()
           && schema.sobjecttype.Account.fields.ElixirSuite__MRN_Number_New__c.isAccessible()
           //&& schema.sobjecttype.Account.fields.Bed__c.isAccessible()
           //&& schema.sobjecttype.Account.fields.Treatment_Center__c.isAccessible()
           && schema.sobjecttype.Account.fields.Admit_Date__c.isAccessible()
           && schema.sobjecttype.Account.fields.Discharge_Date__c.isAccessible())
        {



            String[] queryFields = new List<String>();

            String buildQuery = '';
            System.debug('fieldsArr 900 '+fieldsArr);
            if(fieldsArr!=null && fieldsArr.size()>0){
                for(ElixirSuite__Master_Object__c sObj : fieldsArr){
                    apiAndLabelMap.put(sObj.ElixirSuite__Field_Api__c,sObj.ElixirSuite__Field_Label__c);
                    queryFields.add(sObj.ElixirSuite__Field_Api__c);
                    apiOrderMap.put(sObj.ElixirSuite__Field_Label__c,Integer.valueOf(sObj.ElixirSuite__Patient_Tile_Order__c));
                    System.debug('order fields '+sObj.ElixirSuite__Field_Api__c);
                }    
                ElixirOEM_TimelineHelper.mDebugUntruncated(buildQuery); 

                buildQuery = String.join( queryFields, ',' );  
                 if(queryFields.contains('ElixirSuite__Profile_Picture__c')){
                     isProfilePicAllowed = true;
                 }
                /*if(queryFields.contains('ElixirSuite__Bed__c')){
                    buildQuery+=', ElixirSuite__Treatment_Center__r.ElixirSuite__Treatment_center_Name__c,'+
                        'ElixirSuite__House__r.Name,ElixirSuite__Rooms__r.Name,ElixirSuite__Bed__r.ElixirSuite__Formula_Name__c';
                }*/
                String preQuery = 'select Id,Name,ElixirSuite__Profile_Picture__c,ElixirSuite__Age__c,ElixirSuite__DOB__c,ElixirSuite__MRN_Number_New__c,ElixirSuite__Gender__c,'+buildQuery+
                    'Phone,ElixirSuite__Email_Id__c,ElixirSuite__Blood_Group__c,Profile_Picture__c,RecordType.Name,Patient_s_Birth_Date__c,MRN_Number__c,ElixirSuite__MRN_Number_New__c, Age__c,DOB__c,Admit_Date__c,Patient_Check_In__c,Patient_Discharged__c,ElixirSuite__dischargeDateNew__c, Discharge_Date__c,(select Id,name,birthdate from contacts) from Account where RecordType.DeveloperName IN :recordTypes AND elixirsuite__stage__c IN: valueSet3  order by createddate desc';



            }
            if(queryFields.isEmpty()){
                buildQuery = '';
            }
            if(buttonType=='All Patients'){ 
                if(String.isNotBlank(buildQuery)){
                    patient=Database.query('select Id,Name,'+buildQuery+',(select Id,name,birthdate from contacts) from Account where RecordType.DeveloperName IN :recordTypes  '+
                                           ' order by createddate desc' );
                    System.debug('patient val 1234'+patient);
             }
                else {
                     patient=Database.query('select Id,Name'+buildQuery+',(select Id,name,birthdate from contacts) from Account where RecordType.DeveloperName IN :recordTypes  '+
                                           ' order by createddate desc' ); 
                }
               ElixirOEM_TimelineHelper.mDebugUntruncated('select Id,Name,'+buildQuery+',(select Id,name,birthdate from contacts) from Account where RecordType.DeveloperName IN :recordTypes  '+ 
                                                          ' order by createddate desc'); 
            }
            if(buttonType=='Patients In Review' || flagOnInit==true){
                 System.debug('Patients In Review');  

                if(String.isNotBlank(buildQuery)){
                    patient1=Database.query('select Id,Name,'+buildQuery+',(select Id,name,birthdate from contacts) from Account where RecordType.DeveloperName IN :recordTypes AND elixirsuite__stage__c IN: valueSet1 '+
                                            ' order by createddate desc' );
                }
                else {
                     patient1=Database.query('select Id,Name'+buildQuery+',(select Id,name,birthdate from contacts) from Account where RecordType.DeveloperName IN :recordTypes AND elixirsuite__stage__c IN: valueSet1 '+
                                            ' order by createddate desc' );
                }
            }
            if(buttonType=='Current Patients' || flagOnInit==true){
                  System.debug('Current Patients');  
                if(String.isNotBlank(buildQuery)){
                    patient2=Database.query('select Id,Name,'+buildQuery+',(select Id,name,birthdate from contacts) from Account where RecordType.DeveloperName IN :recordTypes AND elixirsuite__stage__c IN: valueSet2  '+
                                            ' order by createddate desc' );
                }
                else {
                      patient2=Database.query('select Id,Name'+buildQuery+',(select Id,name,birthdate from contacts) from Account where RecordType.DeveloperName IN :recordTypes AND elixirsuite__stage__c IN: valueSet2  '+
                                            ' order by createddate desc' );
                }
            }
            if(buttonType=='Discharged Patients' || flagOnInit==true){
                System.debug('Discharged Patients'); 
                if(String.isNotBlank(buildQuery)){
                    patient3=Database.query('select Id,Name,'+buildQuery+',(select Id,name,birthdate from contacts) from Account where RecordType.DeveloperName IN :recordTypes AND elixirsuite__stage__c IN: valueSet3  '+
                                            ' order by createddate desc');
                }
                else {
                      patient3=Database.query('select Id,Name'+buildQuery+',(select Id,name,birthdate from contacts) from Account where RecordType.DeveloperName IN :recordTypes AND elixirsuite__stage__c IN: valueSet3  '+
                                            ' order by createddate desc');
                }
            }

        }
        for(Account a : patient){
            if(a.Id != Null)
                AccId.add(a.Id);
        }
       formatDate(patient,dateAndDateTimeFields); 
        formatDate(patient1,dateAndDateTimeFields); 
        formatDate(patient2,dateAndDateTimeFields); 
        formatDate(patient3,dateAndDateTimeFields); 
            System.debug('patient1 '+patient1.size());
        patientWrap patwrap =new patientwrap(patient,AccId,patient1,patient2,patient3,fieldsArr,
                                             ElixirOEM_FormConfigurationHelper.fetchFieldsForSelectedObject('Account'),
                                             apiAndLabelMap,apiOrderMap,isProfilePicAllowed); 

        return patwrap;    

      /*  catch(Exception e){
          
            ExceptionLog.logError(e);
              return null;
        }*/
    }
    public static void formatDate(List<Account> acctLst,String[] fields){
        System.debug('Accounts '+acctLst);
          System.debug('fields '+fields);
           for(Account a : acctLst){
               for(String s : fields){
                   DateTime dt =(DateTime)a.get(s);
                   dt.formatGMT('yyyy-MM-dd'); 
                   a.put(s,dt);
               }

        }

    }
    public class patientWrap{

        @AuraEnabled public list<Account> pat{get;set;}
        @AuraEnabled public list<Account> pat1{get;set;}
        @AuraEnabled public list<Account> pat2{get;set;}
        @AuraEnabled public list<Account> pat3{get;set;}
        @AuraEnabled public integer TotalAcc{get;set;}
        @AuraEnabled public integer TotalAcc1{get;set;}
        @AuraEnabled public integer TotalAcc2{get;set;}
        @AuraEnabled public integer TotalAcc3{get;set;}
        @AuraEnabled public  ElixirSuite__Master_Object__c[] fieldsArr{get;set;}
        @AuraEnabled public  Map<String,String> apiLabelMap{get;set;}
        @AuraEnabled public  Map<String,String> apiLabelMapConfig{get;set;}
        @AuraEnabled public  Map<String,Integer> apiOrderMap{get;set;}
         @AuraEnabled public Boolean isProfilePicAllowed{get;set;}
        public patientwrap(list<Account> patnt, Set<Id> AccId, list<Account> patnt1,list<Account> patnt2,list<Account> patnt3,
                           ElixirSuite__Master_Object__c[] fieldsArr_Method, Map<String,String> apiLabelMap_param,
                           Map<String,String> apiLabelMapConfig_param,Map<String,Integer> apiOrderMap_param, Boolean isProfilePicAllowed_param){
                               pat=patnt;
                               pat1=patnt1;
                               pat2=patnt2;
                               pat3=patnt3;
                               TotalAcc = patnt.size();
                               TotalAcc1 = patnt1.size();
                               TotalAcc2 = patnt2.size();
                               TotalAcc3 = patnt3.size();
                               fieldsArr = fieldsArr_Method;
                               apiLabelMap = apiLabelMap_param;      
                               apiLabelMapConfig = apiLabelMapConfig_param;   
                               apiOrderMap = apiOrderMap_param;
                               isProfilePicAllowed = isProfilePicAllowed_param;
                               list<ContentVersion> cv = new list<ContentVersion>();

                               try{
                                   if(schema.sobjecttype.ContentVersion.isAccessible()
                                      && schema.sobjecttype.ContentVersion.fields.FIRSTPUBLISHLOCATIONID.isAccessible()
                                      && schema.sobjecttype.ContentVersion.fields.Title.isAccessible())
                                   { 
                                       cv = [select id from ContentVersion WHERE FIRSTPUBLISHLOCATIONID IN:AccId AND Title like '%_profilePic%' WITH SECURITY_ENFORCED order by createdDate desc limit 1];
                                   }
                                   system.debug('cv id'+cv);
                                   list<string> cvsId = new list<string>();
                                   for(ContentVersion cvs : cv){
                                       if(cvs.Id!=null)
                                           cvsId.add(cvs.Id);  
                                       else
                                           cvsId.add('XXXXXXXXXXXXXXXXXX');
                                   }

                               }

                               catch(Exception e)
                               {
                                   System.debug('ERROR:' + e.getLineNumber()+e.getMessage());
                               }

                           }
    }
    public static void patientTileFieldCreate(){
        Id recordTypeId =
            Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName()
            .get('Patient_Tile_Configuration').getRecordTypeId();
        ElixirSuite__Master_Object__c[] fieldsArr =[SELECT ID,ElixirSuite__Field_Label__c,ElixirSuite__Field_Api__c FROM 
                                                    ElixirSuite__Master_Object__c WHERE RecordTypeId = : recordTypeId
                                                    AND ElixirSuite__Patient_Tile_Entity__c='Account' WITH SECURITY_ENFORCED];
        String fieldApiNames = 'SELECT '; 
        for(ElixirSuite__Master_Object__c sObj : fieldsArr){
            fieldApiNames+=sObj.ElixirSuite__Field_Api__c+',';
        }
        fieldApiNames+=' FROM Account';
    }
    @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name from User where Id =:currentUid].ElixirSuite__License_Type__c;
        List<String> lst_availLicense = new List<String>();
        lst_availLicense = AvailLicense.split(';');
        License_Class lCls = new License_Class();
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
        return lCls;
    }
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr;
        @AuraEnabled public Boolean isRcm;
        @AuraEnabled public Boolean isContactCenter;
    }

    @AuraEnabled
    Public static List<Account> getSearchAccount(String searchKey, String currentVal){
         //code for getting dependent values
        Schema.sObjectField dependToken = Account.ElixirSuite__Stage__c;
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        // if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
            (   control.getType() == Schema.DisplayType.Boolean
             ?   null
             :   control.getPicklistValues()
            );

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                    (   controlEntries == null
                     ?   (Object) (index == 1)
                     :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                    );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null
                     ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                    ) continue;
                String controlValue1 = String.valueOf(controlValue);
                if ( !dependentPicklistValues.containsKey( controlValue1 ) )
                {
                    dependentPicklistValues.put( controlValue1, new List<String>() );
                }
                dependentPicklistValues.get( controlValue1 ).add( entry.getLabel() );
            }

        }
        system.debug('dependValuesByControlValue' + dependentPicklistValues);

        List<String> valueSet1 = new List<String>();
        List<String> valueSet2 = new List<String>();
        List<String> valueSet3 = new List<String>();
        for(String key: dependentPicklistValues.keySet()){
            if(key == 'Patients In Review'){
                valueSet1 = dependentPicklistValues.get(key);
            }
            else if(key == 'Current Patients'){
                valueSet2 = dependentPicklistValues.get(key);
            }
            else if(key =='Discharged Patients'){
                valueSet3 = dependentPicklistValues.get(key);
            }
        }
        system.debug('valueSet1' + valueSet1);
         system.debug('valueSet2' + valueSet2);
         system.debug('valueSet3' + valueSet3);
        // code finish for getting dependent values
        String name =  + searchKey + '%';
        //   Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String bussinessAccRecType = val.ElixirSuite__Business_Account_Recordtype__c;
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(bussinessAccRecType).getRecordTypeId();
        list<Account> patient = new list<Account>();
        list<Account> patient1 = new list<Account>();
        list<Account> patient2 = new list<Account>();
        list<Account> patient3 = new list<Account>();

        if(currentVal=='All Patients'){
            patient=[select Id,Name,Phone,ElixirSuite__Email_Id__c,ElixirSuite__Blood_Group__c,Profile_Picture__c,RecordType.Name,Patient_s_Birth_Date__c,MRN_Number__c,ElixirSuite__MRN_Number_New__c,
                     Age__c,DOB__c,Admit_Date__c,Patient_Check_In__c,Patient_Discharged__c,
                     Discharge_Date__c,(select Id,name,birthdate from contacts) from Account where recordtypeId !=: devRecordTypeId and name LIKE :name
                     AND ElixirSuite__dischargeDateNew__c!=NULL AND Admit_Date__c!=NULL
                     WITH SECURITY_ENFORCED
                     order by createddate desc ];
        }
        else if(currentVal=='Patients In Review'){
            patient=[select Id,Name,Phone,ElixirSuite__Email_Id__c,ElixirSuite__Blood_Group__c,Profile_Picture__c,RecordType.Name,Patient_s_Birth_Date__c,MRN_Number__c,ElixirSuite__MRN_Number_New__c,
                     Age__c,DOB__c,Admit_Date__c,Patient_Check_In__c,Patient_Discharged__c,
                     Discharge_Date__c,(select Id,name,birthdate from contacts) from Account where recordtypeId !=: devRecordTypeId AND Patient_Check_In__c=FALSE and name LIKE :name 
                     AND ElixirSuite__dischargeDateNew__c!=NULL AND Admit_Date__c!=NULL AND elixirsuite__stage__c IN: valueSet1
                     WITH SECURITY_ENFORCED
                     order by createddate desc ];
        }
        else if(currentVal=='Current Patients'){
            patient=[select Id,Name,Phone,ElixirSuite__Email_Id__c,ElixirSuite__Blood_Group__c,Profile_Picture__c,RecordType.Name,Patient_s_Birth_Date__c,MRN_Number__c,ElixirSuite__MRN_Number_New__c,
                     Age__c,DOB__c,Admit_Date__c,Patient_Check_In__c,Patient_Discharged__c,
                     Discharge_Date__c,(select Id,name,birthdate from contacts) from Account where recordtypeId !=: devRecordTypeId AND Patient_Check_In__c=TRUE and name LIKE :name 
                     AND ElixirSuite__dischargeDateNew__c!=NULL AND Admit_Date__c!=NULL AND elixirsuite__stage__c IN: valueSet2
                     WITH SECURITY_ENFORCED
                     order by createddate desc ];
        }
        else if(currentVal=='Discharged Patients'){
            patient=[select Id,Name,Phone,ElixirSuite__Email_Id__c,ElixirSuite__Blood_Group__c,Profile_Picture__c,RecordType.Name,Patient_s_Birth_Date__c,MRN_Number__c,ElixirSuite__MRN_Number_New__c,
                     Age__c,DOB__c,Admit_Date__c,Patient_Check_In__c,Patient_Discharged__c,
                     Discharge_Date__c,(select Id,name,birthdate from contacts) from Account where recordtypeId !=: devRecordTypeId AND Patient_Discharged__c=TRUE and name LIKE :name 
                     AND ElixirSuite__dischargeDateNew__c!=NULL AND Admit_Date__c!=NULL AND elixirsuite__stage__c IN: valueSet3
                     WITH SECURITY_ENFORCED
                     order by createddate desc ];
        }
        return patient;
    }


    @AuraEnabled
    public static void handlingAfterUpload(Id accountId){
        Integer var = 0;
        var++;

        var ++;
        ContentVersion cv = new ContentVersion();
        ContentDocument cd=new ContentDocument();
        try{
            if(schema.sobjecttype.ContentVersion.isAccessible()
               && schema.sobjecttype.ContentVersion.fields.FIRSTPUBLISHLOCATIONID.isAccessible()
               && schema.sobjecttype.ContentVersion.fields.Title.isAccessible())
            {
                cv = [select id,Title from ContentVersion WHERE FIRSTPUBLISHLOCATIONID=:accountId WITH SECURITY_ENFORCED order by createdDate desc limit 1];
                if(cv.Id!=null){
                    cv.Title=cv.Title+'_profilePic';
                }
            }
            if (Schema.sObjectType.ContentVersion.fields.Title.isUpdateable())
                update cv;
        }
        catch(Exception e)
        {
            System.debug('ERROR:' + e +e.getLineNumber());
        }
    }
    @AuraEnabled
    public static List<sObject> serachResultForFilter(String key){
        Map<String,String> mapOfKeyToObject = new Map<String,String> { 
             'Location'=>'ElixirSuite__Provider__c'
                };
                    String query = '';
        if(key=='Level Of Care'){
            query = 'SELECT ID,Name FROM '+mapOfKeyToObject.get(String.escapeSingleQuotes(key));
        }
        else {
            query = 'SELECT ID,Name FROM '+mapOfKeyToObject.get(String.escapeSingleQuotes(key)); 
        }

        return Database.query(String.escapeSingleQuotes(query));        
    }
    @AuraEnabled
    public static PatientTileWrapper filterForPatientTile(String fromDate, String toDate,Boolean isFilterByDateUsed,Boolean isCombinedFilterUsed,
                                                          String doubleFilterValue,String filterValue,String filterByDate)
    {  
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String bussinessAccRecType = val.ElixirSuite__Business_Account_Recordtype__c;
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(bussinessAccRecType).getRecordTypeId();
        VariableWrapper varObj = new VariableWrapper();
        Map<String,String> mapOfKeyToObject = new Map<String,String> { 
            'Level Of Care'=>'ElixirSuite__Level_Of_Care__c',
                'Location'=>'ElixirSuite__Active_Care_Episode_Location__c',
                'Gender' => 'ElixirSuite__Gender__c',
                'MRN' =>'ElixirSuite__MRN_Number_New__c',
                'Admit Date' => 'ElixirSuite__Admit_Date__c',
                'Discharge Date' => 'ElixirSuite__dischargeDateNew__c',
                'Primary Care Physician' =>'ElixirSuite__Primary_Care_Physician__c' 
                };
                    SYSTEM.debug('isFilterByDateUsed' + isFilterByDateUsed);
        SYSTEM.debug('isCombinedFilterUsed' + isCombinedFilterUsed); 


        String query = '';

        if(isFilterByDateUsed && isCombinedFilterUsed){
              System.debug('1');
            System.debug('doubleFilterValue '+mapOfKeyToObject.get(filterByDate));
            Date fDate = Date.valueOf(fromDate);
            Date tDate = Date.valueOf(toDate);
            if(String.isBlank(dynamicTileQueryBuilder().tileDynamicQuery)){
                query = 'select Id,Name'+
                ',(select Id,name,birthdate from contacts) from Account WHERE '+ mapOfKeyToObject.get(String.escapeSingleQuotes(filterByDate))+' >= :'+'fDate'+' AND '+
                mapOfKeyToObject.get(String.escapeSingleQuotes(filterByDate))+' <= :'+'tDate'+' AND '+ 'recordtypeId !=: devRecordTypeId'+''+ ' AND '+ 
                mapOfKeyToObject.get(String.escapeSingleQuotes(doubleFilterValue))+'='+'\''+String.escapeSingleQuotes(filterValue)+'\'';  
            }
            else {
                query = 'select Id,Name,'+String.escapeSingleQuotes(dynamicTileQueryBuilder().tileDynamicQuery)+
                ',(select Id,name,birthdate from contacts) from Account WHERE '+ mapOfKeyToObject.get(String.escapeSingleQuotes(filterByDate))+' >= :'+'fDate'+' AND '+
                mapOfKeyToObject.get(String.escapeSingleQuotes(filterByDate))+' <= :'+'tDate'+' AND '+ 'recordtypeId !=: devRecordTypeId'+''+ ' AND '+ 
                mapOfKeyToObject.get(String.escapeSingleQuotes(doubleFilterValue))+'='+'\''+String.escapeSingleQuotes(filterValue)+'\'';  
            }

            if(mapOfKeyToObject.get(filterByDate) == 'ElixirSuite__Admit_Date__c'){
                query+= ' AND ElixirSuite__Admit_Date__c!=null ';
            }
            else if(mapOfKeyToObject.get(filterByDate) == 'ElixirSuite__dischargeDateNew__c'){
                query+= ' AND ElixirSuite__dischargeDateNew__c!=null '; 
            }
        }
        else { 
            if(isFilterByDateUsed && isCombinedFilterUsed==false){
                 System.debug('2');
                Date fDate = Date.valueOf(fromDate);
                Date tDate = Date.valueOf(toDate);
                varObj.fDate = fDate;
                varObj.tDate = tDate;
                //    Date tDate = Date.valueOf(filterByDate);
                if(String.isBlank(dynamicTileQueryBuilder().tileDynamicQuery)){
                    query = 'select Id,Name'+
                    ',(select Id,name,birthdate from contacts) from Account WHERE '+ mapOfKeyToObject.get(String.escapeSingleQuotes(filterByDate))+' >= :'+'fDate'+''+ ' AND '+ 
                    mapOfKeyToObject.get(String.escapeSingleQuotes(filterByDate))+' <= :'+'tDate'+' AND '+ 'recordtypeId !=: devRecordTypeId';  
                }
                else {
                    query = 'select Id,Name,'+String.escapeSingleQuotes(dynamicTileQueryBuilder().tileDynamicQuery)+
                    ',(select Id,name,birthdate from contacts) from Account WHERE '+ mapOfKeyToObject.get(String.escapeSingleQuotes(filterByDate))+' >= :'+'fDate'+''+ ' AND '+ 
                    mapOfKeyToObject.get(String.escapeSingleQuotes(filterByDate))+' <= :'+'tDate'+' AND '+ 'recordtypeId !=: devRecordTypeId';  
                }

            }  

            else if(isCombinedFilterUsed && isFilterByDateUsed==false){
                 System.debug('3');
                if(mapOfKeyToObject.containsKey(doubleFilterValue)){
                    if(String.isBlank(dynamicTileQueryBuilder().tileDynamicQuery)){
                        query =  'select Id,Name'+
                        ',(select Id,name,birthdate from contacts) from Account WHERE '+
                        mapOfKeyToObject.get(String.escapeSingleQuotes(doubleFilterValue))+'='+'\''+String.escapeSingleQuotes(filterValue)+'\''+' AND '+ 'recordtypeId !=: devRecordTypeId' +'';
                    }
                    else {
                    query =  'select Id,Name,'+String.escapeSingleQuotes(dynamicTileQueryBuilder().tileDynamicQuery)+
                        ',(select Id,name,birthdate from contacts) from Account WHERE '+
                        mapOfKeyToObject.get(String.escapeSingleQuotes(doubleFilterValue))+'='+'\''+String.escapeSingleQuotes(filterValue)+'\''+' AND '+ 'recordtypeId !=: devRecordTypeId' +'';
                    }
                }
            }
        }

        mDebugUntruncated(query);
        PatientTileWrapper toReturn = new PatientTileWrapper();
        toReturn.toReturnAllRecords =  Database.query(query);
        toReturn.query = query;
        filterSize(toReturn, varObj.fDate, varObj.tDate,devRecordTypeId);
        toReturn.fieldsArr = patientTileArrQuery( Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName()
                                                 .get('Patient_Tile_Configuration').getRecordTypeId());
        toReturn.apiLabelMap = ElixirOEM_FormConfigurationHelper.fetchFieldsForSelectedObject('Account');
        toReturn.apiLabelMapConfig = dynamicTileQueryBuilder().apiLabelMap;
        toReturn.apiOrderMap = dynamicTileQueryBuilder().apiOrderMap;
        return toReturn;      
    }
    public static void mDebugUntruncated(String sMsg) {
        for (Integer i = 0; i < sMsg.length(); i=i+300) {
            Integer iEffectiveEnd = (i+300 > (sMsg.length()-1) ? sMsg.length()-1 : i+300);
            System.debug(sMsg.substring(i,iEffectiveEnd));
        }
    }
    public static void filterSize(PatientTileWrapper sObj,Date fDate,Date tDate, Id devRecordTypeId){
        sObj.TotalAcc = sObj.toReturnAllRecords.size(); // All Patients

        sObject[] count1 = Database.query(sObj.query+' AND Patient_Check_In__c=FALSE'); // Patients In Review
        sObj.TotalAcc1 = count1.size();

        sObject[] count2 = Database.query(sObj.query+' AND Patient_Check_In__c=TRUE'); // Current Patients
        sObj.TotalAcc2 = count2.size();

        sObject[] count3 = Database.query(sObj.query+' AND Patient_Discharged__c=TRUE'); // Discharged Patients
        sObj.TotalAcc3 = count3.size();        
    }

    public class PatientTileWrapper{
        @AuraEnabled public  List<sObject> toReturnAllRecords{ get; set; }
        @AuraEnabled public  String query{ get; set; }  
        @AuraEnabled public  String tileDynamicQuery{ get; set; }
        @AuraEnabled public integer TotalAcc{get;set;}
        @AuraEnabled public integer TotalAcc1{get;set;}
        @AuraEnabled public integer TotalAcc2{get;set;}
        @AuraEnabled public integer TotalAcc3{get;set;}
        @AuraEnabled public  ElixirSuite__Master_Object__c[] fieldsArr{get;set;}
        @AuraEnabled public  Map<String,String> apiLabelMap{get;set;}
        @AuraEnabled public  Map<String,String> apiLabelMapConfig{get;set;}
        @AuraEnabled public  Map<String,Integer> apiOrderMap{get;set;}
    }
    public static PatientTileWrapper dynamicTileQueryBuilder(){
        PatientTileWrapper doamin_sObj = new PatientTileWrapper();
        Id recordTypeId =
            Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName()
            .get('Patient_Tile_Configuration').getRecordTypeId();
        ElixirSuite__Master_Object__c[] fieldsArr = patientTileArrQuery(recordTypeId);
        Map<String,String> apiAndLabelMap = new Map<String,String>();
        Map<String,Integer> apiOrderMap = new Map<String,Integer>();
        String[] queryFields = new List<String>();
        String buildQuery = '';
        System.debug('fieldsArr '+fieldsArr);
        if(fieldsArr!=null && fieldsArr.size()>0){
            for(ElixirSuite__Master_Object__c sObj : fieldsArr){
                apiAndLabelMap.put(sObj.ElixirSuite__Field_Api__c,sObj.ElixirSuite__Field_Label__c);
                queryFields.add(sObj.ElixirSuite__Field_Api__c);
                apiOrderMap.put(sObj.ElixirSuite__Field_Label__c,Integer.valueOf(sObj.ElixirSuite__Patient_Tile_Order__c));
                System.debug('order fields '+sObj.ElixirSuite__Field_Api__c);
            }    
            ElixirOEM_TimelineHelper.mDebugUntruncated(buildQuery); 
            buildQuery = String.join( queryFields, ', ' );  

            /*if(queryFields.contains('ElixirSuite__Bed__c')){
                buildQuery+=', ElixirSuite__Treatment_Center__r.ElixirSuite__Treatment_center_Name__c,'+
                    'ElixirSuite__House__r.Name,ElixirSuite__Rooms__r.Name,ElixirSuite__Bed__r.ElixirSuite__Formula_Name__c';
            }*/
        }
        doamin_sObj.tileDynamicQuery = buildQuery;
        doamin_sObj.apiLabelMap = apiAndLabelMap;
        doamin_sObj.apiOrderMap = apiOrderMap;
        return doamin_sObj;
    }
    public class VariableWrapper{
        @AuraEnabled    public Date fDate{ get; set; }
        @AuraEnabled    public  Date tDate{ get; set; }
    } 
    public static  ElixirSuite__Master_Object__c[] patientTileArrQuery(Id recordTypeId)
    {  
        return [SELECT ID,ElixirSuite__Field_Label__c,ElixirSuite__Field_Api__c,ElixirSuite__Patient_Tile_Order__c FROM 
                ElixirSuite__Master_Object__c WHERE RecordTypeId = : recordTypeId
                AND ElixirSuite__Patient_Tile_Entity__c='Account' WITH SECURITY_ENFORCED
                ORDER BY ElixirSuite__Patient_Tile_Order__c];
    }
    @AuraEnabled
    public static void failingCallback()
    {  
    }
    
}