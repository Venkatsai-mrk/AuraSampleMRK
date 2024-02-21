public with sharing class PatientStatment_ctr {
    public String PageId{get;set;}
    public Patient_Statement__c objPatSt{get;set;}
    public List<PrivateProcedure> privateProcedures{get;set;}
    public List<InsuranceProcedure> insuranceProcedures{get;set;}
    public Datetime mainDate{get;set;} 
    public String primaryInsuranceName{get;set;}
    public String secInsuranceName{get;set;}
    public Date payFullBy{get;set;}
    public static PDF_Header__c pdfData {get; set;}
    public PatientStatment_ctr(ApexPages.StandardController controller) {
        privateProcedures = new List<PrivateProcedure>();
        insuranceProcedures = new List<InsuranceProcedure>();
        pdfData= StatementAsExportHelper.getPDFData(); 
        PageId=ApexPages.currentPage().getParameters().get('Id');
        objPatSt = new Patient_Statement__c();
        
        String patientAccountId = [SELECT Id,Account__c FROM Patient_Statement__c WHERE Id= : PageId].Account__c;
        objPatSt = [Select Id,Account_Number__c,NewBalance__c,NewCharges__c,Account__c,Account__r.Name,CreatedDate,Account__r.First_Name__c,
                    Statement_from__c,Account__r.MRN_Number_New__c,Account__r.Last_Name__c,Account__r.AccountNumber,
                    PreviousBalance__c,PaymentsAndAdjustmnts__c,Statement_Date__c,Statement_to__c
                    FROM Patient_Statement__c WHERE Id= :PageId WITH SECURITY_ENFORCED];
        Datetime dateField = objPatSt.CreatedDate;
        Integer numberOfDays = Date.daysInMonth(dateField.year(), dateField.month());
        Date lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
        payFullBy = lastDayOfMonth;
        mainDate = objPatSt.CreatedDate;
        Account acctDetails = [SELECT Id,Name,AccountNumber,MRN_Number_New__c from Account WHERE Id= :patientAccountId WITH SECURITY_ENFORCED];
        Datetime startDate = objPatSt.Statement_from__c!=null?objPatSt.Statement_from__c:System.now();
        Datetime endDate = objPatSt.Statement_to__c!=null?objPatSt.Statement_to__c:System.now();
        
		        
        
        //ROHIT - START
        Set<Id> accountIds = new Set<Id>{patientAccountId};
        Set<Id> masterTransactionIds = new Set<Id>();
        List<Patient_Statment_GenerInterval__c> settings = Patient_Statment_GenerInterval__c.getAll().values();
        AutoPatientStatementCreationHelper helperObj = new AutoPatientStatementCreationHelper(accountIds, startDate, endDate);
        Date dateOfService = helperObj.evaluateDOS(settings);     
        
        List<Payment_Transaction__c> privatePayments = new List<Payment_Transaction__c>();
        privatePayments = helperObj.findPrivatePayments(dateOfService);
        for(Payment_Transaction__c privatePayment :privatePayments){
            privateProcedures.add(helperObj.privateProcedureSchema(privatePayment));
            masterTransactionIds.add(privatePayment.Id);
        }
        
        List<Payment_Transaction__c> insurancePayments = new List<Payment_Transaction__c>();
        insurancePayments = helperObj.findInsurancePayments(dateOfService);
          for(Payment_Transaction__c insurancePayment :insurancePayments){
            insuranceProcedures.add(helperObj.insuranceProcedureSchema(insurancePayment));
            masterTransactionIds.add(insurancePayment.Id);
        }
        
        List<Transactions__c> proceduresPaidInMonth = new List<Transactions__c>();
        proceduresPaidInMonth = helperObj.findProcedurePaidInMonth(dateOfService, masterTransactionIds);
        Set<Id> masterTransactionFromTransactions = new Set<Id>();
        for(Transactions__c trans :proceduresPaidInMonth){
            masterTransactionFromTransactions.add(trans.Master_Transaction__c);
        }
        List<Payment_Transaction__c> transactions = helperObj.masterTransactions(dateOfService, masterTransactionFromTransactions);
        for(Payment_Transaction__c payment :transactions){
            if(payment.Procedure__r.Type_Of_Procedure__c.equalsIgnoreCase('Private Payment')){
                privateProcedures.add(helperObj.privateProcedureSchema(payment));
                 masterTransactionIds.add(payment.Id);
            }
            else{//Insurance Payment
                insuranceProcedures.add(helperObj.insuranceProcedureSchema(payment));
                masterTransactionIds.add(payment.Id);
            }
        }
        
        List<Payment_Transaction__c> proceduresRemaining = helperObj.findProceduresRemaining(dateOfService, masterTransactionIds);
        for(Payment_Transaction__c payment :proceduresRemaining){
            if(payment.Procedure__r.Type_Of_Procedure__c.equalsIgnoreCase('Private Payment')){
                privateProcedures.add(helperObj.privateProcedureSchema(payment));
                 masterTransactionIds.add(payment.Id);
            }
            else{//Insurance Payment
                insuranceProcedures.add(helperObj.insuranceProcedureSchema(payment));
                masterTransactionIds.add(payment.Id);
            }
        }        
         //ROHIT - END
        List<VOB__c> primaryInsurances = [SELECT Id, Payer_Name__c, RecordType.DeveloperName
                        FROM VOB__c 
                        WHERE Account__c= :patientAccountId AND RecordType.DeveloperName='VOB_record_type'
                        WITH SECURITY_ENFORCED
                        ORDER BY CreatedDate DESC LIMIT 1];
        if(primaryInsurances!=null && primaryInsurances.size()>0){
            primaryInsuranceName = primaryInsurances[0].Payer_Name__c;
        }
        List<VOB__c> secInsurances = [SELECT Id, Payer_Name__c, RecordType.DeveloperName
                        FROM VOB__c 
                        WHERE Account__c= :patientAccountId AND RecordType.DeveloperName='Secondary_VOB'
                        WITH SECURITY_ENFORCED
                        ORDER BY CreatedDate DESC LIMIT 1];
        if(secInsurances!=null && secInsurances.size()>0){
            secInsuranceName = secInsurances[0].Payer_Name__c;
        }
    }
    public class PrivateProcedure{
        @AuraEnabled public String procedureName {get;set;}
        @AuraEnabled public Datetime dos {get;set;}
        @AuraEnabled public String providerName {get;set;}
        @AuraEnabled public double charges {get;set;}
        @AuraEnabled public double patientPayments {get;set;}
        @AuraEnabled public double discount {get;set;}
        @AuraEnabled public double amountToPay {get;set;}
        @AuraEnabled public List<Transactions__c> transactions {get;set;}
    }
    public class InsuranceProcedure{
        @AuraEnabled public String procedureName {get;set;}
        @AuraEnabled public Datetime dos {get;set;}
        @AuraEnabled public String providerName {get;set;}
        @AuraEnabled public double charges {get;set;}
        @AuraEnabled public double patientPayments {get;set;}
		@AuraEnabled public double insurancePayments {get;set;}
        @AuraEnabled public double amountToPay {get;set;}
        @AuraEnabled public List<Transactions__c> transactions {get;set;}
    }
}