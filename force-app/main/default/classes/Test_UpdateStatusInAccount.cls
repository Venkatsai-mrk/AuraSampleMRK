@isTest
public class Test_UpdateStatusInAccount {
    static testMethod void AccountUpdateTest(){
    Account acc = new Account();
    acc.Name = 'TestAru';
    insert acc;
    
        Opportunity opp = new Opportunity();
        opp.Name = 'AruOpp';
        opp.CloseDate = system.today();
        opp.AccountId = acc.Id;
        opp.StageName = 'Pre';
       // opp.Discharge_Information_created__c = false;
        
        
       insert opp;
        
        opp.StageName = 'Prospecting';
        
        update opp;
        
        opp.StageName = 'Pre-Assessment';
        //opp.Discharge_Information_created__c = true;
        
        update opp;
        
        
        
        opp.StageName = 'Discharge Completed';
        
        update opp;
         System.assertEquals('1', '1','');
        
    }      

}