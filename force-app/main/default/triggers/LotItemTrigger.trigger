trigger LotItemTrigger on Lot_Item__c (before insert, before update,after insert, after delete, after undelete , after update) {
    String virtualClassName = 'GlobalLotItemHelper';
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                      DeveloperName,
                      Virtual_Class__c
                      FROM Elixir_Pluggable_Classes__mdt
                      WHERE DeveloperName='LotItemTrigger' WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalLotItemHelper lotItemHelper = (GlobalLotItemHelper) t.newInstance();
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            lotItemHelper.beforeInsert(Trigger.new);
        }
        if(trigger.isUpdate){
            lotItemHelper.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    
    if(trigger.isAfter){
        if(trigger.isInsert){
           lotItemHelper.afterInsert(Trigger.new);  
        }
        if(trigger.isDelete){
            lotItemHelper.afterDelete(Trigger.old);
        }
        else if(trigger.isUndelete){
            lotItemHelper.afterUndelete(trigger.new);
        }
    }

    if(trigger.isAfter && trigger.isUpdate){
        lotItemHelper.afterUpdate(Trigger.new,Trigger.oldMap);
    }
    
}