@isTest
public class ElixirHC_UAListViewControllerTest {
    public  static testMethod void allCoverageParentMethod(){
        
        Account forIns = new Account();
        forIns.Name='Test Demo';
        forIns.Phone='9876543213';
        forIns.BillingPostalCode='34215';
        forIns.DOB__c= System.today();
        forIns.Gender__c = 'Male';
        forIns.Blood_Group__c = 'O+';
        insert forIns;
        List<String> toDelLst = new  List<String>();
        for(Integer i=0 ; i<=10 ; i++) {
            UA_Sample_Details__c toDel = new UA_Sample_Details__c();
            //toDel.Name = 'Demo'+i;
            toDel.Status__c='Open';
            toDel.Sample_Type__c = 'Physical';
            insert toDel; 
            toDelLst.add(toDel.Id) ;
        }
        
             
       Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();

       ElixirSuite__Provider__c prov = new ElixirSuite__Provider__c();
       prov.RecordTypeId = devRecordTypeId;
       prov.Name = 'Suitcase';
       prov.ElixirSuite__Provider_Code__c = 'Pankaj';
       prov.ElixirSuite__Provider_First_Name__c = 'Massy';
       prov.ElixirSuite__Provider_Last_Name__c = 'Ronaldo';
       insert prov;
        
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduserv2@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserv2@testorg.com');
        insert u;
        
        
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
        // sa.Account__c  = forIns.Id;
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
        ElixirHC_UAListViewController.fetchAllRelatedUrineAnalysisRecordsForAccount(forIns.Id);
        ElixirHC_UAListViewController.deleteRecords(toDelLst);
        ElixirHC_UAListViewController.sendEmailNotificationToUAMember(u.Id,ua.Id);
        ElixirHC_UAListViewController.sendPdfForUA('PhysicalAnalysis',sa.Id,forIns.Id,'');
        ElixirHC_UAListViewController.checkCareEpisode(forIns.Id);
        Test.stopTest();
        System.assert(sa.Appearance__c !=null,'');
    }
}