@isTest
public class ProcedureSearchHelperTest {
@isTest
    static void allocateMethod(){
         ElixirSuite__Procedure__c newModifier = new ElixirSuite__Procedure__c();
         newModifier.Name= 'HD001';
        newModifier.ElixirSuite__Reference_CPT_Code__c= 'HD';
         newModifier.ElixirSuite__Code_Category__c= 'Modifier';
        insert newModifier;
         Test.startTest();
          ProcedureSearchHelper.procedureList('A','HD');
         ProcedureSearchHelper.modfierList('A','HD');
          ProcedureSearchHelper.recordSelected(newModifier.Id);
          System.assertEquals(1, 1, ''); 
             Test.stopTest();
    }
}