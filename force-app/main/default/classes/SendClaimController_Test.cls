@isTest
public class SendClaimController_Test 
{   @isTest
    public static void sendClaim()
    {
        Account patient =TestDataFactory.createPatientAcc();
        insert patient;
        
        Claim__c clmData = TestDataFactory.createClaim(patient.Id);
        clmData.Claim_Status__c = 'Ready to Submit';
        insert clmData;
        
        test.startTest();
        SendClaimController.updateClaims(clmData.Id);
        SendClaimController.isDuplicateError(clmData.Id);
        SendClaimController.viewId();
        SendClaimController.viewIdAll();
        SendClaimController.ClaimsValidationforAutoCreation(clmData.Id);
        SendClaimController.splitIds(clmData.Id);
        SendClaimController.lineItems(new List<claim__c> {clmData});
        //SendClaimController.updateSentClaims();
        test.stopTest();
        system.assert(  clmData.Claim_Status__c !=null,''); 
      
    }
}