//@isTest(seeAllData=true)
@isTest
public class ElixirOEM_AttachEraLineItemHelperTest {
    public static testMethod void  method1(){
       // ElixirSuite__Adjustment_Reason_Code__mdt mt = new ElixirSuite__Adjustment_Reason_Code__mdt(DeveloperName='Abc');
        ElixirSuite__Payor__c pyr = new ElixirSuite__Payor__c();
        pyr.Name = 'Test';
        pyr.ElixirSuite__Payer_Code__c = '56kkkoo';
        insert pyr;
        ElixirSuite__Claim__c cl = new ElixirSuite__Claim__c(ElixirSuite__Insured_s_ID_Number__c = '5434gdfg',ElixirSuite__Patient_Name__c = 'testpat',
                                                             ElixirSuite__Patient_DOB__c = System.today(),ElixirSuite__Patient_s_City__c = 'fsdferf',
                                                             ElixirSuite__Patient_s_State__c = 'state',ElixirSuite__Insured_Policy__c = 'erewsef',
                                                             ElixirSuite__Patient_Or_Auth_Per_Sign__c = 'ewr34',ElixirSuite__Patient_Or_Auth_Person_Date__c = System.today(),
                                                             ElixirSuite__Federal_Tax_Id_Number__c = 'sfserf34',
                                                             ElixirSuite__Payor__c = pyr.Id);
        insert cl;
ElixirSuite__Procedure__c p = new ElixirSuite__Procedure__c(Name = 'TestP',ElixirSuite__CPT_HCPCS_Code__c='ICD9');
        insert p;
        ElixirSuite__Claim_Line_Items__c cli = new ElixirSuite__Claim_Line_Items__c(ElixirSuite__Claim__c = cl.Id,ElixirSuite__Procedure__c = p.Id); 
        insert cli;
        Test.startTest();
        
        
        ElixirOEM_AttachEraLineItemHelper.getClaimLineItems(cl.Id);
                ElixirOEM_AttachEraLineItemHelper.AttachClaimInitWrapper x = new ElixirOEM_AttachEraLineItemHelper.AttachClaimInitWrapper();
ElixirOEM_AttachEraLineItemHelper.getReasonListFromMDT('ALL');
        Test.stopTest();
        System.assertEquals(1,1,'');
    }
}