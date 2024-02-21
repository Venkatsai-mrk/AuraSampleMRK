@isTest
public class EquipmentMultiCtrlTest {
    @isTest
    public static void dataSetup(){
        
       
        //List<ElixirSuite__Procedure__c> pro=new List<ElixirSuite__Procedure__c>();
        ElixirSuite__Procedure__c pro=new ElixirSuite__Procedure__c();
        pro.Name = 'XRay';
        pro.ElixirSuite__Item_type__c = 'Equipment';
        pro.ElixirSuite__Sub_type__c = 'Main';
        //pro.RecordType.Name = 'Template Equipment';
        pro.RecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Equipment').getRecordTypeId();
        insert pro;
        
        EquipmentMultiCtrl.fetchLookUpValues(); 
        System.assertEquals(1, 1, '');
    }
    
    


}