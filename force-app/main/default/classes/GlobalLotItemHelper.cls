global with sharing virtual class GlobalLotItemHelper {
    global virtual void beforeInsert(List<Lot_Item__c> newLotItemList){
        LotItemTriggerHelper.beforeInsert(newLotItemList);
    }
    global virtual void beforeUpdate(List<Lot_Item__c> newLotItemList, Map<Id,Lot_Item__c> lotOldMap){
        LotItemTriggerHelper.beforeUpdate(newLotItemList,lotOldMap);
    }
    global virtual void afterDelete(List<Lot_Item__c> oldLotItemList){
        LotItemTriggerHelper.afterDeleteQuantityUpdate(oldLotItemList);
    }
    global virtual void afterUndelete(List<Lot_Item__c> undeletedLotItemList){
        LotItemTriggerHelper.afterUndeleteQuantityUpdate(undeletedLotItemList);
    }
     global virtual void afterInsert(List<Lot_Item__c> newLotItemList){
        LotItemTriggerHelper.afterInsert(newLotItemList);
    }
    global virtual void afterUpdate(List<Lot_Item__c> newLotItemList,Map<Id,Lot_Item__c> lotOldMap){
        LotItemTriggerHelper.afterUpdate(newLotItemList,lotOldMap);
    }
}