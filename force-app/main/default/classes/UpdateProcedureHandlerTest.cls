@isTest
public class UpdateProcedureHandlerTest {
    public  static testMethod void allCoverageParentMethod(){
        Account acc= new Account(Name='Test', Phone='9874563219', BillingPostalCode='44445');
        insert acc;
        ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestProc',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2',
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c',ElixirSuite__Type_of_Procedure__c='Private Payment',
                                                                    RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId());
        insert p;
        String payload = '{"keysToSave":{"Id":'+'"'+p.Id+'"'+',"codeCategorySelected":"HCPCS Level 2","procedureSelected":"Cough","procedureDescription":"","procedureStart":"2022-03-27T08:07:00.000Z","procedureEnd":"2022-04-08T08:07:00.000Z","placeOfService":"02 - Telehealth","unitsDuration":"90","diagnosisPointer":"","preAuthCode":"cvdsfsd78","claimType":"Professional","isReadyForBilling":false,"claimNumber":"","claimStatus":"","claimGenerated":false,"patientProcedure":false,"isBillable":true,"isProcessed":false}}';
        String modData = '[{"modfier":"Doctor X","description":"doctor x","notes":"de"}]';
        String dd = '[{"Diagnosis":"Knee","description":"Knee","notes":"de"},{"Diagnosis":"Heart","description":"Heart","notes":"de"}]';
        String dd1 = '[{"Diagnosis":"Knee surgery","description":"Knee","notes":"de"}]';
        ElixirSuite__ICD_Codes__c icd = new ElixirSuite__ICD_Codes__c(Name = 'ICDDEMO');
        ElixirSuite__Procedure_Diagnosis__c pd = new ElixirSuite__Procedure_Diagnosis__c(ElixirSuite__Procedure__c = p.Id,
                                                                                        ElixirSuite__ICD_Codes__c = icd.Id);
        
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
        UpdateProcedureHandler.fetchRecordInView(acc.Id,p.Id);
        UpdateProcedureHandler.claimStatusCheck(new List<ElixirSuite__Procedure__c>{p});
        UpdateProcedureHandler.fetchProcedureRecord(p.Id);
        UpdateProcedureHandler.fetchDiagnosisData(p.Id);
        UpdateProcedureHandler.getTypeOfPament(p.Id);
        UpdateProcedureHandler.fetchAllDiagnosisForPatient(acc.Id);
        UpdateProcedureHandler.checkForModifierCombination(idsModifiers,'HD');
        //UpdateProcedureHandler.deleteProcedureDiagnosis(icd.Id);
        //UpdateProcedureHandler.updateDiagnosis(icd.Id);
        UpdateProcedureHandler.updateProcedure(payload, acc.Id, dd, modData,p.Id,dd1);
        UpdateProcedureHandler.getFieldData('ElixirSuite__Procedure__c','ElixirSuite__Procedure_Code_Field_Set');
        Test.stopTest();
        System.assertEquals('TestProc',p.Name, '');
        System.assertEquals('HCPCS Level 2',p.ElixirSuite__Related_Procedure_Code_Category__c, '');
        System.assertEquals('ElixirSuite__Code_Category__c',p.ElixirSuite__Code_Category__c, '');
    }
}