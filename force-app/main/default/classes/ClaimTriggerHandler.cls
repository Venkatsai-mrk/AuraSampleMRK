public with sharing class ClaimTriggerHandler {
	public static void updateReconciliationStatus(List<ElixirSuite__Claim__c> lstClaims, Map< id,ElixirSuite__Claim__c> oldClaimsMap){
        try{
            ElixirSuite__ERA_Generation__c eraCS = ElixirSuite__ERA_Generation__c.getInstance();
            for(ElixirSuite__Claim__c claimObj : lstClaims){
                if(oldClaimsMap != null && (oldClaimsMap.get(claimObj.Id)).ElixirSuite__Posted__c == false && claimObj.ElixirSuite__Posted__c == true && eraCS.ElixirSuite__Manual_ERA_Posting_Opted__c != true ){
                    claimObj.ElixirSuite__Reconciliation_Status__c = 'Auto Reconciled';                
                }
                if(oldClaimsMap != null && claimObj.ElixirSuite__Manual_Reconciliation_Count__c > (oldClaimsMap.get(claimObj.Id)).ElixirSuite__Manual_Reconciliation_Count__c ){
                    claimObj.ElixirSuite__Reconciliation_Status__c = 'Manually Reconciled';                
                }
            }
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
    
    public static void updateAmountStatus(List<ElixirSuite__Claim__c> lstClaims){
        try{
             StopRecursion.claimUpdate = false;
            Set<id> claimRecId = new Set<id>();
            Set<id> primaryclaimRecId = new Set<id>();
            for(ElixirSuite__Claim__c claimObj : lstClaims){
                if(claimObj.id != null){
                    claimRecId.add(claimObj.id);
                    primaryclaimRecId.add(claimObj.ElixirSuite__Claim__c);
                }
            }
            system.debug('claimRecId'+claimRecId);
            List<ElixirSuite__Claim__c> primaryclaimRecLst =new List<ElixirSuite__Claim__c>([SELECT Id, ElixirSuite__Posted__c,
                                                                                        ElixirSuite__Total_Paid__c,ElixirSuite__Total_Charge__c,
                                                                                        ElixirSuite__Claim__c,ElixirSuite__Amount_Status__c
                                                                                        FROM ElixirSuite__Claim__c 
                                                                                        WHERE id IN : primaryclaimRecId AND ElixirSuite__Claim__c = NULL
                                                                                       WITH SECURITY_ENFORCED]);
            
            
             List<ElixirSuite__Claim__c> secondaryclaimRecLst = new List<ElixirSuite__Claim__c>([SELECT Id, ElixirSuite__Posted__c,
                                                                                        ElixirSuite__Total_Paid__c,ElixirSuite__Total_Charge__c,
                                                                                        ElixirSuite__Claim__c,ElixirSuite__Amount_Status__c
                                                                                        FROM ElixirSuite__Claim__c 
                                                                                        WHERE ElixirSuite__Claim__c IN :claimRecId
                                                                                       WITH SECURITY_ENFORCED]);
            
            system.debug('claimRecLst'+primaryclaimRecLst);
			 Map<Id, ElixirSuite__Claim__c> secondaryMap = new Map<Id, ElixirSuite__Claim__c>();
            List<ElixirSuite__Claim__c>lstClaimUpdate = new List<ElixirSuite__Claim__c>();
            
            Map<Id, ElixirSuite__Claim__c> primaryMap = new Map<Id, ElixirSuite__Claim__c>();
            for(ElixirSuite__Claim__c claimrec : primaryclaimRecLst){
                if(claimrec.ElixirSuite__Claim__c == null && claimrec.ElixirSuite__Posted__c == true ){
                        primaryMap.put(claimrec.id,claimrec);
                    
                }
            }
            
            for(ElixirSuite__Claim__c claimrec : secondaryclaimRecLst){
                if(claimrec.ElixirSuite__Claim__c != null && claimrec.ElixirSuite__Posted__c == true ){
                        secondaryMap.put(claimrec.ElixirSuite__Claim__c,claimrec);
                    
                }
            }
            system.debug('primaryMap'+primaryMap);
            system.debug('secondaryMap'+secondaryMap);
             for(ElixirSuite__Claim__c cl : lstClaims){
                if( cl.ElixirSuite__Posted__c == true ){
                    Decimal totalValue = 0;
                    
                    //updation of primary claim when the cl is secondary claim
                    ElixirSuite__Claim__c pri = primaryMap.get(cl.ElixirSuite__Claim__c);
                    if (cl.ElixirSuite__Claim__c != null && pri != null){
                        
                        totalValue = pri.ElixirSuite__Total_Paid__c;       
                        Decimal pritotalPaid = cl.ElixirSuite__Total_Paid__c + totalValue;
                         if(pritotalPaid >= pri.ElixirSuite__Total_Charge__c){
                        	pri.ElixirSuite__Amount_Status__c = 'Paid';
                        }
                         else if(pritotalPaid <= 0){
                            pri.ElixirSuite__Amount_Status__c = 'Not Paid';
                        }
                        else if(pritotalPaid < pri.ElixirSuite__Total_Charge__c){
                            pri.ElixirSuite__Amount_Status__c = 'Partially Paid';
                        }
                       
                        lstClaimUpdate.add(pri);
                       
                    }
                    
                    //updation of secondary claim when the cl is primary claim
                     ElixirSuite__Claim__c sec = secondaryMap.get(cl.id);
                     if (cl.ElixirSuite__Claim__c == null && sec !=null){
                        
                        totalValue = sec.ElixirSuite__Total_Paid__c;       
                        Decimal sectotalPaid = cl.ElixirSuite__Total_Paid__c + totalValue;
                         if(sectotalPaid >= sec.ElixirSuite__Total_Charge__c){
                        	sec.ElixirSuite__Amount_Status__c = 'Paid';
                        }
                         else if(sectotalPaid <= 0){
                            sec.ElixirSuite__Amount_Status__c = 'Not Paid';
                        }
                        else if(sectotalPaid < sec.ElixirSuite__Total_Charge__c){
                            sec.ElixirSuite__Amount_Status__c = 'Partially Paid';
                        }
                       
                        lstClaimUpdate.add(sec);
                       
                    }
                   
					             
                    Decimal totalPaid = cl.ElixirSuite__Total_Paid__c + totalValue;
                    if(totalPaid >= cl.ElixirSuite__Total_Charge__c){
                        cl.ElixirSuite__Amount_Status__c = 'Paid';
                    }
                     else if(totalPaid <= 0){
                       cl.ElixirSuite__Amount_Status__c = 'Not Paid';
                    }
                    else if(totalPaid < cl.ElixirSuite__Total_Charge__c){
                       cl.ElixirSuite__Amount_Status__c = 'Partially Paid';
                    }
                   
                    
                }
            }
            system.debug('lstClaimUpdate'+lstClaimUpdate);
             if(lstClaimUpdate.size()>0 && lstClaimUpdate!= null){
                DMLManager.updateAsUser(lstClaimUpdate);
                
            }
            
            
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        
    }
}