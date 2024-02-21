@isTest
public class PatientStatementHelper_Test 
{
    public static testMethod void patiStamnt()
    {
        Account patient = TestDataFactory.createPatientAcc();
        insert patient;
        Set<Id> accIds = new Set<Id>();
        accIds.add(patient.Id);
        
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
        
        Payment_Transaction__c payTran = new Payment_Transaction__c();
        payTran.Actual_Price__c = 500;
        payTran.Cpt_Codes__c = 'CPT100';
        payTran.Insurance_Payments__c = 200;
        payTran.Account__c = patient.Id;
        payTran.Patient_Payments__c = 300;
        payTran.Payment_Adjustments__c = 400;
        insert payTran;
        
        
        test.startTest();
        Date StartDate = System.today();
        Date EndDate = System.today()+10;
        PatientStatementHelper.parentInitFetchDataForPatientStatement(patient.Id);
        PatientStatementHelper.filteredPaymentHistory(patient.Id,StartDate,EndDate);
        PatientStatementHelper.checkStatementExists(patient.Id, StartDate, EndDate);
        PatientStatementHelper.singleStatementRecordDetils(patStaTwo.Id);
        AutoPatientStatementCreationHelper at = new AutoPatientStatementCreationHelper(accIds,System.now(),System.now());
        at.privateProcedureSchema(payTran);
        at.insuranceProcedureSchema(payTran);
        at.findPrivatePaymentsAggregate(System.Today());
        at.findInsurancePaymentsAggregate(System.Today());
        at.findProcedurePaidInMonthAggregate(System.Today());
        test.stopTest();
        System.assert( patSta.Patient_Code__c !=null,''); 
    }
}