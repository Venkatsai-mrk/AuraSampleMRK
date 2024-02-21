/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-14-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class PushHl7MessageDataHelper {
public  void myHL7msg(List<HL7__c> sID){
       List<HL7__c> hl7MsgList=new List<HL7__c>();
     
        List<HL7__c> listOfHL7 = [Select Id, Order_ID__c, Full_HL7_Dump_Message__c,Patient_Identification__c,Message_Header__c,Observation_Request__c from HL7__c where Id in :sID WITH SECURITY_ENFORCED];
        for(HL7__c Hl7Msg : listOfHL7){
            if(Hl7Msg.Full_HL7_Dump_Message__c!=null){                 
                Hl7MessageParsing.Parse(Hl7Msg);   
                Hl7MsgList.add(Hl7Msg);
            }            
        }
        DMLManager.updateAsUser(Hl7MsgList);  
        
       /* List<HL7__c> Hl7MsgList=new List<HL7__c>();
        List<HL7__c> listOfHL7 = [Select Id,Full_HL7_Dump_Message__c,Patient_Identification__c,Message_Header__c,Observation_Request__c from HL7__c where Id =: sID WITH SECURITY_ENFORCED];
        for(HL7__c Hl7Msg : listOfHL7){
            if(Hl7Msg.Full_HL7_Dump_Message__c!=null){                 
                Hl7MessageParsing.Parse(Hl7Msg);   
                Hl7MsgList.add(Hl7Msg);
            }            
        }
        //update Hl7MsgList;   
DMLManager.updateAsUser(Hl7MsgList);*/}
}