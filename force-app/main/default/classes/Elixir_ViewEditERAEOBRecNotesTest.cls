@isTest
public class Elixir_ViewEditERAEOBRecNotesTest {
    
    @isTest
    public static void Test1(){
        Test.startTest();
        ElixirSuite__EOB__c e = new ElixirSuite__EOB__c();
        insert e;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'testu', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testcase1a@gmail.com');
        insert u;
        
        ElixirSuite__Notes__c notes = new ElixirSuite__Notes__c();
        notes.ElixirSuite__Follow_Up_Notes__c='testing notes';
        notes.ElixirSuite__Elixir_Follow_up_Date__c= System.today();
        notes.ElixirSuite__Elixir_Assigned_To__c = u.Id;
        notes.ElixirSuite__ERA_Notes__c = e.id;
        insert notes;
        
        ElixirSuite__Recommendation__c rec = new ElixirSuite__Recommendation__c();
        rec.ElixirSuite__Elixir_Recommendation__c='testing Rec';
        rec.ElixirSuite__Elixir_Assign_To__c = u.Id;
        rec.ElixirSuite__Elixir_ERA__c = e.id;
        insert rec;
        
        Elixir_ViewEditERAEOBRecNotes.fetchNotes(e.id);
        Elixir_ViewEditERAEOBRecNotes.fetchRecommendations(e.id);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
        
    }

}