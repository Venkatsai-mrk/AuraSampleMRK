public with sharing class ERACustomWidgetCtrl {
	@AuraEnabled
    public static List<EOB__c> fetchOriginalERA(String claimId)
    {
        List<EOB__c> eraLst = new List<EOB__c>([Select id, name, Total_Charge__c, Total_Paid__c 
        from EOB__c where Claim__c =: claimId AND Copy_Of_Original_ERA__c = false AND
         Claim__r.Manual_ERA__c = false WITH SECURITY_ENFORCED LIMIT 50000]);
        
        return eraLst;
    }
}