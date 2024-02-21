/*
 * Class Name  : masterObjectTriggerHelper.apxc
 * Description : Helper class for master object trigger
 * Author      : Anusha Reddy
 * 
 * */
public with sharing class masterObjectTriggerHelper {
    /*
     * Method Name : createRecommendationsAndTasks
     * Params      : newList - Holds the list of new Values
     * Description : Helper method for master object trigger which creates recommendations
     * Author      : Anusha Reddy
     * Story#      : LX3-5263
     * 
     * */
    public static void createRecommendationsAndTasks(List<ElixirSuite__Master_Object__c> newList){
        List<ElixirSuite__Master_Object__c> masterObjectList = newList;
        List<ElixirSuite__Recommendation__c> recommendationList = new List<ElixirSuite__Recommendation__c>();
        try{
        Map<id,ElixirSuite__EOB__c> ERAAndItsItemsMap=new Map<id,ElixirSuite__EOB__c>([select id,(select ElixirSuite__EOB__c,
                                                         		//ElixirSuite__ElixirSuite_Adjustment_Group_Code__c,
                                                                ElixirSuite__Group_1__c,
                                                                ElixirSuite__Group_2__c,
                                                                ElixirSuite__Group_3__c,
                                                                ElixirSuite__Group_4__c,
                                                                ElixirSuite__Group_5__c,
                                                                ElixirSuite__Group_6__c,
                                                                ElixirSuite__Group_7__c,
                                                                ElixirSuite__Group_8__c,
                                                                ElixirSuite__Code_1__c,
                                                                ElixirSuite__Code_2__c,
                                                                ElixirSuite__Code_3__c,
                                                                ElixirSuite__Code_4__c,
                                                                ElixirSuite__Code_5__c,
                                                                ElixirSuite__Code_6__c,
                                                                ElixirSuite__Code_7__c,
                                                                ElixirSuite__Code_8__c,                                  
                                                        		ElixirSuite__ERAInformational_Remark_Codes__c,
                                                        		ElixirSuite__ERASupplemental_Remark_Codes1__c,
                                                        		ElixirSuite__ERASupplemental_Remark_Codes2__c,
                                                        		ElixirSuite__ERASupplemental_Remark_Codes3__c,
                                                        		ElixirSuite__ERASupplemental_Remark_Codes4__c,
                                                        		ElixirSuite__ERASupplemental_Remark_Codes5__c,
                                                        		ElixirSuite__ERASupplemental_Remark_Codes6__c,
                                                        		ElixirSuite__ERASupplemental_Remark_Codes7__c,
                                                        		ElixirSuite__ERASupplemental_Remark_Codes8__c from ElixirSuite__ERA_Line_Item__r) from ElixirSuite__EOB__c  WITH SECURITY_ENFORCED limit 50000]);
        Map<id,List<String>> eraInformationCodes = new Map<id,List<String>>();
        Map<id,set<String>> eraSupplementalCodes = new Map<id,set<String>>();
        Map<id,set<String>> eraAdjustmentCodes = new Map<id,set<String>>();
        for(id i : ERAAndItsItemsMap.keySet()){
            for(ElixirSuite__ERA_Line_Item__c n : ERAAndItsItemsMap.get(i).ElixirSuite__ERA_Line_Item__r){
                if(n.ElixirSuite__ERAInformational_Remark_Codes__c!=null){
                    if(eraInformationCodes.containsKey(i)){
                        eraInformationCodes.get(i).addAll(n.ElixirSuite__ERAInformational_Remark_Codes__c.split(';'));
                    }
                    else{
                        eraInformationCodes.put(i,n.ElixirSuite__ERAInformational_Remark_Codes__c.split(';'));    
                    } 
                }
                if(n.ElixirSuite__Group_1__c!=null && n.ElixirSuite__Code_1__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes1__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes1__c=='None')){
                    if(eraAdjustmentCodes.containsKey(i)){
                        eraAdjustmentCodes.get(i).add(n.ElixirSuite__Group_1__c+n.ElixirSuite__Code_1__c);
                    }
                    else{
                        eraAdjustmentCodes.put(i,new set<String>{n.ElixirSuite__Group_1__c+n.ElixirSuite__Code_1__c});    
                    } 
                }
                if(n.ElixirSuite__Group_2__c!=null && n.ElixirSuite__Code_2__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes2__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes2__c=='None')){
                    if(eraAdjustmentCodes.containsKey(i)){
                        eraAdjustmentCodes.get(i).add(n.ElixirSuite__Group_2__c+n.ElixirSuite__Code_2__c);
                    }
                    else{
                        eraAdjustmentCodes.put(i,new set<String>{n.ElixirSuite__Group_2__c+n.ElixirSuite__Code_2__c});    
                    } 
                }
                if(n.ElixirSuite__Group_3__c!=null && n.ElixirSuite__Code_3__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes3__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes3__c=='None')){
                    if(eraAdjustmentCodes.containsKey(i)){
                        eraAdjustmentCodes.get(i).add(n.ElixirSuite__Group_3__c+n.ElixirSuite__Code_3__c);
                    }
                    else{
                        eraAdjustmentCodes.put(i,new set<String>{n.ElixirSuite__Group_3__c+n.ElixirSuite__Code_3__c});    
                    } 
                }
                if(n.ElixirSuite__Group_4__c!=null && n.ElixirSuite__Code_4__c!=null &&(n.ElixirSuite__ERASupplemental_Remark_Codes4__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes4__c=='None')){
                    if(eraAdjustmentCodes.containsKey(i)){
                        eraAdjustmentCodes.get(i).add(n.ElixirSuite__Group_4__c+n.ElixirSuite__Code_4__c);
                    }
                    else{
                        eraAdjustmentCodes.put(i,new set<String>{n.ElixirSuite__Group_4__c+n.ElixirSuite__Code_4__c});    
                    } 
                }
                if(n.ElixirSuite__Group_5__c!=null && n.ElixirSuite__Code_5__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes5__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes5__c=='None')){
                    if(eraAdjustmentCodes.containsKey(i)){
                        eraAdjustmentCodes.get(i).add(n.ElixirSuite__Group_5__c+n.ElixirSuite__Code_5__c);
                    }
                    else{
                        eraAdjustmentCodes.put(i,new set<String>{n.ElixirSuite__Group_5__c+n.ElixirSuite__Code_5__c});    
                    } 
                }
                if(n.ElixirSuite__Group_6__c!=null && n.ElixirSuite__Code_6__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes6__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes6__c=='None')){
                    if(eraAdjustmentCodes.containsKey(i)){
                        eraAdjustmentCodes.get(i).add(n.ElixirSuite__Group_6__c+n.ElixirSuite__Code_6__c);
                    }
                    else{
                        eraAdjustmentCodes.put(i,new set<String>{n.ElixirSuite__Group_6__c+n.ElixirSuite__Code_6__c});    
                    } 
                }
                if(n.ElixirSuite__Group_7__c!=null && n.ElixirSuite__Code_7__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes7__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes7__c=='None')){
                    if(eraAdjustmentCodes.containsKey(i)){
                        eraAdjustmentCodes.get(i).add(n.ElixirSuite__Group_7__c+n.ElixirSuite__Code_7__c);
                    }
                    else{
                        eraAdjustmentCodes.put(i,new set<String>{n.ElixirSuite__Group_7__c+n.ElixirSuite__Code_7__c});    
                    } 
                }
                if(n.ElixirSuite__Group_8__c!=null && n.ElixirSuite__Code_8__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes8__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes8__c=='None')){
                    if(eraAdjustmentCodes.containsKey(i)){
                        eraAdjustmentCodes.get(i).add(n.ElixirSuite__Group_8__c+n.ElixirSuite__Code_8__c);
                    }
                    else{
                        eraAdjustmentCodes.put(i,new set<String>{n.ElixirSuite__Group_8__c+n.ElixirSuite__Code_8__c});    
                    } 
                }
                if(n.ElixirSuite__Group_1__c!=null && n.ElixirSuite__Code_1__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes1__c!=null){
                    String supString = n.ElixirSuite__Group_1__c+n.ElixirSuite__Code_1__c+n.ElixirSuite__ERASupplemental_Remark_Codes1__c;
                    if(eraSupplementalCodes.containsKey(i)){
                        eraSupplementalCodes.get(i).add(supString);
                    }
                    else{
                        eraSupplementalCodes.put(i,new set<String>{supString});    
                    } 
                }
                if(n.ElixirSuite__Group_2__c!=null && n.ElixirSuite__Code_2__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes2__c!=null){
                    String supString = n.ElixirSuite__Group_2__c+n.ElixirSuite__Code_2__c+n.ElixirSuite__ERASupplemental_Remark_Codes2__c;
                    if(eraSupplementalCodes.containsKey(i)){
                        eraSupplementalCodes.get(i).add(supString);
                    }
                    else{
                        eraSupplementalCodes.put(i,new set<String>{supString});    
                    } 
                }
                if(n.ElixirSuite__Group_3__c!=null && n.ElixirSuite__Code_3__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes3__c!=null){
                    String supString = n.ElixirSuite__Group_3__c+n.ElixirSuite__Code_3__c+n.ElixirSuite__ERASupplemental_Remark_Codes3__c;
                    if(eraSupplementalCodes.containsKey(i)){
                        eraSupplementalCodes.get(i).add(supString);
                    }
                    else{
                        eraSupplementalCodes.put(i,new set<String>{supString});    
                    } 
                }
                if(n.ElixirSuite__Group_4__c!=null && n.ElixirSuite__Code_4__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes4__c!=null){
                    String supString = n.ElixirSuite__Group_4__c+n.ElixirSuite__Code_4__c+n.ElixirSuite__ERASupplemental_Remark_Codes4__c;
                    if(eraSupplementalCodes.containsKey(i)){
                        eraSupplementalCodes.get(i).add(supString);
                    }
                    else{
                        eraSupplementalCodes.put(i,new set<String>{supString});    
                    } 
                }
                if(n.ElixirSuite__Group_5__c!=null && n.ElixirSuite__Code_5__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes5__c!=null){
                    String supString = n.ElixirSuite__Group_5__c+n.ElixirSuite__Code_5__c+n.ElixirSuite__ERASupplemental_Remark_Codes5__c;
                    if(eraSupplementalCodes.containsKey(i)){
                        eraSupplementalCodes.get(i).add(supString);
                    }
                    else{
                        eraSupplementalCodes.put(i,new set<String>{supString});    
                    } 
                }
                if(n.ElixirSuite__Group_6__c!=null && n.ElixirSuite__Code_6__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes6__c!=null){
                    String supString = n.ElixirSuite__Group_6__c+n.ElixirSuite__Code_6__c+n.ElixirSuite__ERASupplemental_Remark_Codes6__c;
                    if(eraSupplementalCodes.containsKey(i)){
                        eraSupplementalCodes.get(i).add(supString);
                    }
                    else{
                        eraSupplementalCodes.put(i,new set<String>{supString});    
                    } 
                }
                if(n.ElixirSuite__Group_7__c!=null && n.ElixirSuite__Code_7__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes7__c!=null){
                    String supString = n.ElixirSuite__Group_7__c+n.ElixirSuite__Code_7__c+n.ElixirSuite__ERASupplemental_Remark_Codes7__c;
                    if(eraSupplementalCodes.containsKey(i)){
                        eraSupplementalCodes.get(i).add(supString);
                    }
                    else{
                        eraSupplementalCodes.put(i,new set<String>{supString});    
                    } 
                }
                if(n.ElixirSuite__Group_8__c!=null && n.ElixirSuite__Code_8__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes8__c!=null){
                    String supString = n.ElixirSuite__Group_8__c+n.ElixirSuite__Code_8__c+n.ElixirSuite__ERASupplemental_Remark_Codes8__c;
                    if(eraSupplementalCodes.containsKey(i)){
                        eraSupplementalCodes.get(i).add(supString);
                    }
                    else{
                        eraSupplementalCodes.put(i,new set<String>{supString});    
                    } 
                }
            }
        }
        for(ElixirSuite__Master_Object__c m:masterObjectList){
            String masterAdjString =m.ElixirSuite__Adjustment_Group_Code__c+m.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;
            String masterSuppString=masterAdjString+ m.ElixirSuite__Supplemental_Group_Code__c;
            for(id ERAid :eraInformationCodes.keyset()){
                if(eraInformationCodes.get(ERAid).contains(m.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c) && m.recordtypeid==Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Informational_Remark_Codes').getRecordTypeId()){
                    ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                    recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Informational_Remark_Codes').getRecordTypeId();
                    recommendation.ElixirSuite__Elixir_Recommendation__c=m.ElixirSuite__ElixirSuite_Recommendation__c;
                    recommendation.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c=m.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c;
                    recommendation.ElixirSuite__Elixir_ERA__c=ERAid;
                    recommendation.ElixirSuite__Elixir_Assign_To__c=m.ElixirSuite__ElixirSuite_Assign_To__c;
                    recommendation.ElixirSuite__Master_Object__c=m.Id;
                    recommendationList.add(recommendation);
                }
            }
           system.debug('***ElixirSuite__Adjustment_Group_Code__c');
           for(id ERAid :eraAdjustmentCodes.keyset()){
                if(eraAdjustmentCodes.get(ERAid).contains(masterAdjString) && m.recordtypeid==Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId()){
                     system.debug('***inside if');
                    ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                    recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId();
                    recommendation.ElixirSuite__Elixir_Recommendation__c=m.ElixirSuite__ElixirSuite_Recommendation__c;
                    recommendation.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c=m.ElixirSuite__Adjustment_Group_Code__c;
                    recommendation.ElixirSuite__ElixirSuite_Adjustment_Reason__c=m.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;
                    recommendation.ElixirSuite__Elixir_ERA__c=ERAid;
                    recommendation.ElixirSuite__Master_Object__c=m.Id;
                    recommendation.ElixirSuite__Elixir_Assign_To__c=m.ElixirSuite__ElixirSuite_Assign_To__c;
                    recommendationList.add(recommendation);
                system.debug('recommendation list' +recommendationList);
                system.debug('recommendation' +recommendation);
                }
            }
            for(id ERAid :eraSupplementalCodes.keyset()){
                System.debug('masterSuppString***'+masterSuppString);
                System.debug('eraSupplementalCodes.get(ERAid).contains(masterSuppString)'+eraSupplementalCodes.get(ERAid).contains(masterSuppString));
                if(eraSupplementalCodes.get(ERAid).contains(masterSuppString) && m.recordtypeid==Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId()){
                    ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                    recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId();
                    recommendation.ElixirSuite__Elixir_Recommendation__c=m.ElixirSuite__ElixirSuite_Recommendation__c;
                    recommendation.ElixirSuite__ElixirSuite_Supplemental_Group_Code__c=m.ElixirSuite__Supplemental_Group_Code__c;
                    recommendation.ElixirSuite__Elixir_ERA__c=ERAid;
                    recommendation.ElixirSuite__Master_Object__c=m.Id;
                    recommendation.ElixirSuite__Elixir_Assign_To__c=m.ElixirSuite__ElixirSuite_Assign_To__c;
                    recommendation.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c=m.ElixirSuite__Adjustment_Group_Code__c;
                    recommendation.ElixirSuite__ElixirSuite_Adjustment_Reason__c=m.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;
                    recommendationList.add(recommendation);
                }
            }
        }
       
        if(recommendationList.size()>0){
            if(Schema.sObjectType.ElixirSuite__Recommendation__c.isCreateable() &&
           
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Elixir_Recommendation__c.isCreateable() &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Supplemental_Group_Code__c.isCreateable() &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Elixir_ERA__c.isCreateable() &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Master_Object__c.isCreateable() &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Elixir_Assign_To__c.isCreateable() &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Elixir_Assign_To__c.isCreateable() &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.RecordTypeId.isCreateable() &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c.isCreateable() &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Adjustment_Reason__c.isCreateable() &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c.isCreateable()){ 
            insert recommendationList;
            }
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    
/*    public static void updateMasterField(List<ElixirSuite__Master_Object__c> newList){
        List<ElixirSuite__Master_Object__c> moList = new List<ElixirSuite__Master_Object__c>();
        for(ElixirSuite__Master_Object__c m:newList){
            String masterAdjString =m.ElixirSuite__Adjustment_Group_Code__c+m.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;
            String masterSuppString=masterAdjString+ m.ElixirSuite__Supplemental_Group_Code__c;
            if(m.RecordTypeId == Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId()){
             System.debug('adjjjjjjj');
             m.ElixirSuite__AdjSupRecType__c = masterAdjString;
            }
            if(m.RecordTypeId == Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId()){
             System.debug('supppp');
                m.ElixirSuite__AdjSupRecType__c = masterSuppString;
            }
            
        }
     }*/
    
}