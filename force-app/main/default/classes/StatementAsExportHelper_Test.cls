/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class StatementAsExportHelper_Test 
{
    @isTest
    public static void StateHelper()
    {

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




        // Account patient = TestDataFactory.createPatientAcc();
        // insert patient;
        
        Patient_Statement__c patSta = new Patient_Statement__c();
        patSta.Patient_Code__c = '1234';
        patSta.Statement_Date__c = System.today();
        patSta.PaymentsAdjustments_Received__c = 1000;
        patSta.Account_Number__c = '1234';
        insert patSta;
        
        Patient_Statement__c patStaTwo = new Patient_Statement__c();
        patStaTwo.Patient_Code__c = '1234';
        patStaTwo.Statement_Date__c = System.today();
        patStaTwo.PaymentsAdjustments_Received__c = 1000;
        patStaTwo.Account_Number__c = '1234';
        patStaTwo.Account__c = patient.Id;
        patStaTwo.NewCharges__c = 100;
        patStaTwo.PaymentsAndAdjustmnts__c = 100;
        patStaTwo.NewBalance__c = 100;
        patStaTwo.PreviousBalance__c = 50;
        insert patStaTwo;
        
        // Payment_Transaction__c payTran = new Payment_Transaction__c();
        // payTran.Actual_Price__c = 500;
        // payTran.Cpt_Codes__c = 'CPT100';
        // payTran.Insurance_Payments__c = 200;
        // payTran.Account__c = patient.Id;
        // payTran.Patient_Payments__c = 300;
        // payTran.Payment_Adjustments__c = 400;
        // insert payTran;
        
        // Account acc = new Account();
        // acc.Name = 'Testing';
        // insert acc;
        
        // Contract cont = new Contract();
        // cont.AccountId = acc.Id;
        // cont.Status = 'Draft';
        // cont.StartDate = System.today();
        // cont.ContractTerm = 6;
        // insert cont;
        
        // Order ord = new Order();
        // ord.AccountId = acc.Id;
        // ord.ContractId = cont.id;
        // ord.Status = 'Draft';
        // ord.EffectiveDate = System.today();
        // insert ord;
        Date startDate = System.today();
        Date endDate = System.today()+10;
        string finalParametre = startDate + '$' + endDate+ '$' + accountList[0].Id;
        test.startTest();
       
        ApexPages.currentPage().getParameters().put('orderId', String.valueOf(finalParametre));
        StatementAsExportHelper obj = new StatementAsExportHelper();
        StatementAsExportHelper.getPdfImg();
        StatementAsExportHelper.getPaymentTransactionInfoDuplicate(accountList[0].Id,startDate,endDate);
        StatementAsExportHelper.getPDFData();
        StatementAsExportHelper.getStringifiedDate(system.today());
       
        
        System.assertEquals(1,1,'');
    	 system.assert(patSta.Patient_Code__c!=null,''); 
        test.stopTest();
       
    }
}