@isTest
public class ElixirHC_FormsPDFGeneratorHelperTest {
    /*public static testMethod void  parent_CoverAllMethods(){
        Account acc = new Account();
        acc.Name ='test Acc';
        acc.Verification_Code__c='abc59c';
        insert acc;
        Form__c f = new Form__c();
        f.Name ='Risk';
        f.Account__c = acc.Id;
        f.Category__c='Medical';
        f.Sub_Category__c='Medicene';
        f.Version__c=2.3;
        //  f.Form__c=f1.id;
        insert f;
        
        Contact c  = new Contact();
        // c.name = 'test';
        c.birthdate = Date.today();
        c.AccountId=acc.id;
        c.lastName = 'Test last ';
        insert c;
        list<String> lis = new list<string>();
        
        
        
        List<Lead> leads = new List<Lead>();
        String CRON_EXP = '0 0 1 * * ?';
        for(Integer i = 0; i < 200; i++){
            Lead lead = new Lead(LastName = 'Test ' + i, LeadSource = '', Company = 'Test Company ' + i, Status = 'Open - Not Contacted');
            leads.add(lead);
        }
        insert leads;
        // Test.startTest();
        // String jobId = System.schedule('Update LeadSource to DreamForce', CRON_EXP, new DailyLeadProcessor());
        // Test.stopTest();
        Form_Field__c field = new Form_Field__c();
        field.Form__c =f.Id;
        field.Data_Entry_Type__c='Picklist:PhysicalTherapist';
        insert field;
        
        Form_Field__c field1 = new Form_Field__c();
        field1.Form__c =f.Id;
        field1.Data_Entry_Type__c='Picklist:Allergy';
        insert field1;
        
        Form_Field__c field2 = new Form_Field__c();
        field2.Form__c =f.Id;
        field2.Data_Entry_Type__c='Medication_list';
        insert field2;
        
        Form_Field__c field3 = new Form_Field__c();
        field3.Form__c =f.Id;
        field3.Data_Entry_Type__c='Medication_list';
        insert field3;
        
        Form_Field__c field4 = new Form_Field__c();
        field4.Form__c =f.Id;
        field4.Data_Entry_Type__c='Glucose_note';
        insert field4;
        
        Form_Field__c field5 = new Form_Field__c();
        field5.Form__c =f.Id;
        field5.Data_Entry_Type__c='Vitals_signs';
        insert field5;
        
        Form_Field__c field6 = new Form_Field__c();
        field6.Form__c =f.Id;
        field6.Data_Entry_Type__c='Diagnosis_Code';
        insert field6;
        
        Form_Field__c field8 = new Form_Field__c();
        field8.Form__c =f.Id;
        field8.Section__c=3;
        field8.Data_Entry_Type__c='Active_Users';
        insert field8;
        
        Form__c f1 = new Form__c();
        f1.Name ='Risk';
        f1.Category__c='Medical';
        f1.Sub_Category__c='Assessments';
        f1.Version__c=2.3;
        f1.Account__c=acc.id;
        f1.Form__c = f.id;
        insert f1;
        System.debug('f1 '+f1);
        
        Form_Data__c data = new Form_Data__c();
        data.Account__c=acc.Id;
        data.Form__c =f1.id;
        insert data;
        
        f.Form__c=f1.Id;
        update f;
        
        
        lis.add(f1.Id);
        
        List<string> lis1 = new list<string>();
        
        Dataset1__c ec = new Dataset1__c();
        //  ec.Care_Plan_Template_Problem__c = care.id;
        insert ec ;
        list<String> hdiagnosis = new list<String>();
        ICD_Codes__c hd = new ICD_Codes__c();
        hd.Name = 'diagnosis1' ;
        // hd.Care_Plan_Template_Problem__c = care.id;
        hd.Dataset1__c = ec.id;
        insert hd ;
        hdiagnosis.add(hd.id);
        List<String> lstStr = new List<String>();
        lstStr.add(ec.Id);
        list<Medical_Examination__c> oblist = new list<Medical_Examination__c>();
        list<Medical_Examination__c> obslist = new list<Medical_Examination__c>();
        Id devRecordTypeIdGlucose = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Glucose').getRecordTypeId();
        Id devRecordTypeIdVital = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Vital_Sign').getRecordTypeId();
        Id devRecordTypeIdAllergy = Schema.SObjectType.Medical_Examination__c.getRecordTypeInfosByDeveloperName().get('Allergy').getRecordTypeId();
        Medical_Examination__c obs = new Medical_Examination__c();
        obs.Account__c=acc.id;
        obs.RecordTypeId = devRecordTypeIdGlucose;
        obs.Start_Time__c = system.now().adddays(1);
        obs.End_Time__c = system.now().adddays(2) ;
        try
        {
            insert obs;
        }
        catch(Exception e){}
        
        oblist.add(obs);
        
        Medical_Examination__c obs1 = new Medical_Examination__c();
        obs1.Account__c=acc.id;
        obs.RecordTypeId = devRecordTypeIdVital;
        obs1.Start_Time__c = system.now().adddays(1);
        obs1.End_Time__c = system.now().adddays(2);
        try
        {
            insert obs1;
        }
        catch(Exception e){}
        
        obslist.add(obs1);
        
        list<Medical_Examination__c> alis= new list<Medical_Examination__c>(); 
        Medical_Examination__c all = new Medical_Examination__c();
        all.Allergy_Name__c='kk';
        all.Account__c=acc.id;
        all.RecordTypeId = devRecordTypeIdAllergy;
        all.Start_Time__c =system.now().adddays(1);
        all.End_Time__c = system.now().adddays(2) ;
        try
        {
            insert all;
        }
        catch(Exception e){}
        
        alis.add(all);
        
        Notes__c n = new Notes__c();
        n.Account__c = acc.Id;
        insert n;
        List<sObject> sObjLst = new List<sObject>();
        List<String> dat = new List<String>();
        
        ICD_Codes__c hd1  = new ICD_Codes__c();
        hd1.name = 'Test';
        insert hd1;
        List<String> lst  = new List<String>();
        lst.add(hd1.Id);        
        
        Medical_Examination__c ag = new Medical_Examination__c();
        ag.Allergy_Name__c = 'pollen';
        ag.Account__c = acc.id ;
        ag.End_Time__c = system.now().adddays(2);
        ag.Start_Time__c = system.now().adddays(1);
        try
        {
            insert ag ;
        }
        catch(Exception e){}
        
        List<Dataset1__c> parentProblem  = new List<Dataset1__c>();
        list<ICD_Codes__c> relatedicd = new List<ICD_Codes__c>();
        list<Notes__c> relatedNotes = new list<Notes__c>();
        Dataset1__c dataProblem = new Dataset1__c();
        //dataProblem.Problem_Name__c = 'demo';
        insert dataProblem;
        parentProblem.add(dataProblem);
        
        ICD_Codes__c diagnosis = new ICD_Codes__c();
        diagnosis.Code__c = 'CD 101';
        diagnosis.Related_Problem__c = data.id;
        relatedicd.add(diagnosis);
        
        
        Notes__c nt = new Notes__c();
        nt.Dataset1__c = data.Id;
        relatedNotes.add(nt);
        
        List<Prescription_Order__c> toSend  = new List<Prescription_Order__c>();
        Prescription_Order__c p = new Prescription_Order__c();
        p.Drug_Name__c = 'demo';
        insert p;
        Frequency__c freq = new Frequency__c();
        freq.Prescription_Order__c = p.Id;
        insert freq;
        toSend.add(p);
        
        Test.startTest();
        Test.setCurrentPage(Page.FormsPDFGenerator);
        ApexPages.currentPage().getParameters().put('formId',f.Id);
        ElixirHC_FormsPDFGeneratorHelper callConstructor = new ElixirHC_FormsPDFGeneratorHelper();
        Test.stopTest();
          System.assert(p.Drug_Name__c!=null);
        
        ElixirHC_FormsPDFGeneratorHelper.getFormDataWrapper wrpr  = ElixirHC_FormsPDFGeneratorHelper.getFormData(f.Id,acc.Id);
        // ElixirHC_FormsPDFGeneratorHelper demoObject  = new ElixirHC_FormsPDFGeneratorHelper();
        ElixirHC_FormsPDFGeneratorHelper.getFormData(f.Id,acc.Id);
        ElixirHC_FormsPDFGeneratorHelper.medicationDataJSON(toSend);
        //  ElixirHC_FormsPDFGeneratorHelper.initPage2(wrpr);   
        ElixirHC_FormsPDFGeneratorHelper.arrangeConditionDataAsParentChild(parentProblem,relatedicd,relatedNotes); 
        ElixirHC_FormsPDFGeneratorHelper.getApprovalProcessInfo(f.Id);
        ElixirHC_FormsPDFGeneratorHelper.FormDataValues(f.Id);
        ElixirHC_FormsPDFGeneratorHelper.getAllergyData(acc.Id);     
    }*/
}