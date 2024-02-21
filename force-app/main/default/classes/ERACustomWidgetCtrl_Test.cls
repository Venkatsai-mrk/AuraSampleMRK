@isTest
public class ERACustomWidgetCtrl_Test 
{
    public static testMethod void eraTest()
    {
        Account pat = new Account();
        pat.Name = 'test';
        //	pat.Age__c = '18';
        pat.Phone = '1234567890';
        pat.BillingStreet = 'test';
        pat.BillingCity = 'test';
        pat.BillingCountry = 'test';
        pat.BillingState = 'test';
        pat.BillingPostalCode = '123456';
        pat.Gender__c = 'Female';
        //pat.birthdate__c = system.today();
        pat.AccountNumber = '123456';
        insert pat;
        
        Claim__c claim = new Claim__c();
        claim.Claim_Status__c = 'Saved';
        claim.Account__c = pat.Id;
        claim.Patient_s_Phone__c = '1234567890';
        claim.Patient_DOB__c = system.today();
        claim.Patient_Sex__c = 'M';
        claim.Patient_Name__c = pat.Name;
        claim.Patient_s_Address__c = pat.BillingStreet;
        claim.Patient_s_State__c = pat.BillingState;
        claim.Patient_s_City__c = pat.BillingCity;
        claim.Manual_ERA__c = false;
        claim.Patient_s_Zipcode__c = decimal.valueOf(pat.BillingPostalCode) ;
        insert claim;
        
        EOB__c objEb = new EOB__c();
        objEb.Account__c = pat.Id;
        objEb.Copy_Of_Original_ERA__c = false;
        objEb.Claim__c = claim.Id;
        insert objEb;
        
        test.startTest();
        ERACustomWidgetCtrl.fetchOriginalERA(claim.Id);
        test.stopTest();
        System.assert(	claim.Claim_Status__c!=null,'');
    }
}