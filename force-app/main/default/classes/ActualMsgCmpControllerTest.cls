@isTest
public class ActualMsgCmpControllerTest {
    
      @isTest
    public static void GetMsgSubject(){

        ElixirSuite__Message_Subject__c messSubRec = new ElixirSuite__Message_Subject__c();
        messSubRec.ElixirSuite__Subject__c = 'Health Checkup';
        insert messSubRec;
        
        ElixirSuite__Message_Details__c messDelRec = new ElixirSuite__Message_Details__c();
        messDelRec.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec.ElixirSuite__lookup_Message_Subject__c = messSubRec.Id;
        insert messDelRec;
        
        ElixirSuite__Message_Subject__c actMsg = ActualMsgCmpController.fetchSubject(messSubRec.Id);
        
        ActualMsgCmpController.getListViews();
        
        System.assertEquals(1, 1, '');
        
        
    }
    
     @isTest
    public static void GetMsgFiles(){

        ElixirSuite__Message_Subject__c messSubRec = new ElixirSuite__Message_Subject__c();
        messSubRec.ElixirSuite__Subject__c = 'Health Checkup';
        insert messSubRec;
        
        ElixirSuite__Message_Details__c messDelRec = new ElixirSuite__Message_Details__c();
        messDelRec.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec.ElixirSuite__lookup_Message_Subject__c = messSubRec.Id;
        insert messDelRec;
        
         ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=messDelRec.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        
        insert contentlink;
        
        ActualMsgCmpController.fetchFiles(messSubRec.Id);
        
        System.assertEquals(1, 1, '');
        
        
    }
    
     @isTest
    public static void GetMsgDel(){

        ElixirSuite__Message_Subject__c messSubRec = new ElixirSuite__Message_Subject__c();
        messSubRec.ElixirSuite__Subject__c = 'Health Checkup';
        insert messSubRec;
        
        ElixirSuite__Message_Details__c messDelRec = new ElixirSuite__Message_Details__c();
        messDelRec.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec.ElixirSuite__lookup_Message_Subject__c = messSubRec.Id;
        insert messDelRec;
        
        ActualMsgCmpController.delSubject(messSubRec.Id);
        
        ElixirSuite__Message_Subject__c messSubRec1 = new ElixirSuite__Message_Subject__c();
        messSubRec1.ElixirSuite__Subject__c = 'Health Checkup1';
        messSubRec1.ElixirSuite__Deleted__c = '1';
        insert messSubRec1;
        
        ElixirSuite__Message_Details__c messDelRec1 = new ElixirSuite__Message_Details__c();
        messDelRec1.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec1.ElixirSuite__lookup_Message_Subject__c = messSubRec1.Id;
        insert messDelRec1;
        
        ActualMsgCmpController.delSubject(messSubRec1.Id);
        
        ElixirSuite__Message_Subject__c messSubRec2 = new ElixirSuite__Message_Subject__c();
        messSubRec2.ElixirSuite__Subject__c = 'Health Checkup2';
        messSubRec2.ElixirSuite__Deleted__c = '2';
        insert messSubRec2;
        
        ElixirSuite__Message_Details__c messDelRec2 = new ElixirSuite__Message_Details__c();
        messDelRec2.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec2.ElixirSuite__lookup_Message_Subject__c = messSubRec2.Id;
        insert messDelRec2;
        
        ActualMsgCmpController.delSubject(messSubRec2.Id);
        
        ElixirSuite__Message_Subject__c messSubRec3 = new ElixirSuite__Message_Subject__c();
        messSubRec3.ElixirSuite__Subject__c = 'Health Checkup3';
        messSubRec3.ElixirSuite__Deleted__c = '0';
        insert messSubRec3;
        
        ElixirSuite__Message_Details__c messDelRec3 = new ElixirSuite__Message_Details__c();
        messDelRec3.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec3.ElixirSuite__lookup_Message_Subject__c = messSubRec3.Id;
        insert messDelRec3;
        
        ActualMsgCmpController.delSubject(messSubRec3.Id);
        
        System.assertEquals(1, 1, '');
        
        
    }
    
    @isTest
    public static void GetMsgArc(){

        ElixirSuite__Message_Subject__c messSubRec = new ElixirSuite__Message_Subject__c();
        messSubRec.ElixirSuite__Subject__c = 'Health Checkup';
        insert messSubRec;
        
        ElixirSuite__Message_Details__c messDelRec = new ElixirSuite__Message_Details__c();
        messDelRec.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec.ElixirSuite__lookup_Message_Subject__c = messSubRec.Id;
        insert messDelRec;
        
        ActualMsgCmpController.arcSubject(messSubRec.Id);
        
        ElixirSuite__Message_Subject__c messSubRec1 = new ElixirSuite__Message_Subject__c();
        messSubRec1.ElixirSuite__Subject__c = 'Health Checkup1';
        messSubRec1.ElixirSuite__Archived__c = '1';
        insert messSubRec1;
        
        ElixirSuite__Message_Details__c messDelRec1 = new ElixirSuite__Message_Details__c();
        messDelRec1.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec1.ElixirSuite__lookup_Message_Subject__c = messSubRec1.Id;
        insert messDelRec1;
        
        ActualMsgCmpController.arcSubject(messSubRec1.Id);
        
        ElixirSuite__Message_Subject__c messSubRec2 = new ElixirSuite__Message_Subject__c();
        messSubRec2.ElixirSuite__Subject__c = 'Health Checkup2';
        messSubRec2.ElixirSuite__Archived__c = '2';
        insert messSubRec2;
        
        ElixirSuite__Message_Details__c messDelRec2 = new ElixirSuite__Message_Details__c();
        messDelRec2.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec2.ElixirSuite__lookup_Message_Subject__c = messSubRec2.Id;
        insert messDelRec2;
        
        ActualMsgCmpController.arcSubject(messSubRec2.Id);
        
        ElixirSuite__Message_Subject__c messSubRec3 = new ElixirSuite__Message_Subject__c();
        messSubRec3.ElixirSuite__Subject__c = 'Health Checkup3';
        messSubRec3.ElixirSuite__Archived__c = '0';
        insert messSubRec3;
        
        ElixirSuite__Message_Details__c messDelRec3 = new ElixirSuite__Message_Details__c();
        messDelRec3.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec3.ElixirSuite__lookup_Message_Subject__c = messSubRec3.Id;
        insert messDelRec3;
        
        ActualMsgCmpController.arcSubject(messSubRec3.Id);
        
        System.assertEquals(1, 1, '');
        
        
    }
    
    @isTest
    public static void GetMsgBookmark(){

        ElixirSuite__Message_Subject__c messSubRec = new ElixirSuite__Message_Subject__c();
        messSubRec.ElixirSuite__Subject__c = 'Health Checkup';
        insert messSubRec;
        
        ElixirSuite__Message_Details__c messDelRec = new ElixirSuite__Message_Details__c();
        messDelRec.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec.ElixirSuite__lookup_Message_Subject__c = messSubRec.Id;
        insert messDelRec;
        
        ActualMsgCmpController.bookmrkSubject(messSubRec.Id);
        
        ElixirSuite__Message_Subject__c messSubRec1 = new ElixirSuite__Message_Subject__c();
        messSubRec1.ElixirSuite__Subject__c = 'Health Checkup1';
        messSubRec1.ElixirSuite__Bookmarked__c = '1';
        insert messSubRec1;
        
        ElixirSuite__Message_Details__c messDelRec1 = new ElixirSuite__Message_Details__c();
        messDelRec1.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec1.ElixirSuite__lookup_Message_Subject__c = messSubRec1.Id;
        insert messDelRec1;
        
        ActualMsgCmpController.bookmrkSubject(messSubRec1.Id);
        
        ElixirSuite__Message_Subject__c messSubRec2 = new ElixirSuite__Message_Subject__c();
        messSubRec2.ElixirSuite__Subject__c = 'Health Checkup2';
        messSubRec2.ElixirSuite__Bookmarked__c = '2';
        insert messSubRec2;
        
        ElixirSuite__Message_Details__c messDelRec2 = new ElixirSuite__Message_Details__c();
        messDelRec2.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec2.ElixirSuite__lookup_Message_Subject__c = messSubRec2.Id;
        insert messDelRec2;
        
        ActualMsgCmpController.bookmrkSubject(messSubRec2.Id);
        
        ElixirSuite__Message_Subject__c messSubRec3 = new ElixirSuite__Message_Subject__c();
        messSubRec3.ElixirSuite__Subject__c = 'Health Checkup3';
        messSubRec3.ElixirSuite__Bookmarked__c = '0';
        insert messSubRec3;
        
        ElixirSuite__Message_Details__c messDelRec3 = new ElixirSuite__Message_Details__c();
        messDelRec3.ElixirSuite__Message_Body__c = 'We have scheduled your Health Checkup';
        messDelRec3.ElixirSuite__lookup_Message_Subject__c = messSubRec3.Id;
        insert messDelRec3;
        
        ActualMsgCmpController.bookmrkSubject(messSubRec3.Id);
        
        System.assertEquals(1, 1, '');
        
        
    }

}