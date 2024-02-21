@isTest
public class EditCMS1500VFControllerTest {
    @isTest
    public static void testRedirectToLCForClaim() {
        // Create a test claim ID
       Account acc = new Account();
        acc.Name = 'Test';
        acc.Admit_Date__c = System.today().addYears(-40);
        //acc.dischargeDateNew__c = System.today().addYears(-40);
        //acc.CreatedDate = System.today().addYears(-40);
        acc.First_Name__c = 'Hannah';
        acc.Last_Name__c = 'Brown';
        acc.Gender__c = 'Female';
        acc.ShippingStreet = 'Street lane';
        acc.ShippingCity = 'New York';
        acc.ShippingState = 'NY';
        acc.ShippingPostalCode = '10014';
        acc.ShippingCountry = 'US';
        //acc.birthdate__c = System.today().addYears(-40);
        acc.Patient_s_Birth_Date__c = System.today().addYears(-40);
        acc.MRN_Number_New__c = '456456';
        acc.BillingStreet = 'Street lane';
        acc.BillingCity = 'New York';
        acc.Account_Number__c = '235689';
        acc.BillingState = 'NY';
        acc.BillingPostalCode = '10014';
        acc.BillingCountry = 'US';
        acc.Phone = '9879879879';
        insert acc;
        
        ElixirSuite__Claim__c newClaim = new ElixirSuite__Claim__c();
        newClaim.ElixirSuite__Insured_Zipcode__c = 98765;
        newClaim.ElixirSuite__Accept_Assignment__c = 'No';
        newClaim.ElixirSuite__Account__c = acc.Id;
        newClaim.ElixirSuite__Additional_Claim_Information__c = '';
        newClaim.ElixirSuite__Amount_Paid__c = 0;
        newClaim.ElixirSuite__Any_Other_Health_Benefit_Plan__c = false;
        newClaim.ElixirSuite__Auto_Accident_Related__c = '';
        newClaim.ElixirSuite__Batch_Id__c = '';
        newClaim.ElixirSuite__Billing_Provider_Address_1__c = '123';
        newClaim.ElixirSuite__Billing_Provider_Address_2__c = '';
        newClaim.ElixirSuite__Billing_Provider_City__c = 'CS';
        newClaim.ElixirSuite__Billing_Provider_Info_NPI__c = '7894561230';
        newClaim.ElixirSuite__Billing_Provider_Info__c = '';
        newClaim.ElixirSuite__Billing_Provider_Legacy_ID_Provider_Lice__c = '';
        newClaim.ElixirSuite__Billing_Provider_Name__c = 'HDF';
        newClaim.ElixirSuite__Billing_Provider_Other_ID__c = '';
        newClaim.ElixirSuite__Billing_Provider_State__c = 'CA';
        newClaim.ElixirSuite__Billing_Provider_Taxonomy__c = '';
        newClaim.ElixirSuite__Billing_Provider_Tax_ID_Type__c = '';
        newClaim.ElixirSuite__Billing_Provider_Tax_ID__c = '1234567890';
        newClaim.ElixirSuite__Billing_Provider_Zip__c = '50002';
        newClaim.ElixirSuite__Bill_Phone__c = '7894561233';
        newClaim.ElixirSuite__bill_taxid__c = '';
        newClaim.ElixirSuite__Charge_Amount__c = '0';
        newClaim.ElixirSuite__Claimid__c = '';
        newClaim.ElixirSuite__Claim_Codes__c = '';
        newClaim.ElixirSuite__Claim_Md_Id__c = '';
        newClaim.ElixirSuite__Claim_Status__c = 'Claim Validation Error';
        newClaim.ElixirSuite__Diagnosis_B__c = '';
        newClaim.ElixirSuite__Diagnosis_C__c = '';
        newClaim.ElixirSuite__Diagnosis_D__c = '';
        newClaim.ElixirSuite__Diagnosis_E__c = '';
        newClaim.ElixirSuite__Diagnosis_F__c = '';
        newClaim.ElixirSuite__Diagnosis_G__c = '';
        newClaim.ElixirSuite__Diagnosis_H__c = '';
        newClaim.ElixirSuite__Diagnosis_I__c = '';
        newClaim.ElixirSuite__Diagnosis_J__c = '';
        newClaim.ElixirSuite__Diagnosis_K__c = '';
        newClaim.ElixirSuite__Diagnosis_L__c = '';
        newClaim.ElixirSuite__Diagnosis_Reference__c = '';
        
        
        insert newClaim;
        String claimId = newClaim.Id;
        
        // Create a new instance of the controller
        ApexPages.StandardController standardController = new ApexPages.StandardController(new Account());
        EditCMS1500VFController controller = new EditCMS1500VFController(standardController);
        
        // Create a new page reference and set its parameters
        PageReference pageRef = Page.EditCMS1500Form;  // Replace with the name of your Visualforce page
        pageRef.getParameters().put('id', claimId);
        Test.setCurrentPage(pageRef);
        
        // Call the method under test
        PageReference result = controller.redirectToLCForClaim();
        
        // Verify the expected redirect URL
        String expectedUrl = '/lightning/cmp/ElixirSuite__ParentEditCMS1500';
        System.assertEquals(expectedUrl, result.getUrl(),'');
        
        // Verify the parameters passed in the redirect URL
        Map<String, String> parameters = result.getParameters();
        System.assertEquals(claimId, parameters.get('c__strInput'),'');
        System.assertEquals(1, 1, '');
    }
}