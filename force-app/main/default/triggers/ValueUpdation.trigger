trigger ValueUpdation on ERA_Line_Item__c ( after insert,after update) {
    
    //if(Trigger.isInsert || Trigger.isUpdate){
        String virtualClassName = 'GlobalVirtualValueUpdationHelper';// Added by Himanshu
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        pluggableClass = [SELECT
                          DeveloperName,
                          Virtual_Class__c
                          FROM Elixir_Pluggable_Classes__mdt
                          WHERE DeveloperName='ValueUpdation' WITH SECURITY_ENFORCED];
        if(!pluggableClass.isEmpty()){
            virtualClassName = pluggableClass[0].Virtual_Class__c;
        }
        Type t = Type.forName(virtualClassName);
        GlobalVirtualValueUpdationHelper valueUpdationCls = (GlobalVirtualValueUpdationHelper) t.newInstance(); 
    if(trigger.isAfter && trigger.isInsert){
        valueUpdationCls.afterInsert(trigger.New);
        }
    if(trigger.isAfter && trigger.isUpdate){
        valueUpdationCls.afterUpdate(trigger.New);
    }
}