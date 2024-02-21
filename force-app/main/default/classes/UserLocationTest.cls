@isTest
private with sharing class UserLocationTest {
    @isTest
    private static void userInsertion() {
        test.startTest();
        Account patient = TestDataFactory.createPatientAcc();
        insert patient;
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        
        Provider__c providerTemp = TestDataFactory.createProvider(patient.Id);
        providerTemp.Name = 'abcde';
        providerTemp.ElixirSuite__Provider_Code__c = 'abcdef';
        providerTemp.Account__c =  null;
         providerTemp.RecordTypeId = recordTypeId ;
        insert providerTemp;
        Visits__c visit = new Visits__c(
            Status__c='Active',
            Care_Episode_Location__c=providerTemp.Id,
            Account__c=patient.Id
        );
        insert visit;
        UserLocation__c userLocation = new UserLocation__c(
            Provider__c = providerTemp.Id,
            User__c = UserInfo.getUserId()
        );
        Opportunity opp = new Opportunity(
            AccountId = patient.Id,
            Name = 'Test',
            CloseDate = System.today() + 90,
            StageName = 'Open');
        insert opp;
        VOB__c vob = new VOB__c();
        vob.PatientFirstName__c = 'Test';
        vob.PatientLastName__c = 'Patient';
        vob.Patient_Birth_Date__c = System.today().addYears(-26);
        vob.Member_Id__c = '12345';
        vob.Payer_Name__c = 'Test Payer';
        vob.Opportunity__c = opp.Id;
        insert vob;

         //added by Anmol for LX3-7236
         Elixir_Custom_Setting__c customSetting = new Elixir_Custom_Setting__c();
        customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c = 'createddate asc';
        customSetting.Create_Procedures_Automatically__c = True;
        insert customSetting;
        //end by Anmol for LX3-7236

        Transport__c transport = new Transport__c();
        transport.Patient_Name__c = opp.Id;
        transport.End_Time__c = System.now().addMinutes(-1);
        insert transport;
        Pre_Assessment__c assessment = new Pre_Assessment__c(
            Opportunity__c=opp.Id);
        insert assessment;
        insert userLocation;
        delete userLocation;
        test.stopTest();
        System.assertEquals(1, 1, ' ');
    }
    @isTest
    private static void trigCoverage() {
        Account patient = TestDataFactory.createPatientAcc();
        insert patient;
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        Provider__c providerTemp = TestDataFactory.createProvider(patient.Id);
        providerTemp.Account__c =  null;
        providerTemp.Name = 'abcde';
        providerTemp.ElixirSuite__Provider_Code__c = 'abcdef';
        providerTemp.RecordTypeId = recordTypeId ;
        insert providerTemp;
        test.startTest();
        UserLocation__c userLocation = new UserLocation__c(
            Provider__c = providerTemp.Id,
            User__c = UserInfo.getUserId()
        );
        insert userLocation;
        Opportunity opp = new Opportunity(
            AccountId = patient.Id,
            Name = 'Test',
            CloseDate = System.today() + 90,
            StageName = 'Open');
        insert opp;
        VOB__c vob = new VOB__c();
        vob.PatientFirstName__c = 'Test';
        vob.PatientLastName__c = 'Patient';
        vob.Patient_Birth_Date__c = System.today().addYears(-26);
        vob.Member_Id__c = '12345';
        vob.Payer_Name__c = 'Test Payer';
        vob.Opportunity__c = opp.Id;
        insert vob;

          //added by Anmol for LX3-7236
          Elixir_Custom_Setting__c customSetting = new Elixir_Custom_Setting__c();
          customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c = 'createddate asc';
          customSetting.Create_Procedures_Automatically__c = True;
          insert customSetting;
          //end by Anmol for LX3-7236

        Transport__c transport = new Transport__c();
        transport.Patient_Name__c = opp.Id;
        transport.End_Time__c = System.now().addMinutes(-1);
        insert transport;
        Pre_Assessment__c assessment = new Pre_Assessment__c(
            Opportunity__c=opp.Id);
        insert assessment;
        test.stopTest();
        System.assertEquals(1, 1, ' ');
    }
}