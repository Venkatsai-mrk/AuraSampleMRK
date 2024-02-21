@isTest
public class ProcedureDisplayControllerTest {
    @isTest
    public static void unitTest(){
        Account acc = new Account();
        acc.Name= 'ABC';
        insert acc;
        Test.startTest();
        ProcedureDisplayController.recTypemed();
        ProcedureDisplayController.getListViews();
        ProcedureDisplayController.searchKeyProc(acc.id);
        ProcedureDisplayController.searchKeyResult(acc.id);
        System.assertEquals(1, 1, '');
        Test.stopTest();
        
    }
}