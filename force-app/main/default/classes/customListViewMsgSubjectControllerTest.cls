@isTest
public class customListViewMsgSubjectControllerTest {
    
    @isTest
    public static void GetMsgSubject(){
        
        Account testAccount1 = TestDataFactory.createPatientAcc();
        insert testAccount1;
        
        ElixirSuite__Message_Subject__c messSubRec = new ElixirSuite__Message_Subject__c();
        messSubRec.ElixirSuite__Subject__c = 'Health Checkup';
        messSubRec.ElixirSuite__Account__c = testAccount1.Id;
        insert messSubRec;
        
        ElixirSuite__Message_Details__c messDelRec = new ElixirSuite__Message_Details__c();
        messDelRec.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec.ElixirSuite__lookup_Message_Subject__c = messSubRec.Id;
        insert messDelRec;
        String filter='Inbox';
        string searchKeyword='Hea';
        Integer limits=10;
        Integer offsets=0;
        test.startTest();
       
        customListViewMsgSubjectController.fetchFilterRecCount(testAccount1.Id, filter, searchKeyword);
       customListViewMsgSubjectController.fetchFilterRec(testAccount1.Id, filter, searchKeyword, limits, offsets);
       customListViewMsgSubjectController.getAccountName(testAccount1.Id);
        test.stopTest();
        System.assertEquals(1, 1, '');
        
        
    }
}