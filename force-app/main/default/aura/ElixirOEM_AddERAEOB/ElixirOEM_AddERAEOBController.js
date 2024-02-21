({
    myAction : function(component, event, helper) {
        component.set("v.loaded",false); 
        component.set("v.loaded",true); 
        helper.setPaymentMethod(component, event, helper);
        helper.setDefaultJSON(component);
        helper.fetchPicklistValueIfAny(component);
    },
    //Added for Follow up Notes and recommendation
    openRecommendationsNotes : function(component, event, helper) {
        var index = event.getSource().get("v.name"); 
        console.log("index " +index);
        var noteRecIndex = component.get("v.openRecommendationNoteWindow");
        console.log("noteRecIndex "+noteRecIndex);
        var childComp = component.find("newButtonDiv");
        var childERAtableList = component.get("v.childERAtableList");
        if(childERAtableList.length == 1){
            childComp = [childComp];
        }
        if(noteRecIndex != -1){
            if(helper.validateNoteRecords(component, event, noteRecIndex) && helper.validateRecommendations(component, event, noteRecIndex)){
                //var childERAtableList = component.get("v.childERAtableList");
                //var selectedId = childERAtableList[index].Id;
                component.set("v.openRecommendationNoteWindow",-1);
                //component.set("v.selectedERAId",selectedId);
                //component.set("v.claimNo",childERAtableList[index].ClaimNumber)
                if(noteRecIndex == index){
                    $A.util.addClass(childComp[index], "slds-hide");
                    component.set("v.openRecommendationNoteWindow",-1);  
                }else{
                    $A.util.addClass(childComp[noteRecIndex], "slds-hide");
                    $A.util.removeClass(childComp[index], "slds-hide");
                    component.set("v.openRecommendationNoteWindow",index);  
                }
            }    
        }
        else {
            //var childERAtableList = component.get("v.childERAtableList");
            //var selectedId = childERAtableList[index].Id;
            //component.set("v.selectedERAId",selectedId);
            //component.set("v.claimNo",childERAtableList[index].ClaimNumber)
            
            $A.util.removeClass(childComp[index], "slds-hide");
            
            component.set("v.openRecommendationNoteWindow",index);   
            
        }
    },
    handleComponentEventFollowupNotes : function(component, event){
        var noteList = event.getParam("notesData");        
        var recList = event.getParam("recommendationData");
        var index = event.getParam("mapIndex");
        var eraNoteList = component.get("v.noteList");
        eraNoteList[index] = noteList;                  
        var eraRecommendationList = component.get("v.recommendationList");
        eraRecommendationList[index] = recList;                        
        component.set("v.noteList" , eraNoteList);       
        component.set("v.recommendationList" , eraRecommendationList);        
        console.log("test 1" , JSON.stringify(eraNoteList));        
        console.log("test 3 " , JSON.stringify(eraRecommendationList));     
    },
    //end
    openAttachClaims : function(component) {
        if(component.get("v.openAttachClaimWindow")){
            component.set("v.openAttachClaimWindow",false);
        }
        else {
            component.set("v.openAttachClaimWindow",true);   
        }              
    },
    searchClaim : function(component, event, helper) {
        var lstArr = [];
        let childERAtableList =  component.get("v.childERAtableList");
        childERAtableList.forEach(function(element) {
            lstArr.push(element.Id);
        });
        helper.fetchAllClaims(component, event, helper,lstArr);        
    },
    attachClaimToChildERAtable : function(component, event, helper) {
        try{
            let index = event.getSource().get("v.name");        
            console.log('index '+index);
            let array = index.split('$');
            //let sObj = array[0];
            let arrIndex = array[1];
            let allClaimResultTable = component.get("v.allClaimResultTable");
            allClaimResultTable[arrIndex].attachAbility = true;
            component.set("v.allClaimResultTable",allClaimResultTable); 
            helper.fetchClaimPicklist(component, event, helper,allClaimResultTable[arrIndex]); // Also used to fetch child era's line items
        }
        catch(e){
            alert(e);
        }
        
    },
    clearClaimSearchFilter : function(component, event, helper) {
        component.set("v.attachClaimParam",{"patientId" : '' , "claimHash" : '','openResultTable' : false});
        helper.globalFlagToast(component, event, helper,'All filter cleared!', ' ','success');
    },
    openRespectiveLineItem :  function(component, event, helper) {
        let index = event.getSource().get("v.name");      
        let allClaimResultTable = component.get("v.childERAtableList");
        helper.fetchLineItemPerClaim(component, event, helper, allClaimResultTable[index].Id,index);
    },
    removeChildERA :  function(component, event) {
        try{
            let index = event.getSource().get("v.name");  
            
            var eraNoteList = component.get("v.noteList");
            eraNoteList.splice(index, 1);
            var eraRecommendationList = component.get("v.recommendationList");
            eraRecommendationList.splice(index, 1);
            
            component.set("v.noteList" , eraNoteList);
            component.set("v.recommendationList" , eraRecommendationList);
            
            let childERAtableList = component.get("v.childERAtableList");
            let recordId = childERAtableList[index].Id;
            let allClaimResultTable = component.get("v.allClaimResultTable");
            let arrIndex = allClaimResultTable.findIndex(obj_clRes => obj_clRes.Id == recordId);
            if(arrIndex>=0){
                allClaimResultTable[arrIndex].attachAbility = false;
                component.set("v.allClaimResultTable",allClaimResultTable);  
            }            
            let arrIndex_childEraTable = childERAtableList.findIndex(obj => obj.Id == recordId);
            childERAtableList.splice(arrIndex_childEraTable, 1);
            component.set("v.childERAtableList",childERAtableList); 
        }
        catch(e){
            alert(e);
        }
    },
    handleAllowedAmtChanged :  function(component, event, helper) {
        try{
            var index = event.getSource().get("v.name"); 
            var value = event.getSource().get("v.value");
            helper.calculateTotalAdjustment_OnAllowedAmtChanged(component, event, helper,JSON.parse(JSON.stringify(value)),index);
        }
        catch(e){
            alert(e);
        }
    },
    saveERA : function(component, event, helper) {
        if(component.get("v.EOBRecToSave").ElixirSuite__Payer__c){
            var noteRecIndex = component.get("v.openRecommendationNoteWindow");
            console.log("noteRecIndex "+noteRecIndex);
            if(noteRecIndex != -1){
                if(helper.validateNoteRecords(component, event, noteRecIndex) && helper.validateRecommendations(component, event, noteRecIndex)){
                    helper.saveERAData(component, event, helper,false,false);    
                }    
            }
            else{
                helper.saveERAData(component, event, helper,false,false);    
            }    
            
        }
        else{ 
            helper.globalFlagToast(component, event, helper,'Please select Payer!', 'Payer is mandatory!','error');  
        }
      //  const addRecsParent = component.find('addRecsParent');
        //addRecsParent.saveRecommends();        
    },
    saveAndNew : function(component, event, helper) {
        if(component.get("v.EOBRecToSave").ElixirSuite__Payer__c){
            
            var noteRecIndex = component.get("v.openRecommendationNoteWindow");
            console.log("noteRecIndex "+noteRecIndex);
            if(noteRecIndex != -1){
                if(helper.validateNoteRecords(component, event, noteRecIndex) && helper.validateRecommendations(component, event, noteRecIndex)){
                    helper.saveERAData(component, event, helper,true,false);   
                }    
            }
            else{
                helper.saveERAData(component, event, helper,true,false);  
            }    
            
        }
        else{ 
            helper.globalFlagToast(component, event, helper,'Please select Payer!', 'Payer is mandatory!','error');  
        } 
    },
    cancelModal : function(component) {
        component.set("v.isOpen",false);
    },
    saveAndPostPayments : function(component, event, helper) {
        if(component.get("v.EOBRecToSave").ElixirSuite__Payer__c){
            var noteRecIndex = component.get("v.openRecommendationNoteWindow");
            console.log("noteRecIndex "+noteRecIndex);
            if(noteRecIndex != -1){
                if(helper.validateNoteRecords(component, event, noteRecIndex) && helper.validateRecommendations(component, event, noteRecIndex)){
                    if(helper.validatePostedClaims(component)){
                        component.set("v.flagPostedClaimLst",true);
                    }
                    else {
                        helper.saveERAData(component, event, helper,false,true);
                    }
                    
                }    
            }
            else{
                if(helper.validatePostedClaims(component)){
                    component.set("v.flagPostedClaimLst",true);
                }
                else {
                    helper.saveERAData(component, event, helper,false,true);
                }  
            }    
            
        }
        else{ 
            helper.globalFlagToast(component, event, helper,'Please select Payer!', 'Payer is mandatory!','error');  
        }  
    },
    allowSaveWithPostedClaims : function(component, event, helper) {  
        helper.saveERAData(component, event, helper,false,true); 
    },
    closeWindow : function(component) {  
        component.set("v.flagPostedClaimLst",false);
    }
})