({
    goalSectionReplica  : function(component) {
        var goalIdx = component.get("v.goalIdx");
        console.log('goalIdx :'+goalIdx);
        var goalId = component.get("v.goalId");
        var acc = component.find("goalSection");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        
        if(! $A.util.isUndefinedOrNull(goalId)){  
            var goalFirstCallBack = component.get("v.goalFirstCallBack");
            console.log('goalFirstCallBack :'+goalFirstCallBack);
            var action = component.get("c.getTasks");                
            action.setParams({ 
                goalId : goalId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    var listOfTasks = response.getReturnValue();     
                    console.log('listOfTasks '+JSON.stringify(listOfTasks));
                    var goal = component.get("v.goal");
                    goal['listOfTask'] = listOfTasks.listOfObj;
                    goal['listOfIntervention'] = listOfTasks.listOfInterv;
                    
                    for(let goalRec in goal['listOfTask']){
                        goal['listOfTask'][goalRec]['endDate'] = goal['endDate'];
                    } 
                    for(let goalRec in goal['listOfIntervention']){
                        goal['listOfIntervention'][goalRec]['endDate'] = goal['endDate'];
                    }
                    component.set('v.tasksList',goal);
                    component.set('v.goal',goal);
                    component.set("v.goalFirstCallBack",false);
                    component.set("v.readyObservation",true);
                    
                    
                }else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
            });
            $A.enqueueAction(action);
            
        }
    },
    heirarchyDescisionTree : function(component, event, helper) {
        
        var decisionTree = {'openLinearTree' : false,
                            'openBinaryTree': false,
                            'hasLevelHeirarchy' : false};
        
        var csSetting = component.get("v.customSetting");
        if(csSetting.hasOwnProperty('ElixirSuite__Relationship_Level_2__c')){
            if(csSetting.ElixirSuite__Relationship_Level_2__c==''){
                decisionTree.hasLevelHeirarchy = true;
                
            }
            
        }
        else {
            decisionTree.hasLevelHeirarchy = true;
            //   helper.checkSemicolonArrangement(component, event, helper,decisionTree);
        }
        
        if(csSetting.hasOwnProperty('ElixirSuite__Relationship_Level_3__c')){
            if(csSetting.ElixirSuite__Relationship_Level_3__c!=''){
                
                helper.arrangementForHeirarchyDescisionTree(component, event, helper,decisionTree);
            }
           
        }
       
        component.set("v.decisionTree",decisionTree); 
        
    },
    arrangementForHeirarchyDescisionTree : function(component, event, helper,decisionTree) {
        var csSetting = component.get("v.customSetting");
        var labelApiMap = component.get("v.labelApicombo_CustomSetting");
        console.log('labelApiMap'+labelApiMap);
        var relationLevel_3 = csSetting.ElixirSuite__Relationship_Level_3__c;
       // var level_4 = csSetting.ElixirSuite__Third_Level__c;
        if(!relationLevel_3.includes(';')){
            decisionTree.openLinearTree = true;
            
        }
        else {
            decisionTree.openBinaryTree = true;   
        }
        
        
        
    },
    checkSemicolonArrangement : function(component, event, helper,decisionTree) {
        var csSetting = component.get("v.customSetting");
        var relationLevel_3 = csSetting.ElixirSuite__Relationship_Level_2__c;
        //var level_4 = csSetting.ElixirSuite__Second_Level__c;
        if(relationLevel_3.includes(';')){
            decisionTree.hasLevelHeirarchy = false;
        }
    }
})