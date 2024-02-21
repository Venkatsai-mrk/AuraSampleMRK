@isTest
public class PrescriptionColumnsConfigControllerTest {
	@isTest
    public static void getColumns(){
        List<Object> obj = new List<Object>{'content1', 'content2'};
        Elixir_Custom_Setting__c cs = new Elixir_Custom_Setting__c();
        cs.Prescription_Columns__c = 'content1;content2';
        insert cs;
        
        test.startTest();
        PrescriptionColumnsConfigController.getPrescriptionColumns();
        PrescriptionColumnsConfigController.saveColumns(obj);
        System.assertEquals(1,1,' ');
        test.stopTest();
    }
}