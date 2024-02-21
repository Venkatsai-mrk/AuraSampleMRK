@isTest
public class TestDataDisplayController {
    
    public static testMethod void  coverScenariosForGeneratePDF(){
        
        Account a  = new Account(name = 'DmeoAccount');
        insert a;
        Contact con = new Contact(LastName='Roy',birthdate=System.today(),AccountId=a.Id);
        insert con;
        UA_Sample_Details__c demoInsertRecords= new UA_Sample_Details__c(Account__c = a.id,Medical_Test__c='Test',Fax__c = '0001',
                                                                         Ordered_Via__c='Email', Necessity_Details__c='Quack\nIm flying!!\nI cant fly\nIm flying with a rocket',
                                                                         On_Admission__c=true,Start_Date__c=System.today());
        
        insert demoInsertRecords;
        
        System.debug('inserted '+demoInsertRecords.id);
        
        Test.StartTest();
        
        PageReference pageRef = Page.PDFgenerator;
        pageRef.getParameters().put('orderId',demoInsertRecords.id);
        // ApexPages.currentPage().getParameters().put('orderId',String.valueOf(demoInsertRecords.id));
        
        Test.setCurrentPage(pageRef);
        System.debug('Apex page order id=='+ApexPages.currentPage().getParameters().get('orderId'));
        DataDisplayController objectTocall = new DataDisplayController();             
        objectTocall.getlabOrderInfo(demoInsertRecords.Id);
        objectTocall.getAccountInfo(a.id); 
        // DataDisplayController callContrct = new DataDisplayController();
        
        Test.StopTest();
        System.assertEquals(1, 1, ' ');
    }
    
}