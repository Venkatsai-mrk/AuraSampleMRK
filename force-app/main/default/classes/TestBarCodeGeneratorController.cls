@isTest
public class TestBarCodeGeneratorController {
    
    public static testMethod void  BarCodeGeneratorControllerTestMethod(){
        
        Account a  = new Account(name = 'DmeoAccount');
        insert a;
        UA_Sample_Details__c demoInsertRecords= new UA_Sample_Details__c(Account__c = a.id,Medical_Test__c='Test',Fax__c = '0001',
                                                                         Ordered_Via__c='Email', Necessity_Details__c='Quack\nIm flying!!\nI cant fly\nIm flying with a rocket',
                                                                         On_Admission__c=true,Start_Date__c=System.today());
        
        insert demoInsertRecords;
        System.debug('inserted '+demoInsertRecords.id);
        
        List<UA_Sample_Details__c> uaSampleList = new List<UA_Sample_Details__c>();
        uaSampleList.add(demoInsertRecords);
        
        Test.StartTest();
        
        PageReference pageRef = Page.PDFgenerator;
        ApexPages.currentPage().getParameters().put('orderId',demoInsertRecords.id);
        
        Test.setCurrentPage(pageRef);
        
        BarCodeGeneratorController objectTocall= new BarCodeGeneratorController();
        objectTocall.getsampleList(uaSampleList);
        
        
        Test.StopTest();
        system.assert(a.name!=null);
    }
}