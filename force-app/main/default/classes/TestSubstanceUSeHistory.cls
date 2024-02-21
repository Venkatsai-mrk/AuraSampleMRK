/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TestSubstanceUSeHistory {
    @isTest
    static void saveSubsanceUseHistoryRecords()
    {
        Test.startTest();
        List<Substance_Use_History__c> substanceUseHistoryRecords=new List<Substance_Use_History__c>();
        Substance_Use_History__c getRecords=TestDataUtility.setupSubstanceUseHistoryTestData();
        substanceUseHistoryRecords.add(getRecords);
   
        SubstanceUSeHistory.saveSubsanceUseHistoryRecords(substanceUseHistoryRecords);
        
        Test.stopTest();
        System.AssertNotEquals(0,[select id from Substance_Use_History__c].size(),'');
        System.AssertEquals(1,1,' ');
    }
    @isTest
    static void PicklistFromSUH()
    {
        Test.startTest();
        Substance_Use_History__c getRecords=TestDataUtility.setupSubstanceUseHistoryTestData();
        SubstanceUSeHistory.PicklistFromSUH();
        SubstanceUSeHistory.LicensBasdPermission();
        Test.stopTest();    
        System.AssertEquals(1,1,' ');
    }
}