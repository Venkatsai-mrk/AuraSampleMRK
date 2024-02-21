public with sharing class PaymentInformationTriggerHelper {
    
    public static void afterInsert(List<ElixirSuite__Payment_Information__c> newPaymentList) {
        
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Payment_Information__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        
        Set<Id> accIds = new Set<Id>();
        List<ElixirSuite__Payment_Information__c> finPayInfLst = new List<ElixirSuite__Payment_Information__c>();
        Map<Id,ElixirSuite__Payment_Information__c> payIdVsPayRec = new Map<Id,ElixirSuite__Payment_Information__c>();
        
        try{
        for(ElixirSuite__Payment_Information__c payRec : newPaymentList){
            if(payRec.ElixirSuite__Account__c != null && payRec.recordTypeId == recordTypeId){
                accIds.add(payRec.ElixirSuite__Account__c);
                if(payRec.ElixirSuite__Default__c == true){
                    payIdVsPayRec.put(payRec.Id,payRec);
                }
            }
        }
        if(accIds.size() >0 && accIds != null){
            Map<Id,Account> accIdVsAcc = new Map<Id,Account>([SELECT Id ,
                                                              (SELECT Id FROM ElixirSuite__Payment_Information__r) 
                                                              FROM Account
                                                              WHERE Id In: accIds
                                                              WITH SECURITY_ENFORCED]); 
            
            List<ElixirSuite__Payment_Information__c> payInfLst = [SELECT Id,
                                                                   ElixirSuite__Account__c,
                                                                   ElixirSuite__Default__c,
                                                                   recordTypeId
                                                                   FROM ElixirSuite__Payment_Information__c
                                                                   WHERE ElixirSuite__Account__c IN : accIds
                                                                   WITH SECURITY_ENFORCED];
            for(ElixirSuite__Payment_Information__c payRec : payInfLst){     
                Account acc = accIdVsAcc.get(payRec.ElixirSuite__Account__c);
                if(acc.ElixirSuite__Payment_Information__r.size() == 1){
                    payRec.ElixirSuite__Default__c = true;
                    finPayInfLst.add(payRec);
                }
                else if(acc.ElixirSuite__Payment_Information__r.size() >1 && !payIdVsPayRec.isEmpty() && payIdVsPayRec.get(payRec.Id) == null){
                    
                        payRec.ElixirSuite__Default__c = false;
                        finPayInfLst.add(payRec);
                    
                }
            } 
        }
        
        if(finPayInfLst.size() >0 && finPayInfLst != null){
            DMLManager.updateAsUser(finPayInfLst);
        }
    }
        
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    
    public static void afterUpdate(List<ElixirSuite__Payment_Information__c> newPaymentList) {
        
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Payment_Information__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        
        Set<Id> accIds = new Set<Id>();
        List<ElixirSuite__Payment_Information__c> finPayInfLst = new List<ElixirSuite__Payment_Information__c>();
        Map<Id,ElixirSuite__Payment_Information__c> payIdVsPayRec = new Map<Id,ElixirSuite__Payment_Information__c>();
        
        try{
        for(ElixirSuite__Payment_Information__c payRec : newPaymentList){
            if(payRec.ElixirSuite__Account__c != null && payRec.recordTypeId == recordTypeId){
                accIds.add(payRec.ElixirSuite__Account__c);
                if(payRec.ElixirSuite__Default__c == true){
                    payIdVsPayRec.put(payRec.Id,payRec);
                }
            }
        }
        if(accIds.size() >0 && accIds != null){
            Map<Id,Account> accIdVsAcc = new Map<Id,Account>([SELECT Id ,
                                                              (SELECT Id FROM ElixirSuite__Payment_Information__r) 
                                                              FROM Account
                                                              WHERE Id In: accIds
                                                              WITH SECURITY_ENFORCED]); 
            
            List<ElixirSuite__Payment_Information__c> payInfLst = [SELECT Id,
                                                                   ElixirSuite__Account__c,
                                                                   ElixirSuite__Default__c,
                                                                   recordTypeId
                                                                   FROM ElixirSuite__Payment_Information__c
                                                                   WHERE ElixirSuite__Account__c IN : accIds
                                                                   WITH SECURITY_ENFORCED];
            for(ElixirSuite__Payment_Information__c payRec : payInfLst){     
                Account acc = accIdVsAcc.get(payRec.ElixirSuite__Account__c);
                
                if(acc.ElixirSuite__Payment_Information__r.size() >1 && !payIdVsPayRec.isEmpty() && payIdVsPayRec.get(payRec.Id) == null){
                    
                        payRec.ElixirSuite__Default__c = false;
                        finPayInfLst.add(payRec);
                    
                }
            } 
        }
        
        if(finPayInfLst.size() >0 && finPayInfLst != null){
            DMLManager.updateAsUser(finPayInfLst);
        }
    }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    
}