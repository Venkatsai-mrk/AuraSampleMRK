public class LotItemQueuable implements Queueable{
    public List<ElixirSuite__Lot_Item__c> LotItemsList ; 
      public LotItemQueuable(List<ElixirSuite__Lot_Item__c> LotItemsList){
          this.LotItemsList = LotItemsList ;  
      }
      public void execute(QueueableContext context){
          List<ElixirSuite__Lot_Line_Items__c> lotLineItems = new List<ElixirSuite__Lot_Line_Items__c>();
          List<ElixirSuite__Lot_Line_Items__c> wastageLotLineItems = new List<ElixirSuite__Lot_Line_Items__c>();
          Map<String,Decimal> lotIdVSWastageQty = new Map<String,Decimal>();
          
          for (ElixirSuite__Lot_Item__c lotItem : LotItemsList) {
              Integer wastageQty = integer.valueOf(lotItem.ElixirSuite__Wastage_Quantity__c);
              Integer orderedQuantity;
              if(wastageQty!=null){
                  lotIdVSWastageQty.put(lotItem.Id,lotItem.ElixirSuite__Wastage_Quantity__c);
              orderedQuantity = integer.valueOf(lotItem.ElixirSuite__Ordered_Quantity__c) - wastageQty;
              }
              else{
                  orderedQuantity = integer.valueOf(lotItem.ElixirSuite__Ordered_Quantity__c);
              }
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
          }
          
          if(lotIdVSWastageQty!= null){
              
              for (ElixirSuite__Lot_Item__c lotItem : LotItemsList) {
                  if(lotIdVSWastageQty.get(lotItem.Id)!=null){
                      Integer wastageQty = integer.valueOf(lotIdVSWastageQty.get(lotItem.Id));
                      
                      if (wastageQty > 0) {
                  for (Integer i = 0; i < wastageQty; i++) {
                      ElixirSuite__Lot_Line_Items__c lineItem = new ElixirSuite__Lot_Line_Items__c();
                      lineItem.ElixirSuite__Item_Name__c = lotItem.Id;
                      lineItem.ElixirSuite__Arrival_Date__c = lotItem.ElixirSuite__Arrival_Date__c;
                      lineItem.ElixirSuite__Expire_Date__c = lotItem.ElixirSuite__Expiry_Date__c;
                      lineItem.ElixirSuite__Available__c = false;
                      wastageLotLineItems.add(lineItem);
                  }
              }
                      
                  }
              }
              
          }
          
          if (!wastageLotLineItems.isEmpty()) {
              DMLManager.insertAsUser(wastageLotLineItems);
          }
      }
  }