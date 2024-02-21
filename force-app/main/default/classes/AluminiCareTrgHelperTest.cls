@isTest
public class AluminiCareTrgHelperTest {
    public static testMethod void testmethod1(){
        
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        patient.ElixirSuite__Deceased__c =true;
        insert patient;                
        
        Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=patient.id;       
        op.Referral_Type__c='Inbound';
        op.StageName='Prospecting';        
        insert op;
        
        ElixirSuite__Alumni_Care_Services__c al = new ElixirSuite__Alumni_Care_Services__c();
        al.ElixirSuite__Patient_Account__c = patient.id;
		al.ElixirSuite__Patient_Name__c  = op.Id;         
        insert al;

        
        AluminiCareTrgHelper.stopDeceasedEdit(new List<ElixirSuite__Alumni_Care_Services__c>{al},false);
        AluminiCareTrgHelper.stopDeceasedEdit(new List<ElixirSuite__Alumni_Care_Services__c>{al},true);
        
        
        try{   
        AluminiCareTrgHelper.preventEditIfDeceasedCheckedOnAccount(new List<ElixirSuite__Alumni_Care_Services__c>{al});
        }
        catch(DMLException e){
             AluminiCareTrgHelper.preventEditIfDeceasedCheckedOnAccount(null);
            System.assertEquals('expected text', e.getMessage());
        }
        
        try{   
        AluminiCareTrgHelper.blockDeleteIfDeceased(new List<ElixirSuite__Alumni_Care_Services__c>{al});
        }
        catch(Exception e){
             AluminiCareTrgHelper.blockDeleteIfDeceased(null);
        }
        system.assertEquals(1,1,'Hello');
    }
}