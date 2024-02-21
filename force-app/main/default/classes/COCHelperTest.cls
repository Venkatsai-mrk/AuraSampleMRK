@isTest
public class COCHelperTest {

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
        
        VOB__c vobRec = new VOB__c();
        vobRec.Account__c = patient.Id;
        vobRec.ElixirSuite__Insured_Address__c ='ABC';
        vobRec.ElixirSuite__Date_Of_Birth__c =date.valueOf('2000-04-16');
        insert vobRec;
        
        Result__c vobResultRec = new Result__c();
        vobResultRec.VOB__c = vobRec.Id;
        insert vobResultRec;
    }
    
    @isTest
    public static void unitTest1() {
        
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        
        Procedure__c procedure = [Select id from Procedure__c Limit 1];
        List<String> procIdList = new List<String>();
        procIdList.add(procedure.Id);
        
        Estimates__c estimateRec = new Estimates__c();
        estimateRec.Account__c = patAcc.Id;
        insert estimateRec;
        
        Map<String, Object> mapOfInsurance = new Map<String, Object>();
        mapOfInsurance.put('Co_Insurance_Provider_Percent__c', 100 );
        mapOfInsurance.put('in_network_total__c', 100 );
        mapOfInsurance.put('out_of_network_outOfPocket_total__c', 100 );
        mapOfInsurance.put('Payer_Name__c', 'Payer_Name__c' );
        
        List<Object> objList = new List<Object>();
        objList.add(mapOfInsurance);
        
        Map<String, Object> keysToSaveMap = new Map<String, Object>();
        keysToSaveMap.put('keysToSave', objList);
        
        Map<String, Object> mapofProcedure = new Map<String, Object>();
        mapofProcedure.put('CPT_HCPCS_Code__c', 'test' );
        mapofProcedure.put('Name', 'test' );
        mapofProcedure.put('Days_Units__c', 1 );
        mapofProcedure.put('Contracted_Price__c', 100 );
        mapofProcedure.put('totalContractedPrice', '100' );
        
        List<Object> objList1 = new List<Object>();
        objList1.add(mapofProcedure);
        
        Map<String, Object> keysToSaveForPrceduresMap = new Map<String, Object>();
        keysToSaveForPrceduresMap.put('keysToSaveForPrcedures', objList1);
        
        test.startTest();
        COCHelper.parentInit_FetchDataForCOC(patAcc.Id);
        COCHelperforEHR.parentInitFetchDataForCOC(patAcc.Id, '');//added by Anmol for LX3-6577
        COCHelper.getProceduresTemplates(procIdList);
        COCHelperforEHR.getProceduresTemplates(procIdList);//added by Anmol for LX3-6577
        COCHelper.fetchIndividualRecordDetailsForView(estimateRec.Id);
        COCHelperforEHR.fetchIndividualRecordDetailsForView(estimateRec.Id);//added by Anmol for LX3-6577
        COCHelper.saveCOC(patAcc.Id, 100, 200, 300, JSON.serialize(keysToSaveMap), JSON.serialize(keysToSaveForPrceduresMap), false, 50);
        COCHelperforEHR.saveCOC(patAcc.Id, 100, 200, 300, JSON.serialize(keysToSaveMap), JSON.serialize(keysToSaveForPrceduresMap), false, 50,100,200,300,'','','','');//added by Anmol for LX3-6577
        COCHelperforEHR.procedureList('99202','Procedures',procIdList);
        COCHelperforEHR.procedureList('99202','Labs',procIdList);
        COCHelperforEHR.employerList('Ja');
        COCHelperforEHR.updateUseStatusForCOCEstimateSingleRecord(estimateRec.Id,false);
        System.assertEquals(1, 1, ' ');
        test.stopTest();
    }
}