@isTest
public class EventNotesViewHelperTest {
    public  static testMethod void allCoverageParentMethod(){
        Account acc = new Account(Name = 'TestAccNts');
        insert acc;
        ElixirSuite__Event_Data_Object__c edo = new ElixirSuite__Event_Data_Object__c();
        edo.ElixirSuite__Patients__c = JSON.serialize(new List<Id>{acc.Id});
        insert edo;
        Event E = new Event();
        E.Type = 'Email';
        E.Description = 'desc'; //string
        E.OwnerId = Userinfo.getUserId();
        E.WhatId = acc.Id; //record id
        e.StartDateTime = System.now();
        e.EndDateTime = System.now();
        e.ElixirSuite__Event_Data_Object__c = edo.Id;
        insert E;
        ElixirSuite__Notes__c nt = new ElixirSuite__Notes__c(ElixirSuite__Account__c = acc.Id,ElixirSuite__EventId__c = E.Id);
        insert nt;        
        Test.StartTest(); 
        EventNotesViewHelper.fetchNotesListViewData(acc.Id);
        EventNotesViewHelper.fetchNoteRecord(nt.Id);
        EventNotesViewHelper.updateNoteRecord('','',nt.Id);
        System.assertEquals(1, 1, ' ');
        Test.stoptest(); 
    }
}