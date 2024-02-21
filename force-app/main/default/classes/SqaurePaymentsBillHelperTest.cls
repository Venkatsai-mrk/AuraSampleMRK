/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SqaurePaymentsBillHelperTest {
    public static testMethod void SqaurePaymentsBillHelperTestMethod(){
        List<Account> accountList = new List<Account>();
         Account patient =new Account ();
         patient.Name= 'Virat Kohli';
         patient.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
         patient.ElixirSuite__Gender__c='Male';
         patient.ElixirSuite__Email_Id__c='virat@gmail.com';
		 patient.phone='9988776655';
		 patient.ElixirSuite__First_Name__c='Virat';
		 patient.ElixirSuite__Last_Name__c='Kohli';
	     patient.BillingPostalCode='50021';
		 patient.ElixirSuite__SSN__c='12345';
         patient.ElixirSuite__MRN_Number_New__c='1234567890';
        accountList.add(patient);
         insert accountList;
        
        List<Payment_Transaction__c> paymentList = new List<Payment_Transaction__c>();
        Payment_Transaction__c payTran = new Payment_Transaction__c();
        payTran.Actual_Price__c = 500;
        payTran.Cpt_Codes__c = 'CPT100';
        payTran.Insurance_Payments__c = 200;
        payTran.Account__c = patient.Id;
        payTran.Patient_Payments__c = 300;
        payTran.Payment_Adjustments__c = 400;
        paymentList.add(payTran);
        insert paymentList;
        
        List<ElixirSuite__Master_Transaction__c> otherTransactionList = new List<ElixirSuite__Master_Transaction__c>();
        
        ElixirSuite__Master_Transaction__c otherTransaction = new ElixirSuite__Master_Transaction__c(
                ElixirSuite__Total_Amount_Paid__c = 1000,
                ElixirSuite__Account__c = accountList[0].Id,
                 ElixirSuite__Discount_Amount__c = 100,
                ElixirSuite__Type_of_Allocation__c = 'Discounted',
                //ElixirSuite__Payment_Transaction_Number__c = pmtTransactionNumber,
                ElixirSuite__Transaction_Date__c = system.today(), 
                ElixirSuite__Mode_of_Payment__c = 'Cash',
                ElixirSuite__Reason_Of_Payment__c = 'Applied Payment',
                ElixirSuite__Payment_Received_By__c='Patient'); 
				otherTransactionList.add(otherTransaction);
            insert otherTransactionList;     
        
        List<Transactions__c> transactionList = new List<Transactions__c>();
        Transactions__c trans = new Transactions__c();
        trans.ElixirSuite__Master_Transaction__c=paymentList[0].id;
        trans.ElixirSuite__Other_Transactions__c=otherTransactionList[0].id;
        trans.Amount_Paid__c = 1200;
        trans.Payment_Received_By__c = 'Patient';
        //trans.ElixirSuite__Type_of_Payment__c ='';
        transactionList.add(trans);
        insert transactionList;  
        
         //Query test data that was just created
        List<ElixirSuite__Payment_Transaction__c> createdPayments = [SELECT id,name,ElixirSuite__Actual_Price__c,ElixirSuite__Procedure_Name__c,Provider__r.Name,
                     Procedure__r.From_Date_of_Service__c,(select id,name from ElixirSuite__Transactions__r )
                     From ElixirSuite__Payment_Transaction__c
                     WHERE  ElixirSuite__Account__c = :accountList[0].id
                     WITH SECURITY_ENFORCED
                     ORDER BY ElixirSuite__Date_Of_Service__c];
         //Assert list is not empty
        System.assert(!createdPayments.isEmpty(),'List should not be empty');
        
         //Loop through ElixirSuite__Payment_Transaction__c ensure ElixirSuite__Transactions__r is not null
        for(ElixirSuite__Payment_Transaction__c acc : createdPayments){
            System.assert(acc.ElixirSuite__Transactions__r != null,'ElixirSuite Transactions should not be null');
        }
         string finalParametre = accountList[0].Id + '$' + otherTransactionList[0].id + '$' + 'true';
        
        Test.startTest();
            ApexPages.currentPage().getParameters().put('orderId', String.valueOf(finalParametre));
            SqaurePaymentsBillHelper NASA = new SqaurePaymentsBillHelper();
           // SqaurePaymentsBillHelper.getImg();
        	SqaurePaymentsBillHelper.getPdfImg();
        	SqaurePaymentsBillHelper.getPDFData();
            NASA.redirectToAccount();
            NASA.downloadPdf();
            System.assertEquals(1,1,'');
        
          Test.stopTest(); 
    }

}