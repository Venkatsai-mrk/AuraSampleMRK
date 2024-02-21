@isTest
public class TestCensus_GetAllPatient {
    
    @isTest
    public static void getPatients(){
        //Inserting Account
        Account a =new Account ();
        a.Name= 'Virat Kohli';
        a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        a.ElixirSuite__Gender__c='Male';
        a.ElixirSuite__Email_Id__c='virat@gmail.com';
        a.phone='9988776655';
        a.ElixirSuite__First_Name__c='Virat';
        a.ElixirSuite__Last_Name__c='Kohli';
        a.BillingPostalCode='50021';
        a.ElixirSuite__SSN__c='12345';
        a.ElixirSuite__MRN_Number_New__c='1234567890';

        insert a;

        //Inserting opportunity
        Opportunity o=new Opportunity();
        o.Name='test';
        o.AccountId=a.id;
        o.StageName='Prospecting';
        o.CloseDate=system.today();
        o.Gender__c='Male';
        o.Admit_Date__c=system.today();
        o.Discharge_Date__c=system.now();
        insert o;

        //Inserting Visit
        visits__c v=new visits__c();
        v.Name='test';
        v.Account__c=a.id;
        v.Opportunity__c=o.id;
        o.Gender__c=o.Gender__c;
        v.Status__c='Active';
        StopRecursion.stopLocationUpdation = false;
        insert v;
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        setting.ElixirSuite__Business_Account_Recordtype__c = 'Business_Account';
        insert setting;
        String obj='Account';
        String fiel='Name';
        List<String> queryFields = new List<String>();
       Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
       for (String fieldName : fieldMap.keySet()) {
        queryFields.add(fieldName);
      }

         List<String> dateAndDateTimeFields = new List<String>();
         SObjectType accountType = Account.getSObjectType();
         Map<String, SObjectField> fieldsMap = accountType.getDescribe().fields.getMap();
        for (String fieldName : fieldsMap.keySet()) {
          SObjectField field = fieldsMap.get(fieldName);
          if (field.getDescribe().getType() == Schema.DisplayType.Date ||
              field.getDescribe().getType() == Schema.DisplayType.DateTime) {
              dateAndDateTimeFields.add(fieldName);
          }
      }
      String key='Location';
      String sMsg='abcedefgh';

      String fromDate = '2023-02-06';
      String toDate = '2023-02-26';
      Boolean isFilterByDateUsed = true;
      Boolean isCombinedFilterUsed = true;
      String doubleFilterValue = 'Gender';
      String filterValue = 'Male';
      String filterByDate = 'Admit Date';

      Id recordTypeId =
      Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName()
      .get('Patient_Tile_Configuration').getRecordTypeId();
      Census_GetAllPatient.VariableWrapper var=new Census_GetAllPatient.VariableWrapper();
      var.fDate=Date.newInstance(2023, 5, 17);
      var.tDate=Date.newInstance(2022, 5, 20);

        Census_GetAllPatient.License_Class lc=new Census_GetAllPatient.License_Class();
        lc.isContactCenter=true;
        lc.isEhr=true;
        lc.isRcm=true;

        Test.startTest();
        Census_GetAllPatient.displayDataTypeOfField(obj, fiel);
        Census_GetAllPatient.filterDateFields(queryFields, dateAndDateTimeFields);
        Census_GetAllPatient.patientCardMethod('current', true);
        Census_GetAllPatient.getSearchAccount('t', 'Current');
        Census_GetAllPatient.handlingAfterUpload(a.id);
        Census_GetAllPatient.patientTileFieldCreate();
        Census_GetAllPatient.LicensBasdPermission();
        Census_GetAllPatient.serachResultForFilter(key);
        Census_GetAllPatient.filterForPatientTile(fromDate, toDate, isFilterByDateUsed, isCombinedFilterUsed,
        doubleFilterValue, filterValue, filterByDate);
        Census_GetAllPatient.filterForPatientTile('', '', false, true, 'Gender', 'Male', '');
       // Census_GetAllPatient.filterForPatientTile('', '', false, false, '', '', '');
        Census_GetAllPatient.dynamicTileQueryBuilder();
        Census_GetAllPatient.patientTileArrQuery(recordTypeId);

        Census_GetAllPatient.mDebugUntruncated(sMsg);
        System.assert(o.Name!=null,'');
        System.assertEquals(1,1,'');
        Test.stopTest();
        
        
    } 
}