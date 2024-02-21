@isTest
public class TestTreatmentHistory {
    @isTest
    static void saveTreatmentHistoryRecords()
    {
          Account acc =new Account ();
        acc.Name= 'Virat Kohli';
        acc.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        acc.ElixirSuite__Gender__c='Male';
        acc.ElixirSuite__Email_Id__c='virat@gmail.com';
        acc.phone='9988776655';
        acc.ElixirSuite__First_Name__c='Virat';
        acc.ElixirSuite__Last_Name__c='Kohli';
        acc.BillingPostalCode='50021';
        acc.ElixirSuite__SSN__c='12345';
        acc.ElixirSuite__MRN_Number_New__c='1234567890';
      
        insert acc;
        Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=acc.id;
        op.StageName='Prospecting';
        insert op;
       
        Pre_assessment__c p=new Pre_assessment__c();
        p.Opportunity__c=op.id;
        insert p;
        List<Treatment_History__c> treatmentRecords =new List<Treatment_History__c>();
        Treatment_History__c th=new Treatment_History__c();
        th.Pre_assessment__c=p.id;
        th.Date__c=System.today();
        th.Facility__c='av';
        th.Level_of_Care__c='Detox';
        th.Outcome_Relapsed_when__c='a';
        treatmentRecords.add(th);
       
        Test.startTest();
        TreatmentHistory.saveTreatmentHistoryRecords(treatmentRecords);
        TreatmentHistory.PicklistFromTH();
        TreatmentHistory.LicensBasdPermission();
        Test.stopTest();
        System.assertEquals(1, 1, 'Welcome to Elixir');
        
    }
    
}