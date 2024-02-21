({
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
            else {
                
            }
        }
        else {
            
        }
        component.set("v.decisionTree",decisionTree); 
        
    },
    arrangementForHeirarchyDescisionTree : function(component, event, helper,decisionTree) {
        var csSetting = component.get("v.customSetting");
        var labelApiMap = component.get("v.labelApicombo_CustomSetting");
        var relationLevel_3 = csSetting.ElixirSuite__Relationship_Level_3__c;
        var level_4 = csSetting.ElixirSuite__Third_Level__c;
        if(!relationLevel_3.includes(';')){
            decisionTree.openLinearTree = true;
            
        }
        else {
            decisionTree.openBinaryTree = true;   
        }
        
        
        
    },
    checkSemicolonArrangement : function(component, event, helper,decisionTree) {
        var relationLevel_3 = csSetting.ElixirSuite__Relationship_Level_2__c;
        var level_4 = csSetting.ElixirSuite__Second_Level__c;
        if(relationLevel_3.includes(';')){
            decisionTree.hasLevelHeirarchy = false;
        }
    }
    
})