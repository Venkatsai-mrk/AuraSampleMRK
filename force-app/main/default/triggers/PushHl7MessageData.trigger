trigger PushHl7MessageData on HL7__c (after insert) {
    if(System.FeatureManagement.checkPermission('DataMigration')) return; //LX3-6835 - Bypass the trigger execution during data migration
    /* PushHl7MessageDataHelper pushHelp = new PushHl7MessageDataHelper();
    if(trigger.isInsert){       
        pushHelp.myHL7msg(Trigger.new);     
    }*/
    /*
    if(trigger.isUpdate){
         for(HL7__c Hl7Msg:[Select Id,Full_HL7_Dump_Message__c,Patient_Identification__c,Message_Header__c,Observation_Request__c from HL7__c where Id in :Trigger.new]){             
             if(Hl7Msg.Full_HL7_Dump_Message__c!=null){             
                 HL7__c Hl7Msgold=Trigger.oldMap.get(Hl7Msg.ID);                
                 if(Hl7Msgold.Full_HL7_Dump_Message__c==null)
                      Hl7MessageParsing.Parse(Hl7Msg);
             }
         }             
     }*/
     String virtualClassName = 'GlobalPushHl7MessageData';// Added in Review
    List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
    pluggableClass = [SELECT
                    DeveloperName,
                    Virtual_Class__c
                    FROM Elixir_Pluggable_Classes__mdt
                    WHERE DeveloperName='PushHl7MessageData'
                    WITH SECURITY_ENFORCED];
    if(!pluggableClass.isEmpty()){
        virtualClassName = pluggableClass[0].Virtual_Class__c;
    }
    Type t = Type.forName(virtualClassName);
    GlobalPushHl7MessageData  PushHl7MsgData= (GlobalPushHl7MessageData) t.newInstance(); 
    
   /* if(trigger.isInsert){
        PushHl7MsgData.msgInsert(trigger.new);
    }   */
    if(trigger.isAfter && trigger.isInsert){
        PushHl7MsgData.msgInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
        PushHl7MsgData.msgUpdate(trigger.new);
    }            
}