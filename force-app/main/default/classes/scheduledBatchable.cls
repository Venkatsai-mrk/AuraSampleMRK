global with sharing class scheduledBatchable implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        /*
		List<CMS_1500_Claim_Generation__c> CMSlist = [SELECT ID, days__c, After_every_hours__c, Active__c 
		FROM CMS_1500_Claim_Generation__c WHERE Active__c = true WITH SECURITY_ENFORCED];
		for(CMS_1500_Claim_Generation__c cms : CMSlist){ 
			Integer day = Integer.valueOf(cms.days__c);
			system.debug('day--'+day);
			String sch = '0 0 '+day+' * ?';
		}
        OpenClaimGenerationBatch b = new OpenClaimGenerationBatch(); */
		// system.schedule('Batch Scheduled', sch15, b);
		// system.schedule('Batch Scheduled', sch30, b);
    }
}