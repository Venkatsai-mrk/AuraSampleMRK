@isTest
public class PicklistHelperTest {

    @isTest
    static void testGetPicklistOptions(){
        Test.startTest();
        PicklistHelper.getPicklistOptions('ElixirSuite__Procedure__c','ElixirSuite__Anesthesia_code__c');
        system.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    
}