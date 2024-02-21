/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ProcCreatnForTransport_handler 
{
    public static void  populateCareEpisode(ElixirSuite__Transport__c[] transportList){
        set<String> acctIds = new set<String>(); //ElixirSuite__Account__c
        if(transportList!=null && transportList.size()>0){
            for(ElixirSuite__Transport__c transport:transportList)
        acctIds.add(transport.ElixirSuite__Account__c); //adding id into the set
        }
        
         //added by Anmol for LX3-7236
         Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
         String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
         if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
         String careStatus = 'Active';
 
         string querystr = '';
         querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c in : acctIds WITH SECURITY_ENFORCED order by ';
         querystr += careFilter ;
         ElixirSuite__Visits__c[] activeCP = database.query(querystr);
         //end by Anmol for LX3-7236

        system.debug('activeCP'+activeCP);
        if(activeCP!=null && activeCP.size()>0){
        for(ElixirSuite__Transport__c Transport :transportList){
            Transport.ElixirSuite__Care_Episode__c = activeCP[0].Id;
        }
        }
    }
    public static void createProc(List<ElixirSuite__Transport__c> lst_transport)
    {
        try{
        List<Procedure__c> lst_procedure = new List<Procedure__c>();
        for(ElixirSuite__Transport__c objTrans : lst_transport)
        {
            String devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
            
            String recTypeName = [Select Id,RecordType.Name from ElixirSuite__Transport__c where Id=: objTrans.Id
            WITH SECURITY_ENFORCED].RecordType.Name;
            
            List<ElixirSuite__Visits__c> lst_visits = [Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c='Active' AND ElixirSuite__Account__c=:objTrans.ElixirSuite__Account__c 
            WITH SECURITY_ENFORCED LIMIT 1];                                                    
            if(Elixir_Utility.fetchCreateProcedureReturnValue()==true){
            Procedure__c newProcedure = new Procedure__c();
            newProcedure.Account__c=objTrans.ElixirSuite__Account__c; 
            newProcedure.RecordTypeId = devRecordTypeId;
            newProcedure.From_Date__c = date.valueOf(objTrans.ElixirSuite__Start_Time__c);
            newProcedure.Start_Time__c = objTrans.ElixirSuite__Start_Time__c ;
            
            if(!lst_visits.isEmpty())
            {
                newProcedure.ElixirSuite__Visits__c =lst_visits[0].Id;
            }
            if(objTrans.ElixirSuite__End_Time__c < = objTrans.ElixirSuite__Start_Time__c)
            {
                newProcedure.End_Time__c = objTrans.ElixirSuite__Start_Time__c.addMinutes(1);
            }
            else
            {
                newProcedure.End_Time__c = objTrans.ElixirSuite__End_Time__c;
            }
            newProcedure.To_Date__c = date.valueOf(objTrans.ElixirSuite__End_Time__c) ;
            //newProcedure.End_Time__c = objTrans.ElixirSuite__End_Time__c ;
            newProcedure.Name = recTypeName + ' Transportation';
            lst_procedure.add(newProcedure);
        }
       
    }
             if(lst_procedure.size()>0)
        {
            if(Schema.sObjectType.Procedure__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Name.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.ElixirSuite__Visits__c.isCreateable()){
               
            insert lst_procedure;
             }
        }
        }
        catch(Exception e){
               ExceptionLog.logError(e);
            }
    
    }
    
    public static void updateProc(List<ElixirSuite__Transport__c> lst_transport)
    {
        try{
        List<Procedure__c> lst_procedure = new List<Procedure__c>();
        for(ElixirSuite__Transport__c objTrans : lst_transport)
        {
            String devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
            
            String recTypeName = [Select Id,RecordType.Name from ElixirSuite__Transport__c where Id=: objTrans.Id WITH SECURITY_ENFORCED].RecordType.Name;
            
            List<ElixirSuite__Visits__c> lst_visits = [Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c 
            from ElixirSuite__Visits__c 
            where ElixirSuite__Status__c='Active' AND ElixirSuite__Account__c=:objTrans.ElixirSuite__Account__c 
            WITH SECURITY_ENFORCED
            LIMIT 1];                                                    
            if(Elixir_Utility.fetchCreateProcedureReturnValue()==true){
            Procedure__c newProcedure = new Procedure__c();
            newProcedure.Account__c=objTrans.ElixirSuite__Account__c; 
            newProcedure.RecordTypeId = devRecordTypeId;
            newProcedure.From_Date__c = date.valueOf(objTrans.ElixirSuite__Start_Time__c);
            newProcedure.Start_Time__c = objTrans.ElixirSuite__Start_Time__c ;
            
            if(!lst_visits.isEmpty())
            {
                newProcedure.ElixirSuite__Visits__c =lst_visits[0].Id;
            }
            if(objTrans.ElixirSuite__End_Time__c < = objTrans.ElixirSuite__Start_Time__c)
            {
                newProcedure.End_Time__c = objTrans.ElixirSuite__Start_Time__c.addMinutes(1);
            }
            else
            {
                newProcedure.End_Time__c = objTrans.ElixirSuite__End_Time__c;
            }
            newProcedure.To_Date__c = date.valueOf(objTrans.ElixirSuite__End_Time__c) ;
            //newProcedure.End_Time__c = objTrans.ElixirSuite__End_Time__c ;
            newProcedure.Name = recTypeName + ' Transportation';
            lst_procedure.add(newProcedure);
        }
        }
        if(lst_procedure.size()>0)
        {
            
            if(Schema.sObjectType.Procedure__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Account__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.RecordTypeId.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.From_Date__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Start_Time__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.To_Date__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.End_Time__c.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.Name.isCreateable() &&
            Schema.sObjectType.Procedure__c.fields.ElixirSuite__Visits__c.isCreateable()){
            insert lst_procedure;
            }
        }
    
    }
    
    
    catch(Exception e){
               ExceptionLog.logError(e);
            }
}
}