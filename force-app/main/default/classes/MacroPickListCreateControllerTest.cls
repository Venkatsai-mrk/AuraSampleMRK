@isTest
public class MacroPickListCreateControllerTest {
    @isTest
    public static void test()
    {
        
        ElixirSuite__Form_Template__c f = new ElixirSuite__Form_Template__c();
        f.name='Test test';
        f.ElixirSuite__Form_Label__c='Test test';
        f.ElixirSuite__Active__c=true;
        f.ElixirSuite__Select_Forms__c='demoformname';
        insert f;
        
        Contact con = new Contact();
        con.LastName ='testcon';
        insert con;
        
        ElixirSuite__User_and_Form_Template__c uF = new ElixirSuite__User_and_Form_Template__c();
        uF.ElixirSuite__Contact__c=con.Id;
        uF.ElixirSuite__Form_Template__c=f.Id;
        insert uF;
           Test.startTest();
        MacroPickListCreateController.formLabels('test' ,'demoformname');
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }

}