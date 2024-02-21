({
	 updateViaCommonAttribute : function(component ,event ,helper,endDate) {
         var nameSpace = 'ElixirSuite__';
        var leve2_heirarchy = component.get("v.goalsList");
        if(! $A.util.isUndefinedOrNull(leve2_heirarchy)){
            var goals = leve2_heirarchy['listOfGoal'];
            var def = leve2_heirarchy['listOfDef'];
            
            if(! $A.util.isUndefinedOrNull(goals)){
                for(var goalRec in goals){
                    goals[goalRec]['ElixirSuite__Due_Date__c'] = endDate;
                     if($A.util.isUndefinedOrNull(goals[goalRec][nameSpace+'Dataset2__c'])){
                        //No Action Taken
                    }else{
                        goals[goalRec]['Action'] = 'UPDATE';
                    }
                    var tasks = goals[goalRec]['listOfTask'];
                    var interventions_directParent = goals[goalRec]['listOfIntervention'];
                    if(! $A.util.isUndefinedOrNull(tasks)){
                        for(var taskRec in tasks){
                            tasks[taskRec]['ElixirSuite__Due_Date__c'] = endDate;
                            
                            var interventions = tasks[taskRec]['listOfIntervention'];
                            if(! $A.util.isUndefinedOrNull(interventions)){
                                for(var IntRec in interventions){
                                    interventions[IntRec]['ElixirSuite__Due_Date__c'] = endDate;
                                }
                            }
                        }
                    }
                    if(! $A.util.isUndefinedOrNull(interventions_directParent)){
                        for(let taskRec in interventions_directParent){
                            interventions_directParent[taskRec]['ElixirSuite__Due_Date__c'] = endDate;
                            
                            
                        }
                    }
                }
            }
            if(! $A.util.isUndefinedOrNull(def)){
                for(let goalRec in def){
                    def[goalRec]['ElixirSuite__Due_Date__c'] = endDate;
                     if($A.util.isUndefinedOrNull(def[goalRec][nameSpace+'Dataset2__c'])){
                        //No Action Taken
                    }else{
                        def[goalRec]['Action'] = 'UPDATE';
                    }
                    
                    let tasks = def[goalRec]['listOfTask'];
                    let interventions_directParent = goals[goalRec]['listOfIntervention'];
                    if(! $A.util.isUndefinedOrNull(tasks)){
                        for(let taskRec in tasks){
                            tasks[taskRec]['ElixirSuite__Due_Date__c'] = endDate;
                            
                            let interventions = tasks[taskRec]['listOfIntervention'];
                            if(! $A.util.isUndefinedOrNull(interventions)){
                                for(let IntRec in interventions){
                                    interventions[IntRec]['ElixirSuite__Due_Date__c'] = endDate;
                                }
                            }
                        }
                    }
                    if(! $A.util.isUndefinedOrNull(interventions_directParent)){
                        for(let taskRec in interventions_directParent){
                            interventions_directParent[taskRec]['ElixirSuite__Due_Date__c'] = endDate;
                            
                            
                        }
                    }
                }
            }
            component.set("v.goalsList" , leve2_heirarchy);
        }
    }
})