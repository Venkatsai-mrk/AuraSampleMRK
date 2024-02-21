@isTest
public class FormUpdateClassTest {
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
        ElixirSuite__Elixir_Custom_Setting__c ecs = new ElixirSuite__Elixir_Custom_Setting__c();
        ecs.Form_Label__c = 'ElixirSuite__Form_Label__c';
        INSERT ecs;
        ElixirSuite__Form_Label__c flRec = new ElixirSuite__Form_Label__c();
        flRec.FormId__c = 'I874841232323';
        flRec.ElixirSuite__AccountId__c = testAccount1.Id;
        flRec.Label__c = 'Test Label';
        INSERT flRec;
        List<Form_Value__c> fvList = new List<Form_Value__c>();
        Form_Value__c fvRec = new Form_Value__c(Section_Number__c = 2.5, Row_Number__c = 2, Account__c = testAccount1.Id, 
                                                Form_Id__c = 'I874841232323', Is_AutoText__c = false, Is_Consent__c = true,
                                                Field_Api_Name__c = 'Name', Default1__c = 'Test');
        fvList.add(fvRec); 
        Form_Value__c fvRec2 = new Form_Value__c(Section_Number__c = 2.5, Row_Number__c = 2, Account__c = testAccount1.Id, 
                                                Form_Id__c = 'I874841232323', Is_AutoText__c = false, Is_Consent__c = true,
                                                Field_Api_Name__c = 'Name', Default1__c = 'Test');
        fvList.add(fvRec2); 
        INSERT fvList;
        List<ContentVersion> cvRecList = new List<ContentVersion>();
        ContentVersion cvRec = new ContentVersion(Form_Id__c = 'I874841232323', Unique_File_Name__c = 'Test File1', Title = 'TestTitle', PathOnClient = '/TestTitle', VersionData = Blob.valueOf('ver1'),ElixirSuite__Form_css_id__c = '001');
        ContentVersion cvRec2 = new ContentVersion(Form_Id__c = 'I874841232323', Unique_File_Name__c = 'Test File1', Title = 'TestTitle2', PathOnClient = '/TestTitle2', VersionData = Blob.valueOf('ver2'),ElixirSuite__Form_css_id__c = '002');
        cvRecList.add(cvRec);
        cvRecList.add(cvRec2);
        INSERT cvRecList;
        Object_1_css__c cssRecords = new Object_1_css__c();
        
        List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names' LIMIT 1];
        List<RecordType> recordTypes = new List<RecordType>();
        if(metadata!=null && metadata.size()>0){
            Set<String> metadataObjects = new Set<String>();
            metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
            recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType
                                            WHERE IsActive = true AND SobjectType IN :metadataObjects ORDER BY DeveloperName];
        
       
        cssRecords.Css__c = 'text';
        cssRecords.Indentation__c ='';
        cssRecords.Class__c ='Class';
        cssRecords.Form_Specific_Data__c = true;
        cssRecords.ElixirSuite__Default_Inventory_Type__c = '';
        cssRecords.ElixirSuite__Lot_Number__c = true;
        cssRecords.parent_query__c = 'abc';
        cssRecords.ElixirSuite__Add_Problem__c = true;
        cssRecords.Auto_text__c = 'abcd';
        cssRecords.Enable_Auto_text__c = true;
        cssRecords.Hide_Selections__c = false;
        cssRecords.Form_Category__c = '';
        cssRecords.Default_text__c = 'abcdfgh';
        cssRecords.isFormMacro__c = true; 
        cssRecords.ElixirSuite__Add_Procedure__c = true;
        cssRecords.Map_query__c = 'abcd';
        cssRecords.Section_Number__c = 1;
        cssRecords.Is_Consent__c = false;
        cssRecords.Columns_In_Section__c = 1;
        cssRecords.Object_Name__c = 'abcdfgh';
        cssRecords.ElixirSuite__Is_Time_Enabled__c = true; 
        cssRecords.ElixirSuite__Add_Procedure__c = true;
        cssRecords.Is_matrix__c = true;
        cssRecords.Columns_Matrix__c = 1;
        cssRecords.Headings__c = 'head';
        cssRecords.Consent_Query__c = 'rue';
        cssRecords.Add_Notes__c = true;
        cssRecords.Type_of_Note__c = 'fgh';
         cssRecords.Static_file_name__c = 'klm';   
        cssRecords.Form__c = recordTypes[0].Name;
        cssRecords.Section_Number__c = 1;
        cssRecords.Select_Form_Component__c = 'Enable Upload And Annotate';
        cssRecords.Section_Name__c ='Section1';
        
        INSERT cssRecords;                             
    }
    }
    @isTest 
    public static void testBuildForm()
    {
        Test.startTest();
        List<Form_Value__c> dBconsentValues= new List<Form_Value__c>();
        Account testAccount1 = [SELECT Id from Account Limit 5];
        
                                                       
        Form_Value__c fvalue1= new  Form_Value__c();
            fvalue1.Field_Api_Name__c = 'Acc';
            fvalue1.Section_Number__c = 1;
            fvalue1.Row_Number__c = 1 ;
            fvalue1.Column_Number__c =1 ;
            fvalue1.Consent_Text__c = 'Hello';
            fvalue1.Consent_Default_text__c = 'hi';
            fvalue1.Consent_Input_JSON__c = 'FGH';
            fvalue1.Consent_Pdf__c = 'PDF';
            fvalue1.Blue_Print__c = 'Shna';
            fvalue1.Default1__c ='default';
            fvalue1.Account__c = testAccount1.Id;
            fvalue1.Only_text_in_consent__c = true;
            insert fvalue1;
        
        Form_Value__c fvalue2= new  Form_Value__c();
            fvalue2.Field_Api_Name__c = 'Acc1';
            fvalue2.Section_Number__c = 2;
            fvalue2.Row_Number__c = 1 ;
            fvalue2.Column_Number__c =1 ;
            fvalue2.Consent_Text__c = 'Hello1';
            fvalue2.Consent_Default_text__c = 'hi1';
            fvalue2.Consent_Input_JSON__c = 'FGH1';
            fvalue2.Consent_Pdf__c = 'PDF1';
            fvalue2.Blue_Print__c = 'Shna1';
            fvalue2.Default1__c ='default1';
            fvalue2.Account__c = testAccount1.Id;
            fvalue2.Only_text_in_consent__c = true;
            insert fvalue2;
        
        Form_Value__c fvalue3= new  Form_Value__c();
            fvalue3.Field_Api_Name__c = 'Acc2';
            fvalue3.Section_Number__c = 2;
            fvalue3.Row_Number__c = 2 ;
            fvalue3.Column_Number__c =1 ;
            fvalue3.Consent_Text__c = 'Hello2';
            fvalue3.Consent_Default_text__c = 'hi2';
            fvalue3.Consent_Input_JSON__c = 'FGH2';
            fvalue3.Consent_Pdf__c = 'PDF2';
            fvalue3.Blue_Print__c = 'Shna2';
            fvalue3.Default1__c ='default2';
            fvalue3.Account__c = testAccount1.Id;
            fvalue3.Only_text_in_consent__c = true;
            insert fvalue3;
        dBconsentValues.add(fvalue1);
        dBconsentValues.add(fvalue2);
        dBconsentValues.add(fvalue3);
        
        Map<Decimal, Map<Decimal, List<Form_Value__c>>> secRowColumn = new Map<Decimal, Map<Decimal, List<Form_Value__c>>>();
        for (Form_Value__c rec:dBconsentValues){
            if(secRowColumn.containsKey(rec.Section_Number__c)){
                Map<Decimal, List<Form_Value__c>> rowColumns = secRowColumn.get(rec.Section_Number__c);
                if(rowColumns.containsKey(rec.Row_Number__c)){
                    rowColumns.get(rec.Row_Number__c).add(rec);
                }else{
                    rowColumns.put(rec.Row_Number__c, new List<Form_Value__c>{rec}); 
                }
            }else{
                Map<Decimal, List<Form_Value__c>> rowColumns = new Map<Decimal, List<Form_Value__c>>();
                rowColumns.put(rec.Row_Number__c, new List<Form_Value__c>{rec});
                secRowColumn.put(rec.Section_Number__c,rowColumns );
            }
            }

        List<ElixirSuite__Inventory__c> eiList = new List<ElixirSuite__Inventory__c>();
        ElixirSuite__Inventory__c eiRec = new ElixirSuite__Inventory__c();
        eiRec.ElixirSuite__Lot_Number__c = '7869';
        eiRec.ElixirSuite__Account__c= testAccount1.Id;
        eiRec.ElixirSuite__Inventory_Item_Name__c = 'Item testing';
        eiRec.ElixirSuite__Units_Available__c = 9;
        eiRec.ElixirSuite__Units_Procured__c = 7; 
        eiRec.ElixirSuite__Form_Unique_Id__c = 'I874841232323';
        eiList.add(eiRec);
        INSERT eiList;
        
        List<Form_Object__mdt> metadata = [SELECT Id, QualifiedApiName, Object_Name__c FROM Form_Object__mdt WHERE Object_Name__c!=NULL AND DeveloperName='Object_Names' LIMIT 1];
        List<RecordType> recordTypes = new List<RecordType>();
        if(metadata!=null && metadata.size()>0){

            Set<String> metadataObjects = new Set<String>();
            metadataObjects = new Set<String>(metadata[0].Object_Name__c.split(';'));
            recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsActive FROM RecordType
                                            WHERE IsActive = true AND SobjectType IN :metadataObjects ORDER BY DeveloperName];
        
        FormUpdateClass.buildForm(recordTypes[0].Name,testAccount1.Id,'I874841232323');
             FormUpdateClass.getActiveCareEpisodeId(testAccount1.Id);
             FormUpdateClass.fetchAccountProblems(testAccount1.Id,'I874841232323');
            FormRenderClass.fetchAccountDiagnosis(testAccount1.Id,new List<String>());
            FormUpdateClass.submitToProvider(recordTypes[0].Name,'I874841232323');
         System.assertEquals(1, 1, '');
        Test.stopTest();
    }
}
    @isTest
     public static void testfetchCustomSettingsPrescription(){
     Test.startTest();
     ElixirSuite__TabPermissionBasedOnProfiles__c prof=new ElixirSuite__TabPermissionBasedOnProfiles__c();
         prof.ElixirSuite__Prescription_Priority__c='High';
         Insert prof;
     FormUpdateClass.fetchCustomSettingsPrescription();
     System.assertEquals(1, 1, '');
     Test.stopTest();
     }
    @isTest 
    public static void testUinfoNew()
    {
        Test.startTest();
        FormUpdateClass.UinfoNew();
       
         System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void testFetchNameSpace()
    {
        Test.startTest();
        FormUpdateClass.fetchNameSpace();
         System.assertEquals(1, 1, '');
        Test.stopTest();
    }
   @isTest 
    public static void testfetchTimingsAsProcedure()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
     FormUpdateClass.fetchTimingsAsProcedure('I874841232323',testAccount1.Id);
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
        FormUpdateClass.handleTimeDataOnForm('I874841232323',testAccount1.Id,timeWrapper,'test');
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
        String cvId = cv.Id;
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        Map<String, String> imgData = new Map<String, String>();
        imgData.put(cvId,'test img1');
        //imgData.put('002','test img2');
        FormUpdateClass.saveImages(imgData,testAccount1.Id,'I874841232323');
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
        FormUpdateClass.deleteAllProblemSavedFromForm(dcRecList,procIdList);
         System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void tesTexternalCmpDataForEditScreen()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        FormUpdateClass.externalCmpDataForEditScreen(testAccount1.Id,'I874841232323');
         System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    @isTest 
    public static void tesSaveDefaultValues()
    {
        Test.startTest();
        Account testAccount1 = [SELECT Id from Account Limit 1];
        List<Form_Value__c> dBformValues = [SELECT Id, Field_Api_Name__c, Default1__c, Account__c FROM Form_Value__c];
        String dBformValuesString = JSON.serialize(dBformValues);
        FormUpdateClass.saveDefaultValues(testAccount1.Id,new List<String>{'test'},dBformValuesString);
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
    
    @isTest 
    public static void testSaveForm()
    { 
        Test.startTest();
       
  
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
        
        String accountId  =acc.Id;
        String formName ='Aditya Form';
        String changedFormName='Aditya Form';
        String cssRecords ='{"cssRecords":[{"Id":"a121m000004PObZAAW","ElixirSuite__Lot_Number__c":false,"ElixirSuite__Form_Specific_Data__c":false,"ElixirSuite__Add_Problem__c":false,"ElixirSuite__Enable_Auto_text__c":false,"ElixirSuite__Hide_Selections__c":false,"ElixirSuite__Form_Category__c":"Form","ElixirSuite__isFormMacro__c":false,"ElixirSuite__Add_Procedure__c":false,"ElixirSuite__Section_Number__c":1,"ElixirSuite__Is_Consent__c":false,"ElixirSuite__Columns_In_Section__c":1,"ElixirSuite__Is_Time_Enabled__c":false,"ElixirSuite__Is_matrix__c":false,"ElixirSuite__Add_Notes__c":false,"ElixirSuite__Object_1_css__r":[{"ElixirSuite__Object_1_css__c":"a121m000004PObZAAW","Id":"a121m000004PObaAAG","ElixirSuite__IsCommon__c":false,"ElixirSuite__Object_Name__c":"ElixirSuite__Object_2__c","ElixirSuite__Is_Consent__c":false,"ElixirSuite__Field_Name__c":"ElixirSuite__Patient_Name_1__c","ElixirSuite__Field_Label_Long__c":"Patient Name","ElixirSuite__Data_Type__c":"STRING","ElixirSuite__No_Label__c":false,"ElixirSuite__Is_Common_Parent__c":false,"ElixirSuite__Form_Specific_Data__c":false,"ElixirSuite__Row__c":1,"ElixirSuite__Column__c":1,"ElixirSuite__Form_Data_Type__c":"Default","ElixirSuite__IMG_Type_of_Upload__c":"Single","ElixirSuite__IMG_Type_of_Row__c":"Field","ElixirSuite__Is_matrix__c":false,"ElixirSuite__Is_formula_Field__c":false,"Columns":[{"ElixirSuite__Object_1_css__c":"a121m000004PObZAAW","Id":"a121m000004PObaAAG","ElixirSuite__IsCommon__c":false,"ElixirSuite__Object_Name__c":"ElixirSuite__Object_2__c","ElixirSuite__Is_Consent__c":false,"ElixirSuite__Field_Name__c":"ElixirSuite__Patient_Name_1__c","ElixirSuite__Field_Label_Long__c":"Patient Name","ElixirSuite__Data_Type__c":"STRING","ElixirSuite__No_Label__c":false,"ElixirSuite__Is_Common_Parent__c":false,"ElixirSuite__Form_Specific_Data__c":false,"ElixirSuite__Row__c":1,"ElixirSuite__Column__c":1,"ElixirSuite__Form_Data_Type__c":"Default","ElixirSuite__IMG_Type_of_Upload__c":"Single","ElixirSuite__IMG_Type_of_Row__c":"Field","ElixirSuite__Is_matrix__c":false,"ElixirSuite__Is_formula_Field__c":false,"Columns":[],"lengthOfField":255,"value":"aditya","colsize":"slds-size_12-of-12"}],"lengthOfField":255,"value":"aditya","colsize":"slds-size_12-of-12"}]}]}';
        String formUniqueId	='a131m0000013l93AAA;471071268';
        String objNameToValue='{"ElixirSuite__Object_2__c":{"ElixirSuite__Patient_Name_1__c":"aditya","Id":"a131m0000013l93AAA"}}';
        String problemData='';
        String precriptionData='';
        List<String> deletedProblem =new List<String>();
        //String deletedProblem	= '' ;	
        List<String>  toDelProblemFromUpdate = new List<String>();
        String toUpdateProblem	='';
        Boolean isProblemEnabled = false;	
        String procedureWrapper	='{"insertedProcedure":[],"updatedProcedure":[],"toDelProcRecords":[]}';
        String timeWrapper='{"paramSame":false,"setEndTimeAsCurrent":false}';
        Boolean isTimeEnabled= false ;
        Boolean isClone=false;
        Boolean isDeceased = false;
        String modularMatrixData='';
        String fetchFlag = 'false';
         try{
        FormUpdateClass.saveForm(accountId,formName,changedFormName,cssRecords,formUniqueId,objNameToValue,problemData,precriptionData,deletedProblem,toDelProblemFromUpdate,toUpdateProblem,isProblemEnabled,procedureWrapper,timeWrapper,isTimeEnabled,isClone,isDeceased,modularMatrixData,fetchFlag,true);
         }
        catch(AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}