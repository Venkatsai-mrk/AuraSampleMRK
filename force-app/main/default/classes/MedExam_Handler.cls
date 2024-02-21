/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 01-20-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class MedExam_Handler  
{
    public static void  populateCareEpisode(ElixirSuite__Medical_Examination__c[] medicalExaminationList){
        set<String> acctIds = new set<String>(); //ElixirSuite__Account__c
        if(medicalExaminationList!=null && medicalExaminationList.size()>0){
            for(ElixirSuite__Medical_Examination__c medExam :medicalExaminationList)
                acctIds.add(medExam.ElixirSuite__Account__c); //adding id into the set
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
        
        if(activeCP!=null && activeCP.size()>0){
            for(ElixirSuite__Medical_Examination__c me :medicalExaminationList){
                me.ElixirSuite__Care_Episode__c = activeCP[0].Id; //adding care episode
            }
        }
    }
    public static void createProcMed(List<ElixirSuite__Medical_Examination__c> lst_medExamntion)
    {
        List<Procedure__c> lst_procedures = new List<Procedure__c>();
        try{
            for(ElixirSuite__Medical_Examination__c objMed : lst_medExamntion)
            {
                String devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
                
                String recTypeName = '';
                List<Medical_Examination__c> rec = [Select Id,RecordType.Name from ElixirSuite__Medical_Examination__c where Id=: objMed.Id WITH SECURITY_ENFORCED];
                if(rec!=null && rec.size()>0){
                    recTypeName = rec[0].RecordType.Name;
                }
                
                //added by Anmol for LX3-7236
                Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
                String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
                if(string.isBlank(careFilter)){
                    careFilter = 'createddate desc';
                }
                String careStatus = 'Active';
                String accId = objMed.ElixirSuite__Account__c;
                
                string querystr = '';
                querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED order by ';
                querystr += careFilter ;
                List<ElixirSuite__Visits__c> lst_visits = database.query(querystr);
                //end by Anmol for LX3-7236
                
                if(Elixir_Utility.fetchCreateProcedureReturnValue()==true){
                    Procedure__c newProcedure = new Procedure__c();
                    newProcedure.Account__c=objMed.ElixirSuite__Account__c; 
                    newProcedure.RecordTypeId = devRecordTypeId;
                    newProcedure.From_Date__c = date.valueOf(objMed.ElixirSuite__Start_Time__c) ;
                    newProcedure.Start_Time__c = objMed.ElixirSuite__Start_Time__c ;
                    newProcedure.To_Date__c = date.valueOf(objMed.ElixirSuite__End_Time__c) ;
                    if(!lst_visits.isEmpty())
                    {
                        newProcedure.ElixirSuite__Visits__c =lst_visits[0].Id;
                    }
                    if(objMed.ElixirSuite__End_Time__c <=objMed.ElixirSuite__Start_Time__c)
                    {
                        newProcedure.End_Time__c = objMed.ElixirSuite__Start_Time__c.addMinutes(1) ;
                    }
                    else
                    {
                        newProcedure.End_Time__c = objMed.ElixirSuite__End_Time__c ;
                    }
                    newProcedure.Name = recTypeName + ' Medical Examination';
                    lst_procedures.add(newProcedure);
                }
                
            }
            if(lst_procedures.size()>0)
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
                       
                       insert lst_procedures;
                   }
            }
        }
        
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    
    public static void updateProcMed(List<ElixirSuite__Medical_Examination__c> lst_medExamntion)
    {
        List<Procedure__c> lst_procedures = new List<Procedure__c>();
        try{
            for(ElixirSuite__Medical_Examination__c objMed : lst_medExamntion)
            {
                String devRecordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
                
                String recTypeName = [Select Id,RecordType.Name from ElixirSuite__Medical_Examination__c where Id=: objMed.Id].RecordType.Name;
                
                //added by Anmol for LX3-7236
                Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
                String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
                if(string.isBlank(careFilter)){
                    careFilter = 'createddate desc';
                }
                String careStatus = 'Active';
                String accId = objMed.ElixirSuite__Account__c;
                
                string querystr = '';
                querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accId WITH SECURITY_ENFORCED order by ';
                querystr += careFilter ;
                List<ElixirSuite__Visits__c> lst_visits = database.query(querystr);
                //end by Anmol for LX3-7236                                                    
                if(Elixir_Utility.fetchCreateProcedureReturnValue()==true){
                    Procedure__c newProcedure = new Procedure__c();
                    newProcedure.Account__c=objMed.ElixirSuite__Account__c; 
                    newProcedure.RecordTypeId = devRecordTypeId;
                    newProcedure.From_Date__c = date.valueOf(objMed.ElixirSuite__Start_Time__c) ;
                    newProcedure.Start_Time__c = objMed.ElixirSuite__Start_Time__c ;
                    newProcedure.To_Date__c = date.valueOf(objMed.ElixirSuite__End_Time__c) ;
                    if(!lst_visits.isEmpty())
                    {
                        newProcedure.ElixirSuite__Visits__c =lst_visits[0].Id;
                    }
                    if(objMed.ElixirSuite__End_Time__c <=objMed.ElixirSuite__Start_Time__c)
                    {
                        newProcedure.End_Time__c = objMed.ElixirSuite__Start_Time__c.addMinutes(1) ;
                    }
                    else
                    {
                        newProcedure.End_Time__c = objMed.ElixirSuite__End_Time__c ;
                    }
                    newProcedure.Name = recTypeName + ' Medical Examination';
                    lst_procedures.add(newProcedure);
                }
            }
            if(lst_procedures.size()>0)
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
                       if(Schema.sObjectType.Procedure__c.isCreateable()){
                           insert lst_procedures;
                       }
                   }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
}