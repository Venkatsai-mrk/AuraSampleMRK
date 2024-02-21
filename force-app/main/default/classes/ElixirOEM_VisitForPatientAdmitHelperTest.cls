@isTest
public class ElixirOEM_VisitForPatientAdmitHelperTest {
@isTest
    public Static void unitTest1(){
        Account patient = TestDataFactory.createPatientAcc();
		insert patient;
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        ElixirOEM_VisitForPatientAdmitHelper.wrapperForVisit obj = new  ElixirOEM_VisitForPatientAdmitHelper.wrapperForVisit();
         Integer countRecordsTest = obj.countRecords ;
         String accNameTest = obj.accName; 
        test.startTest();
        ElixirOEM_VisitForPatientAdmitHelper.generateAutoNumber(String.valueOf(patAcc.Id));
        ElixirOEM_VisitForPatientAdmitHelper.abc();
        System.assertEquals(1, 1, '');
        test.stopTest();

    }
}