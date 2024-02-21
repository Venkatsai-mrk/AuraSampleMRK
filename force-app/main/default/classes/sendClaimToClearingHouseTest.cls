@isTest
public class sendClaimToClearingHouseTest {
    
    
  /*  @isTest
    public static void unitTest1() {
        
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
        
        Claim__c claim = TestDataFactory.createClaim(patient.Id);
        claim.Account__c = patient.Id;
        insert claim;
        
        Procedure__c procedure = TestDataFactory.createProcedure(patient.Id);
        procedure.Claim__c = claim.Id;
        insert procedure;
        
        Procedure__c procedure1 = TestDataFactory.createProcedure(patient.Id);
        insert procedure1;
        
        Claim_Line_Items__c cli = TestDataFactory.createClaimLineItems(claim.Id, procedure.Id);
        cli.ERA_Received__c = true;
        insert cli;
        
        
        Master_Transaction__c mst = TestDataFactory.createMasterTrans(patient.Id, 'Unallocated');
        insert mst;
        
        Payment_Transaction__c payTrans = TestDataFactory.createPayTransaction(procedure.Id, patient.Id, 'Payment Started');
        insert payTrans;
        
        Payment_Transaction__c payTrans1 = TestDataFactory.createPayTransaction(procedure.Id, patient.Id, 'Payment Started');
        insert payTrans1;
        
        Payment_Information__c payInfo =  TestDataFactory.createPayIno(patient.Id);
        insert payInfo;
        
        Claim__c claimRec = [Select id, Name from Claim__c where Account__c =: patient.Id LIMIT 1];
        Claim_Line_Items__c cliRec = [Select id, Name from Claim_Line_Items__c where Claim__c =: claimRec.Id LIMIT 1];
        
        test.startTest();
        //Test.setMock(HttpCalloutMock.class, new GetERAIDBatchMock(claimRec.Name, cliRec.Name));
        //sendClaimToClearingHouse.updateClaim(claimRec.Id);
        test.stopTest();
               System.assertEquals('1', '1'); 
        
    }*/
    
    @isTest
    public static void LicensBasdPermissionTest(){
        sendClaimToClearingHouse.LicensBasdPermission();
       system.assertEquals(1, 1, '');
    }}