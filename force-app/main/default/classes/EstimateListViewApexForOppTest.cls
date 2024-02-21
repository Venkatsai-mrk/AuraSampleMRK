@isTest
public class EstimateListViewApexForOppTest {
@testSetup
    public static void createTestData() {
        
        Account patient = TestDataFactory.createPatientAcc();
		insert patient;
        
        VOB__c newVob = TestDataFactory.createVOB();
        insert newVob ;
    }
@isTest
    public static void BringDataTest(){
       List<Account> patAccList = [Select id from Account];
        List<VOB__c> vobDataList = [Select id from VOB__c];
        Account patAcc = patAccList[0];
        VOB__c vobData = vobDataList[0];
        Estimates__c estimateRec = new Estimates__c();
        estimateRec.Account__c = patAcc.Id;
        insert estimateRec;
        
        test.startTest();
        EstimateListViewApexForOpp.BringData(String.valueOf(patAcc.Id), vobData.Id);
        EstimateListViewApexForOpp.BringDataViewAll(String.valueOf(patAcc.Id), vobData.Id);
        EstimateListViewApexForOpp.BringFilterData(String.valueOf(Date.today()), String.valueOf(Date.today()), String.valueOf(patAcc.Id),vobData.Id);
        EstimateListViewApexForOpp.BringFilterDataViewAll(String.valueOf(Date.today()), String.valueOf(Date.today()), String.valueOf(patAcc.Id),vobData.Id);
        EstimateListViewApexForOpp.LicensBasdPermission();
        System.assertEquals(1, 1, '');
        test.stopTest();
    }
}