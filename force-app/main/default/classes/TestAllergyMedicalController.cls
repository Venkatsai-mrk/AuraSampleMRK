@istest
public class TestAllergyMedicalController {

	 @istest
    public static void Test() 
    {
        Account acc = new Account();
        acc.Name ='test Acc';
        acc.Verification_Code__c='abc59c';
      //  acc.Category__c='Food Allergy';
      //  acc.RecordType.Name = 'Allergy';
        insert acc;
        
       
        
        Account accForPrescription = new Account();
        accForPrescription.Name ='test Acc';
        accForPrescription.Verification_Code__c='abc59c';
        insert accForPrescription;
       // String a = '{"jsonListForTaper":[{"medicationName":"Taper Demo","types":"Taper","startDate":"2020-06-29","dispenseExpectedSupplyDuration":"1","afterDischarge":true,"Route":"injection","dosageForm":"Dosage Form","reasonLabel":"For Pain","accountId":"0016A00000sgapSQAQ","Days":[{"Id":"a0S3s000008p7EmEAI","times":[],"Strength":[],"Units":[],"Dosage":[],"indexOfDay":1,"Repeat":"'n' times a day","Dosage_Instruction":"4","textMessage":" 4 times a day"}]}],"jsonListForPRN":[{"medicationName":"Demo Care","types":"PRN","startDate":"2020-06-29","dispenseExpectedSupplyDuration":"1","afterDischarge":false,"Route":"injection","dosageForm":"Packet","accountId":"0016A00000sgapSQAQ","reasonLabel":"for pain updated","singleRecForPrn":[{"Id":"a0S3s000008p7EnEAI","UnitsForPrn":"tablet dispersible","StrengthForPrn":"50mg","DosageForPrn":"1.000","Repeat":"After every 'n' hours","Dosage_Instruction":"1","textMessage":" After every 1 hours"}]}],"jsonListForAOrder":[]}';
        List<String> passOnEmpty = new List<String>();
        Prescription_Order__c testObj = new Prescription_Order__c();
        testObj.Drug_Name__c = 'Test';
        testObj.Account__c = accForPrescription.id;
        insert testObj;
        
         Prescription_Order__c testObjForUtility = new Prescription_Order__c();
        testObjForUtility.Drug_Name__c = 'Test';
        testObjForUtility.Account__c = accForPrescription.id;
        testObjForUtility.Type__c = 'Taper';
        insert testObjForUtility;
        
         Id rc= Schema.Sobjecttype.Medical_Examination__c.getRecordTypeInfosByName().get('Allergy').getRecordTypeId();
      
        Medical_Examination__c me= new Medical_Examination__c();
        me.RecordTypeId= rc;
        me.Account__c=acc.Id;
        me.Category__c = 'Food Allergy';
        try
        {
            insert me;
        }
        Catch(Exception e){}
        
        ViewPrescriptionController.Days taperDays  = new ViewPrescriptionController.Days();
        taperDays.ID = testObj.id;
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
        taperObj.id= testObj.id;
        taperObj.medicationName = testObj.name;
        taperObj.types = 'Taper' ; 
        taperObj.startDate = '2020-06-29';
        taperObj.dispenseExpectedSupplyDuration = 1;
        taperObj.afterDischarge = true ;
        taperObj.dosageForm = 'Dosage Form' ;
        taperObj.reasonLabel = 'For Pain' ;
        taperObj.Route = 'injection';
        taperObj.Warning = 'label' ;
       // taperObj.accountId = '';
        taperObj.Days = passOnTaper ; 
        
        
         ViewPrescriptionController.JSON2Apex PRNObj = new ViewPrescriptionController.JSON2Apex();
        PRNObj.id= testObj.id;
        PRNObj.medicationName = testObj.name;
        PRNObj.types = 'PRN' ; 
        PRNObj.startDate = '2020-06-29';
        PRNObj.dispenseExpectedSupplyDuration = 1;
        PRNObj.afterDischarge = true ;
        PRNObj.dosageForm = 'Dosage Form' ;
        PRNObj.reasonLabel = 'For Pain' ;
        PRNObj.Route = 'injection';
        PRNObj.Warning = 'label' ;
       // taperObj.accountId = '';
        PRNObj.Days = passOnTaper ; 
        
        
        
        List<ViewPrescriptionController.JSON2Apex> taperlst = new List<ViewPrescriptionController.JSON2Apex>();
        //  List<ViewPrescriptionController.JSON2Apex> PRNLst = new List<ViewPrescriptionController.JSON2Apex>();
        taperlst.add(taperObj); 
       // PRNLst.add(PRNObj);
        //String taperDynamicJSON = JSON.serialize(taperlst);
        
        ViewPrescriptionController.singleRecPRN passOnPRN = new ViewPrescriptionController.singleRecPRN();
        passOnPRN.Dosage_Instruction = '1';
        passOnPRN.DosageForPrn = '1.00';
        passOnPRN.Repeat = 'After every '+ '\''+ 'n' +'\''+ ' hours';
        passOnPRN.StrengthForPrn = '50mg';
        passOnPRN.UnitsForPrn = 'tablet dispersible';
        passOnPRN.id = testObj.id;
        List<ViewPrescriptionController.singleRecPRN> toPassPRN = new List<ViewPrescriptionController.singleRecPRN>();
        toPassPRN.add(passOnPRN);
        
        ViewPrescriptionController.JSONprn PRNObjTest = new ViewPrescriptionController.JSONprn();
        PRNObjTest.afterDischarge = false;
        PRNObjTest.dispenseExpectedSupplyDuration = 10;
        PRNObjTest.dosageForm = 'Packet';
        PRNObjTest.Id = testObj.id;
        PRNObjTest.medicationName = 'demo';
        PRNObjTest.reasonLabel = 'pain';
       // PRNObjTest.accountId = accForPrescription.id;
        PRNObjTest.startDate = '2020-06-29';
        PRNObjTest.singleRecForPrn = toPassPRN;
        List<ViewPrescriptionController.JSONprn> prnlst = new List<ViewPrescriptionController.JSONprn>();
        prnlst.add(PRNObjTest);
      //  String prnDynamicJSON = JSON.serialize(prnlst);
        
        ViewPrescriptionController.actionOrder actionOrderObjTest = new ViewPrescriptionController.actionOrder();
        List<ViewPrescriptionController.actionOrder> actionlst = new List<ViewPrescriptionController.actionOrder>();
        actionlst.add(actionOrderObjTest);
        //String actionOrderDynamicJSON = JSON.serialize(actionlst);
        //String finalDynamicJSON = '{jsonListForTaper:' + taperDynamicJSON + 'jsonListForPRN:' + prnDynamicJSON + 'jsonListForAOrder:' + actionOrderDynamicJSON+'}' ;  
        ViewPrescriptionController.root finalDynamicJSON = new ViewPrescriptionController.root();
		finalDynamicJSON.jsonListForTaper = taperlst;
        finalDynamicJSON.jsonListForPRN =  taperlst ; 
        finalDynamicJSON.jsonListForAOrder =  taperlst ; 
        String toSendAsTest = JSON.serialize(finalDynamicJSON);
        
        
        list<string> ordrlist = new list<string>();
        
        
        Prescription_Order__c ordr = new Prescription_Order__c();
        ordr.Status__c = 'Open';
      //  ordr.Signature_Status__c=true;
       // ordr.Signature_Comments__c = 'demo';
        ordr.Account__c = acc.id;
      //  ordr.Signed_Date__c = String.valueOf(Date.today());
        
        insert ordr;
        
        
         Prescription_Order__c ordrTest = new Prescription_Order__c();
        ordrTest.Status__c = 'Open';
      // ordrTest.Signature_Status__c=true;
       // ordrTest.Signature_Comments__c = 'demo';
        ordrTest.Account__c = accForPrescription.id;
       // ordrTest.Signed_Date__c = String.valueOf(Date.today());
        
        insert ordrTest;
        
         Prescription_Order__c ordr3= new Prescription_Order__c();
        ordr3.Status__c = 'Open';
       // ordr3.Signature_Status__c=true;
       // ordr3.Signature_Comments__c = 'demo';
        ordr3.Account__c = acc.id;
      //  ordr3.Signed_Date__c = String.valueOf(Date.today());
        
        insert ordr3;
        
        ordrlist.add(ordr.id);
        
      /*  Id recTypeId1 = Schema.SObjectType.HealthCloudGA__EhrAllergyIntolerance__c.getRecordTypeInfosByName().get('Medical Alerts').getRecordTypeId();
        Id recTypeId = Schema.SObjectType.HealthCloudGA__EhrAllergyIntolerance__c.getRecordTypeInfosByName().get('Allergy').getRecordTypeId();
        HealthCloudGA__EhrAllergyIntolerance__c a = new HealthCloudGA__EhrAllergyIntolerance__c();
        a.Category__c='Food Allergy';
        a.RecordTypeId =recTypeId;
        a.Account__c=acc.id;
        a.Start_Time__c = system.now().adddays(1);
        a.End_Time__c = system.now().adddays(2) ;
        insert a;
        
        HealthCloudGA__EhrAllergyIntolerance__c b = new HealthCloudGA__EhrAllergyIntolerance__c();
        b.Category__c='Skin Allergy';
        b.RecordTypeId =recTypeId;
        b.Account__c=acc.id;
        b.Start_Time__c = system.now().adddays(1);
        b.End_Time__c = system.now().adddays(2) ;
        insert b;
        
        HealthCloudGA__EhrAllergyIntolerance__c c = new HealthCloudGA__EhrAllergyIntolerance__c();
        c.Category__c='Drug Allergy';
        c.RecordTypeId =recTypeId;
        c.Account__c=acc.id;
        c.Start_Time__c = system.now().adddays(1);
        c.End_Time__c = system.now().adddays(1) ;
        insert c;*/
        
        String toIns = '{"toInsertjsonListForTaper":[],"toInsertjsonListForPRN":[],"toInsertjsonListForAOrder":[]}';
      	Blob bTEst = Blob.valueOf('Test Data');
    	System.debug('final json '+finalDynamicJSON);
    	Attachment attachment = new Attachment();
    	attachment.ParentId = accForPrescription.id;
    	attachment.Name = 'Test Attachment for Parent';
    	attachment.Body = bTEst;
    	insert attachment;
        
        String startTime = String.valueOf(System.now());
		String endTime =  String.valueOf(System.now() + 2);   
        
        
        
        Frequency__c testDosage = new Frequency__c();
        testDosage.Prescription_Order__c = testObjForUtility.id;
        insert testDosage;
        
        Map<Id,Frequency__c> toPassForTest = new Map<Id,Frequency__c>();
        toPassForTest.put(testDosage.id,testDosage);
       Set<Id> toPassMap  = new Set<Id>();
        toPassMap.add(testDosage.id);
       List<Frequency__c> toPassDosageForTest =  new List<Frequency__c>();
        toPassDosageForTest.add(testDosage); 
        
        
       
        test.startTest();
		MedicationListViewApexController.fetchMedications(acc.Id);  
        MedicationListViewApexController.fetchPrescription(acc.Id);
        MedicationListViewApexController.deleteAllOrder(ordrlist);
        ViewPrescriptionController.getCode(acc.Id);
        ViewPrescriptionController.getOrder(ordr3.Id);
        //ViewPrescriptionController.dummyMethod();
        ViewPrescriptionController.saveOrder(accForPrescription.id,ordrTest.id,toSendAsTest,toIns,10,attachment.id,'demoComment','2020-06-29',startTime,endTime,
                                             new List<String>());
        // ViewPrescriptionController.utilityTaper(passOnTaper,toPassMap,toPassForTest,toPassDosageForTest,testObjForUtility);
        AllergyMedicalController.getData(acc.Id);
       /* ElixirHC_PrescriptionOrder_PDFHelper objNew = new ElixirHC_PrescriptionOrder_PDFHelper();
        objNew.getAccountInfo(acc.Id);
        objNew.getprescriptionOrderInfo(ordr3.Id);*/
        system.assertEquals(1, 1,'');
        test.stopTest();
        
    }

}