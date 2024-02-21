/*
Developed By  - Sonal Agarwal
Test Class - GenerateUpfrontPaymentReceiptCtrl
Description - Class for printing Payment receipt when the User selects upfront as payment type through 
*/
@isTest
public class GenerateUpfrontPaymentReceiptTest 
{
	@isTest
    public static void unitTest()
    {
        Account patient = TestDataFactory.createPatientAcc();
        insert patient;
        System.assertNotEquals(patient.Id, null,'');
        
        Provider__c provider = TestDataFactory.createProvider(patient.Id);
        insert provider;
        System.assertNotEquals(provider.Id, null,'');
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('amountPaid', '1000');
        ApexPages.currentPage().getParameters().put('patientId', patient.Id);
        ApexPages.currentPage().getParameters().put('paymetDate', System.today().format());
        
        GenerateUpfrontPaymentReceiptCtrl obj = new GenerateUpfrontPaymentReceiptCtrl();
        
        Test.stopTest();
    }
}