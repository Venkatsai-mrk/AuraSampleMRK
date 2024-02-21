public with sharing class UpdateReconciliationSummaryOnClaimsCls 
{   

    public static void updateParentClaims(set<id> prentsIds)
    {
        List<Claim__c> parentList=new List<Claim__c>();
        Set<Id> deniedStatusClaims = new Set<Id>();
        for(Claim__c tp:[select id, Total_Charge__c,Total_Patient_Responsibility__c,Total_Adjustment_Amount__c,Claim_Status__c,	Total_Contracted_Amount__c,
                         Total_Amount_Paid_By_Insurance__c,Total_Allowed_Amount__c,(select id,Procedure_Charge__c, Patient_Responsibility__c,Total_Adjustment__c,ERA_Received__c,
                                                                                    Amount_Paid_by_Insurance__c,Total_Allowed_Amount__c,Contracted_Amount__c,claim__c
                                                                                    FROM Claim_Line_Items__r) from Claim__c where id IN:prentsIds
                                                                                    WITH SECURITY_ENFORCED])
        {
            Boolean denied = false;
            Claim__c obj=new Claim__c();
            obj.id=tp.Id;
            
            Decimal totalCharge = 0.0;
            Decimal totalAdjustments = 0.0;
            Decimal totalInsurancePayment = 0.0;
            Decimal totalPatientPayment = 0.0;
            Decimal totalContractedAmount = 0.0;
            Decimal totalAllowedAmnt = 0.0;
            Map<Id,Boolean> eraReceivedForClaim = new Map<Id,Boolean>();
            for(Claim_Line_Items__c tc:tp.Claim_Line_Items__r){
                /* Logic to populate amount fields on Claim by rolling up related Claim Line Items */
                if(String.isNotBlank(tc.claim__c) && tc.ERA_received__c){
                    eraReceivedForClaim.put(tc.claim__c,true);
                }
                if( tc.ERA_received__c ){
                    if(tc.Procedure_Charge__c != 0 && tc.Procedure_Charge__c != null)
                    {
                        totalCharge = totalCharge + tc.Procedure_Charge__c;
                    }
                    if(tc.Contracted_Amount__c != 0 && tc.Contracted_Amount__c != null)
                    {
                        totalContractedAmount = totalContractedAmount + tc.Contracted_Amount__c;
                    }
                    if(tc.Total_Adjustment__c != 0 && tc.Total_Adjustment__c != null)
                    {
                        totalAdjustments = totalAdjustments + tc.Total_Adjustment__c;
                    }
                    if(tc.Total_Allowed_Amount__c != 0 && tc.Total_Allowed_Amount__c != null)
                    {
                        totalAllowedAmnt = totalAllowedAmnt + tc.Total_Allowed_Amount__c;
                    }
                    if(tc.Patient_Responsibility__c != 0 && tc.Patient_Responsibility__c != null)
                    {
                        totalPatientPayment = totalPatientPayment + tc.Patient_Responsibility__c;
                    }
                    if(tc.Amount_Paid_by_Insurance__c != 0 && tc.Amount_Paid_by_Insurance__c != null)
                    {
                        totalInsurancePayment = totalInsurancePayment + tc.Amount_Paid_by_Insurance__c;
                    }
                    if(tc.Total_Allowed_Amount__c == 0 || tc.Total_Allowed_Amount__c == null)
                    {
                        denied = true;
                    }
                }
                /* END of the logic to populated amount fields */
            }
            
            //obj.Total_Charge__c = totalCharge;
            obj.Total_Patient_Responsibility__c = totalPatientPayment;
            obj.Total_Adjustment_Amount__c = totalAdjustments;
            obj.Total_Contracted_Amount__c = totalContractedAmount;
            obj.Total_Amount_Paid_By_Insurance__c = totalInsurancePayment;
            obj.Total_Allowed_Amount__c = totalAllowedAmnt;
            if(obj.Total_Amount_Paid_By_Insurance__c !=0 && obj.Total_Patient_Responsibility__c > 0 ){
                if(obj.Total_Amount_Paid_By_Insurance__c < totalContractedPrice(tp) &&
                 eraReceivedForClaim.containsKey(obj.Id)){
                    obj.Claim_Status__c = 'Underpaid';
                }else{
                    obj.Claim_Status__c = 'Paid and Patient Responsibility';
                }
            }else if(obj.Total_Amount_Paid_By_Insurance__c !=0 && obj.Total_Patient_Responsibility__c == 0 ){
                obj.Claim_Status__c = 'Paid and resolved';
            }else if(eraReceivedForClaim.containsKey(obj.Id) && obj.Total_Amount_Paid_By_Insurance__c !=0 && 
            obj.Total_Patient_Responsibility__c < 0 ){
                    obj.Claim_Status__c = 'Overpaid';
            }             
            if(denied && StopRecursion.eraReceived){
                StopRecursion.isDenied.put(obj.Id,true);
                obj.Claim_Status__c  = 'Denied';
                deniedStatusClaims.add(obj.Id);
            }
            parentList.add(obj);
        }
        if(parentList!=null && parentList.size()>0){
            try{
                if(Schema.sObjectType.Claim__c.fields.Total_Patient_Responsibility__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Total_Adjustment_Amount__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Total_Contracted_Amount__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Total_Amount_Paid_By_Insurance__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Total_Allowed_Amount__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Claim_Status__c.isUpdateable()){
                update parentList;        
                }
            }catch(DMLException e){
                ExceptionLog.logError(e);
                system.debug('Exception  ' +e.getMessage());
            }
        }
        if(deniedStatusClaims!=null && deniedStatusClaims.size()>0){
            markDeniedStatusOnERA(deniedStatusClaims); 
        }
    }
    private static void markDeniedStatusOnERA(Set<Id> deniedStatusClaims){
        List<EOB__c> eras = [SELECT Id,Is_Excluded__c FROM EOB__c 
        WHERE Claim__c IN :deniedStatusClaims WITH SECURITY_ENFORCED];
        for(EOB__c era :eras){
            era.Is_Excluded__c = true;
        }
        if(Schema.sObjectType.EOB__c.fields.Is_Excluded__c.isUpdateable()){
            update eras;
        }
    }
    public static void deniedStatusUpdate(set<id> prentsIds)
    {
        Map<String,Claim__c> map_updateClaim = new Map<String,Claim__c>();
        for(Claim__c cId : [Select Id,Total_Patient_Responsibility__c,Claim_Status__c,Total_Amount_Paid_By_Insurance__c 
        FROM Claim__c WHERE Id IN: prentsIds])
        {
            map_updateClaim.put(cId.Id,cId);          
        }
        for(Claim_Line_Items__c cli : [Select Id,Patient_Responsibility__c,Amount_Paid_by_Insurance__c,Contracted_Amount__c,Total_Allowed_Amount__c,Claim__c,ERA_Received__c from Claim_Line_Items__c where Claim__c IN: prentsIds  WITH SECURITY_ENFORCED])
        {
            if(map_updateClaim.containsKey(cli.Claim__c) && cli.ERA_Received__c == true && cli.ERA_Received__c == true && cli.Total_Allowed_Amount__c == 0)
            {
                map_updateClaim.get(cli.Claim__c).Claim_Status__c = 'Denied';

            }
            else if(map_updateClaim.containsKey(cli.Claim__c) && cli.ERA_Received__c == true && cli.ERA_Received__c == true && cli.Total_Allowed_Amount__c > contractedPrice(cli))
            {
                map_updateClaim.get(cli.Claim__c).Claim_Status__c = 'Overpaid';
            }
            else if(map_updateClaim.containsKey(cli.Claim__c) && cli.ERA_Received__c == true && cli.ERA_Received__c == true && cli.Total_Allowed_Amount__c < contractedPrice(cli) && cli.Total_Allowed_Amount__c != 0)
            {
                map_updateClaim.get(cli.Claim__c).Claim_Status__c = 'Underpaid';
            }
        }
        if(Schema.sObjectType.Claim__c.fields.Claim_Status__c.isUpdateable()){
        update map_updateClaim.values();
        }
    }
    
    public static void paidAndPatientResponseSec(set<id> prentsIds)
    {
        Map<String,Claim__c> map_claimVob = new Map<String,Claim__c>();
        for(Claim__c cId : [Select Id,Account__c,Total_Patient_Responsibility__c,Claim_Status__c,Total_Contracted_Amount__c,Total_Allowed_Amount__c,Total_Amount_Paid_By_Insurance__c 
        FROM Claim__c where Id IN: prentsIds WITH SECURITY_ENFORCED])
        {
            map_claimVob.put(cId.Account__c,cId);          
        }
        for(VOB__c vob : [Select Id,Insurance_Counts__c,VOB_Verification_Status__c,Account__c from VOB__c where Account__c IN :map_claimVob.keySet() WITH SECURITY_ENFORCED])
        {
            if(map_claimVob.containsKey(vob.Account__c) && vob.VOB_Verification_Status__c == 'Approved' && vob.Insurance_Counts__c == 'Secondary' && map_claimVob.get(vob.Account__c).Total_Allowed_Amount__c == map_claimVob.get(vob.Account__c).Total_Contracted_Amount__c && map_claimVob.get(vob.Account__c).Total_Patient_Responsibility__c > 0)
            {
                map_claimVob.get(vob.Account__c).Claim_Status__c = 'Paid and patient responsibility with Secondary';
            }
            
        }
        if(Schema.sObjectType.Claim__c.fields.Claim_Status__c.isUpdateable()){
        update map_claimVob.values();
        }
    }
    private static Decimal contractedPrice(Claim_Line_Items__c cli){
        if(cli.Contracted_Amount__c == null || cli.Contracted_Amount__c == 0){
            return cli.Procedure_Charge__c;
        }else{
            return cli.Contracted_Amount__c;
        }
    }
    private static Decimal totalContractedPrice(Claim__c cli){
        if(cli.Total_Contracted_Amount__c == null || cli.Total_Contracted_Amount__c == 0){
            return cli.Total_Charge__c;
        }else{
            return cli.Total_Contracted_Amount__c;
        }
    }
}
//Comminted