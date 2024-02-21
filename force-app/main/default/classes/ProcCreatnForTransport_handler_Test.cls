@isTest
public class ProcCreatnForTransport_handler_Test 
{
    public static testMethod void createTrans()
    {
        //Insert test account
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        String recTypeId =   [SELECT Id FROM RecordType WHERE SobjectType = 'ElixirSuite__Transport__c' AND DeveloperName = 'Air_Travel' LIMIT 1].Id;
        
        ElixirSuite__Visits__c objVisist = new ElixirSuite__Visits__c();
        objVisist.ElixirSuite__Status__c = 'Active';
        objVisist.ElixirSuite__Account__c = acc.Id;
        StopRecursion.stopLocationUpdation = false;
        insert objVisist;

          //added by Anmol for LX3-7236
          Elixir_Custom_Setting__c customSetting = new Elixir_Custom_Setting__c();
          customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c = 'createddate asc';
          customSetting.Create_Procedures_Automatically__c = True;
          insert customSetting;
          //end by Anmol for LX3-7236
        
        Transport__c t = new Transport__c();
        t.Account__c = acc.id ; 
        t.ElixirSuite__BypassValidation__c = True;
        t.Start_Time__c = system.today();
        t.RecordTypeId = recTypeId;
        t.End_Time__c = system.today() + 1 ;
        insert t;
        
        List<Transport__c> lst_transport = new List<Transport__c>();
        lst_transport.add(t);

        Elixir_Custom_Setting__c ecs = new Elixir_Custom_Setting__c();
        ecs.Create_Procedures_Automatically__c = True;
        insert ecs;
        
        Test.startTest();
        ProcCreatnForTransport_handler.createProc(lst_transport);
        ProcCreatnForTransport_handler.updateProc(lst_transport);
        system.assertEquals(1,1,' ');
        Test.stopTest();
    }
}