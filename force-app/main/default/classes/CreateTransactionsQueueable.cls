public class CreateTransactionsQueueable implements Queueable,Database.AllowsCallouts{
	public String recordId;
    public String procedures;
    public Decimal totalAmount;
    public Decimal discountAmount;
    public string cardType;
    
     public CreateTransactionsQueueable(String recordId, String procedures,Decimal totalAmount,Decimal discountAmount, String cardType){
        this.recordId = recordId;
        this.procedures = procedures;
        this.totalAmount = totalAmount;
        this.discountAmount = discountAmount;
        this.cardType = cardType;
    }
    
    
    public void execute(QueueableContext context){
        Master_Transaction__c otherTransaction = new Master_Transaction__c(); 
        otherTransaction.Account__c = recordId;
        otherTransaction.Transaction_Date__c = System.today();
        otherTransaction.Total_Amount_Paid__c = totalAmount;
        otherTransaction.Payment_Type__c = 'Terminal';
        otherTransaction.Discount_Amount__c = discountAmount;
        otherTransaction.ElixirSuite__Mode_of_Payment__c = cardType;
        otherTransaction.ElixirSuite__Reason_Of_Payment__c = 'Applied Payment';
        otherTransaction.ElixirSuite__Payment_Received_By__c='Patient';
        //otherTransaction.Discount_Percentage__c = discountPercent;
        if(Schema.sObjectType.Master_Transaction__c.isCreateable() &&
            Schema.sObjectType.Master_Transaction__c.fields.ElixirSuite__Payment_Received_By__c.isCreateable() &&
            Schema.sObjectType.Master_Transaction__c.fields.ElixirSuite__Reason_Of_Payment__c .isCreateable() &&
            Schema.sObjectType.Master_Transaction__c.fields.ElixirSuite__Mode_of_Payment__c.isCreateable() &&
            Schema.sObjectType.Master_Transaction__c.fields.Discount_Amount__c.isCreateable() &&
            Schema.sObjectType.Master_Transaction__c.fields.Payment_Type__c .isCreateable() &&
            Schema.sObjectType.Master_Transaction__c.fields.Total_Amount_Paid__c.isCreateable() &&
            Schema.sObjectType.Master_Transaction__c.fields.Transaction_Date__c.isCreateable() &&
            Schema.sObjectType.Master_Transaction__c.fields.Account__c.isCreateable()){
            
        insert otherTransaction;
            }
        Map<String, Object> m =   (Map<String, Object>) JSON.deserializeUntyped(procedures);
        List<Object> proceduresList = (List<Object>) m.get('procedures');
        List<ElixirSuite__Transactions__c> transactionsToInsert = new List<ElixirSuite__Transactions__c>();
        for(Object procedure :proceduresList){
            Map<String,Object> proc = (Map<String,Object>) procedure;
            String masterId = (String) proc.get('Id');
            if( proc.get('inputDiscountNew')!=null && Decimal.valueOf(String.valueOf(proc.get('inputDiscountNew')))!=0){
                Decimal additionalDiscount = Decimal.valueOf(String.valueOf(proc.get('inputDiscountNew')));
                ElixirSuite__Transactions__c transactionRec = 
                new ElixirSuite__Transactions__c(
                ElixirSuite__Amount_Paid__c = additionalDiscount ,
                ElixirSuite__Master_Transaction__c = masterId,
                ElixirSuite__Payment_DateTime__c = System.now(),
                ElixirSuite__Type_of_Payment__c = 'Discount',
                ElixirSuite__Payment_Status__c = 'In Progress',
                ElixirSuite__Card_Type__c = cardType,
                ElixirSuite__Other_Transactions__c = otherTransaction.Id,
                ElixirSuite__Payment_Received_By__c = 'Patient');
                transactionsToInsert.add(transactionRec);
            }
            if( proc.get('AmountToBeCharged')!=null && Decimal.valueOf(String.valueOf(proc.get('AmountToBeCharged')))!=0){
                ElixirSuite__Transactions__c transactionRec = new ElixirSuite__Transactions__c();
                transactionRec.Master_Transaction__c = masterId;
                transactionRec.Payment_DateTime__c = System.now();
                transactionRec.Payment_Status__c = 'In Progress';
                transactionRec.ElixirSuite__Payment_Received_By__c = 'Patient';
                transactionRec.Other_Transactions__c = otherTransaction.Id;
                transactionRec.ElixirSuite__Card_Type__c = cardType;
transactionRec.ElixirSuite__Type_of_Payment__c = 'Payment';
                transactionRec.ElixirSuite__Amount_Paid__c = Decimal.valueOf(String.valueOf(proc.get('AmountToBeCharged')));   
                transactionsToInsert.add(transactionRec);
            }
        }
        if(transactionsToInsert!=null && transactionsToInsert.size()>0){
            if(Schema.sObjectType.ElixirSuite__Transactions__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.Master_Transaction__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.Payment_DateTime__c.isCreateable() &&  
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.Payment_Status__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.ElixirSuite__Payment_Received_By__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.Other_Transactions__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.ElixirSuite__Card_Type__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.ElixirSuite__Amount_Paid__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.ElixirSuite__Master_Transaction__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.ElixirSuite__Payment_DateTime__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.ElixirSuite__Type_of_Payment__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.ElixirSuite__Payment_Status__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Transactions__c.fields.ElixirSuite__Other_Transactions__c.isCreateable()){
                insert transactionsToInsert;
        }
    }
}
}