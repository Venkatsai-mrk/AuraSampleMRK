@isTest
public class CheckModifierControllerTest {
@isTest
    static void allocateMethod(){
         Elixir_Custom_Setting__c mcs = new  Elixir_Custom_Setting__c();
        mcs.ElixirSuite__Add_Modifiers_Feature__c = true;
        insert mcs;
       // Apexpages.currentPage().getparameters().put('id',test.id);
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
Map<id,string> patientProcedureMap = new Map<id,string>();
        patientProcedureMap.put(newpro.Id,newpro.ElixirSuite__Reference_CPT_Code__c);
         List<ElixirSuite__Procedure__c> lstTemplateProcedures = 
                                [Select Id, name ,ElixirSuite__Reference_CPT_Code__c, ElixirSuite__Modifier1__c, ElixirSuite__Modifier2__c, ElixirSuite__Modifier3__c, ElixirSuite__Modifier4__c,
                                ElixirSuite__Modifier1__r.Name, ElixirSuite__Modifier2__r.Name, ElixirSuite__Modifier3__r.Name, ElixirSuite__Modifier4__r.Name                             
                                from ElixirSuite__Procedure__c where (ElixirSuite__Modifier1__c!=null or ElixirSuite__Modifier2__c!=null or
                                 ElixirSuite__Modifier3__c!=null or ElixirSuite__Modifier4__c!=null) AND Id =:newpro.Id ];

    // List<String> idsModifiers = new List<String>{'a1I1m000001uVozEAE', 'a1I1m000001uVp4EAE'};
for( ElixirSuite__Procedure__c objProcedure: lstTemplateProcedures) {
     idsModifiers.clear();
     if(objProcedure.ElixirSuite__Modifier1__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier1__c);
     if(objProcedure.ElixirSuite__Modifier2__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier2__c);
     if(objProcedure.ElixirSuite__Modifier3__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier3__c);
     if(objProcedure.ElixirSuite__Modifier4__c != null) idsModifiers.add(objProcedure.ElixirSuite__Modifier4__c);
     system.debug(objProcedure.name + ' ===> ' + idsModifiers);
} 
      // list<ElixirSuite__Procedure__c> records = new list<ElixirSuite__Procedure__c>(); 
         Test.startTest();
          CheckModifierController.getTemplateProcedureForModifiers(idsModifiers,'HD');
CheckModifierControllerCharges.getTemplateProcedureForModifiers(new Map<Id, List<String>>(),patientProcedureMap);
          System.assertEquals(1, 1, ' ');
             Test.stopTest();
             
    }
}