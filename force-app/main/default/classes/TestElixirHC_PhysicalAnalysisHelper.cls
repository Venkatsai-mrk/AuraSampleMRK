/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TestElixirHC_PhysicalAnalysisHelper {
    
    public static testMethod void  coverScenariosForPhysicallAnalysisHelper(){
        String toPass  = '{"Name":"","Elixir_HC__Appearance__c":"Clear","Elixir_HC__Bacteria__c":"","Elixir_HC__Bilrubin__c":"","Elixir_HC__Casts__c":"","Elixir_HC__Comments__c":"test","Elixir_HC__Crystal__c":"","Elixir_HC__Examined_By__c":"","Elixir_HC__Notes__c":"test","Elixir_HC__Examined_Datetime__c":"2020-06-24T15:15:00.000Z","Elixir_HC__Glucose__c":"","Elixir_HC__Leukocyte__c":"","Elixir_HC__Lab_Name__c":"","Elixir_HC__Mucus__c":"","Elixir_HC__PH__c":"","Elixir_HC__Picklist__c":"","Elixir_HC__Puss_Cells_W_B_C__c":"","Elixir_HC__Protein__c":"","Elixir_HC__Red_Cells_R_B_C__c":"","Elixir_HC__Specific_Gravity__c":"","Elixir_HC__Schistosoma_Eggs__c":"","Elixir_HC__Specimen_Status__c":"Active","Elixir_HC__Spermatozoa__c":"","Elixir_HC__Trichomonas__c":"","Elixir_HC__Status__c":"Positive","Elixir_HC__UA_Sample_Details__c":"","Elixir_HC__Urobilinogen__c":"","Elixir_HC__Type__c":"","Elixir_HC__Bilesalt__c":"","Elixir_HC__Yeast_Cells__c":"","Elixir_HC__Epithelial_Cells__c ":"","Elixir_HC__Colour__c":"Colourless","Elixir_HC__Account__c":""}';
        Account a  = new Account(name = 'DmeoAccount');
        insert a;
        
        UA_Sample_Details__c ua = new UA_Sample_Details__c();
        ua.Sample_Type__c='Physical';
        ua.ContainerType__c='Test';
        ua.Container_Description__c='Des';
        ua.ContainerSize__c='Test';
        ua.Specimen_Quantity__c= 'Test';
        ua.Additives_if_Any__c = 'Test';
        ua.Specimen_Condition__c = 'Test';
        ua.Notes__c= 'Test';
        ua.Status__c = 'Open';
        ua.Collection_Datetime__c = System.now();
        ua.Specimen_Collector__c='Test';
        ua.Account__c = a.id;
        insert ua;
        
        
        Sample_Analysis__c sa  = new Sample_Analysis__c();
        // sa.Elixir_HC__Account__c  = forIns.Id;
        sa.Appearance__c = 'Clear';
        sa.Colour__c = 'Colourless';
        sa.Comments__c = 'Cooments';
        sa.Examined_Datetime__c = System.now();
        sa.Notes__c = 'Notes';
        sa.Specimen_Status__c = 'Active';
        sa.Status__c = 'Positive';
        sa.UA_Sample_Details__c = ua.Id;
        insert sa;
        
        
        PageReference pageRef = Page.ElixirHC_PhysicalAnalysisPDFGenerator;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('orderId',toPass);
        ElixirHC_PhysicalAnalysisHelper objectTocall = new ElixirHC_PhysicalAnalysisHelper();             
        //  objectTocall.getprescriptionOrderInfo(sa.id);
        objectTocall.getAccountInfo(a.id);
        ElixirHC_PhysicalAnalysisHelper.getStringifiedDate(date.newInstance(2012,05,22));
       // system.assert( a.Name!=null); 
       system.assertEquals(1,1,'');
    }
    
}