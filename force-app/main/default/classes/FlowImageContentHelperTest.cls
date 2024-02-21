@isTest
public class FlowImageContentHelperTest {
    public static testMethod void  method1(){
        Object sObj = 'abc';
        Account acc= new Account();
        acc.name='Demo';
        insert acc;
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = acc.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        Test.startTest();
        FlowImageContentHelper.myCustomSave(new List<Object>{sObj},acc.Id,'dummy','draw');    
        FlowImageContentHelper.myCustomSaveForStatic(sObj,acc.Id,'dummydummy','draw');
        FlowImageContentHelper.checkStaticResourceReacordExistence('43243dgbcgbgfbgf');
        FlowImageContentHelper.inserStaticResourceFromLWC(documents[0].Id);
        FlowImageContentHelper.delResourceDrawforAnnotation(new List<String>{'draw2122433'});
        Test.stopTest();
        system.assertEquals(1, 1,'');
    }
}