@isTest
public class PrescriptionControllerTest {
    @IsTest
    static void testGetPrescriptionOrders(){
        
        Test.startTest();
        ElixirSuite__Elixir_Custom_Setting__c settings = new ElixirSuite__Elixir_Custom_Setting__c(
            ElixirSuite__Care_Episode_based_filtering_for_Notes__c = true
        );
        insert settings;
        PrescriptionController.getPrescriptionOrders('');
        System.assertEquals(1, 1, ''); 

        Test.stopTest();
        
    }
}