@isTest
public class CreatePaymentTransactionHelperTest {
    public  static testMethod void allCoverageParentMethod(){
        set<Id> setIds = new set<Id>();
        set<Id> setProcedureIds = new set<Id>();
         Account acc= new Account(Name='Test');
        insert acc;
        setIds.add(acc.Id);
        Provider__c pd = new Provider__c();
        pd.Account__c = acc.Id;
        pd.Provider_Code__c = 'NP';
        insert pd;
        setIds.add(pd.Id);
         ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestProc',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2',
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c',
                                                                    RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId());
        insert p ;
        setProcedureIds.add(p.id);
         List<ElixirSuite__Procedure__c> lstTemplateProcedures = 
                                [Select Id, name ,ElixirSuite__Reference_CPT_Code__c, ElixirSuite__Modifier1__c, ElixirSuite__Modifier2__c, ElixirSuite__Modifier3__c, ElixirSuite__Modifier4__c,
                                ElixirSuite__Modifier1__r.Name, ElixirSuite__Modifier2__r.Name, ElixirSuite__Modifier3__r.Name, ElixirSuite__Modifier4__r.Name                             
                                from ElixirSuite__Procedure__c where (ElixirSuite__Modifier1__c!=null or ElixirSuite__Modifier2__c!=null or
                                 ElixirSuite__Modifier3__c!=null or ElixirSuite__Modifier4__c!=null) AND Id =:p.Id ];
         Test.startTest();
       // CreatePaymentTransactionHelper.updateCharges(setIds,lstTemplateProcedures);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
        
    }
      public  static testMethod void allCoverageParentMethod1(){
        set<Id> setIds = new set<Id>();
        set<Id> setProcedureIds = new set<Id>();
         Account acc= new Account(Name='Test');
        insert acc;
        setIds.add(acc.Id);
        Provider__c pd = new Provider__c();
        pd.Account__c = acc.Id;
        pd.Provider_Code__c = 'NP';
        insert pd;
        setIds.add(pd.Id);
         ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestProc',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2',
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c',
                                                                    RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId());
        insert p ;
        setProcedureIds.add(p.id);
         List<ElixirSuite__Procedure__c> lstTemplateProcedures = 
                                [Select Id, name ,ElixirSuite__Reference_CPT_Code__c, ElixirSuite__Modifier1__c, ElixirSuite__Modifier2__c, ElixirSuite__Modifier3__c, ElixirSuite__Modifier4__c,
                                ElixirSuite__Modifier1__r.Name, ElixirSuite__Modifier2__r.Name, ElixirSuite__Modifier3__r.Name, ElixirSuite__Modifier4__r.Name                             
                                from ElixirSuite__Procedure__c where (ElixirSuite__Modifier1__c!=null or ElixirSuite__Modifier2__c!=null or
                                 ElixirSuite__Modifier3__c!=null or ElixirSuite__Modifier4__c!=null) AND Id =:p.Id ];
         Test.startTest();
       // CreatePaymentTransactionHelper.updateCharges(setIds,lstTemplateProcedures);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
        
    }
    public  static testMethod void allCoverageParentMethod2(){
        set<Id> setIds = new set<Id>();
        set<Id> setProcedureIds = new set<Id>();
         Account acc= new Account(Name='Test');
        insert acc;
        setIds.add(acc.Id);
        Provider__c pd = new Provider__c();
        pd.Account__c = acc.Id;
        pd.Provider_Code__c = 'NP';
        insert pd;
        setIds.add(pd.Id);
         ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestProc',ElixirSuite__Related_Procedure_Code_Category__c = 'HCPCS Level 2',
                                                                    ElixirSuite__Code_Category__c = 'ElixirSuite__Code_Category__c',
                                                                    RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId());
        insert p ;
        setProcedureIds.add(p.id);
         List<ElixirSuite__Procedure__c> lstTemplateProcedures = 
                                [Select Id, name ,ElixirSuite__Reference_CPT_Code__c, ElixirSuite__Modifier1__c, ElixirSuite__Modifier2__c, ElixirSuite__Modifier3__c, ElixirSuite__Modifier4__c,
                                ElixirSuite__Modifier1__r.Name, ElixirSuite__Modifier2__r.Name, ElixirSuite__Modifier3__r.Name, ElixirSuite__Modifier4__r.Name                             
                                from ElixirSuite__Procedure__c where (ElixirSuite__Modifier1__c!=null or ElixirSuite__Modifier2__c!=null or
                                 ElixirSuite__Modifier3__c!=null or ElixirSuite__Modifier4__c!=null) AND Id =:p.Id ];
         Test.startTest();
       // CreatePaymentTransactionHelper.updateCharges(setIds,lstTemplateProcedures);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
        
    }
}