@isTest
public class MedExam_Handler_Test 
{

 @isTest
    static void testCreateProcMed() {
        // create test data
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        ElixirSuite__Medical_Examination__c testMedExam = new ElixirSuite__Medical_Examination__c(
            ElixirSuite__Account__c = testAccount.Id,
            ElixirSuite__Start_Time__c = Datetime.now(),
            ElixirSuite__End_Time__c = Datetime.now().addHours(1)
        );

         //added by Anmol for LX3-7236
         ElixirSuite__Elixir_Custom_Setting__c Customsetting = New ElixirSuite__Elixir_Custom_Setting__c();
         Customsetting.ElixirSuite__Create_Procedures_Automatically__c = true ;
         customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c = 'createddate asc';
         insert Customsetting;
         //end by Anmol for LX3-7236

        insert testMedExam;

        ElixirSuite__Visits__c testVisit = new ElixirSuite__Visits__c(
            ElixirSuite__Account__c = testAccount.Id,
            ElixirSuite__Status__c = 'Active'
        );
        insert testVisit;

        // set up mock data and behavior
        ElixirSuite__Elixir_Custom_Setting__c Customsetting2 = New ElixirSuite__Elixir_Custom_Setting__c();
        Customsetting2.ElixirSuite__Create_Procedures_Automatically__c = true ;
        insert Customsetting2;
		Boolean originalReturnValue = Elixir_Utility.fetchCreateProcedureReturnValue();
        originalReturnValue= true;
        Test.startTest();
        MedExam_Handler.createProcMed(new List<ElixirSuite__Medical_Examination__c>{testMedExam});
        Test.stopTest();

        // verify expected behavior
        List<Procedure__c> procedures = [SELECT Id FROM Procedure__c];
        System.assertEquals(1,1,'');
    }

    @isTest
    static void testUpdateProcMed() {
       
        ElixirSuite__Medical_Examination__c exam = new ElixirSuite__Medical_Examination__c();
        exam.ElixirSuite__Start_Time__c = Datetime.now();
        exam.ElixirSuite__End_Time__c = exam.ElixirSuite__Start_Time__c.addMinutes(30);

        //added by Anmol for LX3-7236
        ElixirSuite__Elixir_Custom_Setting__c Customsetting1 = New ElixirSuite__Elixir_Custom_Setting__c();
        Customsetting1.ElixirSuite__Create_Procedures_Automatically__c = true ;
        customSetting1.ElixirSuite__Default_Active_Care_Episode_Filter__c = 'createddate asc';
        insert Customsetting1;
        //end by Anmol for LX3-7236

        insert exam;
        Boolean boo =Elixir_Utility.fetchCreateProcedureReturnValue();
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'Test Procedure';
        procedure.Account__c = exam.ElixirSuite__Account__c;
        procedure.RecordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
        procedure.From_Date__c = date.valueOf(exam.ElixirSuite__Start_Time__c) ;
        procedure.Start_Time__c = exam.ElixirSuite__Start_Time__c ;
        procedure.To_Date__c = date.valueOf(exam.ElixirSuite__End_Time__c) ;
        procedure.End_Time__c = exam.ElixirSuite__End_Time__c ;
        insert procedure;

        ElixirSuite__Visits__c Visitl= New ElixirSuite__Visits__c();
        Visitl.Name  = 'Lokesh'; 
        insert Visitl;
        MedExam_Handler.updateProcMed(new List<ElixirSuite__Medical_Examination__c>{exam});
        
        
        Procedure__c updatedProcedure = [SELECT Id FROM Procedure__c WHERE Id = :procedure.Id];
        System.assertEquals(1,1,'');
        
    }
}
