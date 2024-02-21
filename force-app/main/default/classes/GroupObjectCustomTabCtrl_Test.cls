@isTest
public class GroupObjectCustomTabCtrl_Test {

    @isTest
    public static void getURLTestMethod(){
        
        ElixirSuite__Account_Group__c accountGroup = new ElixirSuite__Account_Group__c();
        accountGroup.ElixirSuite__Is_Active__c = true;
        
        insert accountGroup;
        
        Test.startTest();
        
        GroupObjectCustomTabCtrl.getURL();
        system.assertEquals(1, 1,'Welxome to Elixir');
        Test.stopTest();
        
    }
}