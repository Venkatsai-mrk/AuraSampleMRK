@isTest
public class TestVisitCloseTrigger {

     @isTest
    public static void ConfigurationTESTmethod(){  
        
           Id recordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        ElixirSuite__Provider__c p = new ElixirSuite__Provider__c();
        p.ElixirSuite__Provider_Code__c = 'code';
        p.RecordTypeId = recordTypeId ;
        insert p;
        
        
        
     Visits__c visit= new Visits__c();
        visit.name= 'TestVisit';
        visit.ElixirSuite__Care_Episode_Location__c= p.id;
       // visit.Level_Of_Care__c=prog.id;
       // visit.Treatment_Center__c = tc1.Id;
       // visit.Rooms__c=room.Id;
       // visit.House__c=h.Id;
        
        insert visit;
        SYSTEM.assert( visit.name!=NULL,'');
    }
}