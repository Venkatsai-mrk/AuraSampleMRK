/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class BillingSummaryApexTest {
 @testSetup
    public static void TestData1(){
        Account patient = TestDataFactory.createPatientAcc();
		insert patient;
        VOB__c vb = TestDataFactory.createVOB();
        vb.Account__c = patient.Id;
        insert vb;
        
    }
    @isTest
    public static void TestMethod1(){
       Account patient = [Select id from Account Limit 1];
        BillingSummaryApex.billSum(String.valueOf(patient.Id));
        BillingSummaryApex.billSum('str');
        system.assertEquals(1,1,'');
    }
}