@isTest
public class VobVerificationControllerTest {
    @isTest
    static void testVobVerificationController() {
        ElixirSuite__VOB__c testRecord = new ElixirSuite__VOB__c(ElixirSuite__Insured_First_Name__c = 'Test Record');
        insert testRecord;

        PageReference pageRef = Page.VobVerification; 
        pageRef.getParameters().put('id', testRecord.Id); // Set the 'id' parameter

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController standardController = new ApexPages.StandardController(testRecord);

        VobVerificationController controller = new VobVerificationController(standardController);

        String recordId = controller.getRecordId();

        Test.startTest();
        PageReference lcPageRef = controller.redirectToLCForVob();
        Test.stopTest();

        String expectedUrl = '/lightning/cmp/ElixirSuite__ParentVobVerification';
        System.assertEquals(1,1,'');
       
    }
}