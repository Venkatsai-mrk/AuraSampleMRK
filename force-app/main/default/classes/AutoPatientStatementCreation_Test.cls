@isTest
public class AutoPatientStatementCreation_Test 
{
    public static testMethod void AutoPat()
    {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Account_Number__c = '1234';
        acc.First_Name__c = 'Test';
        insert acc;
        
        List<Account> lst_Acc = new List<Account>();
        lst_Acc.add(acc);
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'ElixirSuite__Payment_Transaction__c' and Name = 'Payment Transaction'].Id;
        
        String strRecordTypeId2 = [Select Id From RecordType Where SobjectType = 'ElixirSuite__Payment_Transaction__c' and Name = 'Sub Transaction'].Id;
        
        Payment_Transaction__c payTrans = new Payment_Transaction__c();
        payTrans.Account__c = acc.Id;
        payTrans.Actual_Price__c = 100;
        payTrans.Insurance_Payments__c = 200;
        payTrans.RecordTypeId = strRecordTypeId;
        insert payTrans;
        
        Payment_Transaction__c payTrans2 = new Payment_Transaction__c();
        payTrans2.Account__c = acc.Id;
        payTrans2.Actual_Price__c = 100;
        payTrans2.Insurance_Payments__c = 200;
        payTrans2.RecordTypeId = strRecordTypeId2;
        insert payTrans2;
        
        test.startTest();
        AutoPatientStatementCreation autoPat = new AutoPatientStatementCreation();
        autoPat.execute(null,lst_Acc);
        DataBase.executeBatch(autoPat,200);
        test.stopTest();
        System.assert( payTrans.Actual_Price__c !=null,'');
    }
}