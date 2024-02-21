public with sharing class newOrderScreenController {
    
    
    @AuraEnabled
    public static String saveOrder(String orderLst, String accountId){
        
        System.debug('saveOrder****'+orderLst);
        
        Map<String, Object> objDataLst =(Map<String, Object>) JSON.deserializeUntyped(orderLst);
        List<Object> apexDataLst = (List<Object>) objDataLst.get('keysToSave');
        List<ElixirSuite__Inventory__c> lstInsInv = new List<ElixirSuite__Inventory__c >();
        List<ElixirSuite__Lot_Item__c> lotUpdLst = new List<ElixirSuite__Lot_Item__c>();
        List<ElixirSuite__Lot_Line_Items__c> lotLineUpdLst = new List<ElixirSuite__Lot_Line_Items__c>();
        ElixirSuite__Order__c ordRec = new ElixirSuite__Order__c();
        try{
            
            Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
        String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
        if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
        String careStatus = 'Active';

        string querystr = '';
        querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accountId WITH SECURITY_ENFORCED order by ';
        querystr += careFilter ;
        List<ElixirSuite__Visits__c> lst_visits = database.query(querystr);
            
            
            ordRec.ElixirSuite__Order_Type__c = 'Inventory Order';
            ordRec.ElixirSuite__Patient__c = accountId;
            ordRec.ElixirSuite__Order_Date__c = System.today();
            if(!lst_visits.isEmpty())
          {
               ordRec.ElixirSuite__Care_Episode__c =lst_visits[0].Id;
          }
            //insert ordRec;
            if(ordRec != null){
                DMLManager.insertAsUser(ordRec);
            }
            Map<string,Integer> lotItemVsReq = new Map<string,Integer>();
            for(Object obj : apexDataLst){
                
                
                Map<String,Object> mpData = ( Map<String,Object>) obj;
                System.debug('mpData***'+mpData);
                ElixirSuite__Inventory__c invRec = new ElixirSuite__Inventory__c();
                
                invRec.ElixirSuite__Procedure_Codes__c  = String.valueof(mpData.get('proid'));
                invRec.ElixirSuite__Lot_Item__c  = String.valueof(mpData.get('eid')); // assign the lot item id here
                invRec.ElixirSuite__Account__c = accountId;
                invRec.ElixirSuite__Order__c = ordRec.Id;
                invRec.ElixirSuite__Order_Line_Item_Date__c = System.today();
                
                invRec.ElixirSuite__Lot_Number__c  = String.valueof(mpData.get('Lot'));
                if(!string.isBlank(String.valueof(mpData.get('totalPrice')))){
                invRec.ElixirSuite__Total_Price__c  = Integer.valueof(mpData.get('totalPrice'));
                }
                invRec.ElixirSuite__Inventory_Item_Name__c  = String.valueof(mpData.get('Name'));
                invRec.ElixirSuite__Units_Procured__c  = Integer.valueof(mpData.get('req'));
                
                String lotItemId = String.valueof(mpData.get('eid'));
                
                Integer rq = Integer.valueof(mpData.get('req'));
                lotItemVsReq.put(lotItemId,rq);
                lstInsInv.add(invRec);
            }
            
            if(lstInsInv.size() >0 && lstInsInv != null){
                DMLManager.insertAsUser(lstInsInv);
            }
            
            Map<String,ElixirSuite__Inventory__c> lotVSInventory = new Map<String,ElixirSuite__Inventory__c>();
            
            for(ElixirSuite__Inventory__c invRec : lstInsInv){
                lotVSInventory.put(invRec.ElixirSuite__Lot_Item__c,invRec);
            }
            
            List<ElixirSuite__Lot_Item__c> lotItemRecLst = [select id,name,ElixirSuite__Available_Qty__c from ElixirSuite__Lot_Item__c where id IN: lotItemVsReq.keyset() WITH SECURITY_ENFORCED];
            for(ElixirSuite__Lot_Item__c lotItemRec:lotItemRecLst){
                Integer rq = lotItemVsReq.get(lotItemRec.Id);
                lotItemRec.ElixirSuite__Available_Qty__c =  lotItemRec.ElixirSuite__Available_Qty__c - rq;
                lotUpdLst.add(lotItemRec);
            }
            List<ElixirSuite__Lot_Line_Items__c> eqpLn = [SELECT Id, 
                                                          ElixirSuite__Available__c, 
                                                          ElixirSuite__Item_Name__c 
                                                          FROM ElixirSuite__Lot_Line_Items__c 
                                                          WHERE ElixirSuite__Item_Name__c IN: lotItemVsReq.keyset()
                                                          AND ElixirSuite__Available__c=true
                                                          AND ElixirSuite__In_Maintenance__c=false
                                                          WITH SECURITY_ENFORCED];
            Map<String,List<ElixirSuite__Lot_Line_Items__c>> lotVSLotlineitem = new Map<String,List<ElixirSuite__Lot_Line_Items__c>>();
            for(ElixirSuite__Lot_Line_Items__c rec:eqpLn){
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
            for(string s:lotItemVsReq.keyset()){
                List<ElixirSuite__Lot_Line_Items__c> nList = lotVSLotlineitem.get(s);
                
                for(integer i=0;i<lotItemVsReq.get(s);i++){
                    
                    nList[i].ElixirSuite__Available__c = false;
                     nList[i].ElixirSuite__Order_Line_Item__c = (lotVSInventory.get(s)).Id;
                    lotLineUpdLst.add(nList[i]);
                }
            }
            
            
            
            if(lotUpdLst.size() >0 && lotUpdLst != null){
                ElixirSuite.DeceasedGlobalStopRecursion.run = false;
                DMLManager.updateAsUser(lotUpdLst);
            }
            
            if(lotLineUpdLst.size() >0 && lotLineUpdLst != null){
                DMLManager.updateAsUser(lotLineUpdLst);
            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        return ordRec.Id;  
        
    }
    
}