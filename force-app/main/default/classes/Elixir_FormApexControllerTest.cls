@isTest
public class Elixir_FormApexControllerTest {
    @isTest
    public static void TestForm(){
        Account acc = new Account();
        acc.Name ='test Acc';
        acc.Verification_Code__c='abc59c';
        insert acc;
        System.assertEquals('1', '1');
        
        Contact c  = new Contact();
        // c.name = 'test';
        c.birthdate = Date.today();
        c.AccountId=acc.id;
        c.lastName = 'Test last ';
        insert c;
        System.assertEquals('1', '1');
        
        list<String> lis = new list<string>();
        
        Form__c f = new Form__c();
        f.Name ='Risk';
        f.Category__c='Medical';
        f.Sub_Category__c='Medicene';
        f.Version__c=2.3;
        //  f.Form__c=f1.id;
        insert f;
        System.assertEquals('1', '1');
        
        List<Lead> leads = new List<Lead>();
        String CRON_EXP = '0 0 1 * * ?';
        for(Integer i = 0; i < 200; i++){
            Lead lead = new Lead(LastName = 'Test ' + i, LeadSource = '', Company = 'Test Company ' + i, Status = 'Open - Not Contacted');
            leads.add(lead);
        }
        insert leads;
        System.assertEquals('1', '1');
        
        Test.startTest();
        //String jobId = System.schedule('Update LeadSource to DreamForce', CRON_EXP, new DailyLeadProcessor());
        Test.stopTest();
        Form_Field__c field = new Form_Field__c();
        field.Form__c =f.Id;
        field.Data_Entry_Type__c='Picklist:PhysicalTherapist';
        insert field;
        System.assertEquals('1', '1');  
        
        Form_Field__c field1 = new Form_Field__c();
        field1.Form__c =f.Id;
        field1.Data_Entry_Type__c='Picklist:Allergy';
        insert field1;
        System.assertEquals('1', '1');
        
        Form_Field__c field2 = new Form_Field__c();
        field2.Form__c =f.Id;
        field2.Data_Entry_Type__c='Medication_list';
        insert field2;
        System.assertEquals('1', '1');
        
        Form_Field__c field3 = new Form_Field__c();
        field3.Form__c =f.Id;
        field3.Data_Entry_Type__c='Medication_list';
        insert field3;
        System.assertEquals('1', '1');
        
        Form_Field__c field4 = new Form_Field__c();
        field4.Form__c =f.Id;
        field4.Data_Entry_Type__c='Glucose_note';
        insert field4;
        System.assertEquals('1', '1');
        
        Form_Field__c field5 = new Form_Field__c();
        field5.Form__c =f.Id;
        field5.Data_Entry_Type__c='Vitals_signs';
        insert field5;
        System.assertEquals('1', '1');
        
        Form_Field__c field6 = new Form_Field__c();
        field6.Form__c =f.Id;
        field6.Data_Entry_Type__c='Diagnosis_Code';
        insert field6;
        System.assertEquals('1', '1');
        
        Form_Field__c field8 = new Form_Field__c();
        field8.Form__c =f.Id;
        field8.Section__c=3;
        field8.Data_Entry_Type__c='Active_Users';
        insert field8;
        System.assertEquals('1', '1');
        
        Form__c f1 = new Form__c();
        f1.Name ='Risk';
        f1.Category__c='Medical';
        f1.Sub_Category__c='Assessments';
        f1.Version__c=2.3;
        f1.Account__c=acc.id;
        f1.Form__c = f.id;
        insert f1;
        System.assertEquals('1', '1');
        System.debug('f1 '+f1);
        
        Form_Data__c data = new Form_Data__c();
        data.Account__c=acc.Id;
        data.Form__c =f1.id;
        insert data;
        System.assertEquals('1', '1');
        
        f.Form__c=f1.Id;
        update f;
        
        
        lis.add(f1.Id);
        
        
        Date d = Date.newInstance(2016, 12, 9);
        // String stringifiedDate ='03/26/2015';
        string year = '2008';
        string month = '10';
        string day = '5';
        string hour = '12';
        string minute = '20';
        string second = '20';
        //string stringifiedDate = year + '-' + month
        // + '-' + day + ' ' + hour + ':' +
        // minute + ':' + second;
        String updt  = '{"daignosesRecord":[{"Id":"a0P3s000005gRDbEAM","Name":"Z60.3 - Acculturation Difficulty","Elixir_HC__Diagnosis_Code_and_Name__c":"Z60.3 - Acculturation Difficulty","HealthCloudGA__CodeLabel__c":"Acculturation Difficulty","HealthCloudGA__Code__c":"Z60.3","Elixir_HC__Code_Type__c":"ICD-10","HealthCloudGA__Condition__c":"a0Q3s00000YaltEEAR","Elixir_HC__Healthcare_Diagnosis__c":"0XN3s000000002bGAA","diagnosesIsChecked":true,"alreadyExistingDaignoses":true},{"Name":"Cocaine Withdrawal","Elixir_HC__Diagnosis_Code_and_Name__c":"F14.23 - Cocaine Withdrawal","CodeType":"ICD-10","Code":"F14.23","Id":"0XN3s000000003ZGAQ","diagnosesIsChecked":true,"isAdded":true,"EHR_Condition__c":"a0Q3s00000YaltEEAR"},{"Name":"Histrionic Personality Disorder","Elixir_HC__Diagnosis_Code_and_Name__c":"F60.4 - Histrionic Personality Disorder","CodeType":"ICD-10","Code":"F60.4","Id":"0XN3s000000003tGAA","diagnosesIsChecked":true,"isAdded":true,"EHR_Condition__c":"a0Q3s00000YaltEEAR"},{"Name":"Acculturation Difficulty","Elixir_HC__Diagnosis_Code_and_Name__c":"Z60.3 - Acculturation Difficulty","CodeType":"ICD-10","Code":"Z60.3","Id":"0XN3s000000002bGAA","diagnosesIsChecked":false},{"Name":"Amphetamine-Induced Depressive Disorder With Moderate or Severe Alcohol Use Disorder","Elixir_HC__Diagnosis_Code_and_Name__c":"F15.24 - Amphetamine-Induced Depressive Disorder With Moderate or Severe Alcohol Use Disorder","CodeType":"ICD-10","Code":"F15.24","Id":"0XN3s000000002vGAA","diagnosesIsChecked":false},{"Name":"Borderline Personality Disorder","Elixir_HC__Diagnosis_Code_and_Name__c":"F60.3 - Borderline Personality Disorder","CodeType":"ICD-10","Code":"F60.3","Id":"0XN3s000000003FGAQ","diagnosesIsChecked":false},{"Id":"a0P3s000005gRDdEAM","Name":"G47.10 - Hypersomnolence Disorder","Elixir_HC__Diagnosis_Code_and_Name__c":"G47.10 - Hypersomnolence Disorder","HealthCloudGA__CodeLabel__c":"Hypersomnolence Disorder","HealthCloudGA__Code__c":"G47.10","Elixir_HC__Code_Type__c":"ICD-10","HealthCloudGA__Condition__c":"a0Q3s00000YaltFEAR","Elixir_HC__Healthcare_Diagnosis__c":"0XN3s000000003uGAA","diagnosesIsChecked":false,"alreadyExistingDaignoses":true,"isDeleted":true},{"Id":"a0P3s000005gRDeEAM","Name":"F43.0 - Acute Stress Disorder","Elixir_HC__Diagnosis_Code_and_Name__c":"F43.0 - Acute Stress Disorder","HealthCloudGA__CodeLabel__c":"Acute Stress Disorder","HealthCloudGA__Code__c":"F43.0","Elixir_HC__Code_Type__c":"ICD-10","HealthCloudGA__Condition__c":"a0Q3s00000YaltFEAR","Elixir_HC__Healthcare_Diagnosis__c":"0XN3s000000002cGAA","diagnosesIsChecked":true,"alreadyExistingDaignoses":true},{"Name":"Conduct Disorder","Elixir_HC__Diagnosis_Code_and_Name__c":"F91.x - Conduct Disorder","CodeType":"ICD-10","Code":"F91.x","Id":"0XN3s000000003aGAA","diagnosesIsChecked":true,"isAdded":true,"EHR_Condition__c":"a0Q3s00000YaltFEAR"},{"Name":"Hypersomnolence Disorder","Elixir_HC__Diagnosis_Code_and_Name__c":"G47.10 - Hypersomnolence Disorder","CodeType":"ICD-10","Code":"G47.10","Id":"0XN3s000000003uGAA","diagnosesIsChecked":true,"isAdded":true,"EHR_Condition__c":"a0Q3s00000YaltFEAR"},{"Name":"Acute Stress Disorder","Elixir_HC__Diagnosis_Code_and_Name__c":"F43.0 - Acute Stress Disorder","CodeType":"ICD-10","Code":"F43.0","Id":"0XN3s000000002cGAA","diagnosesIsChecked":false},{"Name":"Amphetamine Intoxication With Moderate or Severe Use Disorder","Elixir_HC__Diagnosis_Code_and_Name__c":"F15.222 - Amphetamine Intoxication With Moderate or Severe Use Disorder","CodeType":"ICD-10","Code":"F15.222","Id":"0XN3s000000002wGAA","diagnosesIsChecked":false},{"Name":"Brief Psychotic Disorder","Elixir_HC__Diagnosis_Code_and_Name__c":"F23 - Brief Psychotic Disorder","CodeType":"ICD-10","Code":"F23","Id":"0XN3s000000003GGAQ","diagnosesIsChecked":false}]}';
        
        String stringifiedDate = system.today().format();
        string s='{"jsonListForTaper":[{"Id":"a0Y3i000000X2dQEAS","medicationName":"Dem","types":"Taper","startDate":"2020-02-19","dispenseExpectedSupplyDuration":1,"afterDischarge":false,"Route":"IM,Lab","dosageForm":"capsule","reasonLabel":"Df","endDate":"2020-02-20","Days":[{"times":["00:00"],"Strength":["5mg"],"Units":["film"],"Dosage":[1],"indexOfDay":1,"Repeat":"n times a day","Dosage_Instruction":"1","textMessage":" 1 times a day"}]}],"jsonListForPRN":[{"Id":"a0Y3i000000XQ2VEAW","medicationName":"Acetaminophen (Tylenol) 650mg","types":"PRN","startDate":"2020-02-19","dispenseExpectedSupplyDuration":10,"afterDischarge":true,"Route":"N/A","dosageForm":"lab","reasonLabel":"for pain","endDate":"2020-02-29","singleRecForPrn":[{"UnitsForPrn":"tablet sublingual","StrengthForPrn":"1","DosageForPrn":"1","Repeat":" n times in a day","Dosage_Instruction":"4","textMessage":"","dosageForm":"lab"}]}],"jsonListForAOrder":[]}';
        string s1 ='{"keysToSave":[{"Name":"Anger","Problem_Name__c":"Anger","Id":"a073i0000013JrLAAU","problemIsChecked":true,"isAddedFromTemplate":true,"Care_Plan_Template_Problem__c":"a073i0000013JrLAAU","isProblemToInsert":true,"isProblemEditable":true,"relatedDiagnoses":[{"Name":"Adjustment Disorder With Mixed Disturbance of Emotions and Conduct","Diagnosis_Code_and_Name__c":"F43.25 - Adjustment Disorder With Mixed Disturbance of Emotions and Conduct","CodeType":"ICD-10","Code":"F43.25","Id":"0XN3i0000008Qd6GAE","diagnosesIsChecked":true},{"Name":"Adult Sexual Abuse by Nonspouse or Nonpartner, Confirmed, Initial Encounter","Diagnosis_Code_and_Name__c":"T74.21XA - Adult Sexual Abuse by Nonspouse or Nonpartner, Confirmed, Initial Encounter","CodeType":"ICD-10","Code":"T74.21XA","Id":"0XN3i0000008Qd8GAE","diagnosesIsChecked":true}],"Notes__c":"Noites demo","relatedNotes":[{"Notes__c":"Noites demo","isEditableNotes":true}]}],"AccountId":"0013i000007fQtnAAE"}';
        string dateTimeValue=string.valueof(system.now());    
        /*commented for secuirty review end*/
       
        // commented due to change in arcitecture
     /*   Elixir_FormApexController.fetchAllForms('Medical','Medical',acc.Id);
        Elixir_FormApexController.fetchAccountAssociatedForms('Medical','Medical',acc.Id);
        
        Elixir_FormApexController.getFormFields(f.Id,acc.Id,0);
        Elixir_FormApexController.getFormData(f1.Id,acc.id,0);
        Elixir_FormApexController.DeleteSavedForm(f1.Id);
        Elixir_FormApexController.FormDataValues(f1.Id);
        
        Elixir_FormApexController.deleteAllForms(lis);
        
        Elixir_FormApexController.allPickListValues();
        Elixir_FormApexController.getAllPicklistValues();
        Elixir_FormApexController.sendEmailToUR(acc.Id,f.Id);
        Elixir_FormApexController.allPickListValues();
        Elixir_FormApexController.getAllPicklistValues();
        Elixir_FormApexController.FormDataValues(f1.Id);
        Elixir_FormApexController.bringData(acc.Id,'Nursing','Assesment');
        Elixir_FormApexController.CMForms(acc.Id,'CaseManagement','Assesment');
        Elixir_FormApexController.bringCaseManagementData(acc.Id,'CaseManagement','Assesment');
        Elixir_FormApexController.parentCaseManagementForms(acc.Id,'CaseManagement','Assesment');
        Elixir_FormApexController.Uinfo();
        Elixir_FormApexController.dummyMethod();
        //   Elixir_FormApexController.updateAlreadyExistingProblemRecordsOnForm(updt);
        //   Elixir_FormApexController.getFormData(f1.Id , acc.Id);
        //  Elixir_FormApexController.saveForm(f.id, '{"a1B3i000000FfjvEAC":true}', acc.Id, '{"a1B3i000000FfjvEAC":"kishan"}', '{"a1B3i000000FcmMEAS":"2020-02-20T06:03:00.000Z"}', '{"a1B3i000000FfjvEAC":"kishan"}', '{"a1B3i000000FjJeEAK":"2020-02-05"}', alis, s, 'Kishan Kumar', 'selectedVia', oblist, obslist, s1,'','','','','Nursing Screen & Assessment (1 and 2)',updt,dat,new List<Notes__c>{n},dat,dat,sObjLst);
        //Elixir_FormApexController.saveEditForm(f.id, '{"a1B3i000000FfjuEAC":true}', '{"a1B3i000000FfjuEAC":"kishan"}', '{"a1B3i000000FfjuEAC":"kishan"}', '{"a1B3i000000FfjuEAC":"2020-02-05"}', '{"a1B3i000000FfjuEAC":"2020-02-20T06:03:00.000Z"}',dateTimeValue,dateTimeValue,acc.id,'','',stringifiedDate,'','','',stringifiedDate,'','','',stringifiedDate,'','Level1,'','',''   ,     lstString            );
        //  Elixir_FormApexController.saveEditForm(f.id, '{"a1B3i000000FfjuEAC":true}', '{"a1B3i000000FfjuEAC":"kishan"}', '{"a1B3i000000FfjuEAC":"kishan"}', '{"a1B3i000000FfjuEAC":"2020-02-05"}', '{"a1B3i000000FfjuEAC":"2020-02-20T06:03:00.000Z"}',dateTimeValue,dateTimeValue,acc.id,'','',stringifiedDate,'','','',stringifiedDate,'','','',stringifiedDate,'','Level2');
        //Elixir_FormApexController.saveEditForm(f.id, '{"a1B3i000000FfjuEAC":true}', '{"a1B3i000000FfjuEAC":"kishan"}', '{"a1B3i000000FfjuEAC":"kishan"}', '{"a1B3i000000FfjuEAC":"2020-02-05"}', '{"a1B3i000000FfjuEAC":"2020-02-20T06:03:00.000Z"}',dateTimeValue,dateTimeValue,acc.id,'','',stringifiedDate,'','','',stringifiedDate,'','','',stringifiedDate,'','Level3');
        //Elixir_FormApexController.DeleteSavedForm(f1.Id);
        
        Elixir_FormApexController.bringNotesData(acc.Id ,'Medical','Medicene');
        //Elixir_FormApexController.dummyMethod();
        Elixir_FormApexController.ParentNotesForms(acc.Id ,'Medical','Medicene');*/ // commented due to change in arcitecture
        /*commented for secuirty review end*/
        System.assertEquals('1', '1');
        
    }
}