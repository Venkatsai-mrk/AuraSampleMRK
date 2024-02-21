@isTest
public class TestPrintReceiptPdfHelper {
    
    @isTest
    public static void ConfigurationTESTmethod(){  
        
        Account acc= new Account();
        acc.Name='TestAccount';
        acc.ElixirSuite__Email_Id__c= 'test@mirketa.com';
        insert acc;
        
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test';
        oppty.AccountId=acc.id;
        oppty.ElixirSuite__Email__c='test@gmail.com';
        oppty.StageName = 'Prospecting';
        oppty.CloseDate = system.today().adddays(1);
        oppty.Admission_Date__c = system.today().adddays(1);
        
        //  oppty.Level_Of_Care__c = prog.id;
        insert oppty;
        
        ElixirSuite__Master_Transaction__c mt= new ElixirSuite__Master_Transaction__c();
        mt.account__c= acc.Id;
        mt.ElixirSuite__Transaction_Date__c= system.today();
        mt.ElixirSuite__Payment_Due__c= system.today() + 5;
        mt.Total_Amount_Paid__c = 200;
        insert mt;
        
        test.startTest();
        Payment_Transaction__c pt= new Payment_Transaction__c();
        pt.ElixirSuite__Master_Transaction__c=mt.Id;
        pt.ElixirSuite__Account__c = acc.Id;
        pt.ElixirSuite__Actual_Price__c= 12;
        insert pt;
        // test.stopTest();
        
        ElixirSuite__Transactions__c t= new ElixirSuite__Transactions__c();
        t.ElixirSuite__Master_Transaction__c=pt.Id;
        t.ElixirSuite__Other_Transactions__c= mt.Id;
        t.ElixirSuite__Amount_Paid__c = 100;
        insert t;
        
       
        // test.startTest();
        
        PageReference pageRef = Page.PrintReceiptPdf;
        pageRef.getParameters().put('tranId',mt.Id);
        Test.setCurrentPage(pageRef);
       
        PrintReceiptPdfHelper pa = new PrintReceiptPdfHelper();
        
        PrintReceiptPdfHelper.getAccData(acc.Id, new List<String>{mt.Id});
        PrintReceiptPdfHelper.getPaymentData(mt.Id,mt);
        
        system.assert( acc.Name!=NULL,'');
        test.stopTest();
    }
    
}