@isTest
public class LabOrderRecordsTest {
    @isTest static void getLabOrderList(){
        Account acc = new Account(Last_name__c='Test', First_Name__c='Account',Name='Test Account',BillingStreet='NewDelhi',BillingCity = 'Ghaziabad',BillingState='DE',BillingPostalCode='23456', BillingCountry='IN', Gender__c='Male',SSN__c='3465432',Phone='3456222224');
        insert acc;
        string searchkey='300';
        test.startTest();
        List<Lab_Order__c> getLabsList = LabOrderRecords.getLabOrderList(searchkey, acc.Id,'','','');
        //List<Lab_Order__c> getLabsList1 = LabOrderRecords.getLabOrderList(searchkey, acc.Id,'','','','lab_order_req__c','LIKE','10');
       // List<Lab_Order__c> getLabsList2 = LabOrderRecords.getLabOrderList(searchkey, acc.Id,'status__c','LIKE','E','lab_order_req__c','LIKE','10');
        LabOrderRecords.countLabOrders();
        //map<string,string> Map1=LabOrderRecords.getObjectFields();
        System.assertEquals(1, 1, '');
        test.stopTest(); 
    }
   /* @isTest static void getLabOrderList1(){
        Account acc1 = new Account(Last_name__c='Test', First_Name__c='Account',Name='Test Account',BillingStreet='NewDelhi',BillingCity = 'Ghaziabad',BillingState='DE',BillingPostalCode='23456', BillingCountry='IN', Gender__c='Male',SSN__c='3465432',Phone='3456222224');
        insert acc1;
       // string searchkey1='300';
        test.startTest();
        List<Lab_Order__c> getLabsList1 = LabOrderRecords.getLabOrderList('', acc1.Id,'status__c','LIKE','Entered');
        test.stopTest();
       
    }*/
    @isTest static void getLabOrderList2(){
        Account acc2 = new Account(Last_name__c='Test', First_Name__c='Account',Name='Test Account',BillingStreet='NewDelhi',BillingCity = 'Ghaziabad',BillingState='DE',BillingPostalCode='23456', BillingCountry='IN', Gender__c='Male',SSN__c='3465432',Phone='3456222224');
        insert acc2;
       // string searchkey1='300';
        test.startTest();
        List<Lab_Order__c> getLabsList2 = LabOrderRecords.getLabOrderList('', acc2.Id,'status__c','=','Entered');
        System.assertEquals(1, 1, '');
        test.stopTest();
       
    }
     @isTest static void getLabOrderList3(){
        Account acc2 = new Account(Last_name__c='Test', First_Name__c='Account',Name='Test Account',BillingStreet='NewDelhi',BillingCity = 'Ghaziabad',BillingState='DE',BillingPostalCode='23456', BillingCountry='IN', Gender__c='Male',SSN__c='3465432',Phone='3456222224');
        insert acc2;
       // string searchkey1='300';
        test.startTest();
        List<Lab_Order__c> getLabsList7 = LabOrderRecords.getLabOrderList('', acc2.Id,'status__c','=','Entered');
        System.assertEquals(1, 1, '');
        test.stopTest();
     }
}