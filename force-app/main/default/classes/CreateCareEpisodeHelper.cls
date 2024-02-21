public with sharing class CreateCareEpisodeHelper {
    public static void createCareEpisode(List<Opportunity> oppList,String opperation){
        try{
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> oppIdUpdateSet = new Set<Id>();
        
        for(Opportunity opp: oppList){
            oppIdSet.add(opp.Id);
        }
        List<Visits__C> careEpisodeList = new List<Visits__c>();
        List<Visits__C> careEpisodeUpdateList = new List<Visits__c>();
        List<Opportunity> oppRecordList = [Select Id,AccountId, Name,Gender__c from Opportunity where Id IN: oppIdSet
        WITH SECURITY_ENFORCED]; 
        Map<Id,Opportunity> oppIdUpdateMap = new Map<Id,Opportunity>(oppRecordList);
        for(Opportunity opp: oppRecordList){
            if(opperation=='Insert'){
                Visits__c careEpisode = new Visits__c(Name=opp.Name,Gender__c=opp.Gender__c,Opportunity__c=opp.Id,Account__c=opp.AccountId,Status__c='Active');
                careEpisodeList.add(careEpisode);
            }
            if(opperation=='Update')
            {
                oppIdUpdateSet.add(opp.Id);  
                
            }
        }
        
        system.debug('oppIdUpdateSet'+oppIdUpdateSet);
        
            //added by Anmol for LX3-7236
            Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
            String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
            if(string.isBlank(careFilter)){
                careFilter = 'createddate desc';
            }
            String careStatus = 'Active';
    
            string querystr = '';
            querystr += 'Select Id,Name,ElixirSuite__Gender__c,ElixirSuite__Account__c,ElixirSuite__Opportunity__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Opportunity__c In :oppIdUpdateSet WITH SECURITY_ENFORCED order by ';
            querystr += careFilter ;
            List<ElixirSuite__Visits__c> careEpisodeToUpdate = database.query(querystr);
    //end by Anmol for LX3-7236
        

        //system.debug('OppStatus'++);
        system.debug('careep'+careEpisodeToUpdate);
        for(Visits__C careEpi : careEpisodeToUpdate)
        {
            if(oppIdUpdateMap.containsKey(careEpi.Opportunity__c))
            {
                // oppIdUpdateMap.get(careEpi.Opportunity__c) = careEpi;
                careEpi.Account__c=oppIdUpdateMap.get(careEpi.Opportunity__c).AccountId;
                careEpi.Gender__c=oppIdUpdateMap.get(careEpi.Opportunity__c).Gender__c;
                careEpi.Name=oppIdUpdateMap.get(careEpi.Opportunity__c).Name;
                careEpisodeUpdateList.add(careEpi);
            }
            
        }
        if(careEpisodeList.size()>0){
            if(Schema.sObjectType.Visits__c.fields.Name.isCreateable() &&
            Schema.sObjectType.Visits__c.fields.Gender__c.isCreateable() &&
            Schema.sObjectType.Visits__c.fields.Opportunity__c.isCreateable() &&
            Schema.sObjectType.Visits__c.fields.Account__c.isCreateable() &&
            Schema.sObjectType.Visits__c.fields.Status__c.isCreateable()){
                if(Schema.sObjectType.Visits__C.isCreateable()){
            insert careEpisodeList;
                } 
            }
        }
        if(careEpisodeUpdateList.size()>0){
            if(Schema.sObjectType.Visits__c.fields.Name.isUpdateable() &&
            Schema.sObjectType.Visits__c.fields.Gender__c.isUpdateable() &&
            Schema.sObjectType.Visits__c.fields.Opportunity__c.isUpdateable() &&
            Schema.sObjectType.Visits__c.fields.Account__c.isUpdateable() &&
            Schema.sObjectType.Visits__c.fields.Status__c.isUpdateable()){
                if(Schema.sObjectType.Visits__C.isUpdateable()){
            update careEpisodeUpdateList; 
                }
            }
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void updateCareEpisode(Map<Id,Opportunity> oMap, List<Opportunity> newOpp){
        try{
        List<Opportunity> oppIdList= new List<Opportunity>();
        for(Opportunity opp:newOpp)
        {
            
            if(oMap.get(opp.id).AccountId !=opp.AccountId ||
               oMap.get(opp.id).Gender__c !=opp.Gender__c ||
               oMap.get(opp.id).Name !=opp.Name)
            {
                oppIdList.add(opp);  
            }
        }
        if(oppIdList.size()>0){
            CreateCareEpisodeHelper.createCareEpisode(oppIdList,'Update');
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    public static void insertVOB(List<ID> oppIdList){ 
        try{
         List<VOB__c> VoBList = new List<VOB__c>();
        List<Opportunity> oppList = [Select Id, Name, AccountId,Insurance_Providor__c, Insurance_Phone_Number__c,
         Subscriber_Name__c,Subscriber_DOB__c, Insurance_Policy_ID__c, Insurance_Group_Number__c
          from Opportunity where Id IN: oppIdList
          WITH SECURITY_ENFORCED];  
        
        
        for(Opportunity opp: oppList){
            
            VOB__c Vob = new VOB__c(Opportunity__c = opp.Id);
            //Vob.Name = opp.Name;
            //Vob Account__c to be updated form Opportunity
            Vob.Account__c=opp.AccountId;
            Vob.Ins_Comp__c = opp.Insurance_Providor__c;
            Vob.ElixirSuite__Insurance_Company_Phone__c = opp.Insurance_Phone_Number__c;
            Vob.Subscriber_Name__c = opp.Subscriber_Name__c; 
            Vob.Date_Of_Birth1__c = opp.Subscriber_DOB__c; 
            Vob.ID__c = opp.Insurance_Policy_ID__c;
            Vob.Group__c = opp.Insurance_Group_Number__c;             
            VoBList.add(Vob);         
        }
        
        if(VoBList.size()>0){
            if(Schema.sObjectType.VOB__c.fields.Ins_Comp__c.isCreateable() &&
            Schema.sObjectType.VOB__c.fields.Gender__c.isCreateable() &&
            Schema.sObjectType.VOB__c.fields.Opportunity__c.isCreateable() &&
            Schema.sObjectType.VOB__c.fields.Account__c.isCreateable() &&
            Schema.sObjectType.VOB__c.fields.ElixirSuite__Insurance_Company_Phone__c.isCreateable() &&
            Schema.sObjectType.VOB__c.fields.Subscriber_Name__c.isCreateable() &&
            Schema.sObjectType.VOB__c.fields.Date_Of_Birth1__c.isCreateable() &&
            Schema.sObjectType.VOB__c.fields.ID__c.isCreateable() &&
            Schema.sObjectType.VOB__c.fields.Group__c.isCreateable()){
            insert VoBList; 
            }
        } 
    }
       catch(Exception e){
               ExceptionLog.logError(e);
            }
}
}