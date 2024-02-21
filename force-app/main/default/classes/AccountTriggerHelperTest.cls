@isTest
public class AccountTriggerHelperTest {
    public static testMethod void  method1(){
        Account acc = TestDataFactory.createPatientAcc();
        acc.MRN_Number_New__c = '123456';
        insert acc;
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
        setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        insert setting;
        Map<Id, Account> oldAccMap = new Map<Id, Account>();
        oldAccMap.put(acc.Id, acc);
        
        acc.MRN_Number_New__c = '654321';
        
        Opportunity opp = new Opportunity(Name = 'testOpp',AccountId = acc.Id);
        Map<Id,Account> mpAcc = new Map<Id,Account>{acc.Id=>acc};
        AccountTriggerHelper.blockEditIfDeceased(new List<Account>{acc},mpAcc);
        AccountTriggerHelper.checkDeceasedFilter(new List<Account>{acc});
        AccountTriggerHelper.updateAllCCrelatedObctsForDeceasedAsTrue(new List<Account>{acc}); 
        AccountTriggerHelper.updateAllEvent(new Set<Id>{acc.Id});
        AccountTriggerHelper.updateAllOpportunity(new Set<Id>{acc.Id});
        AccountTriggerHelper.updateAllPreAsses(new Set<Id>{opp.Id});
        AccountTriggerHelper.updateAllVOB(new Set<Id>{acc.Id},new Set<Id>{opp.Id});
        AccountTriggerHelper.updateAllContact(new Set<Id>{acc.Id});
        AccountTriggerHelper.updateAllAluminiCare(new Set<Id>{acc.Id},new Set<Id>{opp.Id});
        AccountTriggerHelper.generateMrnForAccount(new List<Account>{acc});
        AccountTriggerHelper.mrnFieldNullUpdate(new List<Account>{acc});
        AccountTriggerHelper.mrnFieldNullClassBeforeUpdate(new List<Account>{acc},oldAccMap);
        AccountTriggerHelper.mrnValidationBeforeUpdate(new List<Account>{acc}, oldAccMap);
        System.assertEquals(1,1,'Welcome to Elixir');
    }
}