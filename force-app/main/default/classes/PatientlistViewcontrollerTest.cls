@isTest
public class PatientlistViewcontrollerTest {

    /*@testSetup
    public static void createTestData() {
        
        Patient_Account__c patient = TestDataFactory.createPatientAcc();
		insert patient;
        
        Procedure__c procedureTemp = TestDataFactory.createProcedure(patient.Id);
        procedureTemp.Patient_Account__c =  null;
        insert procedureTemp;
        
        Provider__c providerTemp = TestDataFactory.createProvider(patient.Id);
        providerTemp.Patient_Account__c =  null;
        insert providerTemp;
        
        Provider__c provider = TestDataFactory.createProvider(patient.Id);
        insert provider;
        
        Actual_Price__c actualPrice = TestDataFactory.createActualPrice(procedureTemp.Id, providerTemp.Id);
		insert actualPrice;
        
        Claim__c claim = TestDataFactory.createClaim(patient.Id);
        insert claim;
        
        Procedure__c procedure = TestDataFactory.createProcedure(patient.Id);
        procedure.Claim__c = claim.Id;
        insert procedure;
        
        Procedure__c procedure1 = TestDataFactory.createProcedure(patient.Id);
        insert procedure1;
        
        Claim_Line_Items__c cli = TestDataFactory.createClaimLineItems(claim.Id, procedure.Id);
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
        

        List<Patient_Account__c> patAccList = [Select id from Patient_Account__c];
        Patient_Account__c patAcc = patAccList[0];
        
        Estimates__c estimateRec = new Estimates__c();
        estimateRec.Patient_Account__c = patAcc.Id;
        insert estimateRec;
        
        test.startTest();
        PatientlistViewcontroller.fetchPatientlist();
        PatientlistViewcontroller.fetchClaims(String.valueOf(patAcc.Id));
        PatientlistViewcontroller.fetchPayment();
        System.assertEquals(1, patAccList.size());
        test.stopTest();
    }*/
}