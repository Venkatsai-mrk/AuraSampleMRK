@isTest
public class TestDataUtility {
public static Account setupAccountTestData()
    {
       Account acc=new Account();
        acc.Name='Mr. ab bc cd';
        insert acc;
        return acc;
    }
    //setup data for Inbound Referral Account
    public static Account setupAccountInboundTestData()
    {
       Account acc1=new Account();
        acc1.Name='ab. cd bc ef';
        //acc1.Inbound_Total__c=null;
       
        insert acc1;
        return acc1;
    }
    //setup data for outbound referral Account
     public static Account setupAccountoutboundTestData()
    {
       Account acc1=new Account();
        acc1.Name='ab. cd bc ef';
         //acc1.Outbound_Total__c=null;
        insert acc1;
        return acc1;
    }
    //Referredin with inbound type
    public static Opportunity setupOpportunityInReferralTestData()
    {
        Account ac=setupAccountTestData();
       Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=ac.id;
        Account a=setupAccountInboundTestData();
        op.Referred_In_Organization__c=a.id;
        op.Referral_Type__c='Inbound';
        op.StageName='Prospecting';
        insert op;
        return op;
        
    }
    //Referral in with outbound
    public static Opportunity setupOpportunityInReferralOutboundTestData()
    {
        Account ac=setupAccountTestData();
       Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=ac.id;
        Account a=setupAccountInboundTestData();
        op.Referred_In_Organization__c=a.id;
        op.Referral_Type__c='Outbound';
        op.StageName='Prospecting';
        insert op;
        return op;
        
    }
    public static Opportunity setupOpportunityOutReferralTestData()
    {
        Account ac=setupAccountTestData();
       Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=ac.id;
        Account a=setupAccountoutboundTestData();
        op.Referred_Out_Organization__c=a.id;
        op.StageName='Prospecting';
         op.Referral_Type__c='Outbound';
        insert op;
        return op;
        
    }
    public static Lead setupLeadTestData()
    {
       Lead ld=new Lead();
        ld.LastName='ab';
        ld.Phone='1234567890';
        ld.Status='open';
        ld.Has_Insurance__c=True;
        ld.Company='TestCompany';
        insert ld;
        return ld;
        
        
    }
     public static Opportunity setupOpportunityTestData()
    {
        Account ac=setupAccountTestData();
       Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=ac.id;
        op.StageName='Prospecting';
        insert op;
        return op;
        
    }
     
    public static Pre_assessment__c setupPreassessmentTestData()
    {
        Opportunity op=setupOpportunityTestData();
       Pre_assessment__c p=new Pre_assessment__c();
        p.Opportunity__c=op.id;
        insert p;
        return p;

        
    }
     public static Substance_Use_History__c setupSubstanceUseHistoryTestData()
    {
        Pre_assessment__c p=setupPreassessmentTestData();
        Substance_Use_History__c su=new Substance_Use_History__c();
        su.Pre_assessment__c=p.id;
        su.First_Use__c='b';
        su.Frequency__c='Daily';
        su.Last_Use__c='a';
        su.Route__c='b';
        su.Substance__c='Alcohol';
        //insert su;
        return su;
       
        
    }
    public static Treatment_History__c setupTreatmentHistoryTestData()
    {
        Pre_assessment__c p=setupPreassessmentTestData();
        Treatment_History__c th=new Treatment_History__c();
        th.Pre_assessment__c=p.id;
        th.Date__c=System.today();
        th.Facility__c='av';
        th.Level_of_Care__c='Detox';
        th.Outcome_Relapsed_when__c='a';
        
        //insert th;
        return th;  
    }
    public static Medication_History__c setupMedicationHistoryTestData()
    {
        Pre_assessment__c p=setupPreassessmentTestData();
        Medication_History__c mh=new Medication_History__c();
        mh.Pre_assessment__c=p.id;
        mh.Medication__c='a';
        mh.Dose__c='b';
        mh.Currently_taking__c='Yes';
        mh.Frequency__c='Daily';
        
       // insert mh;
        return mh;
       
        
    }
    
}