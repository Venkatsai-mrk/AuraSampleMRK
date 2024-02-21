public with sharing class dualBoxcontroller {
    
    @AuraEnabled
    public static wrapper getselectOptions(String Cid) { 
        string Qutes ;
        wrapper objwrap = new wrapper();
        try{
        Resubmission_Codes__mdt[] obj = [SELECT MasterLabel, QualifiedApiName, Quotes__c 
                                         FROM Resubmission_Codes__mdt 
                                         WHERE MasterLabel = 'DualboxValues'
                                         WITH SECURITY_ENFORCED];
        for(Resubmission_Codes__mdt rsc : obj){
            Qutes = rsc.Quotes__c;
        }
        List < String > allOpts = Qutes.split(',');
        Claim__c ClaimData = new Claim__c();
        ClaimData=[Select Id,Patient_Relationship_to_Insured__c,Claim_Status__c,Payerid__c,
                   Billing_Provider_Tax_ID_Type__c,Accept_Assignment__c  from Claim__c where id =: Cid
                   WITH SECURITY_ENFORCED];
        //  return ClaimData;
        //  
        objwrap.claimRecord = ClaimData ;
        objwrap.ListOfCodes = allOpts ;
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
         return objwrap ; 
      }    
    @AuraEnabled
    public static void getValues(Id claimid, List<string> selectedoptions) {
        system.debug('clmid'+claimid);
        system.debug('clmid'+selectedoptions.size());
        string values = '' ;
        
        for(integer i=0 ; i<selectedoptions.size() ;i++ ){
            if(values == ''){
                values = selectedoptions[i];
            }
            else{
                values = values + ',' + selectedoptions[i] ;
                // values = selectedoptions[i]+',';
            } 
        }
        
        Claim__c obj = [Select id , name,Resubmission_Code__c,claim_status__c 
                        from Claim__c where id=: claimid WITH SECURITY_ENFORCED];
        obj.Resubmission_Code__c = values;
        obj.claim_status__c = 'Ready to Submit';
        if(Schema.sObjectType.Claim__c.fields.Resubmission_Code__c.isUpdateable() &&
           Schema.sObjectType.Claim__c.fields.claim_status__c.isUpdateable()){
               update obj;
           }
    }
    
    public class wrapper{
        @AuraEnabled public Claim__c claimRecord;
        @AuraEnabled public List<String> ListOfCodes;
    }
    
}