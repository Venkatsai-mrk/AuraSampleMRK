({
    myAction : function(component, event, helper) {
                helper.getERADetails(component,event);
            },
    openPop : function(component){
        component.set("v.isOpen",true);
    },
    cancelWindow : function(component){
        component.set("v.isOpen",false);
    },
    editRecord : function(component, event){
        var index = event.getSource().get("v.tabindex");
        var AllRowsList= component.get("v.eraLineLst");
        AllRowsList[index].isOpen = true;
        
        component.set("v.eraLineLst",AllRowsList);
    },
    deleteRecord : function(component, event){
        var index = event.getSource().get("v.tabindex");
        var AllRowsList= component.get("v.eraLineLst");
        AllRowsList[index].isOpenforDelete = true;
        
        component.set("v.eraLineLst",AllRowsList);
    },
    mapRecord : function(component, event){
        var index = event.getSource().get("v.tabindex");
        var AllRowsList= component.get("v.eraLineLst");
        AllRowsList[index].isOpenforMap = true;
        
        component.set("v.eraLineLst",AllRowsList);
    },
    calculateInterestLateFilingCharge_onChange : function(component, event){
        var paidAmt =0;
        var netAmt =0;
        var providerAdAmt = 0;
        var interestlateFiling = 0;
        var billedAmt = 0;
        netAmt  =event.getSource().get('v.value');
        paidAmt = component.get("v.TotalPaid");
        billedAmt = component.get("v.BilledAmount");
        
        paidAmt = paidAmt ? paidAmt : 0 ;
        billedAmt = billedAmt ? billedAmt : 0 ;
        
        interestlateFiling = netAmt - paidAmt;
        providerAdAmt = billedAmt - paidAmt - interestlateFiling;
        component.set("v.interestLateFilingCharges",interestlateFiling);
        component.set("v.TotalProviderAdjustmentAmt",providerAdAmt);
    },
    handleComponentEventFollowupNotes : function(component, event){
        var noteList = event.getParam("notesData");
        var delNoteList = event.getParam("delNotesData");
        var recList = event.getParam("recommendationData");
        var delRecList = event.getParam("delRecommendationData");
        //console.log("test 1" , JSON.stringify(noteList));
        //console.log("test 2 " , JSON.stringify(delNoteList));
        //console.log("test 3 " , JSON.stringify(recList));
        //console.log("test 4 " , JSON.stringify(delRecList));
        component.set("v.noteList" , noteList);
        component.set("v.delNoteList" , delNoteList);
        component.set("v.recommendationList" , recList);
        component.set("v.delRecommendationList" , delRecList);
    },
    
    saveERA : function(component, event, helper){
        if(helper.validateRecommendations(component, event) && helper.validateNoteRecords(component)){
        //helper.saveEraData(component, event);
        helper.saveChildEraLines(component, event,helper,false);
        }
        
    },
    handleDeleteEvent : function(component, event,helper){
        
        var index = event.getParam("lineIndex");
        var deletedLine = event.getParam("deletedLineId");
        var rowList =component.get("v.eraLineLst");
        var lineItemList =component.get("v.deletedEralineLst");
        
        
        lineItemList.push(deletedLine);
        if(index!=-1){
            rowList.splice(index,1);
        }
        component.set("v.deletedEralineLst",lineItemList);
        component.set("v.eraLineLst",rowList);
        var mode = 'delete';
        helper.setERAValuesFromParentScreen(component, event,helper,mode);
        
    },
    handleComponentEvent :  function(component, event,helper) {
        console.log('component event handler');
        var index = event.getParam("lineIndex");
        var mode = 'edit';
        var erList =component.get("v.eraLineLst");
        erList[index].IsEdited = true;
        helper.setERAValuesFromParentScreen(component, event,helper,mode);
        
        component.set("v.eraLineLst",erList);
        
    },
    handleClaimLineMapEvent : function(component, event) {
        console.log('component event handler');
        var claimlineId = event.getParam("ClaimLineId");
        var index = event.getParam("MapIndex");
        
        var AllRowsList= component.get("v.eraLineLst");
       // var mtAmount= 0;
        var totalAmount= 0;
       // var paidAmt= component.get("v.TotalPaid");
        var oldClaimLineConnectedEraLine =0;
        for(var i=0;i<AllRowsList.length; i++){
            if(AllRowsList[i].eralineItem.ElixirSuite__Claim_Line_Items__c == claimlineId){
                if(i == index){
                    // mtAmount = parseInt(mtAmount) + parseInt(AllRowsList[i].paidAmount);
                    
                }else{
                    AllRowsList[i].eralineItem.ElixirSuite__Claim_Line_Items__c = '';
                    oldClaimLineConnectedEraLine = parseInt(oldClaimLineConnectedEraLine) + parseInt(AllRowsList[i].paidAmount);
                }
            }else if(AllRowsList[i].eralineItem.ElixirSuite__Claim_Line_Items__c == ''){
                oldClaimLineConnectedEraLine = parseInt(oldClaimLineConnectedEraLine) + parseInt(AllRowsList[i].paidAmount);
            }
            totalAmount = parseInt(totalAmount) + parseInt(AllRowsList[i].paidAmount);
            // AllRowsList[i].claimLineItemId = AllRowsList[i].eralineItem.ElixirSuite__Claim_Line_Items__c;
        }
        
        totalAmount = totalAmount ? totalAmount : 0 ;
        oldClaimLineConnectedEraLine = oldClaimLineConnectedEraLine ? oldClaimLineConnectedEraLine : 0 ;
        
        component.set("v.eraLineLst",AllRowsList);
        component.set("v.MatchedAmt",totalAmount - oldClaimLineConnectedEraLine);
        component.set("v.UnmatchedAmt",oldClaimLineConnectedEraLine);
        console.log('component event handler');
    },
    saveAndPostERA : function(component, event,helper) {
        if(helper.validateRecommendations(component, event) && helper.validateNoteRecords(component)){
         helper.saveChildEraLines(component, event,helper,true);  
        }   
    }
})