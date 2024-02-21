/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-16-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class  InsertPreAssessment {
@auraEnabled
    public static void InsertPreAssessmentid(Id Oppid){
        system.debug('opp id'+oppid);
        
        Pre_assessment__c p=new Pre_assessment__c();
        try{
        if(Schema.sobjecttype.Opportunity.isAccessible()
                          && Schema.sObjectType.Opportunity.fields.Phone__c.isAccessible() && Schema.sObjectType.Opportunity.fields.DOB__c.isAccessible() )
        {
            Opportunity o=[select id,StageName,Phone__c,DOB__c from Opportunity where id=:Oppid];
            if(Schema.sObjectType.Pre_assessment__c.fields.Opportunity__c.isCreateable())
            {
              p.Opportunity__c=o.id;  
            }
             if( Schema.sObjectType.Pre_assessment__c.fields.Date_Of_Birth__c.isCreateable())
             {
                 p.Date_Of_Birth__c=o.DOB__c;
             }
       if( Schema.sObjectType.Pre_assessment__c.fields.Phone__c.isCreateable())
       {
         p.Phone__c=o.Phone__c;  
       }
        if(Schema.sObjectType.Pre_assessment__c.fields.Stage__c.isCreateable())
        {
            p.Stage__c=o.StageName;  
        }
      
        }
        
       
     if(schema.sobjecttype.Pre_assessment__c.isCreateable())
     {
         //insert p;
         DMLManager.insertAsUser(p);
     }
        }
         catch(Exception e){
         ExceptionLog.logError(e);
        }
   }
    
}