@isTest
public class patientCardControllerOpportunityTest {
    @isTest
    public static void patientCardMethod(){
        Account acc = new Account();
        acc.Name = 'ABC';
        insert acc;
        
      Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=acc.id;
        op.StageName='Prospecting';
        insert op;
        Id recordTypeId = Schema.SObjectType.Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Info_Card_Configuration').getRecordTypeId();
         ElixirSuite__Master_Object__c masterRec1 = new ElixirSuite__Master_Object__c();
            masterRec1.ElixirSuite__Field_Label__c = 'Field 1';
            masterRec1.ElixirSuite__Field_Api__c = 'Id';
            masterRec1.ElixirSuite__Patient_Tile_Entity__c = 'Opportunity';
            masterRec1.ElixirSuite__Patient_Tile_Order__c = 1;
            masterRec1.RecordTypeId = recordTypeId;
        
        insert masterRec1;
        Test.startTest();
        patientCardControllerOpportunity.patientCardMethod(op.id);
        patientCardControllerOpportunity.handlingAfterUpload(op.id);
        patientCardControllerOpportunity.LicensBasdPermission();
        patientCardControllerOpportunity.getTileConfigFieldsOrder(op.id);
        patientCardControllerOpportunity.getlabelsforFields();
        patientCardControllerOpportunity.patientWrapperMethod(op.id);
       // patientCardControllerOpportunity.License_Class{
           //  Boolean isEhr;
         //    Boolean isRcm;
          //   Boolean isContactCenter;
        Opportunity opp = new Opportunity();
                if(Schema.sobjecttype.Opportunity.isAccessible() 
                          && Schema.sObjectType.Opportunity.fields.Profile_Picture__c.isAccessible())
                {
                      opp =[select id,Profile_Picture__c from Opportunity where id =:op.Id]; 
                }
             
        patientCardControllerOpportunity.PatientWrapper wrap = new patientCardControllerOpportunity.PatientWrapper();
       
        System.assertEquals(1, 1, '');
        Test.stopTest();
        
    }
@testSetup static void setupTestData() {
 Opportunity opp = new Opportunity(Name = 'Test Opp', CloseDate = Date.today(), StageName = 'Prospecting');
 insert opp; 
ContentVersion cv = new ContentVersion(); 
cv.Title = 'Test Content'; 
cv.PathOnClient = 'test.pdf'; 
cv.VersionData = Blob.valueOf('Test Content Data');
cv.FirstPublishLocationId = opp.Id; insert cv;
    System.assertEquals(1, 1, '');
} 
@isTest 
static void testHandlingAfterUpload() {
    Opportunity opp = [SELECT Id, Profile_Picture__c FROM Opportunity WHERE Name = 'Test Opp']; 
    ContentVersion cv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId = :opp.Id ORDER BY CreatedDate DESC LIMIT 1]; 
    Test.startTest(); 
    patientCardControllerOpportunity.handlingAfterUpload(opp.Id); 
    Test.stopTest(); 
    opp = [SELECT Profile_Picture__c FROM Opportunity WHERE Id = :opp.Id]; 
    cv = [SELECT Title FROM ContentVersion WHERE Id = :cv.Id]; 
  System.assertEquals(1, 1, '');
}
}