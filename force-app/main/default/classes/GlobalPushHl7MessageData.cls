global with sharing virtual class GlobalPushHl7MessageData {
    global virtual void msgInsert(List<HL7__c> msgLstRecords){
        new PushHl7MessageDataHelper().myHL7msg(msgLstRecords); 

    }
    global virtual void msgUpdate(List<HL7__c> msgListRecords){
        new PushHl7MessageDataHelper().myHL7msg(msgListRecords); 

    }
}