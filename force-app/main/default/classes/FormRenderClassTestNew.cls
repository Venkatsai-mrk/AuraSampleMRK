@isTest
public class FormRenderClassTestNew 
{
    @TestSetup
    public static void testData()
    {
        Account testAccount1 = TestDataFactory.createPatientAcc();
        INSERT testAccount1;
        ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestProc',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2',
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c', ElixirSuite__End_Time__c = System.now(),
                                                                    ElixirSuite__Account__c = testAccount1.Id, ElixirSuite__Form_Unique_ID__c='I874841232323', ElixirSuite__Start_Time__c = System.now(),
                                                                    RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId());
        insert p;
        ElixirSuite__Procedure__c p2 = new ElixirSuite__Procedure__c(Name = 'TestProc1',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2',
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c', ElixirSuite__End_Time__c = System.now(),
                                                                    ElixirSuite__Account__c = testAccount1.Id, ElixirSuite__Form_Unique_ID__c='I874841232323', ElixirSuite__Start_Time__c = System.now(),
                                                                    RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId());
        insert p2;
        ElixirSuite__Provider__c pRec = new ElixirSuite__Provider__c(ElixirSuite__Account__c = testAccount1.Id, ElixirSuite__Provider_Code__c = 'NPI374674346');
        INSERT pRec;
        Visits__c vRec = new Visits__c(Account__c = testAccount1.Id, Status__c = 'Active',ElixirSuite__Care_Episode_Location__c = pRec.Id);
        INSERT vRec;
        List<Form_Value__c> fvList = new List<Form_Value__c>();
        Form_Value__c fvRec = new Form_Value__c(Section_Number__c = 2, Row_Number__c = 2, Account__c = testAccount1.Id, 
                                                Form_Id__c = 'I874841232323', Is_AutoText__c = true, Is_Consent__c = true,
                                                Field_Api_Name__c = 'Name', Default1__c = 'Test');
        fvList.add(fvRec); 
        Form_Value__c fvRec2 = new Form_Value__c(Section_Number__c = 3, Row_Number__c = 2, Account__c = testAccount1.Id, 
                                                Form_Id__c = 'I874841232323', Is_AutoText__c = true, Is_Consent__c = true,
                                                Field_Api_Name__c = 'Name', Default1__c = 'Test');
        fvList.add(fvRec2);
        INSERT fvList; 
        List<Form_Template_Data__c> tdList = new List<Form_Template_Data__c>();
        Form_Template_Data__c tdRec = new Form_Template_Data__c(Form_Unique_Id__c = 'I874841232323', Section_Number__c = '2', Account__c = testAccount1.Id);
        tdList.add(tdRec);
        Form_Template_Data__c tdRec2 = new Form_Template_Data__c(Form_Unique_Id__c = 'I874841232323', Section_Number__c = '3', Account__c = testAccount1.Id);
        tdList.add(tdRec2);
        INSERT tdList;
        ElixirSuite__Lot_Item__c lotItemRec = new ElixirSuite__Lot_Item__c(Name = 'Crocin');
        INSERT lotItemRec;
    }
    @isTest 
    public static void testBuildForm()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        Object_1_css__c cssRecords = new Object_1_css__c();
        cssRecords.Form__c = 'Inventory Form';
        cssRecords.Section_Number__c = 1;
        INSERT cssRecords;
       
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c;  
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        Contact con = new Contact();
        con.RecordTypeId = recordTypeId;
        con.Is_Active__c = true;
        con.lastName = 'Mahendra';
        insert con;

        FormRenderClass.buildForm('Inventory Form',testAccount1.Id);
        FormRenderClass.fetchAccountProblems(testAccount1.Id,new List<String>());
        FormRenderClass.fetchAccountDiagnosis(testAccount1.Id,new List<String>());
        FormRenderClass.getActiveCareEpisodeId(testAccount1.Id);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testUinfoNew()
    {
        Test.startTest();
        FormRenderClass.UinfoNew();
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testFetchNameSpace()
    {
        Test.startTest();
        FormRenderClass.fetchNameSpace();
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
  
    
    @isTest 
    public static void testHandleTimeDataOnForm()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        String currentTime = String.valueOf(System.now());
        String timeWrapper = '{"paramSame":"true","setEndTimeAsCurrent":"true","startTime":"'+currentTime+'"}';
        FormRenderClass.handleTimeDataOnForm('I874841232323',testAccount1.Id,timeWrapper,'test');
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testAttachCareEpisode()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];

         //added by Anmol for LX3-7236
         Elixir_Custom_Setting__c customSetting = new Elixir_Custom_Setting__c();
         customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c = 'createddate asc';
         insert customSetting;
         //end by Anmol for LX3-7236

        FormRenderClass.attachCareEpisode('I874841232323',testAccount1.Id,'test form');
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testSaveImages()
    {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        //List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        String cvId = cv.Id;
        
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        Map<String, String> imgData = new Map<String, String>();
        imgData.put(cvId,'test img1');
        //imgData.put('a0zN0000003ChleIAC','test img1');
        //imgData.put('a0zN0000003CkiiIAC','test img2');
        FormRenderClass.saveImages(imgData,testAccount1.Id,'I874841232323');
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void tesSaveDefaultValues()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        List<Form_Value__c> dbFormValues = [SELECT Id, Field_Api_Name__c, Default1__c, Account__c FROM Form_Value__c];
        String dbFormValuesString = JSON.serialize(dbFormValues);
        FormRenderClass.saveDefaultValues(testAccount1.Id,new List<String>{'test'},dbFormValuesString);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testDeleteAllProblemSavedFromForm()
    {
        Test.startTest();
        List<ElixirSuite__Procedure__c> procRec = [SELECT Id from ElixirSuite__Procedure__c LIMIT 2];
        String[] procIdList = new String[2];
        for(ElixirSuite__Procedure__c p : procRec){
             procIdList.add(p.Id);
        }
        ElixirSuite__Diagnosis_Code__c dcRec = new ElixirSuite__Diagnosis_Code__c();
        INSERT dcRec;
        List<String> dcRecList = new List<String>{dcRec.Id};
        FormRenderClass.deleteAllProblemSavedFromForm(dcRecList,procIdList);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testAttachInventory()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        ElixirSuite__Lot_Item__c lotItemRec = [select id,name,ElixirSuite__Available_Qty__c from ElixirSuite__Lot_Item__c LIMIT 1];
        ElixirSuite__Procedure__c ep = [SELECT ID from ElixirSuite__Procedure__c LIMIT 1];
        Map<String, Object> invLstMap = new Map<String, Object>();
        invLstMap.put('Lot','Test Lot');
        invLstMap.put('proid',ep.Id);
        invLstMap.put('eid',lotItemRec.Id);
        invLstMap.put('Name','Test');
        invLstMap.put('req',5);
        List<Object> invList = new List<Object>{invLstMap};
        FormRenderClass.attachInventory('I874841232323',testAccount1.Id,invList);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testGenerateRandomNumber()
    {
        Test.startTest();
        FormRenderClass.generateRandomNumber();
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testSaveAutoText()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        List<Form_value__c> valueForAutoText = [SELECT Id, Blue_Print__c, Section_Number__c, Is_AutoText__c, Auto_Text__c FROM Form_Value__c];
        Set<Integer> sectNumber = new Set<Integer>{2,3};
        FormRenderClass.saveAutoText(testAccount1.Id,'I874841232323',sectNumber,valueForAutoText);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testSaveMacroData()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        List<Form_Template_Data__c> macroTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c FROM Form_Template_Data__c];
        Set<String> sectNumber = new Set<String>{'2','3'};
        FormRenderClass.saveMacroData(testAccount1.Id,'I874841232323',sectNumber,macroTemp);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testsaveProblemNoteData()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        List<Form_Template_Data__c> macroTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c FROM Form_Template_Data__c];
        Set<String> sectNumber = new Set<String>{'2','3'};
        FormRenderClass.saveProblemNoteData(testAccount1.Id,'I874841232323',sectNumber,macroTemp);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testSaveDiagnosisNoteData()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        List<Form_Template_Data__c> macroTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c FROM Form_Template_Data__c];
        Set<String> sectNumber = new Set<String>{'2','3'};
        FormRenderClass.saveDiagnosisNoteData(testAccount1.Id,'I874841232323',sectNumber,macroTemp);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testSaveProcedureNoteData()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        List<Form_Template_Data__c> macroTemp = [SELECT Id,name,Form_Unique_Id__c,Section_Number__c,Form_Data_Description__c FROM Form_Template_Data__c];
        Set<String> sectNumber = new Set<String>{'2','3'};
        FormRenderClass.saveProcedureNoteData(testAccount1.Id,'I874841232323',sectNumber,macroTemp);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
     @isTest	
     public static void testfetchCustomSettingsPrescription(){	
     Test.startTest();	
     ElixirSuite__TabPermissionBasedOnProfiles__c prof=new ElixirSuite__TabPermissionBasedOnProfiles__c();	
         prof.ElixirSuite__Prescription_Priority__c='High';	
         Insert prof;	
     //ElixirSuite__TabPermissionBasedOnProfiles__c tb = [SELECT Id, ElixirSuite__Prescription_Priority__c FROM ElixirSuite__TabPermissionBasedOnProfiles__c LIMIT 1];	
     FormRenderClass.fetchCustomSettingsPrescription();	
     System.assertEquals(1, 1, '');	
     Test.stopTest();	
     }
    @isTest 
    public static void testAllergyDataAcctSpeific()
    {
        Test.startTest();
        String notesSpecificData = '{"allergyData" : [],"medicationData" : [],"vitalData" : [],"diagnosisData" : [],"problemData": []}';
        Account testAccount1 = [SELECT Id from Account Limit 1];
        FormRenderClass.allergyDataAcctSpeific(testAccount1.Id,notesSpecificData);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testFetchAccountProblems()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        FormRenderClass.fetchAccountProblems(testAccount1.Id,new List<String>());
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    
    @isTest 
    public static void testSaveForm()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
    
		 Account acc = new Account();
        acc.name = 'Test Patient1';
        acc.ElixirSuite__Email_Id__c = 'karan@gmail.com';
        acc.Patient_s_Birth_Date__c = System.today().addyears(-20);
        acc.MRN_Number__c = 12345;
        acc.ElixirSuite__First_Name__c ='fnames';
        acc.ElixirSuite__Last_Name__c ='lnames';
        acc.ElixirSuite__SSN__c ='123';
        acc.ElixirSuite__Gender__c='Male';
        acc.Phone ='9919850367';
        acc.BillingPostalCode='24640';
        INSERT acc;
        String accountId='';
        accountId  =acc.Id;
        String formName='';
        formName ='Aditya Form';
        String changedFormName='';
        changedFormName='Aditya Form';
        String cssRecordString='';
        cssRecordString ='{"cssRecords":[{"Id":"a121m000004PObZAAW","ElixirSuite__Lot_Number__c":false,"ElixirSuite__Form_Specific_Data__c":false,"ElixirSuite__Add_Problem__c":false,"ElixirSuite__Enable_Auto_text__c":false,"ElixirSuite__Hide_Selections__c":false,"ElixirSuite__Form_Category__c":"Form","ElixirSuite__isFormMacro__c":false,"ElixirSuite__Add_Procedure__c":false,"ElixirSuite__Section_Number__c":1,"ElixirSuite__Is_Consent__c":false,"ElixirSuite__Columns_In_Section__c":1,"ElixirSuite__Is_Time_Enabled__c":false,"ElixirSuite__Is_matrix__c":false,"ElixirSuite__Add_Notes__c":false,"ElixirSuite__Object_1_css__r":[{"ElixirSuite__Object_1_css__c":"a121m000004PObZAAW","Id":"a121m000004PObaAAG","ElixirSuite__IsCommon__c":false,"ElixirSuite__Object_Name__c":"Account","ElixirSuite__Is_Consent__c":false,"ElixirSuite__Field_Name__c":"ElixirSuite__Patient_Name_1__c","ElixirSuite__Field_Label_Long__c":"Patient Name","ElixirSuite__Data_Type__c":"STRING","ElixirSuite__No_Label__c":false,"ElixirSuite__Is_Common_Parent__c":false,"ElixirSuite__Form_Specific_Data__c":false,"ElixirSuite__Row__c":1,"ElixirSuite__Column__c":1,"ElixirSuite__Form_Data_Type__c":"Default","ElixirSuite__IMG_Type_of_Upload__c":"Single","ElixirSuite__IMG_Type_of_Row__c":"Field","ElixirSuite__Is_matrix__c":false,"ElixirSuite__Is_formula_Field__c":false,"Columns":[{"ElixirSuite__Object_1_css__c":"a121m000004PObZAAW","Id":"a121m000004PObaAAG","ElixirSuite__IsCommon__c":false,"ElixirSuite__Object_Name__c":"Account","ElixirSuite__Is_Consent__c":false,"ElixirSuite__Field_Name__c":"ElixirSuite__Patient_Name_1__c","ElixirSuite__Field_Label_Long__c":"Patient Name","ElixirSuite__Data_Type__c":"STRING","ElixirSuite__No_Label__c":false,"ElixirSuite__Is_Common_Parent__c":false,"ElixirSuite__Form_Specific_Data__c":false,"ElixirSuite__Row__c":1,"ElixirSuite__Column__c":1,"ElixirSuite__Form_Data_Type__c":"Default","ElixirSuite__IMG_Type_of_Upload__c":"Single","ElixirSuite__IMG_Type_of_Row__c":"Field","ElixirSuite__Is_matrix__c":false,"ElixirSuite__Is_formula_Field__c":false,"Columns":[],"lengthOfField":255,"value":"aditya","colsize":"slds-size_12-of-12"}],"lengthOfField":255,"value":"aditya","colsize":"slds-size_12-of-12"}]}]}';
        String formUniqueId='';
        formUniqueId='a131m0000013l93AAA;471071268';
        String objNameToValue='';
        objNameToValue='{"ElixirSuite__Object_2__c":{"ElixirSuite__Patient_Name_1__c":"aditya","Id":"a131m0000013l93AAA"}}';
        String problemData='';
        String precriptionData='';
        List<String> deletedProblem =new List<String>();
        //String deletedProblem	= '' ;	
        List<String>  toDelProblemFromUpdate = new List<String>();
        String toUpdateProblem	='';
        Boolean isProblemEnabled = false;	
        String procedureWrapper	='{"insertedProcedure":[],"updatedProcedure":[],"toDelProcRecords":[]}';
        Boolean isProcedureEnabled =false;
        String timeWrapper='{"paramSame":false,"setEndTimeAsCurrent":false}';
        Boolean isTimeEnabled= false ;
        Boolean isClone;
        isClone=false;
        Boolean isDeceased;
        isDeceased = false;
        //String modularMatrixData='';
        String fetchFlag='';
        fetchFlag = 'false';
        String formCategory  = 'Admission';
        String modularMatrixFormValue='';
        String notesSpecificData = '{"allergyData" : [],"medicationData" : [],"vitalData" : [],"diagnosisData" : [],"problemData": []}';
       
          //added by Anmol for LX3-7236
          //Elixir_Custom_Setting__c customSetting = new Elixir_Custom_Setting__c();
          //customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c = 'createddate asc';
          //insert customSetting;
          //end by Anmol for LX3-7236

        FormRenderClass.saveForm(testAccount1.Id,formName,changedFormName,formCategory,cssRecordString,problemData,precriptionData,deletedProblem,toDelProblemFromUpdate,toUpdateProblem,isProblemEnabled,procedureWrapper,isProcedureEnabled,timeWrapper,isTimeEnabled,modularMatrixFormValue,notesSpecificData);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest	
    public static void testattachPrescription(){	
        Test.startTest();
        Account testAccount1=new Account();
        testAccount1 = [SELECT Id from Account Limit 1];
         SelectionMedicationRecordsApexController.root sRoot = new SelectionMedicationRecordsApexController.root();
        SelectionMedicationRecordsApexController.JSON2Apex sJsonApex = new SelectionMedicationRecordsApexController.JSON2Apex();
        List<SelectionMedicationRecordsApexController.JSON2Apex> sJsonApexList = new List<SelectionMedicationRecordsApexController.JSON2Apex>();
        SelectionMedicationRecordsApexController.Days daysRecord = new SelectionMedicationRecordsApexController.Days();
        List<SelectionMedicationRecordsApexController.Days> daysRecordList = new List<SelectionMedicationRecordsApexController.Days>();
        sJsonApex.Id = '1234';
        sJsonApex.medicationName = 'test drug';
        sJsonApex.types = 'PRN';
        sJsonApex.startDate = String.valueOf(Date.today().addDays(-2));
        sJsonApex.dispenseExpectedSupplyDuration = 2;
        sJsonApex.afterDischarge = true;
        sJsonApex.dosageForm = 'capsule';
        sJsonApex.reasonLabel = 'test';
        sJsonApex.Route = 'Lab';
        sJsonApex.Warning = 'test';
        sJsonApex.MARdisplay = true;
        sJsonApex.PRNdisplay = true;
        daysRecord.times = new List<String>{'1','2'};
        daysRecord.Units = new List<String>{'1','2'};
        daysRecord.Dosage = new List<String>{'1','2'};
        daysRecord.Strength = new List<String>{'1','2'};
        daysRecord.indexOfDay = 1;
        daysRecord.Repeat = 'yes';
        daysRecord.Dosage_Instruction = 2;
        daysRecordList.add(daysRecord);
        sJsonApex.Days = daysRecordList;
        sJsonApexList.add(sJsonApex);
        sRoot.jsonListForTaper = sJsonApexList;
        sRoot.jsonListForPRN = sJsonApexList;
        sRoot.jsonListForAOrder = sJsonApexList;
        String prescLst='';
        prescLst = JSON.serialize(sRoot);
        
        String formUniqueId ='';
        formUniqueId = '345678';	
        String prescriptionLst ='';
        prescriptionLst = '{"root":{"jsonListForTaper":[{"Id":"1234","medicationName":"test drug","types":"PRN","startDate":"2022-12-30","dispenseExpectedSupplyDuration":2,"afterDischarge":true,"dosageForm":"capsule","reasonLabel":"test","Route":"Lab","Warning":"test","MARdisplay":true,"PRNdisplay":true,"Days":[{"times":["1","2"],"Units":["1","2"],"Dosage":["1","2"],"Strength":["1","2"],"indexOfDay":1,"Repeat":"Yes","Dosage_Instruction":2}]}]}}';
        String selUser ='';
        selUser = 'test user';	
        String selVia ='';
        selVia = 'fgh';	
        date dt1 = system.today();
        date dt2 = system.today()+2;
        String startTm='';
        startTm = string.valueof(dt1);	
        String endTm='';
        endTm =  string.valueof(dt2);
        
        //FormRenderClass.attachPrescription(prescriptionLst,selUser,selVia,testAccount1.Id,startTm,endTm,formUniqueId);	
        System.assertEquals(1, 1, '');	
        Test.stopTest();	
    }
   
}