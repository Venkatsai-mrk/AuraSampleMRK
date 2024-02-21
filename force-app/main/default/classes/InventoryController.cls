/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class InventoryController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getInventoryType(){
        
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = ElixirSuite__Procedure__c.ElixirSuite__Sub_type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        try{
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }  
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
        return pickListValuesList;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static String getInventoryLabel(){
        String res='';
        try{
            Elixir_Custom_Setting__c mc = Elixir_Custom_Setting__c.getOrgDefaults();
            if(mc.Inventory_Order_Type__c!=null){
                res= mc.Inventory_Order_Type__c;
            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        System.debug('res****'+res);
        return res;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getInventoryNames(string strInventoryType){
        List<ElixirSuite__Procedure__c> lstInventory= new List<ElixirSuite__Procedure__c>();
        
        
            lstInventory = [select Id, Name, (select id from ElixirSuite__Inventory_Lot_Items__r
            ), ElixirSuite__Quantity__c,ElixirSuite__Item_type__c,ElixirSuite__Sub_type__c, recordtype.name 
            from ElixirSuite__Procedure__c 
            where ElixirSuite__Item_type__c = 'Inventory' 
            and ElixirSuite__Sub_type__c =:strInventoryType
            and Id in(select ElixirSuite__Procedure_Codes__c from ElixirSuite__Lot_Item__c where ElixirSuite__Available_Qty__c > 0) WITH SECURITY_ENFORCED];
        
        system.debug('lstInventory'+lstInventory); //added by Anmol
        List<String> inventoryNames = new List<String>();
        try{
            for( ElixirSuite__Procedure__c obj : lstInventory){
                inventoryNames.add(obj.name);
            }  
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        System.debug('inventoryNames'+inventoryNames);
        return inventoryNames;    
    }

    @AuraEnabled(cacheable=true)
    public static String getProcedureId(string procName){

        ElixirSuite__Procedure__c procRec= new ElixirSuite__Procedure__c();
        
        string procId;
        
        procRec = [select Id, Name, ElixirSuite__Quantity__c,ElixirSuite__Item_type__c,ElixirSuite__Sub_type__c, recordtype.name from ElixirSuite__Procedure__c where ElixirSuite__Item_type__c = 'Inventory' and Name =:procName WITH SECURITY_ENFORCED];

        procId = procRec.Id;

        return procId;

    }

        @AuraEnabled(cacheable=true)
    public static List<String> getInventoryLotNumber(String procId ){
        
    List<ElixirSuite__Lot_Item__c> lstInventory= [SELECT Id, Name, ElixirSuite__Ordered_Quantity__c, ElixirSuite__Available_Qty__c, ElixirSuite__Procedure_Codes__c , ElixirSuite__Lot_Number__c FROM ElixirSuite__Lot_Item__c where ElixirSuite__Procedure_Codes__c = :procId and ElixirSuite__Available_Qty__c > 0 WITH SECURITY_ENFORCED];
    system.debug('lstInventory'+lstInventory);
    List<String> InventoryTypeLot = new List<String>();
    try{
        for( ElixirSuite__Lot_Item__c obj : lstInventory){
            InventoryTypeLot.add(obj.Name);
        }  
    }
    catch(Exception e){
        ExceptionLog.logError(e);
    }
    System.debug('InventoryTypeLot'+InventoryTypeLot);
    return InventoryTypeLot;  
        
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getTotalPrice(String procId , Decimal unitReq ){
        
        Decimal totalPrice ;
        try{
        ElixirSuite__Actual_Price__c actualPriceRec = [select id,ElixirSuite__Procedure__c,ElixirSuite__List_Price__c 
                                        from ElixirSuite__Actual_Price__c where ElixirSuite__Procedure__c= :procId WITH SECURITY_ENFORCED];
    system.debug('actualPriceRec'+actualPriceRec);
    totalPrice = actualPriceRec.ElixirSuite__List_Price__c * unitReq;
        
    }
    catch(Exception e){
        ExceptionLog.logError(e);
    }
    return totalPrice;
        
    }

 
    
    @AuraEnabled
    public static Decimal getLotAvailable(string lotNum , string procId){
        
        Decimal sum = 0;
        try{
        List<ElixirSuite__Lot_Item__c> eq =  [SELECT Id, Name, ElixirSuite__Ordered_Quantity__c, ElixirSuite__Available_Qty__c, ElixirSuite__Procedure_Codes__c , ElixirSuite__Lot_Number__c FROM ElixirSuite__Lot_Item__c where ElixirSuite__Procedure_Codes__c = :procId and Name = :lotNum WITH SECURITY_ENFORCED];
            
            List<ElixirSuite__Lot_Line_Items__c> eqpLn = [SELECT Id, 
                                                          ElixirSuite__Available__c, 
                                                          ElixirSuite__Item_Name__c 
                                                          FROM ElixirSuite__Lot_Line_Items__c 
                                                          WHERE ElixirSuite__Item_Name__c =: eq[0].Id
                                                          AND ElixirSuite__Available__c=true
                                                          AND ElixirSuite__In_Maintenance__c=false
                                                          WITH SECURITY_ENFORCED];
            
            Decimal lotLineItemSize = eqpLn.size();
            
        System.debug('eq in getLotAvailable'+eq);
       /* for(ElixirSuite__Lot_Item__c eqp : eq){
            
            sum = sum + eqp.ElixirSuite__Available_Qty__c;
            
        }*/
            sum = sum + lotLineItemSize;
    }
        catch(Exception e){
            ExceptionLog.logError(e);

             }
        System.debug('getLotAvailable sum : '+sum);
        return sum;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static String getLotId(string ty,string lt){
        
        String sid;
        try{
     

        ElixirSuite__Lot_Item__c lotRec= [SELECT Id, Name, ElixirSuite__Ordered_Quantity__c, ElixirSuite__Available_Qty__c, ElixirSuite__Procedure_Codes__c , ElixirSuite__Lot_Number__c FROM ElixirSuite__Lot_Item__c where Name = :lt and ElixirSuite__Procedure_Codes__c=:ty WITH SECURITY_ENFORCED];
        
        sid = lotRec.Id;
    }
        catch(Exception e){
            ExceptionLog.logError(e);

             }
        
        return sid;
        
    }
    
    
    
}