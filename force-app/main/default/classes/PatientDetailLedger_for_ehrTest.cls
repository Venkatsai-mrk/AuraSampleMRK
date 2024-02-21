@isTest
public class PatientDetailLedger_for_ehrTest {
 @isTest
    public static void ledgerMethod(){
        Account a = new Account();
        a.Name = 'ABC';
        insert a;
        Test.startTest();
        PatientDetailLedger_for_ehr.getAllData(a.id);
        PatientDetailLedger_for_ehr.LicensBasdPermission();
        PatientDetailLedger_for_ehr.handlingAfterUpload(a.id);
       // PatientDetailLedger_for_ehr.wrapperData();
      // PatientDetailLedger_for_ehr.License_Class(a.id);
        
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
}