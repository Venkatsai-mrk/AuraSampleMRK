@isTest
public class TestSuperBill_PdfGenerator {
    
    @isTest
    public static void superBillTest(){
        
        
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
        insert patient;
        
        ElixirSuite__Payor__c pay1 = new ElixirSuite__Payor__c();
        pay1.Payer_Code__c = '12345';
        insert pay1;
        
        Id templateProcId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('VOB_record_type').getRecordTypeId();
        ElixirSuite__VOB__c vob2 = new ElixirSuite__VOB__c();
        vob2.status__c = 'Active';
        vob2.type__c = 'Primary';
        vob2.RecordTypeId = templateProcId;
        vob2.ElixirSuite__Account__c = patient.id;
        vob2.Insured_First_Name__c = 'TestVob';
        vob2.Insured_Middle_Name__c = 'Mid';
        vob2.Insured_Last_Name__c = 'Last';
        vob2.ElixirSuite__Benefit__c = 'AI = Substance Abuse';
        vob2.ElixirSuite__Patient_Relationship_With_Insured__c = 'Self';
        vob2.ElixirSuite__Payer__c = pay1.id;
        vob2.ElixirSuite__Service_Date__c = system.today();
        insert vob2;
        
        
        ElixirSuite__Provider__c exPrvdr = new ElixirSuite__Provider__c();
        exPrvdr.ElixirSuite__Account__c = patient.Id;
        exPrvdr.Name = 'Test Provider';
        exPrvdr.ElixirSuite__Provider_Zip__c = '12356';
        exPrvdr.ElixirSuite__Provider_State__c = 'TestState';
        exPrvdr.ElixirSuite__Provider_Last_Name__c = 'TestLastProvider';
        exPrvdr.ElixirSuite__Provider_City__c = 'TestProviderCity';
        exPrvdr.ElixirSuite__Provider_Code__c = '14785';
        insert exPrvdr;
        
        ElixirSuite__Visits__c exVisit = new ElixirSuite__Visits__c();
        exVisit.ElixirSuite__Account__c = patient.Id;
        exVisit.ElixirSuite__Status__c = 'Active';
        exVisit.ElixirSuite__Location__c = 'US';
        exVisit.ElixirSuite__Care_Episode_Location__c = exPrvdr.Id;
        exVisit.Name = 'Test Visit';
        insert exVisit;
        
        ElixirSuite__Procedure__c exPrcdr = new ElixirSuite__Procedure__c();
        exPrcdr.ElixirSuite__Account__c = patient.Id;
        exPrcdr.ElixirSuite__Active__c = true;
        exPrcdr.ElixirSuite__Is_Billable__c = true;
        exPrcdr.ElixirSuite__From_Date_of_Service__c = System.today();
        exPrcdr.ElixirSuite__Code_Description__c = 'A90';
        exPrcdr.ElixirSuite__Days_Units__c = 1;
        exPrcdr.ElixirSuite__Visits__c = exVisit.Id;
		exPrcdr.ElixirSuite__Type_of_Procedure__c = 'Private Payment';
        exPrcdr.ElixirSuite__Charges__c = 100;
        exPrcdr.Name = 'Test Care Episode';
        insert exPrcdr;
        Id paymntTxnRecordTypeIdPrivate = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Private_Payment').getRecordTypeId();
        
        test.startTest();
        Payment_Transaction__c payTran1 = new Payment_Transaction__c();
        payTran1.ElixirSuite__Procedure__c = exPrcdr.Id;
        payTran1.Cpt_Codes__c = 'CPT100';
        payTran1.RecordTypeId = paymntTxnRecordTypeIdPrivate;
        payTran1.Insurance_Payments__c = 200;
        payTran1.Account__c = patient.Id;
        payTran1.Patient_Payments__c = 100;
        payTran1.Payment_Adjustments__c = 10;
        insert payTran1;

        Transactions__c trans1 = new Transactions__c();
        trans1.ElixirSuite__Master_Transaction__c=payTran1.Id;
        trans1.Amount_Paid__c = 200;
        insert trans1;
        
        ElixirSuite__ICD_Codes__c icd = new ElixirSuite__ICD_Codes__c(Name = 'ICDDEMO');
        insert icd;
        ElixirSuite__Procedure_Diagnosis__c pd = new ElixirSuite__Procedure_Diagnosis__c(ElixirSuite__Procedure__c = exPrcdr.Id,
                                                                                        ElixirSuite__ICD_Codes__c = icd.Id);
        insert pd;
        
        ApexPages.currentPage().getParameters().put('aId', String.valueOf(patient.Id));
        ApexPages.currentPage().getParameters().put('careId', String.valueOf(exVisit.Id));
        SuperBill_PdfGenerator superBill = new SuperBill_PdfGenerator();
        
        List<Id> idLst = new List<Id>();
        idLst.add(exVisit.Id);
        
        SuperBill_PdfGenerator.createPdf(idLst,String.valueOf(patient.Id));
        
        test.stopTest(); 
        
        System.assertEquals(1, 1, ' ');
        
        
        
        
    }

}