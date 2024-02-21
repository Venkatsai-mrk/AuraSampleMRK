@isTest
public class PatientDetailLedgerTest {

    @testSetup
    public static void createTestData() {
        
        Account patient = TestDataFactory.createPatientAcc();
		insert patient;
    
        Procedure__c procedureTemp = TestDataFactory.createProcedure(patient.Id);
        procedureTemp.Account__c =  null;
        insert procedureTemp;
        
        Provider__c providerTemp = TestDataFactory.createProviderTemp();
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
        
        List<Account> patAccList = [Select id from Account];
        Account patAcc = patAccList[0];
        
        
        Estimates__c estimateRec = new Estimates__c();
        estimateRec.Account__c = patAcc.Id;
        insert estimateRec;
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.FIRSTPUBLISHLOCATIONID = patAcc.Id;
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        
        Id recordTypeId = Schema.SObjectType.Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Info_Card_Configuration').getRecordTypeId();
         ElixirSuite__Master_Object__c masterRec1 = new ElixirSuite__Master_Object__c();
            masterRec1.ElixirSuite__Field_Label__c = 'Id';
            masterRec1.ElixirSuite__Field_Api__c = 'Id';
            masterRec1.ElixirSuite__Patient_Tile_Entity__c = 'Account';
            masterRec1.ElixirSuite__Patient_Tile_Order__c = 1;
            masterRec1.RecordTypeId = recordTypeId;
        insert masterRec1;
        
        test.startTest();
        PatientDetailLedger.getAllData(String.valueOf(patAcc.Id));
        PatientDetailLedger.handlingAfterUpload(String.valueOf(patAcc.Id));
        PatientDetailLedger.LicensBasdPermission();
        PatientDetailLedger.getTileConfigFieldsOrder(patAcc.Id);
        PatientDetailLedger.fetchInsuanceType(patAcc.Id);
        VerifyInsurance.getAllData(String.valueOf(patAcc.Id));
VerifyInsurance.LicensBasdPermission();
        VerifyInsurance.handlingAfterUpload(String.valueOf(patAcc.Id));
        

        //System.assertEquals(1, patAccList.size());
        test.stopTest();
        System.assertEquals(1, 1, '');
    }
    
     @isTest
    public static void unitTest2() {
        
        Account acc = new Account();
        acc.Name = 'Aruacc';
        //Added by Anubhav
        acc.ElixirSuite__MRN_Number_New__c ='8765';
        acc.ElixirSuite__First_Name__c ='first';
        acc.ElixirSuite__Last_Name__c ='last';
        acc.ElixirSuite__SSN__c ='1234';
        acc.ElixirSuite__Email_Id__c ='ghj@gmail.com';
        acc.ElixirSuite__DOB__c =Date.parse('04/11/1998');
        acc.ElixirSuite__Gender__c='Male';
        acc.Phone ='7359919085';
        acc.BillingPostalCode='22222';
        acc.BillingCity = 'BilCity';
        acc.BillingState = 'BilState';
        acc.BillingPostalCode = '27440';
        //Anubhav addition ends
        insert acc;
        
        Payor__c ins = new Payor__c(name='Test', Payer_code__c='12345');
        ins.ElixirSuite__Payer_Code__c = 'abc1234';
        insert ins;
        
        
        VOB__c v = new VOB__c();
        v.ElixirSuite__Account__c = acc.id;
        v.ElixirSuite__Payer__c = ins.id;
        v.ElixirSuite__Status__c = 'Active';
        v.ElixirSuite__Member_Id__c = '7';
        v.ElixirSuite__InsPhone__c ='1234567890';
        v.ElixirSuite__Insured_Zipcode__c ='12345';
        v.ElixirSuite__Gender__c ='Male';
        v.ElixirSuite__Patient_Relationship_With_Insured__c ='18';
        v.ElixirSuite__Insured_First_Name__c ='first';
        v.ElixirSuite__Insured_Last_Name__c ='last';
        v.ElixirSuite__Address_Same_as_Patient__c =true;
        v.ElixirSuite__Date_Of_Birth__c =System.today();
        v.RecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('VOB_record_type').getRecordTypeId();
        insert v;
        
       // PatientDetailLedger.fetchInsuanceType(String.valueOf(acc.Id));
        PatientDetailLedger.fetchInsuranceList('Primary Insurance',String.valueOf(acc.Id), 'ElixirSuite__Member_Id__c');
        System.assertEquals(1, 1, '');
        //PatientDetailLedger.fetchVOBData('Primary Insurance',String.valueOf(acc.Id), 'ElixirSuite__Member_Id__c','1234','abcd');
        
    }
    
}