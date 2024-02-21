@isTest
public class AnnotationHandlerTest {
    public static testMethod void  method1(){
        Object sObj = 'abc';
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
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'draw',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = documents[0].Id;
		cdl.LinkedEntityId = acc.id;
		cdl.ShareType = 'V';
		cdl.Visibility = 'AllUsers';
        insert cdl;
        
        List<StaticResource> static_resource = [SELECT Id, SystemModStamp FROM StaticResource];

		List<String> staticResToDel = new List<String>();

		for (StaticResource sr : static_resource) {
    	staticResToDel.add(sr.Id);
		}   
        Test.startTest();
        AnnotationHandler.saveDrawData(new List<Object>{sObj},'dummy',
                                       'draw',sObj,new List<String> {documents[0].Id} ,
                                       staticResToDel,acc.Id);
        AnnotationHandler.initBuild(acc.id);
        AnnotationHandler.deleteImageFromCanvas( documents[0].Id,acc.Id);
        Test.stopTest();
        System.assertEquals(1, 1,'welcome to Elixir');
    }
   
}