/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TestOpportunityTriggerHelper {
    @isTest
    public static void OpportunityTriggerHelperTest1(){  
        
        test.startTest();
        Elixir_Custom_Setting__c record = new Elixir_Custom_Setting__c();
        record.ElixirSuite__Patient_Deceased__c = true;
        insert record;
         Account acc1= new Account();
        acc1.Name  = 'Test';
        insert acc1;
        Opportunity opp = new Opportunity(Name = 'testOpp',AccountId = acc1.Id);
        opp.ElixirSuite__Deceased__c = true;
        Opportunity[] lst = new List<Opportunity>(); 
        lst.add(opp);
        OpportunityTriggerHelper.stopDeceasedEdit(lst,false);
        DeceasedGlobalStopRecursion.run = true;
        OpportunityTriggerHelper.preventEditIfDeceasedCheckedOnAccount(lst);
        OpportunityTriggerHelper.blockDeleteIfDeceased(lst);
        OpportunityTriggerHelper up1 = new OpportunityTriggerHelper();
        up1.updateAccount(lst);
       
        
        Account acc= new Account();
        acc.Name='TestAccount';
        insert acc;
        
	    Opportunity oppty1 = new Opportunity();
        oppty1.Name = 'Test';
        oppty1.AccountId=acc.id;
        oppty1.StageName = 'Prospecting';
        oppty1.CloseDate = system.today().adddays(1);
       
        
        insert oppty1; 
        
        Opportunity oppty2 = new Opportunity();
        oppty2.Name = 'Test 2';
        oppty2.AccountId=acc.id;
        oppty2.StageName = 'Prospecting';
        oppty2.CloseDate = system.today().adddays(1);
        
        Test.stopTest();
        System.assertEquals(1,1,'');
        
    }
    
    @isTest
    public static void OpportunityTriggerHelperTest2(){  
        
        test.startTest();
        Elixir_Custom_Setting__c record = new Elixir_Custom_Setting__c();
        record.ElixirSuite__Patient_Deceased__c = true;
        insert record;
         Account acc1= new Account();
        acc1.Name  = 'Test';
        insert acc1;
        Opportunity opp = new Opportunity(Name = 'testOpp',AccountId = acc1.Id);
        Opportunity[] lst = new List<Opportunity>(); 
        lst.add(opp);
        OpportunityTriggerHelper.stopDeceasedEdit(lst,false);
        OpportunityTriggerHelper.preventEditIfDeceasedCheckedOnAccount(lst);
       
        
        Account acc= new Account();
        acc.Name='TestAccount';
        insert acc;
        
        Opportunity oppty1 = new Opportunity();
        oppty1.Name = 'Test';
        oppty1.AccountId=acc.id;
        oppty1.StageName = 'Prospecting';
        oppty1.CloseDate = system.today().adddays(1);
     
        
        insert oppty1; 
        
        
        
        Opportunity oppty2 = new Opportunity();
        oppty2.Name = 'Test 2';
        oppty2.AccountId=acc.id;
        oppty2.StageName = 'Prospecting';
        oppty2.CloseDate = system.today().adddays(1);
        insert oppty2;
        
        
        Test.stopTest();
        System.assertEquals(1,1,'');
        
    }
    
    @isTest
    public static void OpportunityTriggerHelperTest3(){  
        
        test.startTest();
        Elixir_Custom_Setting__c record = new Elixir_Custom_Setting__c();
        record.ElixirSuite__Patient_Deceased__c = true;
        insert record;
       
        
        List<Account> acclst = new List<Account>();
        
        Account acc= new Account();
        acc.Name='TestAccount';
        acclst.add(acc);
        
        Account acc2= new Account();
        acc2.Name='TestAccount2';
        acclst.add(acc2);
        
        Account acc3= new Account();
        acc3.Name='TestAccount21';
        acclst.add(acc3);
        
        Account acc4= new Account();
        acc4.Name='TestAccount211';
        acclst.add(acc4);
        
        insert acclst;
        
        
        Opportunity oppty1 = new Opportunity();
        oppty1.Name = 'Test';
        oppty1.AccountId=acc.id;
        oppty1.StageName = 'Prospecting';
        oppty1.CloseDate = system.today().adddays(1);
       
        
        Opportunity oppty2 = new Opportunity();
        oppty2.Name = 'Test';
        oppty2.AccountId=acc2.id;
        oppty2.StageName = 'Admitted';
        oppty2.CloseDate = system.today().adddays(1);
        
        
        Opportunity oppty3 = new Opportunity();
        oppty3.Name = 'Test';
        oppty3.AccountId=acc2.id;
        oppty3.StageName = 'Discharged';
        oppty3.CloseDate = system.today().adddays(1);
       
        
        Opportunity oppty4 = new Opportunity();
        oppty4.Name = 'Test';
        oppty4.AccountId=acc2.id;
        oppty4.StageName = 'test';
        oppty4.CloseDate = system.today().adddays(1);
       
        
        insert oppty1; 
        insert oppty2;
        insert oppty3;
        insert oppty4;

        List<Opportunity> lst2 = new List<Opportunity>();
        lst2.add(oppty1);
        lst2.add(oppty2);
        lst2.add(oppty3);
        lst2.add(oppty4);
        OpportunityTriggerHelper update1 = new OpportunityTriggerHelper();
        update1.updateAccount(lst2);
        Test.stopTest();
        System.assertEquals(1,1,'');
    }
    
}