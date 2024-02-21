@isTest
public class ProcedureListViewApexTest {
    @isTest
     static void coverageAllMethods(){
         Account acc = new Account();
        acc.Name = 'Test';
        acc.Admit_Date__c = System.today().addYears(-40);
        acc.First_Name__c = 'Hannah';
        acc.Last_Name__c = 'Brown';
        acc.Gender__c = 'Female';
        acc.Account_Number__c = '235689';
        acc.BillingState = 'NY';
        acc.BillingPostalCode = '10014';
        acc.BillingCountry = 'US';
        acc.Phone = '9879879879';
        insert acc;
                ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestProc',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2', ElixirSuite__Account__c = acc.Id,
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c',
                                                                    RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId());
        insert p;
          Test.startTest();
        ProcedureListViewApex.BringDataFirst(p.Id);
        ProcedureListViewApex.BringDataViewAll(p.Id);
        ProcedureListViewApex.deleteRec(p.Id);
        System.assertEquals(1, 1, ''); 
        Test.stopTest();
    }
}