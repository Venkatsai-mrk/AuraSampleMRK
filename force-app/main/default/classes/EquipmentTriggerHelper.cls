/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing Class EquipmentTriggerHelper{
    
    public void createEquipmentLineItem(Map<Id,ElixirSuite__Equipment__c> Equipments){
        try{
        Map<Id,ElixirSuite__Equipment__c> tempMap = Equipments;
       
        List<ElixirSuite__Equipment_Line_Item__c> EquipmentLineItemsToCreate = new List<ElixirSuite__Equipment_Line_Item__c>();
        if(tempMap.size()>0){
            for(Id eq : tempMap.KeySet()){
             if(tempMap.get(eq).ElixirSuite__Quantity__c!=null){
                    for(Integer i=0;i<Integer.valueOf(tempmap.get(eq).ElixirSuite__Quantity__c);i++){
                        if(Schema.sobjecttype.ElixirSuite__Equipment_Line_Item__c.isCreateable())
                        {
                           EquipmentLineItemsToCreate.add(new ElixirSuite__Equipment_Line_Item__c(ElixirSuite__Equipment_Name__c=eq)); 
                        }
                        
                    }
                }
            }
        }
        if(EquipmentLineItemsToCreate.size()>0){
        if(Schema.sObjectType.ElixirSuite__Equipment_Line_Item__c.isCreateable() &&
        Schema.sObjectType.ElixirSuite__Equipment_Line_Item__c.fields.ElixirSuite__Equipment_Name__c.isCreateable()){
            insert EquipmentLineItemsToCreate;
        }
		  }
        }
            catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
}