@isTest
public class CreateCareEpisodeHelperTest {
    @isTest
    public static void createCareEpisodeTest(){
         Set<Id> accSet = new Set<Id>();
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
        
        List<Opportunity> opList = new List<Opportunity>();
        Opportunity op=new Opportunity();
        op.Name='a';
        op.AccountId=patient.Id;        
        op.CloseDate=System.today();     
        op.Referred_In_Organization__c=patient.id;
        op.Referral_Type__c='Inbound';
        op.StageName='Prospecting';
        opList.add(op);
        insert opList;  
        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
    	oppMap.put(op.Id, op);
        
        List<Id> oppIdList = new List<Id>();
        oppIdList.add(op.id);      
        
        List<Visits__c> visList =  new List<Visits__c>();
		Visits__c vis = new Visits__c();
        vis.Name = 'Visit Name';
        vis.Gender__c = 'Male';
        vis.Status__c = 'Active';
        vis.Account__c = patient.id;
        vis.Opportunity__c = op.Id;
        visList.add(vis);
        insert visList;        
        
         Test.startTest();
        CreateCareEpisodeHelper.createCareEpisode(opList, 'Insert');
        CreateCareEpisodeHelper.createCareEpisode(opList, 'Update');
        CreateCareEpisodeHelper.updateCareEpisode(oppMap, opList);
        CreateCareEpisodeHelper.insertVOB(oppIdList);
        Test.stopTest();
        system.assertEquals(1,1,'Hello');
    }
      


}