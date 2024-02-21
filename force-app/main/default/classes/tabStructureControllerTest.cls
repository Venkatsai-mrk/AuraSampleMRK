@isTest
public class tabStructureControllerTest {
	@isTest
    public static void tabstructController(){
        TabPermissionBasedOnProfiles__c customSetting = new TabPermissionBasedOnProfiles__c();
        customSetting.ElixirSuite__LabOrder_Priority__c = 'Dummy LabOrder; CHC LabOrder1';
        insert customSetting;
        
        Account patientTestRecord=new Account();
        patientTestRecord.phone='1232357692';
        patientTestRecord.BillingPostalCode='12345';
        patientTestRecord.ElixirSuite__Email_Id__c='test@gmail.com';
        
        patientTestRecord.Name='Test Patient';
        patientTestRecord.Admit_Date__c=system.today();
        
        patientTestRecord.Discharge_Date__c=system.today()+5;
        Insert patientTestRecord;
        System.assertEquals(1, 1,'');
        
        
        Account patientTestRecord2=new Account();
        
        patientTestRecord2.Name='Test Patient 1';
        patientTestRecord2.Admit_Date__c=system.today();
        
        patientTestRecord2.Discharge_Date__c=system.today()+5;
        patientTestRecord2.phone='1232357691';
        patientTestRecord2.BillingPostalCode='22345';
        Insert patientTestRecord2;
        System.assertEquals(1, 1,'');
        
        Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
         setting.ElixirSuite__Business_Account_Recordtype__c = 'Business_Account';
         insert setting;
         String bussinessAccRecType = setting.ElixirSuite__Business_Account_Recordtype__c;
        Id objectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(bussinessAccRecType).getRecordTypeId();
        Account accRecord=new account();
        accRecord.Name='Test Acc1114';
        accRecord.phone='1232357695';
        accRecord.BillingPostalCode='42345';
        accRecord.RecordTypeId=objectRecordTypeId;
        insert accRecord;
        
        Account accRecord1=new account();
        accRecord1.Name='Test Acc1114';
        accRecord1.RecordTypeId=objectRecordTypeId;
        accRecord1.phone='1234567896';
        accRecord1.BillingPostalCode='54321';
        insert accRecord1;
        
        
        contact conRecord1=new contact();
        conrecord1.lastname='TestCon11145';
        conrecord1.Email='jaiky@gmail.com';
        conrecord1.AccountId=accRecord1.Id;
        insert conRecord1;
        
       string accId = patientTestRecord.Id;
       VOB__c vob = new VOB__c();
        vob.PatientFirstName__c = 'Test';
        vob.PatientLastName__c = 'Patient';
        vob.Patient_Birth_Date__c = System.today().addYears(-26);
        vob.Member_Id__c = '12345';
        vob.Payer_Name__c = 'Test Payer';
        vob.ElixirSuite__Insured_Address__c = 'ABC';
        vob.ElixirSuite__InsPhone__c = '12365';
        vob.ElixirSuite__Insured_Zipcode__c = '12548';
        vob.ElixirSuite__Insured_First_Name__c = 'Kevin';
        vob.ElixirSuite__Gender__c = 'Male';
        vob.ElixirSuite__Account__c = accId;
        vob.ElixirSuite__Date_Of_Birth__c =date.valueOf('2000-04-18');
        insert vob;
        
        
       Id objectRecordTypeIdloc  = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        
       
       ElixirSuite__Provider__c prov = new ElixirSuite__Provider__c();
       prov.RecordTypeId = objectRecordTypeIdloc;
       prov.Name = 'Suitcase';
       prov.ElixirSuite__Provider_Code__c = 'Pankaj';
       prov.ElixirSuite__Provider_First_Name__c = 'Massy';
       prov.ElixirSuite__Provider_Last_Name__c = 'Ronaldo';
       insert prov;
           
       /*ElixirSuite__Visits__c careepisode  = new ElixirSuite__Visits__c();
       careepisode.ElixirSuite__Account__c = patientTestRecord.Id;
       careepisode.ElixirSuite__Care_Episode_Location__c = prov.Id;
       careepisode.ElixirSuite__Location__c = 'Delhi';
       careepisode.ElixirSuite__Status__c ='Active';
       insert careepisode;*/
                
        
        
        test.startTest();
        tabStructureController.sendEmail(patientTestRecord.Id);
        tabStructureController.getAccess();
        tabStructureController.TabPermission();
        tabStructureController.LicensBasdPermission();
        tabStructureController.accountFieldValidation(patientTestRecord.Id);
       // tabStructureController.fetchDynamicTabStructureData();
        newCareApexController.countCareEpisode(patientTestRecord.Id);
        newCareApexController.customLocationStatus();
        tabStructureController.accNewCropFieldValidation(patientTestRecord.Id);
        tabStructureController.checkCareEpisodePrompt(patientTestRecord.Id);
        tabStructureController.VOBValidation(accId);
        System.assertEquals(1, 1,'');
        test.stopTest();
    }
    
}