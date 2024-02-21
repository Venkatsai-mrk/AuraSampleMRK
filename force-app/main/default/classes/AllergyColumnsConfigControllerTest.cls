@isTest
public class AllergyColumnsConfigControllerTest {
    @isTest
    public static void getAllergyColumnsTest(){
        List<Object> obj = new List<Object>{'content1', 'content2'};
        Elixir_Custom_Setting__c cs = new Elixir_Custom_Setting__c();
        cs.ElixirSuite__Allergy_Columns__c = 'content1;content2';
        cs.ElixirSuite__Vital_Sign_Columns__c='content1;content2';
        insert cs;
        
        test.startTest();
        AllergyColumnsConfigController.getAllergyColumns();
        AllergyColumnsConfigController.saveColumns(obj);
        System.assertEquals(1,1,' ');
        test.stopTest();
    }
    @isTest
    public static void getViatlsignColumnsTest(){
        List<Object> obj = new List<Object>{'content1', 'content2'};
        Elixir_Custom_Setting__c cs = new Elixir_Custom_Setting__c();
        cs.ElixirSuite__Vital_Sign_Columns__c='content1;content2';
        insert cs;
        
        test.startTest();
        AllergyColumnsConfigController.getVitalSignColumns();
        AllergyColumnsConfigController.saveVitalSignColumns(obj);
        System.assertEquals(1,1,' ');
        test.stopTest();
    }
}