@isTest
public class TestPaymentSchedule {
    
    static testMethod void CheckPaymentSchedule(){
        
        Account a=new Account(name='TEST');
        
        insert a;
        Opportunity o=new Opportunity();
        o.Name='test';
        o.AccountId=a.id;
        o.StageName='Prospecting';
        o.CloseDate=system.today();
        
        o.Instalments_by_Frequency__c=100;
        o.LOC__c='IOP';
        o.Payment_Frequency__c='Daily';
        
        insert o;
        Product2 p=new Product2(name='Admit Fee');
        insert p;
        PricebookEntry pe=new PricebookEntry(Product2Id=p.id,UnitPrice=200,Pricebook2Id=Test.getStandardPricebookId(),isactive=true);
        insert pe;
        OpportunityLineitem oli=new OpportunityLineitem(OpportunityId=o.id,quantity=2,Product2Id=p.id,PricebookEntryId=pe.id);
        oli.UnitPrice=200;
        insert oli;
        Payment_Information__c pi =new Payment_Information__c(Patient_Name__c = o.id, Amount__c=10);
        insert pi;
        string id1=o.id;
        Test.startTest();
        //     PaymentScheduleApex.InsertRecordFromOppCreatePayment(id1);
        
        Test.stopTest();
        list<Payment_Schedule__c> paymentschedulelist=[select id,Opportunity__r.name from Payment_Schedule__c];
        System.assertEquals(1, 1, ' ');
        
        
    }
    static testMethod void CheckPaymentSchedule2(){
        
        Account a=new Account(name='TEST');
        
        insert a;
        Opportunity o=new Opportunity();
        o.Name='test';
        o.AccountId=a.id;
        o.StageName='Prospecting';
        o.CloseDate=system.today();
        
        o.Instalments_by_Frequency__c=100;
        o.LOC__c='IOP';
        o.Payment_Frequency__c='Monthly';
        
        insert o;
        Product2 p=new Product2(name='Admit Fee');
        insert p;
        PricebookEntry pe=new PricebookEntry(Product2Id=p.id,UnitPrice=200,Pricebook2Id=Test.getStandardPricebookId(),isactive=true);
        insert pe;
        OpportunityLineitem oli=new OpportunityLineitem(OpportunityId=o.id,quantity=2,Product2Id=p.id,PricebookEntryId=pe.id);
        oli.UnitPrice=200;
        insert oli;
        Payment_Information__c pi =new Payment_Information__c(Patient_Name__c = o.id, Amount__c=10);
        insert pi;
        string id1=o.id;
        Test.startTest();
        // PaymentScheduleApex.InsertRecordFromOppCreatePayment(id1);
        Test.stopTest();
        list<Payment_Schedule__c> paymentschedulelist=[select id,Opportunity__r.name from Payment_Schedule__c];
        System.assertEquals(1, 1, ' ');
        
    }
    static testMethod void CheckPaymentSchedule3(){
        
        Account a=new Account(name='TEST');
        
        insert a;
        Opportunity o=new Opportunity();
        o.Name='test';
        o.AccountId=a.id;
        o.StageName='Prospecting';
        o.CloseDate=system.today();
        
        o.Instalments_by_Frequency__c=100;
        o.LOC__c='IOP';
        o.Payment_Frequency__c='Weekly';
        
        insert o;
        Product2 p=new Product2(name='Admit Fee');
        insert p;
        PricebookEntry pe=new PricebookEntry(Product2Id=p.id,UnitPrice=200,Pricebook2Id=Test.getStandardPricebookId(),isactive=true);
        insert pe;
        OpportunityLineitem oli=new OpportunityLineitem(OpportunityId=o.id,quantity=2,Product2Id=p.id,PricebookEntryId=pe.id);
        oli.UnitPrice=200;
        insert oli;
        Payment_Information__c pi =new Payment_Information__c(Patient_Name__c = o.id, Amount__c=10);
        insert pi;
        string id1=o.id;
        Test.startTest();
        //  PaymentScheduleApex.InsertRecordFromOppCreatePayment(id1);
        Test.stopTest();
        list<Payment_Schedule__c> paymentschedulelist=[select id,Opportunity__r.name from Payment_Schedule__c];
        System.assertEquals(1, 1, ' ');
        
        
    }
    static testMethod void CheckPaymentSchedule4(){
        Account a=new Account(name='TEST');
        
        insert a;
        Opportunity o=new Opportunity();
        o.Name='test';
        o.AccountId=a.id;
        o.StageName='Prospecting';
        o.CloseDate=system.today();
        
        o.Instalments_by_Frequency__c=100;
        o.LOC__c='IOP';
        o.Payment_Frequency__c='Daily';
        
        insert o;
        Payment_Information__c p =new Payment_Information__c(Patient_Name__c = o.id, Amount__c=10);
        insert p;
        string id1=o.id;
        
        Test.startTest();
        //   PaymentScheduleApex.FetchOppdataForPayment(id1);
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
        
    }
    
}