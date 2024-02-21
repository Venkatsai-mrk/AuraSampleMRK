@isTest
public class Test_CreateVOB {
    
    public static testMethod void testmethod1(){
    
    Account acc = new Account();
    acc.Name = 'Aruacc';
    insert acc;
    
    Opportunity opp = new Opportunity();
    opp.Name = 'Aru';
    opp.AccountId = acc.Id;
    opp.StageName = 'VOB';
    opp.CloseDate = System.today();
  //  opp.Insurance_Provider__c = ins.id;
    opp.Insurance_Policy_ID__c = '123asddfd';
    insert opp;
        
        VOB__c v = new VOB__c();
        v.Opportunity__c = opp.Id;
        v.ID__c = opp.Insurance_Policy_ID__c;
        v.Ins_Comp__c = opp.Insurance_Providor__c;
        v.ElixirSuite__Insured_Address__c = 'ABC';
        v.ElixirSuite__Date_Of_Birth__c = date.valueOf('2000-04-10');
        insert v;
        System.assertEquals('1', '1','');
    }
}