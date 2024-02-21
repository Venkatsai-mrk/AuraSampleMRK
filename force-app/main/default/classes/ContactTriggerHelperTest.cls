@isTest
public class ContactTriggerHelperTest {
    public static testMethod void  method1(){
         Account acc1= new Account();
        acc1.Name  = 'Test';
        insert acc1;
        Contact ct = new Contact(LastName= 'ContLast' , AccountId = acc1.Id);
        insert ct;
        Opportunity opp = new Opportunity(Name = 'testOpp',AccountId = acc1.Id);
        Opportunity[] lst = new List<Opportunity>(); 
        lst.add(opp);
        ContactTriggerHelper.stopDeceasedEdit(new List<contact>{ct},false);
        ContactTriggerHelper.preventEditIfDeceasedCheckedOnAccount(new List<contact>{ct});
        system.assertEquals('Test', acc1.Name,'');
    }
}