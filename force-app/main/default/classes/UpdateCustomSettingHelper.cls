public with sharing class UpdateCustomSettingHelper {
    public static string deleteAllKey()
    {
        Schema.sObjectType objType = Schema.getGlobalDescribe().get('ElixirSuite__EMR_License__c');     //EMR_License__c changed to ElixirSuite__EMR_License__c //shivam
	    Schema.DescribeSObjectResult objDesc = objType.getDescribe();
        List<EMR_License__c> rec =new  List<EMR_License__c>();
        if(Schema.sobjecttype.EMR_License__c.isAccessible())
         rec = [select id from EMR_License__c where id!=null WITH SECURITY_ENFORCED];
        if((rec.size() > 0) && objDesc.isDeletable()){
            DMLManager.deleteAsUser(rec);                               //delete rec;
            return 'Deleted!';
        }
        return 'Nothing to delete!';
    }
     public static Integer getKeyCounts()
     {
         List<EMR_License__c> rec =new  List<EMR_License__c>();
         if(Schema.sobjecttype.EMR_License__c.isAccessible())
       rec = [select id from EMR_License__c where id!=null  WITH SECURITY_ENFORCED] ;
        if(rec.size() > 0){
            system.debug('hf'+rec.size());
            return rec.size();
        }
        return 0;
     }

}