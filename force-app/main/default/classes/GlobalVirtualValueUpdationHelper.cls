global with sharing virtual class GlobalVirtualValueUpdationHelper {
    
    global virtual void afterInsert(List<ERA_Line_Item__c> eraLineItem){
        afterInsertUpdate(eraLineItem);
    }
    global virtual void afterUpdate(List<ERA_Line_Item__c> eraLineItem){
        afterInsertUpdate(eraLineItem);
    }
    global virtual void afterInsertUpdate(List<ERA_Line_Item__c> eraLineItem){
        String Claim_Line_Items_c;
        set<id> prentsIds=new set<id>();
        
        for(ERA_Line_Item__c tc:eraLineItem){
            System.debug('new '+tc.Claim_Line_Items__c);
            prentsIds.add(tc.Claim_Line_Items__c);
        }
        
        System.debug('set of ids '+prentsIds);
        list<Claim_Line_Items__c >  parentList= new list<Claim_Line_Items__c >();
        list<Claim_Line_Items__c> ParentData = new list<Claim_Line_Items__c>();
        ParentData =[select id,Amount_Paid_by_Insurance__c,Total_Adjustment__c,Total_Allowed_Amount__c from Claim_Line_Items__c 
                     where id IN:prentsIds WITH SECURITY_ENFORCED];
        for(Claim_Line_Items__c c : ParentData){
            for(ERA_Line_Item__c trgInstance : eraLineItem){
                system.debug('meg' + trgInstance.Paid__c);
                c.Amount_Paid_by_Insurance__c=trgInstance.Paid__c;
                system.debug('meg' + c.Amount_Paid_by_Insurance__c);
                //  System.debug('5678 '+trgInstance.Adjustment_Amount_1__c+'2nd '+trgInstance.Adjustment_Amount_2__c); 
                c.Total_Adjustment__c =trgInstance.Adjustment_Amount_1__c+trgInstance.Adjustment_Amount_2__c+trgInstance.Adjustment_Amount_3__c+trgInstance.Adjustment_Amount_4__c+trgInstance.Adjustment_Amount_5__c+trgInstance.Adjustment_Amount_6__c;
                c.Total_Allowed_Amount__c=trgInstance.Total_Allowed_Amount__c;
                parentList.add(c);
            }
            
        }
        if(parentList.size()>0){
            try{
                if(Schema.sObjectType.Claim_Line_Items__c.fields.Amount_Paid_by_Insurance__c.isUpdateable() &&
                   Schema.sObjectType.Claim_Line_Items__c.fields.Total_Adjustment__c.isUpdateable() &&
                   Schema.sObjectType.Claim_Line_Items__c.fields.Total_Allowed_Amount__c.isUpdateable()){
                       update parentList;
                   }
            }
            catch(DMLException e){
                system.debug('Exception has occured! ' +e.getMessage());
            }
        }
    }
}