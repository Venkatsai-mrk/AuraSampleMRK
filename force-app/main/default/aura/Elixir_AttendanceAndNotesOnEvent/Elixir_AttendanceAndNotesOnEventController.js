({
    doAction : function(component, event, helper) {
        
        var recId = component.get("v.recordId"); //event id
        if(recId!=null){
            helper.getAttachedPatientGroup(component,recId);
        }
        
    },

    handleCancel : function(component, event, helper) {
        var recId = component.get("v.recordId"); //event id
        if(recId!=null){
            helper.getAttachedPatientGroup(component,recId);
        }

        component.set("v.isButtonActive",true);

    },
    handleSignature : function(component, event, helper) {
        component.set("v.Signature",true);

    },
    redirectToAccount: function(component, event, helper) {
        var accountId = event.currentTarget.dataset.accountId;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": accountId
        });
        navEvt.fire();
    },
    handleNoteBlur : function(component, event, helper) {
        var message = component.find("grpNote").get("v.value");
        var groupNote = component.get('v.actualGroupNote');
        console.log('richtext***blur',message);
        console.log('richtext***groupNote',groupNote);
    },

    handleNoteFocus : function(component, event, helper) {
        var message = component.find("grpNote").get("v.value");
        console.log('richtext***focus',message);
    },

    handleGroupNoteChange : function(component, event, helper) {
        console.log('change group note**',component.get('v.groupNote'));
        var actualGrpNote = component.get('v.actualGroupNote');
        var changeGrpNote = component.get('v.groupNote');
        var plainText = changeGrpNote.replace(/<[^>]*>/g, '');
        console.log('groupnote***actual',actualGrpNote);
        console.log('groupnote***change',plainText);
        if(actualGrpNote != plainText){
            component.set("v.isButtonActive",false);
            component.set("v.grpNoteChange",true);
        }
    },

    handleNoteChange : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var plainText = val.replace(/<[^>]*>/g, '');
       // var valName = event.getSource().get("v.name");
         var label = event.getSource().get("v.label");
        console.log('val***label',label);
        console.log('val***value',plainText);
       // console.log('val***name',valName);

        component.set("v.isButtonActive",false);

        var attendedMap = component.get("v.accIdToAttended");

        for (var i = 0; i < attendedMap.length; i++) {
            var row = attendedMap[i];
            if(row.accId == label){
                row.notes = plainText;
                row.notesChange = true;
            }
        }
        console.log('attendedMap**afterhandleNoteChange',attendedMap);
        component.set("v.accIdToAttended",attendedMap);
    },
    
    
    handleAttendChange : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var valName = event.getSource().get("v.name");
        console.log('valName***',valName);

        var count = component.get("v.attended");
        var lessCount = component.get("v.count");
        
        if(val==true)count=count+1;
        else count=count-1;
        component.set("v.attended",count);
        if(val==true)lessCount=lessCount-1;
        else lessCount=lessCount+1;
        component.set("v.count",lessCount);
        
        var attendedMap = component.get("v.accIdToAttended");
        console.log('attendedMap**before',attendedMap);
        
        for (var i = 0; i < attendedMap.length; i++) {
            var row = attendedMap[i];
            if(row.accId == valName){
                row.attended = val;
            }
        }
        console.log('attendedMap**after',attendedMap);
        component.set("v.accIdToAttended",attendedMap);
        component.set("v.isButtonActive",false);
        
    },
    
    handleNewSave : function(component, event, helper) {
        
        var action = component.get("c.updatePatientAttendance");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        let sObjLst = {'keysToSave' : component.get("v.accIdToAttended")};

        var grpNote = component.find("grpNote").get("v.value");

        console.log('groupNote***',grpNote);
        
        action.setParams({
            'patientAttended': JSON.stringify(sObjLst),
            'groupNote' : grpNote ,
            'groupNoteChange' : component.get("v.grpNoteChange")
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('inside***updatePatientAttendance');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'The record has been updated successfully.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.find("Id_spinner").set("v.class" , 'slds-hide'); 
                component.set("v.isButtonActive",true);
            }
            else{
                
            }
        });
        $A.enqueueAction(action);
        
    },
    
    
    
})