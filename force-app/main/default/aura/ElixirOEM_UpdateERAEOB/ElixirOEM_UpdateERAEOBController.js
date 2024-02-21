({
    myAction : function(component, event, helper) {
        component.set("v.loaded",false); 
        component.set("v.loaded",true); 
        helper.setDefaultJSON(component);
        helper.initPayloadGenericCallBack(component, event, helper);
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
        var delNoteList = event.getParam("delNotesData");
        var recList = event.getParam("recommendationData");
        var delRecList = event.getParam("delRecommendationData");
        var index = event.getParam("mapIndex");
        var eraNoteList = component.get("v.noteList");
        eraNoteList[index] = noteList;          
        var eraDelNoteList = component.get("v.delNoteList");
        eraDelNoteList[index] = delNoteList;          
        var eraRecommendationList = component.get("v.recommendationList");
        eraRecommendationList[index] = recList;          
        var eraDelRecommendationList = component.get("v.delRecommendationList");
        eraDelRecommendationList[index] = delRecList;          
        component.set("v.noteList" , eraNoteList);
        component.set("v.delNoteList" , eraDelNoteList);
        component.set("v.recommendationList" , eraRecommendationList);
        component.set("v.delRecommendationList" , eraDelRecommendationList);
        
        console.log("test 1" , JSON.stringify(eraNoteList));
        console.log("test 2 " , JSON.stringify(eraDelNoteList));
        console.log("test 3 " , JSON.stringify(eraRecommendationList));
        console.log("test 4 " , JSON.stringify(eraDelRecommendationList));
        
        
    },
    openAttachClaims : function(component) {
        if(component.get("v.openAttachClaimWindow")){
            component.set("v.openAttachClaimWindow",false);
        }
        else {
            component.set("v.openAttachClaimWindow",true);   
        }              
    },
    searchClaim : function(component, event, helper) {
        var result = component.get("v.childERAtableList");
        var existingClaimIds = [];
        result.forEach(function(element) {
            existingClaimIds.push(element.claimId);
        });
        helper.fetchAllClaims(component, event, helper,existingClaimIds);        
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
            helper.fetchClaimPicklist(component, event, helper,allClaimResultTable[arrIndex]);
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
        try{
            let index = event.getSource().get("v.name");  
            let allClaimResultTable = component.get("v.childERAtableList");
            console.log('===allClaimResultTable==='+JSON.stringify(allClaimResultTable));
            console.log('===lineitemList==='+JSON.stringify(allClaimResultTable[index].lineItemLst));
            if(allClaimResultTable[index].hasOwnProperty('lineItemLst')){
                if($A.util.isEmpty(allClaimResultTable[index].lineItemLst)){
                    helper.globalFlagToast(component, event, helper,'No line items defined for this ERA!', ' ','error');   
                }
                else {
                    allClaimResultTable.forEach( function(element) {
                        element.openLineItemWindow = false;
                    });
                    allClaimResultTable[index].openLineItemWindow = true;   
                }                              
            }
            else {
                helper.globalFlagToast(component, event, helper,'No line items defined for this ERA!', ' ','error');
            }
            component.set("v.childERAtableList",allClaimResultTable);             
            //  helper.fetchLineItemPerClaim(component, event, helper, allClaimResultTable[index].Id,index);
        }
        catch(e){
            alert(e);
        }
    },
    removeChildERA :  function(component, event) {
        try{
            let index = event.getSource().get("v.name");
            var eraNoteList = component.get("v.noteList");
            eraNoteList.splice(index, 1);
            var eraDelNoteList = component.get("v.delNoteList");
            eraDelNoteList.splice(index, 1);
            var eraRecommendationList = component.get("v.recommendationList");
            eraRecommendationList.splice(index, 1);
            var eraDelRecommendationList = component.get("v.delRecommendationList");
            eraDelRecommendationList.splice(index, 1);
            
            component.set("v.noteList" , eraNoteList);
            component.set("v.delNoteList" , eraDelNoteList);
            component.set("v.recommendationList" , eraRecommendationList);
            component.set("v.delRecommendationList" , eraDelRecommendationList);
            
            let childERAtableList = component.get("v.childERAtableList");
            let recordId = childERAtableList[index].Id;
            let recordIdClaimId = childERAtableList[index].claimId;
            if($A.util.isUndefinedOrNull(recordId)){
                if(childERAtableList[index].hasOwnProperty('claimId')){
                    recordId = childERAtableList[index].claimId;
                }
            }
            let allClaimResultTable = component.get("v.allClaimResultTable");
            let arrIndex = allClaimResultTable.findIndex(obj_clRes => obj_clRes.Id == recordId); 
            if(arrIndex>=0){
                allClaimResultTable[arrIndex].attachAbility = false;
                component.set("v.allClaimResultTable",allClaimResultTable);  
            }   
            
            let arrIndex_childEraTable = childERAtableList.findIndex(obj => obj.claimId == recordIdClaimId);
            if(arrIndex_childEraTable>=0){
                childERAtableList.splice(arrIndex_childEraTable, 1);
                component.set("v.childERAtableList",childERAtableList); 
            }
            
            // add record id to delete from apex too
            let childERAToDel = component.get("v.childERAToDel");
            childERAToDel.push(recordId);
            component.set("v.childERAToDel",childERAToDel);
        }
        catch(e){
            alert(e);
        }
    },
    
    /*openRecommendationItem : function(component, event, helper) {
        
    },*/
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
                    helper.saveERAData(component, event, helper,false); 
                }    
            }
            else{
                helper.saveERAData(component, event, helper,false); 
                
            }    
            
        }
        else{ 
            helper.globalFlagToast(component, event, helper,'Please select Payer!', 'Payer is mandatory!','error');  
        }
      //  const addRecsParent = component.find('addRecsParent');
       // addRecsParent.saveRecommends();
        
        
        
        
    },
    saveAndNew : function(component, event, helper) {
        if(component.get("v.EOBRecToSave").ElixirSuite__Payer__c){
            
            var noteRecIndex = component.get("v.openRecommendationNoteWindow");
            console.log("noteRecIndex "+noteRecIndex);
            if(noteRecIndex != -1){
                if(helper.validateNoteRecords(component, event, noteRecIndex) && helper.validateRecommendations(component, event, noteRecIndex)){
                    
                    helper.saveERAData(component, event, helper,true);    
                }    
            }
            else{
                helper.saveERAData(component, event, helper,true);    
            }
            
        }
        else{ 
            helper.globalFlagToast(component, event, helper,'Please select Payer!', 'Payer is mandatory!','error');  
        }
    },
    cancelModal : function(component) {
        component.set("v.isOpen",false);
    },
    openEraHash :  function(component, event) {
        try{
            var index = event.getSource().get("v.name"); 
            let childERAtableList = component.get("v.childERAtableList");
            component.set("v.eraHashId",childERAtableList[index].Id);
            childERAtableList.forEach( function(element) {
                element.openEraHash = false;
            }); 
            childERAtableList[index].openEraHash = true;
            component.set("v.childERAtableList",childERAtableList);
        }
        catch(e){
            alert(e);
        }
    },
    
    excludePostedPayment : function(component, event, helper) {
        try{
          //  var index = event.getSource().get("v.name"); 
            
            if(event.getSource().get("v.checked")){
                helper.removePostedChildERAs(component, event, helper); 
            }
            else {
                helper.restoreChildERAs(component, event, helper); 
            }
        }
        catch(e){
            alert(e);
        }
    },
    enablePostingButton : function() {
        
        /*  let index = event.getSource().get("v.name");
        let cuurentVal = event.getSource().get("v.checked");
        let childERAtableList = component.get("v.childERAtableList");
           for(let rec in childERAtableList){
            if(childERAtableList[rec].isPosted){                
                component.set("v.postPaymentAbility",true); 
                break;
            }
            else {
                component.set("v.postPaymentAbility",false); 
            }
        }
         
        if(childERAtableList[index].isPosted){
            helper.globalFlagToast(component, event, helper,'ERA ALREADY POSTED!', ' ','error'); 
          //  component.set("v.postPaymentAbility",true); 
        }
        else {
          //  component.set("v.postPaymentAbility",false); 
        }*/
        
    },
    postPayment :  function(component, event, helper) {  
        if($A.util.isEmpty(helper.filterERAsForPosting(component, event, helper))){
            helper.globalFlagToast(component, event, helper,'Please Select an ERA to post!', ' ','error');  
        }
        else {
            if(helper.validatePostedClaims(component)){
                component.set("v.flagPostedClaimLst",true);
            }
            else {
                helper.postPaymentCallout(component, event, helper);   
            }
            
        }
        
    },
    allowSaveWithPostedClaims : function(component, event, helper) {  
        helper.postPaymentCallout(component, event, helper);    
    },
    closeWindow : function(component) {  
        component.set("v.flagPostedClaimLst",false);
    },
    selectAll : function(component, event) {
        //alert(event.getSource().get("v.checked"));
        let checkedValue = event.getSource().get("v.checked")
        var childERAtableList = component.get("v.childERAtableList");
        for(let childERA of childERAtableList){
            if(!(childERA.isAllowedForPosting)){
               childERA.isSelectedForPosting = checkedValue;
            }
        }
        
       component.set("v.childERAtableList",childERAtableList);
        
    }
})