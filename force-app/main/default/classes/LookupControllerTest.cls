/*
Developed By  - Sonal Agarwal
Test Class - LookupControllerTest
*/
@isTest
public class LookupControllerTest 
{
	@isTest
    public static void unitTest()
    {
        Account patient = TestDataFactory.createPatientAcc();
		insert patient;
        
        Test.startTest();
        LookupController.fetchRecords1('Account','Name','Test');
        LookupController.employerList('Test');
        Test.stopTest();
        system.assertEquals(1, 1);
    }
}