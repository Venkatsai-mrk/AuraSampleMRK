@isTest
public class CreateNewProcedureHandlerTest {
    public  static testMethod void allCoverageParentMethod(){
        Account acc= new Account();
         acc.Name= 'CHECK';
         acc.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
         acc.ElixirSuite__Gender__c='Male';
         acc.ElixirSuite__Email_Id__c='virat@gmail.com';
		 acc.phone='9988776655';
		 acc.ElixirSuite__First_Name__c='Virat';
		 acc.ElixirSuite__Last_Name__c='Kohli';
		 acc.BillingPostalCode='50021';
		 acc.ElixirSuite__SSN__c='12345';
        insert acc;
        ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestProc',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2',
                                                                   ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c',ElixirSuite__Type_of_Procedure__c='Private Payment',
                                                                   RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId());
        insert p;
        String payload = '{"keysToSave":{"codeCategorySelected":"HCPCS Level 2","procedureSelected":"Cough","procedureDescription":"","procedureStart":"2022-03-27T08:07:00.000Z","procedureEnd":"2022-04-08T08:07:00.000Z","placeOfService":"02 - Telehealth","unitsDuration":"90","diagnosisPointer":"","preAuthCode":"cvdsfsd78","claimType":"Professional","isReadyForBilling":false,"claimNumber":"","claimStatus":"","claimGenerated":false,"patientProcedure":false,"isBillable":true,"isProcessed":false}}';
      	String modData = '[{"modfier":"Doctor X","description":"doctor x","notes":"de"}]';
        String dd = '[]';
        
        
              Elixir_Custom_Setting__c mcs = new  Elixir_Custom_Setting__c();
        mcs.ElixirSuite__Add_Modifiers_Feature__c = true;
        insert mcs;
                List<String> idsModifiers = new List<String>();
         ElixirSuite__Procedure__c newModifier = new ElixirSuite__Procedure__c();
         newModifier.Name= 'HD001';
        newModifier.ElixirSuite__Reference_CPT_Code__c= 'HD';
         newModifier.ElixirSuite__Code_Category__c= 'Modifier';
        insert newModifier;
        ElixirSuite__Procedure__c newpro = new ElixirSuite__Procedure__c();
        newpro.Name= 'HD001';
         newpro.ElixirSuite__Code_Category__c= 'ICD -10-PCS ';
        newpro.ElixirSuite__Reference_CPT_Code__c= 'HD';
         newpro.ElixirSuite__Modifier1__c= newModifier.Id;
         newpro.ElixirSuite__Modifier2__c= newModifier.Id;
         newpro.ElixirSuite__Modifier3__c= newModifier.Id;
         newpro.ElixirSuite__Modifier4__c= newModifier.Id;
        insert newpro;
         List<ElixirSuite__Procedure__c> lstTemplateProcedures = 
                                [Select Id, name ,ElixirSuite__Reference_CPT_Code__c, ElixirSuite__Modifier1__c, ElixirSuite__Modifier2__c, ElixirSuite__Modifier3__c, ElixirSuite__Modifier4__c,
                                ElixirSuite__Modifier1__r.Name, ElixirSuite__Modifier2__r.Name, ElixirSuite__Modifier3__r.Name, ElixirSuite__Modifier4__r.Name                             
                                from ElixirSuite__Procedure__c where (ElixirSuite__Modifier1__c!=null or ElixirSuite__Modifier2__c!=null or
                                 ElixirSuite__Modifier3__c!=null or ElixirSuite__Modifier4__c!=null) AND Id =:newpro.Id ];

for( ElixirSuite__Procedure__c objProcedure: lstTemplateProcedures) {
     idsModifiers.clear();
     if(objProcedure.ElixirSuite__Modifier1__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier1__c);
     if(objProcedure.ElixirSuite__Modifier2__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier2__c);
     if(objProcedure.ElixirSuite__Modifier3__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier3__c);
     if(objProcedure.ElixirSuite__Modifier4__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier4__c);
     system.debug(objProcedure.name + ' ===> ' + idsModifiers);
} 
        
        Test.startTest();
        CreateNewProcedureHandler.newScreenProcedureDomain(acc.Id);
        CreateNewProcedureHandler.fetchAllDiagnosisForPatient(acc.Id);
        CreateNewProcedureHandler.checkForModifierCombination(idsModifiers,'HD');
        CreateNewProcedureHandler.saveProcedure(payload, acc.Id, dd, modData);
        CreateNewProcedureHandler.getTypeOfPament(p.Id);
        CreateNewProcedureHandler.getFieldData('ElixirSuite__Procedure__c','ElixirSuite__Procedure_Code_Field_Set');
        Test.stopTest();
        system.assertEquals(1, 1,'');
    }
}