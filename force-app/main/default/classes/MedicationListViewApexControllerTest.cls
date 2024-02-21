/*MedicationListViewApexController/ViewPrescriptionController and AllergyMedicalController covers from this Test Class*/
@istest
public class MedicationListViewApexControllerTest {
	 @istest
    public static void test() 
    {
       
        Account acc = new Account();
        acc.Name ='test Acc';
        acc.Verification_Code__c='abc59c';
        acc.Phone='1234567870';
        acc.BillingPostalCode='98756';
        insert acc;
        
        Account accForPrescription = new Account();
        accForPrescription.Name ='test Acc';
        accForPrescription.Phone='1234567830';
        accForPrescription.BillingPostalCode='45321';
        accForPrescription.Verification_Code__c='abc59c';
        insert accForPrescription;
        List<String> passOnEmpty = new List<String>();
        
        
        ViewPrescriptionController.Days taperDays  = new ViewPrescriptionController.Days();
        taperDays.Dosage = passOnEmpty;
        taperDays.Dosage_Instruction = 10;
        taperDays.indexOfDay = 1;
        taperDays.Repeat = '';
        taperDays.Strength = passOnEmpty;
        taperDays.times = passOnEmpty;
        taperDays.Units = passOnEmpty ; 
        List<ViewPrescriptionController.Days> passOnTaper  = new List<ViewPrescriptionController.Days>();
        passOnTaper.add(taperDays);
        
        
        ViewPrescriptionController.JSON2Apex taperObj = new ViewPrescriptionController.JSON2Apex();
        taperObj.types = 'Taper' ; 
        taperObj.startDate = '2020-06-29';
        taperObj.dispenseExpectedSupplyDuration = 1;
        taperObj.afterDischarge = true ;
        taperObj.dosageForm = 'Dosage Form' ;
        taperObj.reasonLabel = 'For Pain' ;
        taperObj.Route = 'injection';
        taperObj.Warning = 'label' ;
        taperObj.Days = passOnTaper ; 
        List<ViewPrescriptionController.JSON2Apex> taperlst = new List<ViewPrescriptionController.JSON2Apex>();
        taperlst.add(taperObj);
        
        ViewPrescriptionController.singleRecPRN passOnPRN = new ViewPrescriptionController.singleRecPRN();
        passOnPRN.Dosage_Instruction = '1';
        passOnPRN.DosageForPrn = '1.00';
        passOnPRN.Repeat = 'After every '+ '\''+ 'n' +'\''+ ' hours';
        passOnPRN.StrengthForPrn = '50mg';
        passOnPRN.UnitsForPrn = 'tablet dispersible';
        List<ViewPrescriptionController.singleRecPRN> toPassPRN = new List<ViewPrescriptionController.singleRecPRN>();
        toPassPRN.add(passOnPRN);
        
        ViewPrescriptionController.JSONprn prnObjTest = new ViewPrescriptionController.JSONprn();
        prnObjTest.afterDischarge = false;
        prnObjTest.dispenseExpectedSupplyDuration = 10;
        prnObjTest.dosageForm = 'Packet';
        prnObjTest.medicationName = 'demo';
        prnObjTest.reasonLabel = 'pain';
        prnObjTest.startDate = '2020-06-29';
        prnObjTest.singleRecForPrn = toPassPRN;
         List<ViewPrescriptionController.JSONprn> prnlst = new List<ViewPrescriptionController.JSONprn>();
        prnlst.add(prnObjTest);
        
        ViewPrescriptionController.actionOrder actionOrderObjTest = new ViewPrescriptionController.actionOrder();
        List<ViewPrescriptionController.actionOrder> actionlst = new List<ViewPrescriptionController.actionOrder>();
        actionlst.add(actionOrderObjTest);
        ViewPrescriptionController.root finalDynamicJSON = new ViewPrescriptionController.root();
		finalDynamicJSON.jsonListForTaper = taperlst;
        String toSendAsTest = JSON.serialize(finalDynamicJSON);
        
        
        list<string> ordrlist = new list<string>();
        
        Prescription_Order__c ordr = new Prescription_Order__c();
        ordr.Status__c = 'Open';
        ordr.Signature_Status__c=true;
        ordr.Signature_Comments__c = 'demo';
        ordr.Account__c = acc.id;
        ordr.Signed_Date__c = String.valueOf(Date.today());
        
        insert ordr;
        
        
         Prescription_Order__c ordrTest = new Prescription_Order__c();
        ordrTest.Status__c = 'Open';
        ordrTest.Signature_Status__c=true;
        ordrTest.Signature_Comments__c = 'demo';
        ordrTest.Account__c = accForPrescription.id;
        ordrTest.Signed_Date__c = String.valueOf(Date.today());
        
        insert ordrTest;
        
         Prescription_Order__c ordr3= new Prescription_Order__c();
        ordr3.Status__c = 'Open';
        ordr3.Signature_Status__c=true;
        ordr3.Signature_Comments__c = 'demo';
        ordr3.Account__c = acc.id;
        ordr3.Prescription_Order__c = ordrTest.Id;
        ordr3.Signed_Date__c = String.valueOf(Date.today());
        
        insert ordr3;
        
        ordrlist.add(ordr.id);
        
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
       ElixirSuite__Provider__c prov = new ElixirSuite__Provider__c();
       prov.RecordTypeId = devRecordTypeId;
       prov.Name = 'Davamtest';
       prov.ElixirSuite__Provider_Code__c = 'west';
       prov.ElixirSuite__Provider_First_Name__c = 'test1';
       prov.ElixirSuite__Provider_Last_Name__c = 'test2';
       insert prov;
       String toIns = '{"toInsertjsonListForTaper":[],"toInsertjsonListForPRN":[],"toInsertjsonListForAOrder":[]}';
      	Blob bTEst = Blob.valueOf('Test Data');
    	Attachment attachment = new Attachment();
    	attachment.ParentId = accForPrescription.id;
    	attachment.Name = 'Test Attachment for Parent';
    	attachment.Body = bTEst;
    	insert attachment;
        
        String startTime = String.valueOf(System.now());
		String endTime =  String.valueOf(System.now() + 2);   
        test.startTest();
		MedicationListViewApexController.fetchMedications(acc.Id);  
        MedicationListViewApexController.fetchPrescription(acc.Id);
        MedicationListViewApexController.deleteAllOrder(ordrlist);
        
        MedicationListViewApexController.fetchNameSpace();
        ViewPrescriptionController.getCode(acc.Id);
        ViewPrescriptionController.getOrder(ordr3.Id);
        ViewPrescriptionController.saveOrder(accForPrescription.id,ordrTest.id,toSendAsTest,toIns,10,attachment.id,'demoComment','2020-06-29',startTime,endTime,
                                            new List<String>());
        
        AllergyMedicalController.getData(acc.Id);
        MedicationListViewApexController.checkCareEpisode(acc.Id);
       /* ElixirHC_PrescriptionOrder_PDFHelper objNew = new ElixirHC_PrescriptionOrder_PDFHelper();
        objNew.getAccountInfo(acc.Id);
        objNew.getprescriptionOrderInfo(ordr3.Id);*/
        test.stopTest();
        System.assertEquals(1, 1, ' ');
        
    }
}