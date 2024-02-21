public class paymentLineHelper {
  /*  public static void opportunitycheck(List<Payment_Line__c> paymentline)
    {
        system.debug('Enter');
        set<id> oppid=new set<id>();
        
        for(Payment_Line__c p:paymentline)
        {
            if(p.Opportunity__c!=null || p.Opportunity__c!='')
            oppid.add(p.Opportunity__c);
           
        }
        
        List<Payment_Schedule__c> paymentschedule=new List<Payment_Schedule__c>();
        if(Schema.sobjecttype.Payment_Schedule__c.isAccessible() 
                          && Schema.sObjectType.Payment_Schedule__c.fields.Opportunity__c.isAccessible())
        {
               paymentschedule=[select id,Opportunity__c,Name from Payment_Schedule__c where Opportunity__c in:oppid];
        }
     
       Map<id,Payment_Schedule__c> paymnetschedulemap=new Map<id,Payment_Schedule__c>();
        paymnetschedulemap.putAll(paymentschedule);
        
        for(Payment_Line__c p:paymentline)
        {     //opp related payment schedule 
            if(paymentschedule.size()>0)
            {
               // if(p.Payment_Schedule__c!=paymentschedule.id)
                    if(!paymnetschedulemap.containskey(p.Payment_Schedule__c))
            {
                p.Payment_Schedule__c.addError('Please choose Related Payment schedule');
            }
            }
            
            
        }
    
    
    
    }*/
    
    

}