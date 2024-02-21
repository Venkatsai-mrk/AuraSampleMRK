@istest
public class TestPatientChartPDFHelper {
   
    @isTest
    public static void testConstructor() {
        // Create test data (if needed)
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        ElixirSuite__Notes__c note = new ElixirSuite__Notes__c();
        note.ElixirSuite__Type__c='Doctor Notes';
        note.ElixirSuite__Account__c=testAccount.id;
        insert note;
        Form_Object__mdt o = new Form_Object__mdt();
        o.Object_Name__c='Account';
        //insert o;
        ElixirSuite__Visits__c testVisit = new ElixirSuite__Visits__c(
            Name = 'Test Visit',
            ElixirSuite__Account__c = testAccount.Id,
            ElixirSuite__Visit_Start__c = System.now(),
            ElixirSuite__Visit_End__c = System.now().addHours(1)
        );
        insert testVisit;
        ElixirSuite__TabPermissionBasedOnProfiles__c tab = new ElixirSuite__TabPermissionBasedOnProfiles__c();
        tab.ElixirSuite__LabOrder_Priority__c='CHC LabOrder';
        insert tab;
        

        // Set up the page context with parameters
        PageReference pageRef = Page.PatientChartPdfNew; // Replace with your VF page name
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('caseId', testVisit.Id);
        pageRef.getParameters().put('cat', 'ElixirSuite__Problem_List__c');

        // Create an instance of the PatientChartPDFHelper class
        PatientChartPDFHelper helper = new PatientChartPDFHelper();
        PatientChartPDFHelper.doesFieldExist('Account','Name');
        PatientChartPDFHelper.doesFieldExist('Accodfunt','Name');
        helper.fetchAllObjectsInCS();
        PatientChartPDFHelper.CareEpisodePDFWrapper a = new PatientChartPDFHelper.CareEpisodePDFWrapper();
        
        
        // Perform assertions to validate the constructor behavior
        System.assertEquals(true, helper.allowPDFRender);
        System.assertEquals(true, helper.problems);
        System.assertEquals(null, helper.prescriptions);
        System.assertEquals(null, helper.allergies);
        System.assertEquals(null, helper.showLabOrder);
        // Add more assertions as needed to validate the constructor behavior
    }

    // Add more test methods to cover other functionalities of the PatientChartPDFHelper class


    
   

}