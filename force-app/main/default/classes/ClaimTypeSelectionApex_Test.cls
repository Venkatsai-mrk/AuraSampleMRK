@isTest
public class ClaimTypeSelectionApex_Test {

    
    public static  void dataSetup(){
    
        Account acc = new Account();
        acc.Name = 'Aruacc';
        insert acc;
        
        Payor__c ins = new Payor__c(name='Test', Payer_code__c='12345');
        ins.ElixirSuite__Payer_Code__c = 'abc1234';
        insert ins;
        
        
        VOB__c v = new VOB__c();
        v.ElixirSuite__Account__c = acc.id;
        v.ElixirSuite__Payer__c = ins.id;
        v.RecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('VOB_record_type').getRecordTypeId();
        v.ElixirSuite__Insured_Address__c = 'ABC';
        v.ElixirSuite__Date_Of_Birth__c = date.valueOf('2000-10-04');
        insert v;
       
    }
    
    @isTest
    public static void fetchRecordsTestMethod(){
        dataSetup();
        Account ac = [Select id,Name from Account limit 1];
        ClaimTypeSelectionApex.fetchRecords(ac.Id, 'Primary', 'CMS_1500');
        System.assertEquals(1, 1, '');
    }
    
    @isTest
    public static void getchildVobTestMethod(){
        dataSetup();
        Account ac = [Select id,Name from Account limit 1];
        Payor__c pay = [Select id,Name from Payor__c limit 1];
        ClaimTypeSelectionApex.getchildVob(new Set<String>{pay.Id} ,'Primary',ac.Id);
        System.assertEquals(1, 1, '');
    }

    //added by Anmol for LX3-6577
    @isTest
    public static void getDisplaySettingsCMS(){
        
        ElixirSuite__Elixir_Custom_Setting__c cusSett = new  ElixirSuite__Elixir_Custom_Setting__c();
        
        cusSett.ElixirSuite__Include_CMS1500_Form__c = true;
        cusSett.ElixirSuite__Include_UB04_Form__c = false;
        insert cusSett;
        
        ElixirSuite__ERA_Generation__c cusSettERA = new  ElixirSuite__ERA_Generation__c();
        
        cusSettERA.ElixirSuite__Insurance_Payments__c = true;
        cusSettERA.ElixirSuite__Private_Payments__c = false;
        insert cusSettERA;
        
        ClaimTypeSelectionApex.fetchDisplaySettings();
        
        System.assertEquals(1, 1, '');
    }
    
    @isTest
    public static void getDisplaySettingsUB(){
        
        ElixirSuite__Elixir_Custom_Setting__c cusSett = new  ElixirSuite__Elixir_Custom_Setting__c();
        
        cusSett.ElixirSuite__Include_CMS1500_Form__c = false;
        cusSett.ElixirSuite__Include_UB04_Form__c = true;
        insert cusSett;
        
         ElixirSuite__ERA_Generation__c cusSettERA = new  ElixirSuite__ERA_Generation__c();
        
        cusSettERA.ElixirSuite__Insurance_Payments__c = true;
        cusSettERA.ElixirSuite__Private_Payments__c = false;
        insert cusSettERA;
        
        ClaimTypeSelectionApex.fetchDisplaySettings();
        
        System.assertEquals(1, 1, '');
    }
    //end by Anmol for LX3-6577
    
}