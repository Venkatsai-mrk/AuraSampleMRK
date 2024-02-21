/*
Created By - Sonal Agarwal
Apex class - InsuranceController
CreatedDate - 16-12-2020
*/
@isTest
public class InsuranceControllerTest {
    
    @isTest
    public static void unitTest()
    {
		VOB__c testVob = TestDataFactory.createVOB();
        insert testVob;
        System.assertNotEquals(testVob.Id,null,'');
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', testVob.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(testVob);
        
        InsuranceController obj = new InsuranceController(sc);
        obj.closePopup();
        obj.showPopup();
        obj.accept();
        
        Test.stopTest();
    }

}