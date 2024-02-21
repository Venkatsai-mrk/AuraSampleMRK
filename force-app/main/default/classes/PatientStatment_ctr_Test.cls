@isTest
public class PatientStatment_ctr_Test 
{
    public static testMethod void testPatient()
    {
        Account pat = new Account();
        pat.Name = 'test';
        pat.Phone = '1234567890';
        pat.BillingStreet = 'test';
        pat.BillingCity = 'test';
        pat.BillingCountry = 'test';
        pat.BillingState = 'test';
        pat.BillingPostalCode = '1234' ;
        pat.Gender__c = 'Female';
        pat.AccountNumber = '123456';
        insert pat;
        
        Patient_Statement__c patSta = new Patient_Statement__c();
        patSta.Patient_Code__c = '1234';
        patSta.Statement_Date__c = System.today();
        patSta.PaymentsAdjustments_Received__c = 1000;
        patSta.Account_Number__c = '1234';
        insert patSta;
        
        Payment_Transaction__c payTran = new Payment_Transaction__c();
        payTran.Actual_Price__c = 500;
        payTran.Cpt_Codes__c = 'CPT100';
        payTran.Insurance_Payments__c = 200;
        
        payTran.Account__c = pat.Id;
        payTran.Patient_Payments__c = 300;
        payTran.Payment_Adjustments__c = 400;
        insert payTran;
        
        Patient_Statement__c patStaTwo = new Patient_Statement__c();
        patStaTwo.Patient_Code__c = '1234';
        patStaTwo.Statement_Date__c = System.today();
        patStaTwo.PaymentsAdjustments_Received__c = 1000;
        patStaTwo.Account_Number__c = '1234';
        patStaTwo.Account__c = pat.Id;
        if(patStaTwo.PaymntTransIds__c != Null)
        {
            patStaTwo.PaymntTransIds__c = patStaTwo.PaymntTransIds__c + ',' +payTran.Id;
        }
        else
        {
            patStaTwo.PaymntTransIds__c = payTran.Id;
        }
        patStaTwo.NewCharges__c = 100;
        patStaTwo.PaymentsAndAdjustmnts__c = 100;
        patStaTwo.NewBalance__c = 100;
        patStaTwo.PreviousBalance__c = 50;
        insert patStaTwo;

        List<Transactions__c> trLst = new List<Transactions__c>();
        
        test.startTest();

        PatientStatment_ctr.PrivateProcedure pv = new PatientStatment_ctr.PrivateProcedure();
        pv.amountToPay = 10;
        pv.charges = 7;
        pv.discount = 2;
        pv.dos = System.now();
        pv.patientPayments = 5;
        pv.procedureName = '99202';
        pv.providerName = 'Aetna';
        pv.transactions = trLst;
        
        PatientStatment_ctr.InsuranceProcedure ip = new PatientStatment_ctr.InsuranceProcedure();
        ip.procedureName = '99202';
        ip.dos = System.now();
        ip.providerName = 'Aetna';
        ip.amountToPay = 10;
        ip.charges = 7;
        ip.patientPayments = 5;
        ip.insurancePayments = 2;
        ip.transactions = trLst;
        
        ApexPages.StandardController stc = new ApexPages.StandardController(patStaTwo);
        ApexPages.currentPage().getParameters().put('Id',patStaTwo.id);
        PatientStatment_ctr custCont  = new PatientStatment_ctr(stc);
        
        test.stopTest();
        System.assert(pat.Name !=null); 
    }
}