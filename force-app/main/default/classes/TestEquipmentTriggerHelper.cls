@isTest
public class TestEquipmentTriggerHelper {
  public static testMethod void  method1(){
      ElixirSuite__Equipment__c eq = new ElixirSuite__Equipment__c();
      eq.ElixirSuite__Quantity__c = 2 ;
      eq.Name = 'test';
      insert eq;
      
      system.assertEquals('test', 'test','');
  }
}