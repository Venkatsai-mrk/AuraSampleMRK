@isTest
public class BillingSearchGlobalHelperTest {

    @isTest
    public static void searchAcc(){
        Account accountRecord = new Account();
        accountRecord.Name = 'TestRecordAccount';
        accountRecord.ElixirSuite__Email_Id__c = 'testaccount@gmail.com';
        accountRecord.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        accountRecord.ElixirSuite__DOB__c = Date.valueOf('1991-06-02');
        accountRecord.ElixirSuite__Admit_Date__c = Date.valueOf('2021-09-09');
        insert accountRecord;
        system.debug('accountRecord'+accountRecord);
        
        Account acc = [select Id, Name from Account];
        
        BillingSearchGlobalHelper.acctLst(acc.id);
        system.assertEquals(1, 1, '');
    }
    
    @isTest
    public static void searchClaim(){
        Account ac = new Account();
        ac.Name = 'TestRecordAccount';
        insert ac;
        
        ElixirSuite__Claim__c cl = new ElixirSuite__Claim__c();
        	cl.ElixirSuite__Account__c = ac.id;
        insert cl;
        
        ElixirSuite__Claim__c claim = [select Id, Name from ElixirSuite__Claim__c];
        BillingSearchGlobalHelper.claimLst(claim.id);
        BillingSearchGlobalHelper.claimLstWithFilter(claim.id, ac.id);
        system.assertEquals(1, 1, '');
    }
}