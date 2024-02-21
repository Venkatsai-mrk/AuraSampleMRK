@isTest
public class ListViewControllerTest {

    @testSetup
    public static void createTestData() {
        
        Account patient = TestDataFactory.createPatientAcc();
        insert patient;
        
        Procedure__c procedureTemp = TestDataFactory.createProcedure(patient.Id);
        procedureTemp.Account__c =  null;
        insert procedureTemp;
        
        Provider__c providerTemp = TestDataFactory.createProviderTemp();
        //providerTemp.Account__c =  null;
        insert providerTemp;
        
        Provider__c provider = TestDataFactory.createProvider(patient.Id);
        insert provider;
        
        Actual_Price__c actualPrice = TestDataFactory.createActualPrice(procedureTemp.Id, providerTemp.Id);
        insert actualPrice;
        
        Claim__c c = TestDataFactory.createClaim(patient.Id);
        
        c.Patient_Last_Name__c = 'test';
        c.Patient_First_Name__c = 'test';
        c.Payer_ID__c = 'test';
        c.Other_Payer_Name__c = 'test';
        c.Insurance_Number__c = '20';
        c.Patient_DOB__c = Date.today();
        c.Patient_Sex__c = 'test';
        c.Payer_Order__c = 'test';
        c.Patient_s_Address__c = 'test';
        c.Patient_s_City__c = 'test';
        c.Patient_Country_Code__c = 'test';
        c.Patient_s_State__c = 'test';
        c.Patient_s_Zipcode__c = 20;
        c.Patient_Relationship_to_Insured__c = 'test';
        c.Insured_Address__c = 'test';
        c.Insured_City__c = 'test';
        c.Insured_Country_Code__c = 'test';
        c.Insured_State__c = 'test';
        c.Insured_Zipcode__c = 200;
        c.Employment_Related__c = 'test';
        c.Auto_Accident_Related__c = 'test';
        c.Insured_DOB__c = Date.today();
        c.Insured_Sex__c = 'test';
        c.Place_of_Service__c = 'test';
        c.Billing_Provider_Tax_ID__c = 'test';
        c.Billing_Provider_Tax_ID_Type__c = 'E';
        c.Accept_Assignment__c = 'test';
        c.Total_Charge__c = 200;
        c.Amount_Paid__c = 200;
        c.Billing_Provider_Name__c = 'test';
        c.Billing_Provider_Address_1__c = 'test';
        c.Billing_Provider_City__c = 'test';
        c.Billing_Provider_State__c = 'test';
        c.Billing_Provider_Zip__c = 'test';
        c.Bill_Phone__c = 'test';
        c.First_Diagnosis__c = 'test';
        c.Procedure_Code__c = 'test';
        c.Units__c = 'test';
        c.From_Date__c = Date.today();
        c.Thru_Date__c = Date.today();
        c.Charge_Amount__c = 'test';
        c.Diagnosis_Reference__c = 'test';
        
        
        
        
        insert c;
        
        Procedure__c procedure = TestDataFactory.createProcedure(patient.Id);
        procedure.Claim__c = c.Id;
        insert procedure;
        
        Procedure__c procedure1 = TestDataFactory.createProcedure(patient.Id);
        insert procedure1;
        
        Claim_Line_Items__c cli = TestDataFactory.createClaimLineItems(c.Id, procedure.Id);
        insert cli;
        
        
        Master_Transaction__c mst = TestDataFactory.createMasterTrans(patient.Id, 'Unallocated');
        insert mst;
        
        Payment_Transaction__c payTrans = TestDataFactory.createPayTransaction(procedure.Id, patient.Id, 'Payment Started');
        insert payTrans;
        
        Payment_Transaction__c payTrans1 = TestDataFactory.createPayTransaction(procedure.Id, patient.Id, 'Payment Started');
        insert payTrans1;
        
        Payment_Information__c payInfo =  TestDataFactory.createPayIno(patient.Id);
        insert payInfo;
        
    }
    
    @isTest
    public static void unitTest1() {
        
        List<Payment_Transaction__c> payTrans = [Select id,ElixirSuite__PatientOutstanding__c from Payment_Transaction__c];
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        
        Claim__c claimRec = [Select id from Claim__c];
        
        Estimates__c estimateRec = new Estimates__c();
        estimateRec.Account__c = patAcc.Id;
        insert estimateRec;
        
        list<String> claimIdList = new list<String>();
        claimIdList.add(claimRec.Id);
         
        test.startTest();
        ListViewController.BringDataFirst(String.valueOf(patAcc.Id));
        ListViewController.BringDataViewAll(String.valueOf(patAcc.Id));
        ListViewController.BringFilterData(String.valueOf(Date.today()), String.valueOf(Date.today()), String.valueOf(patAcc.Id));
        ListViewController.BringFilterDataViewAll(String.valueOf(Date.today()), String.valueOf(Date.today()), String.valueOf(patAcc.Id));
        ListViewController.generateXML(claimIdList);
        
        ListViewController_for_Ehr.BringDataFirst(String.valueOf(patAcc.Id));
        ListViewController_for_Ehr.BringDataViewAll(String.valueOf(patAcc.Id));
        ListViewController_for_Ehr.BringFilterData(String.valueOf(Date.today()), String.valueOf(Date.today()), String.valueOf(patAcc.Id));
        ListViewController_for_Ehr.BringFilterDataViewAll(String.valueOf(Date.today()), String.valueOf(Date.today()), String.valueOf(patAcc.Id));
        ListViewController_for_Ehr.generateXML(claimIdList);
        
        System.assertEquals(1, patAccList.size(),'');
        test.stopTest();
    }
}