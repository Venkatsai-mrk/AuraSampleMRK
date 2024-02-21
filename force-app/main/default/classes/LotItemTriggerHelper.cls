public with sharing class LotItemTriggerHelper {
    
    public static void beforeInsert(List<Lot_Item__c> newLotItemList) {
        for(Lot_Item__c li : newLotItemList){
            String checkNewAvailableQuantity = String.valueOf(li.ElixirSuite__Available_Qty__c);
            if(String.isNotBlank(checkNewAvailableQuantity)){
                li.ElixirSuite__Available_Qty__c.addError('You are not allowed to add a value to Available Quantity');
            }
            else{
                Integer wastageQty = integer.valueOf(li.ElixirSuite__Wastage_Quantity__c);
                if(wastageQty!=null){
                    li.ElixirSuite__Available_Qty__c = li.ElixirSuite__Ordered_Quantity__c - wastageQty;
                }
                else{
                li.ElixirSuite__Available_Qty__c = li.ElixirSuite__Ordered_Quantity__c;
                }
            }
        }
    }
    
    public static void beforeUpdate(List<Lot_Item__c> newLotItemList, Map<Id,Lot_Item__c> lotOldMap) {
        for(Lot_Item__c li : newLotItemList){
            Decimal oldValue = lotOldMap.get(li.Id).ElixirSuite__Ordered_Quantity__c;
            Decimal newValue = li.ElixirSuite__Ordered_Quantity__c;
            Decimal oldValueAvailableQuantity = lotOldMap.get(li.Id).ElixirSuite__Available_Qty__c;
            Decimal newValueAvailableQuantity = li.ElixirSuite__Available_Qty__c;
            
            if(oldValue != newValue){
                li.ElixirSuite__Ordered_Quantity__c.addError('You are not allowed to edit this field once the record is created');
            }
            
            if((oldValueAvailableQuantity != newValueAvailableQuantity) && DeceasedGlobalStopRecursion.run){
                li.ElixirSuite__Available_Qty__c.addError('You are not allowed to edit this field once the record is created');
            }
        }
        
    }
    
    public static void afterDeleteQuantityUpdate(List<Lot_Item__c> oldLotItemList) {
        Set<Id> procedureIdSet = new Set<Id>();
        for(Lot_Item__c lotItem : oldLotItemList) {
            if(lotItem.Procedure_Codes__c != null) {
                procedureIdSet.add(lotItem.Procedure_Codes__c);
            }
        }
        List<Procedure__c> procedureList = [SELECT Id, Quantity__c,ElixirSuite__IsUpdatedFromFlow__c, (SELECT Id, Available_Qty__c FROM Inventory_Lot_Items__r) FROM Procedure__c WHERE Id IN :procedureIdSet WITH SECURITY_ENFORCED];
        List<Procedure__c> proceduresToUpdate = new List<Procedure__c>();
        List<Procedure__c> proceduresToUpdateFalse = new List<Procedure__c>();
        for(Procedure__c procedure : procedureList) {
            Decimal availableQty = 0;
            for(Lot_Item__c lotItem : procedure.Inventory_Lot_Items__r) {
                availableQty += lotItem.Available_Qty__c;
            }
            procedure.ElixirSuite__IsUpdatedFromFlow__c = true;
            procedure.Quantity__c = availableQty;
            proceduresToUpdate.add(procedure);
        }
        if(proceduresToUpdate != NULL && proceduresToUpdate.size() > 0){
            DMLManager.updateAsUser(proceduresToUpdate);
        }
        for(Procedure__c procedure : procedureList) {
            procedure.ElixirSuite__IsUpdatedFromFlow__c = false;
            proceduresToUpdateFalse.add(procedure);
        }
        if(proceduresToUpdateFalse != NULL && proceduresToUpdateFalse.size() > 0){
            DMLManager.updateAsUser(proceduresToUpdateFalse);
        }
        
    }
    public static void afterUndeleteQuantityUpdate(List<Lot_Item__c> undeletedLotItemList) {
        Set<Id> procedureIdSet = new Set<Id>();
        for(Lot_Item__c lotItem : undeletedLotItemList) {
            if(lotItem.Procedure_Codes__c != null) {
                procedureIdSet.add(lotItem.Procedure_Codes__c);
            }
        }
        List<Procedure__c> procedureList = [SELECT Id, Quantity__c,ElixirSuite__IsUpdatedFromFlow__c, (SELECT Id, Available_Qty__c FROM Inventory_Lot_Items__r) FROM Procedure__c WHERE Id IN :procedureIdSet WITH SECURITY_ENFORCED];
        List<Procedure__c> proceduresToUpdate = new List<Procedure__c>();
        List<Procedure__c> proceduresToUpdateFalse = new List<Procedure__c>();
        for(Procedure__c procedure : procedureList) {
            Decimal availableQty = 0;
            for(Lot_Item__c lotItem : procedure.Inventory_Lot_Items__r) {
                availableQty += lotItem.Available_Qty__c;
            }
            procedure.ElixirSuite__IsUpdatedFromFlow__c = true;
            procedure.Quantity__c = availableQty;
            proceduresToUpdate.add(procedure);
        }
        if(proceduresToUpdate != NULL && proceduresToUpdate.size() > 0){
            DMLManager.updateAsUser(proceduresToUpdate);
        }
        for(Procedure__c procedure : procedureList) {
            procedure.ElixirSuite__IsUpdatedFromFlow__c = false;
            proceduresToUpdateFalse.add(procedure);
        }
        if(proceduresToUpdateFalse != NULL && proceduresToUpdateFalse.size() > 0){
            DMLManager.updateAsUser(proceduresToUpdateFalse);
        }
        
    }


    public static void afterUpdate(List<ElixirSuite__Lot_Item__c> newLotItemList,Map<Id,Lot_Item__c> oldMap) {
        
        Map<String,Decimal> newMapIdVSWastageQty = new Map<String,Decimal>();
        Map<String,Decimal> oldMapIdVSWastageQty = new Map<String,Decimal>();
        Map<String,Decimal> changedMapIdVSIncreaseWastageQty = new Map<String,Decimal>();
        Map<String,Decimal> changedMapIdVSDecreaseWastageQty = new Map<String,Decimal>();
        Map<String,Decimal> changedMapIdVSDiff = new Map<String,Decimal>();
        Map<String,String> changedMapIdVSOpr = new Map<String,String>();
        Set<Id> lotItemIds = new Set<Id>();
        List<ElixirSuite__Lot_Line_Items__c> lotLineUpdLst = new List<ElixirSuite__Lot_Line_Items__c>();
        List<ElixirSuite__Lot_Item__c> lotUpdLst = new List<ElixirSuite__Lot_Item__c>();
        try{
        for (ElixirSuite__Lot_Item__c lotItem : newLotItemList) {
            
            if((oldMap.get(lotItem.Id)).ElixirSuite__Wastage_Quantity__c != lotItem.ElixirSuite__Wastage_Quantity__c){
             if(lotItem.ElixirSuite__Wastage_Quantity__c>(oldMap.get(lotItem.Id)).ElixirSuite__Wastage_Quantity__c){
                changedMapIdVSIncreaseWastageQty.put(lotItem.Id,lotItem.ElixirSuite__Wastage_Quantity__c);
                Decimal diff = lotItem.ElixirSuite__Wastage_Quantity__c - (oldMap.get(lotItem.Id)).ElixirSuite__Wastage_Quantity__c;
                changedMapIdVSDiff.put(lotItem.Id,diff);
                 changedMapIdVSOpr.put(lotItem.Id,'Sub');
                lotItemIds.add(lotItem.Id);
            }
                else if((oldMap.get(lotItem.Id)).ElixirSuite__Wastage_Quantity__c == null && lotItem.ElixirSuite__Wastage_Quantity__c!=null){
                    
                    changedMapIdVSIncreaseWastageQty.put(lotItem.Id,lotItem.ElixirSuite__Wastage_Quantity__c);
                Decimal diff = lotItem.ElixirSuite__Wastage_Quantity__c - 0;
                changedMapIdVSDiff.put(lotItem.Id,diff);
                 changedMapIdVSOpr.put(lotItem.Id,'Sub');
                lotItemIds.add(lotItem.Id);
                    
                }
            else if(lotItem.ElixirSuite__Wastage_Quantity__c<(oldMap.get(lotItem.Id)).ElixirSuite__Wastage_Quantity__c){
                changedMapIdVSDecreaseWastageQty.put(lotItem.Id,lotItem.ElixirSuite__Wastage_Quantity__c);
                Decimal diff = (oldMap.get(lotItem.Id)).ElixirSuite__Wastage_Quantity__c - lotItem.ElixirSuite__Wastage_Quantity__c;
                changedMapIdVSDiff.put(lotItem.Id,diff);
                changedMapIdVSOpr.put(lotItem.Id,'Add');
                lotItemIds.add(lotItem.Id);
            }   
            }
            newMapIdVSWastageQty.put(lotItem.Id,lotItem.ElixirSuite__Wastage_Quantity__c);
        }
        
        
        List<ElixirSuite__Lot_Line_Items__c> eqpLn = [SELECT Id, 
                                                          ElixirSuite__Available__c, 
                                                          ElixirSuite__Item_Name__c 
                                                          FROM ElixirSuite__Lot_Line_Items__c 
                                                          WHERE ElixirSuite__Item_Name__c IN: lotItemIds
                                                          AND ElixirSuite__In_Maintenance__c=false WITH SECURITY_ENFORCED];
        
        
        Map<String,List<ElixirSuite__Lot_Line_Items__c>> lotVSLotlineitem = new Map<String,List<ElixirSuite__Lot_Line_Items__c>>();
            Map<String,List<ElixirSuite__Lot_Line_Items__c>> lotVSLotlineitem1 = new Map<String,List<ElixirSuite__Lot_Line_Items__c>>();
            for(ElixirSuite__Lot_Line_Items__c rec:eqpLn){
                if(rec.ElixirSuite__Available__c==true){
                if(lotVSLotlineitem== null){
                    List<ElixirSuite__Lot_Line_Items__c> nList = new List<ElixirSuite__Lot_Line_Items__c>();
                    nList.add(rec);
                    lotVSLotlineitem.put(rec.ElixirSuite__Item_Name__c, nList); 
                }else{
                    if(lotVSLotlineitem.get(rec.ElixirSuite__Item_Name__c) == null){
                        List<ElixirSuite__Lot_Line_Items__c> nList = new List<ElixirSuite__Lot_Line_Items__c>();
                        nList.add(rec);
                        lotVSLotlineitem.put(rec.ElixirSuite__Item_Name__c, nList);  
                    }else{
                        List<ElixirSuite__Lot_Line_Items__c> nList = lotVSLotlineitem.get(rec.ElixirSuite__Item_Name__c);
                        nList.add(rec);
                        lotVSLotlineitem.put(rec.ElixirSuite__Item_Name__c, nList); 
                    }
                    
                }
            }
                else{
                    
                    if(lotVSLotlineitem1== null){
                    List<ElixirSuite__Lot_Line_Items__c> nList = new List<ElixirSuite__Lot_Line_Items__c>();
                    nList.add(rec);
                    lotVSLotlineitem1.put(rec.ElixirSuite__Item_Name__c, nList); 
                }else{
                    if(lotVSLotlineitem1.get(rec.ElixirSuite__Item_Name__c) == null){
                        List<ElixirSuite__Lot_Line_Items__c> nList = new List<ElixirSuite__Lot_Line_Items__c>();
                        nList.add(rec);
                        lotVSLotlineitem1.put(rec.ElixirSuite__Item_Name__c, nList);  
                    }else{
                        List<ElixirSuite__Lot_Line_Items__c> nList = lotVSLotlineitem1.get(rec.ElixirSuite__Item_Name__c);
                        nList.add(rec);
                        lotVSLotlineitem1.put(rec.ElixirSuite__Item_Name__c, nList); 
                    }
                    
                }
                    
                }
            }
        
        
        System.debug('changedMapIdVSIncreaseWastageQty***'+changedMapIdVSIncreaseWastageQty);
        System.debug('changedMapIdVSDecreaseWastageQty***'+changedMapIdVSDecreaseWastageQty);
        System.debug('changedMapIdVSDiff***'+changedMapIdVSDiff);
        if(changedMapIdVSIncreaseWastageQty!= null){
        for(string s:changedMapIdVSIncreaseWastageQty.keyset()){
                List<ElixirSuite__Lot_Line_Items__c> nList = lotVSLotlineitem.get(s);
                
                for(integer i=0;i<changedMapIdVSDiff.get(s);i++){
                    
                    nList[i].ElixirSuite__Available__c = false;
                    lotLineUpdLst.add(nList[i]);
                }
            }
    }
        
           if(changedMapIdVSDecreaseWastageQty!= null){
        for(string s:changedMapIdVSDecreaseWastageQty.keyset()){
                List<ElixirSuite__Lot_Line_Items__c> nList = lotVSLotlineitem1.get(s);
                
                for(integer i=0;i<changedMapIdVSDiff.get(s);i++){
                    
                    nList[i].ElixirSuite__Available__c = true;
                    lotLineUpdLst.add(nList[i]);
                }
            }
    }
        
        if(changedMapIdVSDiff!= null){
            List<ElixirSuite__Lot_Item__c> updLotItemLst = [SELECT Id,
                                                            ElixirSuite__Available_Qty__c
                                                            FROM ElixirSuite__Lot_Item__c
                                                            WHERE Id=:changedMapIdVSDiff.keyset()
                                                            WITH SECURITY_ENFORCED];
            for(ElixirSuite__Lot_Item__c lotItemRec:updLotItemLst){
                if(changedMapIdVSOpr.get(lotItemRec.Id) == 'Sub'){
                lotItemRec.ElixirSuite__Available_Qty__c = lotItemRec.ElixirSuite__Available_Qty__c - changedMapIdVSDiff.get(lotItemRec.Id);
                }
                else{
                    lotItemRec.ElixirSuite__Available_Qty__c = lotItemRec.ElixirSuite__Available_Qty__c + changedMapIdVSDiff.get(lotItemRec.Id);
                }
                lotUpdLst.add(lotItemRec);
            }
            
        }
        
        System.debug('lotLineUpdLst***'+lotLineUpdLst);
        System.debug('lotLineUpdLst***size'+lotLineUpdLst.size());
        
        if(lotLineUpdLst.size() >0 && lotLineUpdLst != null){
                DMLManager.updateAsUser(lotLineUpdLst);
            }
        
        if(lotUpdLst.size() >0 && lotUpdLst != null){
                ElixirSuite.DeceasedGlobalStopRecursion.run = false;
                DMLManager.updateAsUser(lotUpdLst);
            }
        
    }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        
    }



    public static void afterInsert(List<ElixirSuite__Lot_Item__c> newLotItemList) {

        ID jobID = System.enqueueJob(new LotItemQueuable(newLotItemList));
        System.debug('jobID'+jobID);

     /*   List<ElixirSuite__Lot_Line_Items__c> lotLineItems = new List<ElixirSuite__Lot_Line_Items__c>();
        
        for (ElixirSuite__Lot_Item__c lotItem : newLotItemList) {
            Integer orderedQuantity = integer.valueOf(lotItem.ElixirSuite__Ordered_Quantity__c);
            if (orderedQuantity > 0) {
                for (Integer i = 0; i < orderedQuantity; i++) {
                    ElixirSuite__Lot_Line_Items__c lineItem = new ElixirSuite__Lot_Line_Items__c();
                    lineItem.ElixirSuite__Item_Name__c = lotItem.Id;
                    lineItem.ElixirSuite__Arrival_Date__c = lotItem.ElixirSuite__Arrival_Date__c;
                    lineItem.ElixirSuite__Expire_Date__c = lotItem.ElixirSuite__Expiry_Date__c;
                    lineItem.ElixirSuite__Available__c = true;
                    lotLineItems.add(lineItem);
                }
            }
        }
        if (!lotLineItems.isEmpty()) {
            DMLManager.insertAsUser(lotLineItems);
        }*/
    }
}