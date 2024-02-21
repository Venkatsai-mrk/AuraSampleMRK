({
    updateViaCommonAttribute : function(component ,event ,helper,endDate) {
        var leve2_heirarchy = component.get("v.goalsList");
        if(! $A.util.isUndefinedOrNull(leve2_heirarchy)){
            var goals = leve2_heirarchy['listOfGoal'];
            var def = leve2_heirarchy['listOfDef'];
            
            if(! $A.util.isUndefinedOrNull(goals)){
                for(var goalRec in goals){
                    goals[goalRec]['ElixirSuite__Due_Date__c'] = endDate;
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
    },
    
    helperMethod : function(component , valid) {
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        
        if(!($A.util.isUndefinedOrNull(strtProcedureTime)))
        {
            var today = new Date();
            var dte = new Date(strtProcedureTime);
            var endte = new Date(endProcedureTime);
            
            dte.setHours(dte.getHours(),dte.getMinutes(),0,0);
            endte.setHours(endte.getHours(),endte.getMinutes(),0,0);
            today.setHours(today.getHours(),today.getMinutes(),0,0);
            
            
            if((endte.setDate(endte.getDate()) > today))
            {
                procedureEndCmp.setCustomValidity("End Time cannot be greater than the Current Time.");
                procedureEndCmp.reportValidity();
                valid = false;
            }
            else
            {
                procedureEndCmp.setCustomValidity("");
                procedureEndCmp.reportValidity();
            }
          
            if((dte.setDate(dte.getDate()) >today))
            {
                procedureStartCmp.setCustomValidity("Start Time cannot be greater than the Current Time.");
                procedureStartCmp.reportValidity();
                valid = false;
                console.log('ss');
            }
            else 
            {
                procedureStartCmp.setCustomValidity("");
                procedureStartCmp.reportValidity();
                
            }
        }
        else if($A.util.isUndefinedOrNull(endProcedureTime))
        {
            valid = false;
            procedureEndCmp.setCustomValidity("Complete this field");
            procedureEndCmp.reportValidity();
        }
        
        return valid;
    }
    
    
})