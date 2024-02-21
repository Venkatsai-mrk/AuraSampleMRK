Public with sharing class ProgramsOfferedTriggerHelper{

    /*public static void updateTCFieldOnInsert(List<Programs_Offered__c> programsOffered){
    
        Map<id,String> tc = new Map<id,String>();
        List<Treatment_center__c> tcListToUpdate = new List<Treatment_center__c>();
        
        String allProgramsOffered = '';
        
        for(Programs_Offered__c po : programsOffered){
            allProgramsOffered = allProgramsOffered + po.id+'\n';
            tc.put(po.Treatment_Center__c,allProgramsOffered);
        }
        
        for(id id : tc.keySet()){
            tcListToUpdate.add(new Treatment_center__c(id=id,Programs_List__c=tc.get(id)));
        }
        
        update tcListToUpdate;
    }
    
    public static void updateTCFieldOnDelete(List<Programs_Offered__c> programsOffered){
    
        Map<id,String> tc = new Map<id,String>();
        List<Treatment_center__c> tcListToUpdate = new List<Treatment_center__c>();
        Set<id> tcIds = new Set<id>();
        
        for(Programs_Offered__c po : programsOffered){
            tcIds.add(po.Treatment_Center__c);
        }
        
        if(tcIds.size()>0)
            tcListToUpdate = [select id,Programs_List__c from Treatment_center__c where id in : tcIds];
                
        for(Treatment_center__c temp : tcListToUpdate){
            for(Programs_Offered__c po : programsOffered){
                if(po.Treatment_center__c==temp.id){
                    temp.Programs_List__c = temp.Programs_List__c.remove(po.id);                   
                }
            }
        }
        update tcListToUpdate;
    }
    
    public static void updateTCFieldOnUnDelete(List<Programs_Offered__c> programsOffered){
    
        Map<id,String> tc = new Map<id,String>();
        List<Treatment_center__c> tcListToUpdate = new List<Treatment_center__c>();
        Set<id> tcIds = new Set<id>();
        
        for(Programs_Offered__c po : programsOffered){
            tcIds.add(po.Treatment_Center__c);
        }
        
        if(tcIds.size()>0)
            tcListToUpdate = [select id,Programs_List__c from Treatment_center__c where id in : tcIds];
               
        for(Treatment_center__c temp : tcListToUpdate){
            for(Programs_Offered__c po : programsOffered){
                if(po.Treatment_center__c==temp.id){
                    temp.Programs_List__c = temp.Programs_List__c+'\n'+po.id+'\n';
                }
            }
        }
        
        update tcListToUpdate;
    }*/

}