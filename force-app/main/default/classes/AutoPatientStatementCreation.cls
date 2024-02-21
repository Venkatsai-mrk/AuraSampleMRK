/*Author name           :  Shwetha KJ
* Purpose               :  Create patient statements automatically based on days and hours. 
* Schedule              :  Scheduling on the basis of days and hour. 
* Test Class            :  
* Created Date          :  10-Dec-2020
* Last Modified Date    :  10-Dec-2020

Author name             :  Rohit Singh Bora
* Last Modified Date    :  15-Aug-2022
*/

global with sharing class AutoPatientStatementCreation implements Database.Batchable<sObject>,database.stateful,Schedulable {
    
    global void execute(SchedulableContext sc) {
        AutoPatientStatementCreation schd = new AutoPatientStatementCreation();
        Database.executeBatch(schd, 10);
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Outstanding_Amount__c,Total_Patient_Responsibility__c FROM Account';
        return Database.getQueryLocator(query);  
    }
    global void execute(Database.BatchableContext bc,List<Account> scope){
        Set<Id> accountIds = new Map<Id,Account>(scope).keySet();
        List<Patient_Statment_GenerInterval__c> settings = Patient_Statment_GenerInterval__c.getAll().values();
        
        AutoPatientStatementCreationHelper helperObj = new AutoPatientStatementCreationHelper(accountIds, system.now(), system.now());
        
        Date dateOfService = helperObj.evaluateDOS(settings);     
        system.debug('dateOfService '+dateOfService);
        List<AggregateResult> privatePayments = new List<AggregateResult>();
        privatePayments = helperObj.findPrivatePaymentsAggregate(dateOfService);
        Map<Id,Double> privatePay = new  Map<Id,Double>();
        for(AggregateResult privatePayment :privatePayments){
            privatePay.put((Id) privatePayment.get('d'), (Double) privatePayment.get('c'));
        }
        
        List<AggregateResult> insurancePayments = new List<AggregateResult>();
        insurancePayments = helperObj.findInsurancePaymentsAggregate(dateOfService);
        Map<Id,Double> insurancePay = new  Map<Id,Double>();
        for(AggregateResult privatePayment :insurancePayments){
            insurancePay.put((Id) privatePayment.get('d'), (Double) privatePayment.get('c'));
        }
        
        List<AggregateResult> proceduresPaidInMonth = new List<AggregateResult>();
        proceduresPaidInMonth = helperObj.findProcedurePaidInMonthAggregate(dateOfService);
        Map<Id,Double> proceduresPay = new  Map<Id,Double>();
        for(AggregateResult privatePayment :proceduresPaidInMonth){
            proceduresPay.put((Id) privatePayment.get('d'), (Double) privatePayment.get('c'));
        }
   
        List<Patient_Statement__c> statements = new List<Patient_Statement__c>();
        statements = [SELECT Id, Account__c, NewBalance__c, NewCharges__c, PreviousBalance__c
                     FROM Patient_Statement__c
                     WHERE Account__c IN :accountIds
                     AND CreatedDate> :dateOfService.addDays(-60)
                     ORDER BY CreatedDate ASC];
        Map<Id,Patient_Statement__c> latestStatementPerAccount = new Map<Id,Patient_Statement__c>();
        List<Patient_Statement__c> newStatements = new List<Patient_Statement__c>();
        for(Patient_Statement__c statement :statements){
			 latestStatementPerAccount.put(statement.Account__c, statement);  			         
        }
        
        for(Account patient :scope){
            Patient_Statement__c newStatement = new Patient_Statement__c();
            Id accountId = patient.Id;
            Double privateAmt = privatePay.get(accountId);
            Double insuranceAmt = insurancePay.get(accountId);
            Double newCharges = refactoredAmount(privateAmt) + refactoredAmount(insuranceAmt);
            Double payments = proceduresPay.get(accountId);
            Double previousBalance = 0;
            newStatement.NewCharges__c = newCharges;
            newStatement.PaymentsAndAdjustmnts__c = payments;           
            if(latestStatementPerAccount.containsKey(accountId)){
                previousBalance = latestStatementPerAccount.get(accountId).PreviousBalance__c;
            }
            
            newStatement.NewBalance__c = refactoredAmount(newCharges) + refactoredAmount(previousBalance) - refactoredAmount(payments);
            newStatement.previousBalance__c = previousBalance;
            newStatement.Account__c = accountId;
            newStatement.Statement_from__c = dateOfService;
            newStatement.Statement_to__c = System.today();
            newStatements.add(newStatement);
        }
        if(newStatements!=null && newStatements.size()>0){
            insert newStatements;
        }
    }   
    global void finish(Database.BatchableContext bc){   
    }
    public static double refactoredAmount(double amount){
        if(amount == null){
            return 0.0;
        }
        return amount;
    }
}