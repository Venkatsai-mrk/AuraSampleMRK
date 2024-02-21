/*
Developed By  - Sonal Agarwal
Test Class - GenerateUpfrontPaymentReceiptTest
Description - Class for printing Payment receipt when the User selects upfront as payment type through 
*/
public with sharing class GenerateUpfrontPaymentReceiptCtrl 
{
    public Decimal amountPaid {get;set;}
    public Id patientId {get;set;}
    
    public Provider__c providerData {get;set;}
    public Account patientData {get;set;}
    public String paymentDate {get;set;}
    
    public GenerateUpfrontPaymentReceiptCtrl()
    {
        amountPaid = Decimal.valueOf(ApexPages.currentPage().getParameters().get('amountPaid').escapeHtml4());
        patientId = ApexPages.currentPage().getParameters().get('patientId').escapeHtml4();
        paymentDate = ApexPages.currentPage().getParameters().get('paymentDate').escapeHtml4();
        providerData = getProviderDetails(patientId);
        patientData = getPatientDetails(patientId);
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=Payment-'+patientData.Name +'.pdf');
    }
    
    public Provider__c getProviderDetails(String accId)
    {
        Provider__c providerObj = new Provider__c();
        try{
        providerObj = [Select id, Name, Address__c, Provider_Code__c from Provider__c 
        where Account__c =: patientId 
        WITH SECURITY_ENFORCED
        LIMIT 1];
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return providerObj;
    }
    
    public Account getPatientDetails(String accId)
    {
        Account patientObj = new Account();
        patientObj = [Select id, Name, MRN_Number__c, Phone from Account where Id =: patientId 
        WITH SECURITY_ENFORCED
        LIMIT 1];
        
        return patientObj;
    }
}