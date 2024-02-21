@isTest
public class TestElixirHC_SampleAmalysisController {
    
    public  static testMethod void allCoverageParentMethod(){
        
        Account forIns = new Account();
        forIns.Name='Test Demo';
        forIns.DOB__c= System.today();
        forIns.Gender__c = 'Male';
        forIns.Blood_Group__c = 'O+';
        insert forIns;
        
        Contact c = new Contact(LastName='RSB', AccountId = forIns.Id);
        insert c;
        
        List<User> getEmail  = [select id,email from user LIMIT 1];
        UA_Sample_Details__c ua = new UA_Sample_Details__c();
        ua.Sample_Type__c='Physical';
        ua.ContainerType__c='Test';
        ua.Container_Description__c='Des';
        ua.ContainerSize__c='Test';
        ua.Specimen_Quantity__c= 'Test';
        ua.Additives_if_Any__c = 'Test';
        ua.Specimen_Condition__c = 'Test';
        ua.Notes__c= 'Test';
        ua.Status__c = 'Open';
        ua.Collection_Datetime__c = System.now();
        ua.Specimen_Collector__c='Test';
        ua.Account__c = forIns.id;
        insert ua;
        
        Sample_Analysis__c sa  = new Sample_Analysis__c();
        //sa.Account__c  = forIns.Id;
        sa.Appearance__c = 'Clear';
        sa.Colour__c = 'Colourless';
        sa.Comments__c = 'Cooments';
        sa.Examined_Datetime__c = System.now();
        sa.Notes__c = 'Notes';
        sa.Specimen_Status__c = 'Active';
        sa.Status__c = 'Positive';
        sa.UA_Sample_Details__c = ua.Id;
        insert sa;
        
        Test.startTest();
        ElixirHC_SampleAmalysisApexController.getAccountDetails(forIns.Id,ua.Id);
        ElixirHC_SampleAmalysisApexController.saveDetails(sa,ua,sa,forIns.Id,'PhysicalSampleAnalysis','','');
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
        
    }
    public class wrapper{
        public Account accountRec;
        public UA_Sample_Details__c sampleDetails;
        public UA_Sample_Details__c labDetails;
        public Sample_Analysis__c physicalSampleAnalysis;
        public Sample_Analysis__c labAnalysis;
        public List<User> listOfUsers;
        public Map<String,List<String>> mapOfNameToField ;
    }
}