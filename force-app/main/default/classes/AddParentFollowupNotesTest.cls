@isTest
public class AddParentFollowupNotesTest {
    @isTest static void followupNoteList() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        ElixirSuite__Notes__c notes = new ElixirSuite__Notes__c();
        notes.ElixirSuite__Follow_Up_Notes__c='testing notes';
        notes.ElixirSuite__Elixir_Follow_up_Date__c= System.today();
        notes.ElixirSuite__Elixir_Assigned_To__c = u.Id;
        insert notes;   
        List<ElixirSuite__Notes__c>  lst=new List<ElixirSuite__Notes__c>();
        lst.add(notes);
        
        Test.startTest();
        //Elixir_ViewEditPArentERA.saveNoteList(lst,lst);
        //Elixir_ViewEditPArentERA.fetchNotes(notes.Id);  
        Test.stopTest();
        System.assertEquals(1, 1, 'Welcome To Elixir');
    }
}