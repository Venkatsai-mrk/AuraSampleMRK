public with sharing class PatientStatementHelper {
    @AuraEnabled
    public static ParentWrapperForStatement parentInitFetchDataForPatientStatement(String accountId){
        ParentWrapperForStatement wrpr = new ParentWrapperForStatement();
        try{
        List<Patient_Statement__c> availablePatientStatements = new  List<Patient_Statement__c>();
        availablePatientStatements = [SELECT ID,Name,Patient_Code__c,Statement_Date__c,PaymentsAdjustments_Received__c,
                                      Statement_from__c,Statement_to__c,Account_Number__c from Patient_Statement__c 
                                      WHERE Account__c=:
                                      accountId WITH SECURITY_ENFORCED limit 49999];        
        wrpr.allPatientStatements = availablePatientStatements;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return wrpr;
    }
    
    public class ParentWrapperForStatement{ 
        @AuraEnabled public List<Patient_Statement__c> allPatientStatements; 
        @AuraEnabled public  Payment_Transaction__c singPaymentStatementRecord ; 
        @AuraEnabled public  List<Payment_Transaction__c> paymentStatements ; 
        @AuraEnabled public double totalSum;   
        @AuraEnabled public double newCharges; 
        @AuraEnabled public double newBalance; 
        @AuraEnabled public double paymentAdjustments;   
        @AuraEnabled public double prevBalance;
        @AuraEnabled public Account acctDetails;
        @AuraEnabled public DateTime statementDate;
        @AuraEnabled public List<PatientStatment_ctr.PrivateProcedure> privateProcedures = new List<PatientStatment_ctr.PrivateProcedure>();
        @AuraEnabled public List<PatientStatment_ctr.InsuranceProcedure> insuranceProcedures = new List<PatientStatment_ctr.InsuranceProcedure>();
        @AuraEnabled public String providerName;
        @AuraEnabled public Date payFullBy;
        @AuraEnabled public String primaryInsuranceName;
        @AuraEnabled public String secInsuranceName;
        @AuraEnabled public String headerLogo;
        @AuraEnabled public Boolean squarePayment;
        @AuraEnabled public Boolean elixirPayment;
    }
    @AuraEnabled
    public static List<Patient_Statement__c> filteredPaymentHistory(String accountId,Date startDate,Date endDate){
        endDate = endDate.addDays(1);
        List<Patient_Statement__c> availablePatientStatements = new  List<Patient_Statement__c>();
        try{
        availablePatientStatements = [SELECT ID,Name,Patient_Code__c,Statement_Date__c,PaymentsAdjustments_Received__c,Account__r.Name,Account__r.MRN_Number_New__c,Account__r.MRN_Number__c,
                                      Statement_from__c,Statement_to__c,Account_Number__c from Patient_Statement__c WHERE 
                                      CreatedDate >=: startDate and CreatedDate <=: endDate AND 
                                      Account__c = :accountId  WITH SECURITY_ENFORCED order by CreatedDate];
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return availablePatientStatements;
    }
    @AuraEnabled
    public static Boolean checkStatementExists(String accountId,Date startDate,Date endDate){
        Boolean isStatementPresent = false;
        WrapperData obj = new WrapperData();
        obj.patientPdf= PatientStatementExportPDFHelper.getPaymentTransactionInfoDuplicate(accountId , startDate , endDate);
      if(obj.patientPdf.paymentsTransactions.size()>0){
            isStatementPresent = true;
        }
        return isStatementPresent;
    }
   /* @AuraEnabled
    public static ElixirSuite__Elixir_Custom_Setting__c getPaymentCustomSetting(){
        return ElixirSuite__Elixir_Custom_Setting__c.getInstance();
    }*/
    
    @AuraEnabled
    public static ParentWrapperForStatement singleStatementRecordDetils(String statementId){
        DateTime statementDate  = [SELECT ID,CreatedDate FROM Patient_Statement__c where Id = : statementId].CreatedDate;
        String patientAccountId = [SELECT Id,Account__c FROM Patient_Statement__c WHERE Id= : statementId].Account__c;   
        Patient_Statement__c statement =[Select Id,Account_Number__c,NewBalance__c,NewCharges__c,Account__c,Account__r.Name,
                                         CreatedDate,Account__r.First_Name__c,
                                         Statement_from__c,Account__r.MRN_Number_New__c,Account__r.Last_Name__c,Account__r.AccountNumber,
                                         PreviousBalance__c,PaymentsAndAdjustmnts__c,Statement_Date__c,Statement_to__c
                                         FROM Patient_Statement__c WHERE Id= :statementId WITH SECURITY_ENFORCED];
        Datetime dateField = statement.CreatedDate;
        Integer numberOfDays = Date.daysInMonth(dateField.year(), dateField.month());
        Date lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
        Date payFullBy = lastDayOfMonth;
        Account acctDetails = [SELECT ID,Name,AccountNumber,MRN_Number_New__c from Account 
                               WHERE Id= :patientAccountId WITH SECURITY_ENFORCED];
        Datetime startDate = statement.Statement_from__c!=null?statement.Statement_from__c:System.now();
        Datetime endDate = statement.Statement_to__c!=null?statement.Statement_to__c:System.now();
        
        ParentWrapperForStatement toReturnStatementData = new ParentWrapperForStatement();
        try{
        String primaryInsuranceName='';
        String secInsuranceName='';
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
        
        //ROHIT - START
        Set<Id> accountIds = new Set<Id>{patientAccountId};
        Set<Id> masterTransactionIds = new Set<Id>();
        List<PatientStatment_ctr.PrivateProcedure> privateProcedures = new List<PatientStatment_ctr.PrivateProcedure>();
        List<PatientStatment_ctr.InsuranceProcedure> insuranceProcedures = new List<PatientStatment_ctr.InsuranceProcedure>();
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
        toReturnStatementData.newCharges = statement.NewCharges__c;
        toReturnStatementData.paymentAdjustments = statement.PaymentsAndAdjustmnts__c;
        toReturnStatementData.acctDetails = acctDetails;
        toReturnStatementData.statementDate = statement.CreatedDate;
        toReturnStatementData.prevBalance = statement.PreviousBalance__c;
        toReturnStatementData.newBalance = statement.NewBalance__c;
        toReturnStatementData.PrivateProcedures = privateProcedures;
        toReturnStatementData.InsuranceProcedures = insuranceProcedures;
        toReturnStatementData.payFullBy = payFullBy;
        toReturnStatementData.primaryInsuranceName = primaryInsuranceName;
        toReturnStatementData.secInsuranceName = secInsuranceName;
        toReturnStatementData.headerLogo =  StatementAsExportHelper.getPDFData().PDF_Header_Logo__c;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return toReturnStatementData;
    }
    public class WrapperData{       
        @AuraEnabled public StatementAsExportHelper.wrapperData classTwoWrap;
        @AuraEnabled public PatientStatementExportPDFHelper.wrapperData patientPdf;
    }
}