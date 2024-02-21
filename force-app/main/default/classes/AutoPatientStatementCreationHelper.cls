public with sharing class AutoPatientStatementCreationHelper {
    Set<Id> accountIds = new Set<Id>();
    Datetime startDate;
    Datetime endDate;
    public AutoPatientStatementCreationHelper(Set<Id> accountIds, Datetime startDate, Datetime endDate){
        this.accountIds = accountIds;
        this.startDate = startDate;
        this.endDate = endDate;
    }
    public Date evaluateDOS(List<Patient_Statment_GenerInterval__c> settings){
        Date todaydate = System.today();
        Integer days = Date.daysInMonth(todaydate.year(), todaydate.month());
        if(settings!=null && settings.size()>0){
            if(settings[0].No_of_Days__c != null){
                days = (Integer) settings[0].No_of_Days__c;
            }
        }
        return todaydate.addDays(-days);
    }
    public List<Payment_Transaction__c> findPrivatePayments(Date dateOfService){
        return [SELECT Id, Posted__c, Procedure__r.Name, Procedure__r.From_Date_Of_Service__c,
                Provider__r.Name, Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c, Insurance_Paid__c,Actual_Price__c,
                (SELECT Id, Amount_Paid__c, CreatedDate FROM Transactions__r
                 WHERE CreatedDate>= :startDate AND CreatedDate<= :endDate)
                FROM Payment_Transaction__c
                WHERE Procedure__r.Type_Of_Procedure__c='Private Payment'
                AND Procedure__r.From_Date_Of_Service__c>= :dateOfService
                AND Account__c IN :accountIds
                WITH SECURITY_ENFORCED
                ORDER BY Procedure__r.From_Date_Of_Service__c DESC];
    }
    public List<Payment_Transaction__c> findInsurancePayments(Date dateOfService){
        return [SELECT Id, Posted__c, Procedure__r.Name, Procedure__r.From_Date_Of_Service__c,
                Provider__r.Name, Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c, Insurance_Paid__c, Payment_Adjustments__c,Actual_Price__c,
                (SELECT Id, Amount_Paid__c, CreatedDate FROM Transactions__r
                 WHERE CreatedDate>= :startDate AND CreatedDate<= :endDate)
                FROM Payment_Transaction__c
                WHERE Procedure__r.Type_Of_Procedure__c='Insurance Payment'
                AND Posted__c=TRUE
                AND Procedure__r.From_Date_Of_Service__c>= :dateOfService
                AND Account__c IN :accountIds
                WITH SECURITY_ENFORCED
                ORDER BY Procedure__r.From_Date_Of_Service__c DESC];
    }
    public List<Transactions__c> findProcedurePaidInMonth(Date dateOfService, Set<Id> masterTransactionIds){
        return [SELECT Id, Amount_Paid__c, Master_Transaction__c, Payment_DateTime__c, Payment_Received_By__c
                FROM Transactions__c
                WHERE ( (Master_Transaction__r.Procedure__r.Type_Of_Procedure__c='Insurance Payment' 
                         AND Master_Transaction__r.Posted__c=TRUE )
                       OR Master_Transaction__r.Procedure__r.Type_Of_Procedure__c='Private Payment')
                AND Payment_DateTime__c>= :dateOfService
                AND Master_Transaction__c NOT IN :masterTransactionIds
                AND Master_Transaction__r.Account__c IN :accountIds WITH SECURITY_ENFORCED];
    }
    public List<Payment_Transaction__c> masterTransactions(Date dateOfService, Set<Id> masterTransactionIds){
        return [SELECT Id, Posted__c, Procedure__r.Name, Procedure__r.From_Date_Of_Service__c,Procedure__r.Type_Of_Procedure__c,
                Provider__r.Name, Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c, Insurance_Paid__c,Actual_Price__c,
                (SELECT Id, Amount_Paid__c, CreatedDate FROM Transactions__r
                 WHERE CreatedDate>= :startDate AND CreatedDate<= :endDate)
                FROM Payment_Transaction__c
                WHERE Id IN :masterTransactionIds WITH SECURITY_ENFORCED];
    }
    public PatientStatment_ctr.PrivateProcedure privateProcedureSchema(Payment_Transaction__c payment){
        PatientStatment_ctr.PrivateProcedure privateProc = new PatientStatment_ctr.PrivateProcedure();
        privateProc.procedureName = payment.Procedure__r.Name;
        privateProc.dos = payment.Procedure__r.From_Date_Of_Service__c;
        privateProc.providerName = payment.Provider__r.Name;
        privateProc.charges = payment.Actual_Price__c;
        privateProc.patientPayments = payment.ElixirSuite__Total_Actual_Patient_Paid_Amount__c;
        privateProc.amountToPay = AutoPatientStatementCreation.refactoredAmount(privateProc.charges) - 
            						AutoPatientStatementCreation.refactoredAmount(privateProc.patientPayments);
        privateProc.transactions = payment.Transactions__r;
        return privateProc;
    }
    public PatientStatment_ctr.InsuranceProcedure insuranceProcedureSchema(Payment_Transaction__c payment){
        PatientStatment_ctr.InsuranceProcedure insuranceProc = new PatientStatment_ctr.InsuranceProcedure();
        insuranceProc.procedureName = payment.Procedure__r.Name;
        insuranceProc.dos = payment.Procedure__r.From_Date_Of_Service__c;
        insuranceProc.providerName = payment.Provider__r.Name;
        insuranceProc.charges = payment.Actual_Price__c;
        insuranceProc.patientPayments = payment.ElixirSuite__Total_Actual_Patient_Paid_Amount__c;
        insuranceProc.insurancePayments = AutoPatientStatementCreation.refactoredAmount((Double) (payment.Insurance_Paid__c)) +
            								AutoPatientStatementCreation.refactoredAmount((Double) (payment.Payment_Adjustments__c));
        insuranceProc.amountToPay = AutoPatientStatementCreation.refactoredAmount(insuranceProc.charges) - 
            						AutoPatientStatementCreation.refactoredAmount(insuranceProc.insurancePayments);
        insuranceProc.transactions = payment.Transactions__r;
        return insuranceProc;
    }
    public List<Payment_Transaction__c> findProceduresRemaining(Date dateOfService, Set<Id> masterTransactionIds){
        return [SELECT Id, Posted__c, Procedure__c,Procedure__r.Name,
                Total_Paid_Amount__c,ElixirSuite__Total_Actual_Patient_Paid_Amount__c,Insurance_Paid__c,Procedure__r.Type_Of_Procedure__c,Actual_Price__c,
                Provider__r.Name,Procedure__r.From_Date_of_Service__c,
                (SELECT Id, Amount_Paid__c, CreatedDate FROM Transactions__r
                 WHERE CreatedDate>= :startDate AND CreatedDate<= :endDate)
                FROM Payment_Transaction__c
                WHERE ( (Procedure__r.Type_Of_Procedure__c='Insurance Payment'
                         AND Posted__c=TRUE )
                       OR Procedure__r.Type_Of_Procedure__c='Private Payment')
                AND Procedure__r.From_Date_Of_Service__c>= :dateOfService
                AND ElixirSuite__PatientOutstanding__c!=0
                AND Account__c IN :accountIds
                AND Id NOT IN :masterTransactionIds WITH SECURITY_ENFORCED];
    }
    public List<AggregateResult> findPrivatePaymentsAggregate(Date dateOfService){
        return [SELECT Account__c d, Sum(Actual_Price__c) c FROM Payment_Transaction__c
                WHERE Procedure__r.Type_Of_Procedure__c='Private Payment'
                AND Procedure__r.From_Date_Of_Service__c>= :dateOfService
                AND Account__c IN :accountIds 
                WITH SECURITY_ENFORCED
                GROUP BY Account__c];
    }
    public List<AggregateResult> findInsurancePaymentsAggregate(Date dateOfService){
        return [SELECT Account__c d, Sum(Actual_Price__c) c FROM Payment_Transaction__c
                WHERE Procedure__r.Type_Of_Procedure__c='Insurance Payment'
                AND Posted__c=TRUE
                AND Procedure__r.From_Date_Of_Service__c>= :dateOfService
                AND Account__c IN :accountIds 
                WITH SECURITY_ENFORCED
                GROUP BY Account__c];
    }
    public List<AggregateResult> findProcedurePaidInMonthAggregate(Date dateOfService){
        return [SELECT Master_Transaction__r.Account__c d, SUM(Amount_Paid__c) c
                FROM Transactions__c
                WHERE ( (Master_Transaction__r.Procedure__r.Type_Of_Procedure__c='Insurance Payment' 
                         AND Master_Transaction__r.Posted__c=TRUE )
                       OR Master_Transaction__r.Procedure__r.Type_Of_Procedure__c='Private Payment')
                AND Payment_DateTime__c>= :dateOfService
                AND Master_Transaction__r.Account__c IN :accountIds 
                WITH SECURITY_ENFORCED
                GROUP BY Master_Transaction__r.Account__c];
    }
}