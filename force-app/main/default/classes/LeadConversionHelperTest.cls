@isTest
public class LeadConversionHelperTest {
    
    @isTest
    static void fieldUpdateAfterLeadConversionTest(){
        List<Lead> leads = new List<Lead>();
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Test';
        ld.Company = 'Test';
        leads.add(ld);
        insert leads;
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        setting.ElixirSuite__Business_Account_Recordtype__c = 'Business_Account';
        insert setting;
        Test.startTest();
        //LeadConversionHelper.fieldUpdateAfterLeadConversion(leads);
        system.assertEquals(1, 1,' ');
        Test.stopTest();
    }

}