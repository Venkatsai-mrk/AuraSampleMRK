/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ERALineItemTriggerHelper{
	public static void createRecommendations(List<ElixirSuite__ERA_Line_Item__c> ELIList){
		Set<id> ELIERAIds = new Set<id>();
		List<ElixirSuite__Recommendation__c> recomToInsert =new List<ElixirSuite__Recommendation__c>();
		Set<String> ELIInfoCodes = new Set<String>();
		Set<String> ELIAdjCodes = new Set<String>();
		Set<String> ELISupCodes = new Set<String>();
		for(ElixirSuite__ERA_Line_Item__c ELI : ELIList){
            ELIERAIds.add(ELI.ElixirSuite__EOB__c);
			if(ELI.ElixirSuite__ERAInformational_Remark_Codes__c!=null){
				ELIInfoCodes.addALL(ELI.ElixirSuite__ERAInformational_Remark_Codes__c.split(';'));
			}
            if(ELI.ElixirSuite__Group_1__c!=null){
                ELIAdjCodes.add(ELI.ElixirSuite__Group_1__c);
            }
            if(ELI.ElixirSuite__Group_2__c!=null){
                ELIAdjCodes.add(ELI.ElixirSuite__Group_2__c);
            }
            if(ELI.ElixirSuite__Group_3__c!=null){
                ELIAdjCodes.add(ELI.ElixirSuite__Group_3__c);
            }
            if(ELI.ElixirSuite__Group_4__c!=null){
                ELIAdjCodes.add(ELI.ElixirSuite__Group_4__c);
            }
            if(ELI.ElixirSuite__Group_5__c!=null){
                ELIAdjCodes.add(ELI.ElixirSuite__Group_5__c);
            }
            if(ELI.ElixirSuite__Group_6__c!=null){
                ELIAdjCodes.add(ELI.ElixirSuite__Group_6__c);
            }
            if(ELI.ElixirSuite__Group_7__c!=null){
                ELIAdjCodes.add(ELI.ElixirSuite__Group_7__c);
            }
            if(ELI.ElixirSuite__Group_8__c!=null){
                ELIAdjCodes.add(ELI.ElixirSuite__Group_8__c);
            }
			if(ELI.ElixirSuite__ERASupplemental_Remark_Codes1__c!=null){
				ELISupCodes.add(ELI.ElixirSuite__ERASupplemental_Remark_Codes1__c);
			}
            if(ELI.ElixirSuite__ERASupplemental_Remark_Codes2__c!=null){
				ELISupCodes.add(ELI.ElixirSuite__ERASupplemental_Remark_Codes2__c);
			}
            if(ELI.ElixirSuite__ERASupplemental_Remark_Codes3__c!=null){
				ELISupCodes.add(ELI.ElixirSuite__ERASupplemental_Remark_Codes3__c);
			}
            if(ELI.ElixirSuite__ERASupplemental_Remark_Codes4__c!=null){
				ELISupCodes.add(ELI.ElixirSuite__ERASupplemental_Remark_Codes4__c);
			}
            if(ELI.ElixirSuite__ERASupplemental_Remark_Codes5__c!=null){
				ELISupCodes.add(ELI.ElixirSuite__ERASupplemental_Remark_Codes5__c);
			}
            if(ELI.ElixirSuite__ERASupplemental_Remark_Codes6__c!=null){
				ELISupCodes.add(ELI.ElixirSuite__ERASupplemental_Remark_Codes6__c);
			}
            if(ELI.ElixirSuite__ERASupplemental_Remark_Codes7__c!=null){
				ELISupCodes.add(ELI.ElixirSuite__ERASupplemental_Remark_Codes7__c);
			}
            if(ELI.ElixirSuite__ERASupplemental_Remark_Codes8__c!=null){
				ELISupCodes.add(ELI.ElixirSuite__ERASupplemental_Remark_Codes8__c);
			}
		}
		//Retrieving Rec and its codes
		Map<id,List<String>> ERAAndInfoRecommendationsMap = new Map<id,List<String>>();
		Map<id,List<String>> ERAAndAdjRecommendationsMap = new Map<id,List<String>>();
		Map<id,List<String>> ERAAndSupRecommendationsMap = new Map<id,List<String>>();
		List<ElixirSuite__Recommendation__c> infoRecommendationList = [Select ElixirSuite__Elixir_ERA__c,ElixirSuite__ElixirSuite_Informational_Remark_Codes__c from ElixirSuite__Recommendation__c 
																		where ElixirSuite__Elixir_ERA__c in :ELIERAIds and 
																		ElixirSuite__ElixirSuite_Informational_Remark_Codes__c in :ELIInfoCodes WITH SECURITY_ENFORCED];
		for(ElixirSuite__Recommendation__c info : infoRecommendationList){
			if(ERAAndInfoRecommendationsMap.containsKey(info.ElixirSuite__Elixir_ERA__c)){
				ERAAndInfoRecommendationsMap.get(info.ElixirSuite__Elixir_ERA__c).add(info.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c);
			}
			else{
				ERAAndInfoRecommendationsMap.put(info.ElixirSuite__Elixir_ERA__c,new List<String>{info.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c});
			}
		}
		List<ElixirSuite__Recommendation__c> adjRecommendationList = [Select ElixirSuite__Elixir_ERA__c,ElixirSuite__ElixirSuite_Adjustment_Group_Code__c,ElixirSuite__ElixirSuite_Adjustment_Reason__c from ElixirSuite__Recommendation__c 
																		where ElixirSuite__Elixir_ERA__c in :ELIERAIds and 
																		ElixirSuite__ElixirSuite_Adjustment_Group_Code__c in :ELIAdjCodes WITH SECURITY_ENFORCED];
		for(ElixirSuite__Recommendation__c info : adjRecommendationList){
            String strAdjRec=info.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c+info.ElixirSuite__ElixirSuite_Adjustment_Reason__c;
			if(ERAAndAdjRecommendationsMap.containsKey(info.ElixirSuite__Elixir_ERA__c)){
				ERAAndAdjRecommendationsMap.get(info.ElixirSuite__Elixir_ERA__c).add(strAdjRec);
			}
			else{
				ERAAndAdjRecommendationsMap.put(info.ElixirSuite__Elixir_ERA__c,new List<String>{strAdjRec});
			}
		}
		List<ElixirSuite__Recommendation__c> supRecommendationList = [Select ElixirSuite__Elixir_ERA__c,ElixirSuite__ElixirSuite_Adjustment_Reason__c,ElixirSuite__ElixirSuite_Adjustment_Group_Code__c,ElixirSuite__ElixirSuite_Supplemental_Group_Code__c from ElixirSuite__Recommendation__c 
																		where ElixirSuite__Elixir_ERA__c in :ELIERAIds and 
																		ElixirSuite__ElixirSuite_Supplemental_Group_Code__c in :ELISupCodes WITH SECURITY_ENFORCED];
		for(ElixirSuite__Recommendation__c info : supRecommendationList){
			String strSupRec=info.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c+info.ElixirSuite__ElixirSuite_Adjustment_Reason__c+info.ElixirSuite__ElixirSuite_Supplemental_Group_Code__c;
            if(ERAAndSupRecommendationsMap.containsKey(info.ElixirSuite__Elixir_ERA__c)){
				ERAAndSupRecommendationsMap.get(info.ElixirSuite__Elixir_ERA__c).add(strSupRec);
			}
			else{
				ERAAndSupRecommendationsMap.put(info.ElixirSuite__Elixir_ERA__c,new List<String>{strSupRec});
			}
		}
		//Retrieving master and its codes
		Map<String,List<ElixirSuite__Master_Object__c>> infoAndMasterMap =new Map<String,List<ElixirSuite__Master_Object__c>>();
		Map<String,List<ElixirSuite__Master_Object__c>> AdjAndMasterMap =new Map<String,List<ElixirSuite__Master_Object__c>>();
		Map<String,List<ElixirSuite__Master_Object__c>> supAndMasterMap =new Map<String,List<ElixirSuite__Master_Object__c>>();
		List<ElixirSuite__Master_Object__c> masterInfoList =[select ElixirSuite__ElixirSuite_Assign_To__c,
																ElixirSuite__ElixirSuite_Informational_Remark_Codes__c,
																ElixirSuite__ElixirSuite_Recommendation__c from ElixirSuite__Master_Object__c where
																ElixirSuite__ElixirSuite_Informational_Remark_Codes__c in :ELIInfoCodes WITH SECURITY_ENFORCED];
		List<ElixirSuite__Master_Object__c> tempinfoList = filterMasterRecords(masterInfoList);
		for(ElixirSuite__Master_Object__c eachRec:tempinfoList){
			if(infoAndMasterMap.containsKey(eachRec.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c)){
				infoAndMasterMap.get(eachRec.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c).add(eachRec);
			}
			else{
				infoAndMasterMap.put(eachRec.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c,new List<ElixirSuite__Master_Object__c>{eachRec});
			}
		}		
		List<ElixirSuite__Master_Object__c> masterAdjList =[select ElixirSuite__Adjustment_Group_Code__c,
																ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c,
																ElixirSuite__ElixirSuite_Assign_To__c,
																ElixirSuite__ElixirSuite_Recommendation__c from ElixirSuite__Master_Object__c where 
																ElixirSuite__Adjustment_Group_Code__c in :ELIAdjCodes and ElixirSuite__Supplemental_Group_Code__c=null WITH SECURITY_ENFORCED];
		List<ElixirSuite__Master_Object__c> tempAdjList = filterMasterRecords(masterAdjList);
		for(ElixirSuite__Master_Object__c eachRec : tempAdjList){
            String strAdjMaster = eachRec.ElixirSuite__Adjustment_Group_Code__c+eachRec.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;
			if(AdjAndMasterMap.containsKey(strAdjMaster)){
				AdjAndMasterMap.get(strAdjMaster).add(eachRec);
			}
			else{
				AdjAndMasterMap.put(strAdjMaster,new List<ElixirSuite__Master_Object__c>{eachRec});
			}
		}
		List<ElixirSuite__Master_Object__c> masterSupList =[select ElixirSuite__ElixirSuite_Assign_To__c,ElixirSuite__Adjustment_Group_Code__c,ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c,
																ElixirSuite__ElixirSuite_Recommendation__c, ElixirSuite__Supplemental_Group_Code__c from ElixirSuite__Master_Object__c where 
																ElixirSuite__Supplemental_Group_Code__c in :ELISupCodes WITH SECURITY_ENFORCED];														
		List<ElixirSuite__Master_Object__c> tempSupList = filterMasterRecords(masterSupList);
		for(ElixirSuite__Master_Object__c eachRec : tempSupList){
			String strSupMaster = eachRec.ElixirSuite__Adjustment_Group_Code__c+eachRec.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c+eachRec.ElixirSuite__Supplemental_Group_Code__c;
            if(supAndMasterMap.containsKey(strSupMaster)){
				supAndMasterMap.get(strSupMaster).add(eachRec);
			}
			else{
				supAndMasterMap.put(strSupMaster,new List<ElixirSuite__Master_Object__c>{eachRec});
			}
		}
        Map<id,Set<String>> tempInfoRecommendationMap = new Map<id,Set<String>>();
        Map<id,Set<String>> tempAdjRecommendationMap = new Map<id,Set<String>>();
        Map<id,Set<String>> tempSupRecommendationMap = new Map<id,Set<String>>();
		//Core Logic 
		for(ElixirSuite__ERA_Line_Item__c eachELI : ELIList){
			//info codes
			If(eachELI.ElixirSuite__ERAInformational_Remark_Codes__c !=null){
                for(String code : eachELI.ElixirSuite__ERAInformational_Remark_Codes__c.split(';')){
                    if(!ERAAndInfoRecommendationsMap.containsKey(eachELI.ElixirSuite__EOB__c) && infoAndMasterMap.containsKey(code)){
                        for(ElixirSuite__Master_Object__c masterRecord : infoAndMasterMap.get(code)){
                            ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                            recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Informational_Remark_Codes').getRecordTypeId();
                            recommendation.ElixirSuite__Elixir_Recommendation__c=masterRecord.ElixirSuite__ElixirSuite_Recommendation__c;
                            recommendation.ElixirSuite__Master_Object__c=masterRecord.Id;
                            recommendation.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c=code;
                            recommendation.ElixirSuite__Elixir_ERA__c=eachELI.ElixirSuite__EOB__c;
                            recommendation.ElixirSuite__Elixir_Assign_To__c=masterRecord.ElixirSuite__ElixirSuite_Assign_To__c;
                            //restricts duplicate recommendation creation
                            if(!tempInfoRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c) || !tempInfoRecommendationMap.get(eachELI.ElixirSuite__EOB__c).contains(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c)){
                                recomToInsert.add(recommendation);
                            }
                            if(tempInfoRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c)){
                                tempInfoRecommendationMap.get(eachELI.ElixirSuite__EOB__c).add(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c);
                            }
                            else{
                                tempInfoRecommendationMap.put(eachELI.ElixirSuite__EOB__c,new Set<String>{code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c});
                            }
                        }
                    }
                    else if(ERAAndInfoRecommendationsMap.containsKey(eachELI.ElixirSuite__EOB__c) && infoAndMasterMap.containsKey(code)){
                        if(!ERAAndInfoRecommendationsMap.get(eachELI.ElixirSuite__EOB__c).contains(code)){
                            for(ElixirSuite__Master_Object__c masterRecord : infoAndMasterMap.get(code)){
                                ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                                recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Informational_Remark_Codes').getRecordTypeId();
                                recommendation.ElixirSuite__Elixir_Recommendation__c=masterRecord.ElixirSuite__ElixirSuite_Recommendation__c;
                                recommendation.ElixirSuite__Master_Object__c=masterRecord.Id;
                                recommendation.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c=code;
                                recommendation.ElixirSuite__Elixir_ERA__c=eachELI.ElixirSuite__EOB__c;
                                recommendation.ElixirSuite__Elixir_Assign_To__c=masterRecord.ElixirSuite__ElixirSuite_Assign_To__c;
                                //restricts duplicate recommendation creation
                                if(!tempInfoRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c) || !tempInfoRecommendationMap.get(eachELI.ElixirSuite__EOB__c).contains(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c)){
                                    recomToInsert.add(recommendation);
                                }
                                if(tempInfoRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c)){
                                    tempInfoRecommendationMap.get(eachELI.ElixirSuite__EOB__c).add(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c);
                                }
                                else{
                                    tempInfoRecommendationMap.put(eachELI.ElixirSuite__EOB__c,new Set<String>{code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c});
                                }
                            }
                        }
                    }
                }
            }
			//Adj codes
			set<String> AdjgrpCodes =getAdjSet(eachELI);
            for(String code :AdjgrpCodes){
                if(!ERAAndAdjRecommendationsMap.containsKey(eachELI.ElixirSuite__EOB__c) && AdjAndMasterMap.containsKey(code)){
                    for(ElixirSuite__Master_Object__c masterRecord : AdjAndMasterMap.get(code)){
                        ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                        recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId();
                        recommendation.ElixirSuite__Elixir_Recommendation__c=masterRecord.ElixirSuite__ElixirSuite_Recommendation__c;
                        recommendation.ElixirSuite__Master_Object__c=masterRecord.Id;
                        recommendation.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c=masterRecord.ElixirSuite__Adjustment_Group_Code__c;
                        recommendation.ElixirSuite__ElixirSuite_Adjustment_Reason__c=masterRecord.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;
                        recommendation.ElixirSuite__Elixir_ERA__c=eachELI.ElixirSuite__EOB__c;
                        recommendation.ElixirSuite__Elixir_Assign_To__c=masterRecord.ElixirSuite__ElixirSuite_Assign_To__c;
                        //restricts duplicate recommendation creation
                        if(!tempAdjRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c) || !tempAdjRecommendationMap.get(eachELI.ElixirSuite__EOB__c).contains(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c)){
                           recomToInsert.add(recommendation);
                        }
                        if(tempAdjRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c)){
                            tempAdjRecommendationMap.get(eachELI.ElixirSuite__EOB__c).add(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c);
                        }
                        else{
                            tempAdjRecommendationMap.put(eachELI.ElixirSuite__EOB__c,new Set<String>{code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c});
                        }
                    }
                }
                else if(ERAAndAdjRecommendationsMap.containsKey(eachELI.ElixirSuite__EOB__c) && AdjAndMasterMap.containsKey(code)){
                    if(!ERAAndAdjRecommendationsMap.get(eachELI.ElixirSuite__EOB__c).contains(code)){
                        for(ElixirSuite__Master_Object__c masterRecord : AdjAndMasterMap.get(code)){
                            ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                            recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId();
                            recommendation.ElixirSuite__Elixir_Recommendation__c=masterRecord.ElixirSuite__ElixirSuite_Recommendation__c;
                            recommendation.ElixirSuite__Master_Object__c=masterRecord.Id;
                            recommendation.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c=masterRecord.ElixirSuite__Adjustment_Group_Code__c;
                            recommendation.ElixirSuite__Elixir_ERA__c=eachELI.ElixirSuite__EOB__c;
                            recommendation.ElixirSuite__Elixir_Assign_To__c=masterRecord.ElixirSuite__ElixirSuite_Assign_To__c;
                            //restricts duplicate recommendation creation
                            if(!tempAdjRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c) || !tempAdjRecommendationMap.get(eachELI.ElixirSuite__EOB__c).contains(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c)){
                                recomToInsert.add(recommendation);
                            }
                            if(tempAdjRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c)){
                                tempAdjRecommendationMap.get(eachELI.ElixirSuite__EOB__c).add(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c);
                            }
                            else{
                                tempAdjRecommendationMap.put(eachELI.ElixirSuite__EOB__c,new Set<String>{code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c});
                            }
                        }
                    }
                }
            }
			//sup codes
			set<String> supCodes=getSupSet(eachELI);
            for(String code : supCodes){
                if(!ERAAndSupRecommendationsMap.containsKey(eachELI.ElixirSuite__EOB__c) && supAndMasterMap.containsKey(code)){
                    for(ElixirSuite__Master_Object__c masterRecord : supAndMasterMap.get(code)){
                        ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                        recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId();
                        recommendation.ElixirSuite__Elixir_Recommendation__c=masterRecord.ElixirSuite__ElixirSuite_Recommendation__c;
                        recommendation.ElixirSuite__Master_Object__c=masterRecord.Id;
                        recommendation.ElixirSuite__ElixirSuite_Supplemental_Group_Code__c=masterRecord.ElixirSuite__Supplemental_Group_Code__c;
                        recommendation.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c=masterRecord.ElixirSuite__Adjustment_Group_Code__c;
                        recommendation.ElixirSuite__ElixirSuite_Adjustment_Reason__c=masterRecord.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;
                        recommendation.ElixirSuite__Elixir_ERA__c=eachELI.ElixirSuite__EOB__c;
                        recommendation.ElixirSuite__Elixir_Assign_To__c=masterRecord.ElixirSuite__ElixirSuite_Assign_To__c;
                        //restricts duplicate recommendation creation
                        if(!tempSupRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c) || !tempSupRecommendationMap.get(eachELI.ElixirSuite__EOB__c).contains(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c)){
                            recomToInsert.add(recommendation);
                        }
                        if(tempSupRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c)){
                            tempSupRecommendationMap.get(eachELI.ElixirSuite__EOB__c).add(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c);
                        }
                        else{
                            tempSupRecommendationMap.put(eachELI.ElixirSuite__EOB__c,new Set<String>{code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c});
                        }
                    }
                }
                else if(ERAAndSupRecommendationsMap.containsKey(eachELI.ElixirSuite__EOB__c) && supAndMasterMap.containsKey(code)){
                    if(!ERAAndSupRecommendationsMap.get(eachELI.ElixirSuite__EOB__c).contains(code)){
                        for(ElixirSuite__Master_Object__c masterRecord : supAndMasterMap.get(code)){
                            ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                            recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId();
                            recommendation.ElixirSuite__Elixir_Recommendation__c=masterRecord.ElixirSuite__ElixirSuite_Recommendation__c;
                            recommendation.ElixirSuite__Master_Object__c=masterRecord.Id;
                            recommendation.ElixirSuite__ElixirSuite_Supplemental_Group_Code__c=masterRecord.ElixirSuite__Supplemental_Group_Code__c;
                            recommendation.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c=masterRecord.ElixirSuite__Adjustment_Group_Code__c;
                        	recommendation.ElixirSuite__ElixirSuite_Adjustment_Reason__c=masterRecord.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;
                            recommendation.ElixirSuite__Elixir_ERA__c=eachELI.ElixirSuite__EOB__c;
                            recommendation.ElixirSuite__Elixir_Assign_To__c=masterRecord.ElixirSuite__ElixirSuite_Assign_To__c;
                            //restricts duplicate recommendation creation
                            if(!tempSupRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c) || !tempSupRecommendationMap.get(eachELI.ElixirSuite__EOB__c).contains(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c)){
                                recomToInsert.add(recommendation);
                            }
                            if(tempSupRecommendationMap.containsKey(eachELI.ElixirSuite__EOB__c)){
                                tempSupRecommendationMap.get(eachELI.ElixirSuite__EOB__c).add(code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c);
                            }
                            else{
                                tempSupRecommendationMap.put(eachELI.ElixirSuite__EOB__c,new Set<String>{code+masterRecord.ElixirSuite__ElixirSuite_Recommendation__c});
                            }
                        }
                    }
                }
            }
		}

		if(recomToInsert.size()>0){
            if(Schema.sObjectType.ElixirSuite__Recommendation__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Recommendation__c.fields.RecordTypeId.isCreateable() && 
            Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Elixir_Recommendation__c.isCreateable() && 
            Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Master_Object__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Supplemental_Group_Code__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c.isCreateable() && 
            Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Adjustment_Reason__c.isCreateable() && 
            Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Elixir_ERA__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c.isCreateable() &&
            Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Elixir_Assign_To__c.isCreateable()){
                    insert recomToInsert;
                }
            }
		
        
	}
	public static Set<String> getAdjSet(ElixirSuite__ERA_Line_Item__c n){
		set<String> ELIAdjCodes=new Set<String>();
		if(n.ElixirSuite__Group_1__c!=null && n.ElixirSuite__Code_1__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes1__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes1__c=='None')){
			ELIAdjCodes.add(n.ElixirSuite__Group_1__c+n.ElixirSuite__Code_1__c);
		}
		if(n.ElixirSuite__Group_2__c!=null && n.ElixirSuite__Code_2__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes2__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes2__c=='None')){
			ELIAdjCodes.add(n.ElixirSuite__Group_2__c+n.ElixirSuite__Code_2__c);
		}
		if(n.ElixirSuite__Group_3__c!=null && n.ElixirSuite__Code_3__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes3__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes3__c=='None')){
			ELIAdjCodes.add(n.ElixirSuite__Group_3__c+n.ElixirSuite__Code_3__c);
		}
		if(n.ElixirSuite__Group_4__c!=null && n.ElixirSuite__Code_4__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes4__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes4__c=='None')){
			ELIAdjCodes.add(n.ElixirSuite__Group_4__c+n.ElixirSuite__Code_4__c);
		}
		if(n.ElixirSuite__Group_5__c!=null && n.ElixirSuite__Code_5__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes5__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes5__c=='None')){
			ELIAdjCodes.add(n.ElixirSuite__Group_5__c+n.ElixirSuite__Code_5__c);
		}
		if(n.ElixirSuite__Group_6__c!=null && n.ElixirSuite__Code_6__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes6__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes6__c=='None')){
			ELIAdjCodes.add(n.ElixirSuite__Group_6__c+n.ElixirSuite__Code_6__c);
		}
		if(n.ElixirSuite__Group_7__c!=null && n.ElixirSuite__Code_7__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes7__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes7__c=='None')){
			ELIAdjCodes.add(n.ElixirSuite__Group_7__c+n.ElixirSuite__Code_7__c);
		}
		if(n.ElixirSuite__Group_8__c!=null && n.ElixirSuite__Code_8__c!=null && (n.ElixirSuite__ERASupplemental_Remark_Codes8__c==null || n.ElixirSuite__ERASupplemental_Remark_Codes8__c=='None')){
			ELIAdjCodes.add(n.ElixirSuite__Group_8__c+n.ElixirSuite__Code_8__c);
		}
		return ELIAdjCodes;
	}
    public static Set<String> getSupSet(ElixirSuite__ERA_Line_Item__c n){
        set<String> ELISupCodes=new Set<String>();
        if(n.ElixirSuite__Group_1__c!=null && n.ElixirSuite__Code_1__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes1__c!=null){
			ELISupCodes.add(n.ElixirSuite__Group_1__c+n.ElixirSuite__Code_1__c+n.ElixirSuite__ERASupplemental_Remark_Codes1__c);
		}
		if(n.ElixirSuite__Group_2__c!=null && n.ElixirSuite__Code_2__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes2__c!=null){
			ELISupCodes.add(n.ElixirSuite__Group_2__c+n.ElixirSuite__Code_2__c+n.ElixirSuite__ERASupplemental_Remark_Codes2__c);
		}
		if(n.ElixirSuite__Group_3__c!=null && n.ElixirSuite__Code_3__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes3__c!=null){
			ELISupCodes.add(n.ElixirSuite__Group_3__c+n.ElixirSuite__Code_3__c+n.ElixirSuite__ERASupplemental_Remark_Codes3__c);
		}
		if(n.ElixirSuite__Group_4__c!=null && n.ElixirSuite__Code_4__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes4__c!=null){
			ELISupCodes.add(n.ElixirSuite__Group_4__c+n.ElixirSuite__Code_4__c+n.ElixirSuite__ERASupplemental_Remark_Codes4__c);
		}
		if(n.ElixirSuite__Group_5__c!=null && n.ElixirSuite__Code_5__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes5__c!=null){
			ELISupCodes.add(n.ElixirSuite__Group_5__c+n.ElixirSuite__Code_5__c+n.ElixirSuite__ERASupplemental_Remark_Codes5__c);
		}
		if(n.ElixirSuite__Group_6__c!=null && n.ElixirSuite__Code_6__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes6__c!=null){
			ELISupCodes.add(n.ElixirSuite__Group_6__c+n.ElixirSuite__Code_6__c+n.ElixirSuite__ERASupplemental_Remark_Codes6__c);
		}
		if(n.ElixirSuite__Group_7__c!=null && n.ElixirSuite__Code_7__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes7__c!=null){
			ELISupCodes.add(n.ElixirSuite__Group_7__c+n.ElixirSuite__Code_7__c+n.ElixirSuite__ERASupplemental_Remark_Codes7__c);
		}
		if(n.ElixirSuite__Group_8__c!=null && n.ElixirSuite__Code_8__c!=null && n.ElixirSuite__ERASupplemental_Remark_Codes8__c!=null){
			ELISupCodes.add(n.ElixirSuite__Group_8__c+n.ElixirSuite__Code_8__c+n.ElixirSuite__ERASupplemental_Remark_Codes8__c);
		}
        return ELISupCodes;
    }
    public static List<ElixirSuite__Master_Object__c> filterMasterRecords(List<ElixirSuite__Master_Object__c> masterList){
        Map<String,ElixirSuite__Master_Object__c> tempMap = new Map<String,ElixirSuite__Master_Object__c>();
        for(ElixirSuite__Master_Object__c eachRec : masterList){
            tempMap.put(eachRec.ElixirSuite__ElixirSuite_Recommendation__c,eachRec);
        }
        return tempMap.values();
    }
    
    public static void createRecOnUpdateERALineItem(List<ElixirSuite__ERA_Line_Item__c> ELIList,Map<Id,ElixirSuite__ERA_Line_Item__c> oldELIMap){
        Map<String,set<String>> ERAAndListOfInfoMap = new Map<String,set<String>>();
        Map<String,set<String>> ERAAndListOfAdjCodeMap = new Map<String,set<String>>();
        Map<String,set<String>> ERAAndListOfSuppCodeMap = new Map<String,set<String>>();
        Set<String> informationCodeList = new Set<String>();
        Set<String> ELIAdjCodes = new Set<String>();
        Set<String> ELISupCodes = new Set<String>();
        for(ElixirSuite__ERA_Line_Item__c eli : ELIList){
            if(eli.ElixirSuite__EOB__c != null){
                if(eli.ElixirSuite__ERAInformational_Remark_Codes__c != null && (oldELIMap == null || (oldELIMap!=null && eli.ElixirSuite__ERAInformational_Remark_Codes__c != oldELIMap.get(eli.Id).ElixirSuite__ERAInformational_Remark_Codes__c))){
                    List<String> codeList = eli.ElixirSuite__ERAInformational_Remark_Codes__c.split(';'); 
                    for(String cod:codeList) {
                        informationCodeList.add(cod);    
                        Set<String> infoCodeList =  ERAAndListOfInfoMap.get(eli.ElixirSuite__EOB__c);
                        if(infoCodeList != null){
                            infoCodeList.add(cod); 
                            ERAAndListOfInfoMap.put(eli.ElixirSuite__EOB__c,infoCodeList);    
                        }else{
                            Set<String> newInfoCodeList = new Set<String>();
                            newInfoCodeList.add(cod); 
                            ERAAndListOfInfoMap.put(eli.ElixirSuite__EOB__c,newInfoCodeList);   
                        }
                    }
                }
                for(integer i=1;i<=8;i++){
                    Set<String> AdjCodes =  ERAAndListOfAdjCodeMap.get(eli.ElixirSuite__EOB__c);
                    if(AdjCodes != null){
                        if(eli.get('ElixirSuite__Group_'+i+'__c') !=null && eli.get('ElixirSuite__Code_'+i+'__c') !=null && (eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c')==null || eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c')=='None') && (oldELIMap == null || (oldELIMap!=null && eli.get('ElixirSuite__Group_'+i+'__c') != (oldELIMap.get(eli.Id)).get('ElixirSuite__Group_'+i+'__c')) || (oldELIMap!=null && eli.get('ElixirSuite__Code_'+i+'__c') != (oldELIMap.get(eli.Id)).get('ElixirSuite__Code_'+i+'__c')))){
                            ELIAdjCodes.add(string.valueOf(eli.get('ElixirSuite__Group_'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Code_'+i+'__c')));
                            AdjCodes.add(string.valueOf(eli.get('ElixirSuite__Group_'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Code_'+i+'__c')));
                        } 
                        ERAAndListOfAdjCodeMap.put(eli.ElixirSuite__EOB__c,AdjCodes); 
                    }else{
                        Set<String> newAdjCodes = new Set<String>();
                        if(eli.get('ElixirSuite__Group_'+i+'__c') !=null && eli.get('ElixirSuite__Code_'+i+'__c') !=null  && (eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c')==null || eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c')=='None') && (oldELIMap == null || (oldELIMap!=null && eli.get('ElixirSuite__Group_'+i+'__c') != (oldELIMap.get(eli.Id)).get('ElixirSuite__Group_'+i+'__c')) || (oldELIMap!=null && eli.get('ElixirSuite__Code_'+i+'__c') != (oldELIMap.get(eli.Id)).get('ElixirSuite__Code_'+i+'__c')))){
                            ELIAdjCodes.add(string.valueOf(eli.get('ElixirSuite__Group_'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Code_'+i+'__c')));
                            newAdjCodes.add(string.valueOf(eli.get('ElixirSuite__Group_'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Code_'+i+'__c')));
                        } 
                        ERAAndListOfAdjCodeMap.put(eli.ElixirSuite__EOB__c,newAdjCodes);    
                    }
                    
                    Set<String> SupCodes =  ERAAndListOfSuppCodeMap.get(eli.ElixirSuite__EOB__c);
                    if(SupCodes != null){
                        if(eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c') !=null && eli.get('ElixirSuite__Group_'+i+'__c') !=null && eli.get('ElixirSuite__Code_'+i+'__c') !=null && (oldELIMap == null || (oldELIMap!=null && eli.get('ElixirSuite__Group_'+i+'__c') != (oldELIMap.get(eli.Id)).get('ElixirSuite__Group_'+i+'__c')) || (oldELIMap!=null && eli.get('ElixirSuite__Code_'+i+'__c') != (oldELIMap.get(eli.Id)).get('ElixirSuite__Code_'+i+'__c')) ||(oldELIMap!=null && eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c') != (oldELIMap.get(eli.Id)).get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c')) )){
                            ELISupCodes.add(string.valueOf(eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Group_'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Code_'+i+'__c')));
                            SupCodes.add(string.valueOf(eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Group_'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Code_'+i+'__c')));
                        } 
                        ERAAndListOfSuppCodeMap.put(eli.ElixirSuite__EOB__c,SupCodes); 
                    }else{
                        Set<String> newSupCodes = new Set<String>();
                        if(eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c') !=null && eli.get('ElixirSuite__Group_'+i+'__c') !=null && eli.get('ElixirSuite__Code_'+i+'__c') !=null && (oldELIMap == null || (oldELIMap!=null && eli.get('ElixirSuite__Group_'+i+'__c') != (oldELIMap.get(eli.Id)).get('ElixirSuite__Group_'+i+'__c')) || (oldELIMap!=null && eli.get('ElixirSuite__Code_'+i+'__c') != (oldELIMap.get(eli.Id)).get('ElixirSuite__Code_'+i+'__c')) ||(oldELIMap!=null && eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c') != (oldELIMap.get(eli.Id)).get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c')) )){
                            ELISupCodes.add(string.valueOf(eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Group_'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Code_'+i+'__c')));
                            newSupCodes.add(string.valueOf(eli.get('ElixirSuite__ERASupplemental_Remark_Codes'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Group_'+i+'__c')) + string.valueOf(eli.get('ElixirSuite__Code_'+i+'__c')));
                        } 
                        ERAAndListOfSuppCodeMap.put(eli.ElixirSuite__EOB__c,newSupCodes);    
                    }
                    
                }
            }
        }
        //Master object Record of Information Remark Code
        List<ElixirSuite__Master_Object__c> masterInfoList =[select ElixirSuite__ElixirSuite_Assign_To__c,
                                                             ElixirSuite__ElixirSuite_Informational_Remark_Codes__c,
                                                             ElixirSuite__ElixirSuite_Recommendation__c from ElixirSuite__Master_Object__c where
                                                             ElixirSuite__ElixirSuite_Informational_Remark_Codes__c in :informationCodeList WITH SECURITY_ENFORCED];
        Map<String,List<ElixirSuite__Master_Object__c>> infoAndMasterMap =new Map<String,List<ElixirSuite__Master_Object__c>>();
        for(ElixirSuite__Master_Object__c ms:masterInfoList){
            if(ms.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c != null){   
                List<ElixirSuite__Master_Object__c> msRecordList= infoAndMasterMap.get(ms.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c);
                if(msRecordList != null)  {
                    msRecordList.add(ms);
                    infoAndMasterMap.put(ms.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c,msRecordList);
                }else{
                    List<ElixirSuite__Master_Object__c> newMsList = new List<ElixirSuite__Master_Object__c>();
                    newMsList.add(ms);
                    infoAndMasterMap.put(ms.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c,newMsList);   
                }  
            }       
        }
        //Recommendation Record of Information Remark Code
        List<ElixirSuite__Recommendation__c> infoRecommendationList = [Select ElixirSuite__Elixir_ERA__c,ElixirSuite__Elixir_Recommendation__c,ElixirSuite__ElixirSuite_Informational_Remark_Codes__c,ElixirSuite__Master_Object__c from ElixirSuite__Recommendation__c 
                                                                       where ElixirSuite__Elixir_ERA__c in :ERAAndListOfInfoMap.keyset() AND ElixirSuite__ElixirSuite_Informational_Remark_Codes__c in :informationCodeList];
        Map<String,List<String>> ExistERARecWithInfoCode = new Map<String,List<String>>();
        Map<String,List<String>> ExistInfoCodeWithRecId = new Map<String,List<String>>();
        for(ElixirSuite__Recommendation__c rec:infoRecommendationList){
            
            List<String> codeList = ExistERARecWithInfoCode.get(rec.ElixirSuite__Elixir_ERA__c);
            List<String> recom = ExistInfoCodeWithRecId.get(rec.ElixirSuite__Elixir_ERA__c);
            if(codeList != null){
                codeList.add(rec.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c);
                ExistERARecWithInfoCode.put(rec.ElixirSuite__Elixir_ERA__c,codeList);   
                recom.add(rec.ElixirSuite__Master_Object__c);
                ExistInfoCodeWithRecId.put(rec.ElixirSuite__Elixir_ERA__c,recom);   
            }else{
                List<String> newRecInfo = new List<String>();
                newRecInfo.add(rec.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c);
                ExistERARecWithInfoCode.put(rec.ElixirSuite__Elixir_ERA__c,newRecInfo); 
                List<String> newRec = new List<String>();
                newRec.add(rec.ElixirSuite__Master_Object__c);
                ExistInfoCodeWithRecId.put(rec.ElixirSuite__Elixir_ERA__c,newRec);     
            }
            
        }
        
        List<ElixirSuite__Recommendation__c> insertRecommendationList = new List<ElixirSuite__Recommendation__c>();
        for(String era:ERAAndListOfInfoMap.keyset()){
            for(String infoCode:ERAAndListOfInfoMap.get(era)){
                if(infoAndMasterMap.containsKey(infoCode)){
                    for(ElixirSuite__Master_Object__c ms:infoAndMasterMap.get(infoCode)){ 
                        System.debug('ms '+ms);
                        if(ExistERARecWithInfoCode.containsKey(era)){
                            List<String> RecList = ExistInfoCodeWithRecId.get(era);
                            if(!(RecList.contains(ms.Id))){
                                system.debug('Inside Info If');
                                ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                                recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Informational_Remark_Codes').getRecordTypeId();
                                recommendation.ElixirSuite__Elixir_Recommendation__c=ms.ElixirSuite__ElixirSuite_Recommendation__c;
                                recommendation.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c=infoCode;
                                recommendation.ElixirSuite__Elixir_ERA__c=era;
                                recommendation.ElixirSuite__Elixir_Assign_To__c=ms.ElixirSuite__ElixirSuite_Assign_To__c;
                                recommendation.ElixirSuite__Master_Object__c=ms.Id;
                                insertRecommendationList.add(recommendation);     
                            }
                        }else{
                            ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                            recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Informational_Remark_Codes').getRecordTypeId();
                            recommendation.ElixirSuite__Elixir_Recommendation__c=ms.ElixirSuite__ElixirSuite_Recommendation__c;
                            recommendation.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c=infoCode;
                            recommendation.ElixirSuite__Elixir_ERA__c=era;
                            recommendation.ElixirSuite__Elixir_Assign_To__c=ms.ElixirSuite__ElixirSuite_Assign_To__c;
                            recommendation.ElixirSuite__Master_Object__c=ms.Id;
                            insertRecommendationList.add(recommendation);    
                        }
                    }
                }
            }
        }
        
        //Master object Record of Adjustment Group Code
        List<ElixirSuite__Master_Object__c> masterAdjCodeList =[select ElixirSuite__ElixirSuite_Assign_To__c,
                                                                ElixirSuite__Adjustment_Group_Code__c,ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c,
                                                                ElixirSuite__ElixirSuite_Recommendation__c from ElixirSuite__Master_Object__c where
                                                                ElixirSuite__CodeFormula__c IN :ELIAdjCodes AND RecordType.Name='Adjustment Codes' WITH SECURITY_ENFORCED];
        System.debug('masterAdjCodeList '+JSON.serialize(masterAdjCodeList));
       Map<String,List<ElixirSuite__Master_Object__c>> adjAndMasterMap =new Map<String,List<ElixirSuite__Master_Object__c>>();
        for(ElixirSuite__Master_Object__c ms:masterAdjCodeList){
            if(ms.ElixirSuite__Adjustment_Group_Code__c != null && ms.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c !=null){ 
                String masterAdjString =ms.ElixirSuite__Adjustment_Group_Code__c+ms.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;
                List<ElixirSuite__Master_Object__c> msRecordList= adjAndMasterMap.get(masterAdjString);
                if(msRecordList != null)  {
                    msRecordList.add(ms);
                    adjAndMasterMap.put(masterAdjString,msRecordList);
                }else{
                    List<ElixirSuite__Master_Object__c> newMsList = new List<ElixirSuite__Master_Object__c>();
                    newMsList.add(ms);
                    adjAndMasterMap.put(masterAdjString,newMsList);   
                }  
            }       
        }
        
        //Recommendation Record of Adjustment Group Code
        List<ElixirSuite__Recommendation__c> adjRecommendationList = [Select ElixirSuite__Elixir_ERA__c,ElixirSuite__Elixir_Recommendation__c,ElixirSuite__ElixirSuite_Adjustment_Group_Code__c,ElixirSuite__ElixirSuite_Adjustment_Reason__c,ElixirSuite__Master_Object__c from ElixirSuite__Recommendation__c 
                                                                      where ElixirSuite__Elixir_ERA__c in :ERAAndListOfAdjCodeMap.keyset()];
       
        Map<String,List<String>> ExistERARecWithMasObjId = new Map<String,List<String>>();
        for(ElixirSuite__Recommendation__c rec:adjRecommendationList){
           List<String> msId = ExistERARecWithMasObjId.get(rec.ElixirSuite__Elixir_ERA__c);
            if(msId != null){
                msId.add(rec.ElixirSuite__Master_Object__c);
                ExistERARecWithMasObjId.put(rec.ElixirSuite__Elixir_ERA__c,msId);   
            }else{
                List<String> newMsId = new List<String>();
                newMsId.add(rec.ElixirSuite__Master_Object__c);
                ExistERARecWithMasObjId.put(rec.ElixirSuite__Elixir_ERA__c,newMsId);     
            }
            
        }
        
        for(String era:ERAAndListOfAdjCodeMap.keyset()){
            for(String adjCode:ERAAndListOfAdjCodeMap.get(era)){
                if(adjAndMasterMap.containsKey(adjCode)){
                    for(ElixirSuite__Master_Object__c ms:adjAndMasterMap.get(adjCode)){ 
                        System.debug('ms '+ms);
                        if(ExistERARecWithMasObjId.containsKey(era)){
                            List<String> RecList = ExistERARecWithMasObjId.get(era);
                            if(!(RecList.contains(ms.Id))){
                                system.debug('Inside Adjustment If');
                                ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                                recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId();
                                recommendation.ElixirSuite__Elixir_Recommendation__c=ms.ElixirSuite__ElixirSuite_Recommendation__c;
                                recommendation.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c=ms.ElixirSuite__Adjustment_Group_Code__c;
                                recommendation.ElixirSuite__ElixirSuite_Adjustment_Reason__c= ms.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;    
                                recommendation.ElixirSuite__Elixir_ERA__c=era;
                                recommendation.ElixirSuite__Elixir_Assign_To__c=ms.ElixirSuite__ElixirSuite_Assign_To__c;
                                recommendation.ElixirSuite__Master_Object__c=ms.Id;
                                insertRecommendationList.add(recommendation);     
                            }
                        }else{
                            ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                            recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId();
                            recommendation.ElixirSuite__Elixir_Recommendation__c=ms.ElixirSuite__ElixirSuite_Recommendation__c;
                            recommendation.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c=ms.ElixirSuite__Adjustment_Group_Code__c;
                            recommendation.ElixirSuite__ElixirSuite_Adjustment_Reason__c= ms.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;    
                            recommendation.ElixirSuite__Elixir_ERA__c=era;
                            recommendation.ElixirSuite__Elixir_Assign_To__c=ms.ElixirSuite__ElixirSuite_Assign_To__c;
                            recommendation.ElixirSuite__Master_Object__c=ms.Id;
                            insertRecommendationList.add(recommendation);    
                        }
                    }
                }
            }
        }
        
        
        //Master object Record of Supplemental Remark Group Code
        List<ElixirSuite__Master_Object__c> masterSupCodeList =[select ElixirSuite__ElixirSuite_Assign_To__c,
                                                                ElixirSuite__Supplemental_Group_Code__c,ElixirSuite__Adjustment_Group_Code__c,ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c,
                                                                ElixirSuite__ElixirSuite_Recommendation__c from ElixirSuite__Master_Object__c where
                                                                ElixirSuite__CodeFormula__c IN :ELISupCodes AND RecordType.Name='Supplemental Remark Codes' WITH SECURITY_ENFORCED];
        Map<String,List<ElixirSuite__Master_Object__c>> supAndMasterMap =new Map<String,List<ElixirSuite__Master_Object__c>>();
        for(ElixirSuite__Master_Object__c ms:masterSupCodeList){
            if(ms.ElixirSuite__Supplemental_Group_Code__c != null && ms.ElixirSuite__Adjustment_Group_Code__c != null && ms.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c !=null){
                String masterSupString =ms.ElixirSuite__Supplemental_Group_Code__c+ms.ElixirSuite__Adjustment_Group_Code__c+ms.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;
                List<ElixirSuite__Master_Object__c> msRecordList= supAndMasterMap.get(masterSupString);
                if(msRecordList != null)  {
                    msRecordList.add(ms);
                    supAndMasterMap.put(masterSupString,msRecordList);
                }else{
                    List<ElixirSuite__Master_Object__c> newMsList = new List<ElixirSuite__Master_Object__c>();
                    newMsList.add(ms);
                    supAndMasterMap.put(masterSupString,newMsList);   
                }  
            }       
        }
        
        //Recommendation Record of Supplemental Remark Group Codes
        List<ElixirSuite__Recommendation__c> supRecommendationList = [Select ElixirSuite__Elixir_ERA__c,ElixirSuite__Elixir_Recommendation__c,ElixirSuite__ElixirSuite_Supplemental_Group_Code__c,ElixirSuite__ElixirSuite_Adjustment_Group_Code__c,ElixirSuite__ElixirSuite_Adjustment_Reason__c,ElixirSuite__Master_Object__c from ElixirSuite__Recommendation__c 
                                                                      where ElixirSuite__Elixir_ERA__c in :ERAAndListOfSuppCodeMap.keyset()];
        Map<String,List<String>> ExistERARecSupMasObjId = new Map<String,List<String>>();
        for(ElixirSuite__Recommendation__c rec:supRecommendationList){
            List<String> msId = ExistERARecSupMasObjId.get(rec.ElixirSuite__Elixir_ERA__c);
            if(msId != null){
                msId.add(rec.ElixirSuite__Master_Object__c);
                ExistERARecSupMasObjId.put(rec.ElixirSuite__Elixir_ERA__c,msId);   
            }else{
                List<String> newMsId = new List<String>();
                newMsId.add(rec.ElixirSuite__Master_Object__c);
                ExistERARecSupMasObjId.put(rec.ElixirSuite__Elixir_ERA__c,newMsId);     
            }
        }
        
        for(String era:ERAAndListOfSuppCodeMap.keyset()){
            for(String supCode:ERAAndListOfSuppCodeMap.get(era)){
                if(supAndMasterMap.containsKey(supCode)){
                    for(ElixirSuite__Master_Object__c ms:supAndMasterMap.get(supCode)){ 
                        System.debug('ms '+ms);
                        if(ExistERARecSupMasObjId.containsKey(era)){
                            List<String> RecList = ExistERARecSupMasObjId.get(era);
                            if(!(RecList.contains(ms.Id))){
                                system.debug('Inside Supp If');
                                ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                                recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId();
                                recommendation.ElixirSuite__Elixir_Recommendation__c=ms.ElixirSuite__ElixirSuite_Recommendation__c;
                                recommendation.ElixirSuite__ElixirSuite_Supplemental_Group_Code__c=ms.ElixirSuite__Supplemental_Group_Code__c;
                                recommendation.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c=ms.ElixirSuite__Adjustment_Group_Code__c;    
                                recommendation.ElixirSuite__ElixirSuite_Adjustment_Reason__c= ms.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;    
                                recommendation.ElixirSuite__Elixir_ERA__c=era;
                                recommendation.ElixirSuite__Elixir_Assign_To__c=ms.ElixirSuite__ElixirSuite_Assign_To__c;
                                recommendation.ElixirSuite__Master_Object__c=ms.Id;
                                insertRecommendationList.add(recommendation);     
                            }
                        }else{
                            ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
                            recommendation.RecordTypeId= Schema.SobjectType.ElixirSuite__Recommendation__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId();
                            recommendation.ElixirSuite__Elixir_Recommendation__c=ms.ElixirSuite__ElixirSuite_Recommendation__c;
                            recommendation.ElixirSuite__ElixirSuite_Supplemental_Group_Code__c=ms.ElixirSuite__Supplemental_Group_Code__c;
                            recommendation.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c=ms.ElixirSuite__Adjustment_Group_Code__c;
                            recommendation.ElixirSuite__ElixirSuite_Adjustment_Reason__c= ms.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c;    
                            recommendation.ElixirSuite__Elixir_ERA__c=era;
                            recommendation.ElixirSuite__Elixir_Assign_To__c=ms.ElixirSuite__ElixirSuite_Assign_To__c;
                            recommendation.ElixirSuite__Master_Object__c=ms.Id;
                            insertRecommendationList.add(recommendation);    
                        }
                    }
                }
            }
        }
        
        if(insertRecommendationList.size()>0){
        if(Schema.sObjectType.ElixirSuite__Recommendation__c.isCreateable() &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Supplemental_Group_Code__c.isCreateable () &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Adjustment_Reason__c.isCreateable () &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c.isCreateable () &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Master_Object__c.isCreateable () &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Elixir_Assign_To__c.isCreateable () &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Elixir_ERA__c.isCreateable () &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c.isCreateable () &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.ElixirSuite__Elixir_Recommendation__c.isCreateable () &&
        Schema.sObjectType.ElixirSuite__Recommendation__c.fields.RecordTypeId.isCreateable ()) {

            insert insertRecommendationList; 
            }
        }
    }
   
}