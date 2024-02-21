global with sharing virtual class GlobalEquipmentTriggerHelper {
    global virtual void afterInsert(Map<Id,ElixirSuite__Equipment__c> Equipments){
        new EquipmentTriggerHelper().createEquipmentLineItem(Equipments);

    }
}