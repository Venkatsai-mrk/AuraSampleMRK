({
	myAction : function(component, event, helper) {
		
	},
    showRecords : function( component, event, helper ) {
        component.set("v.modalVisibility", 'slds-show');
        component.set("v.showModal", 'true');
        
        /*commented as per bulk handling requirement.
         if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        
        }*/
       
    },
    handleModalSave: function(component, event, helper){       
        console.log('this is the data', event.getParam('selectedRecords'));
        var selectedRecord = event.getParam('selectedRecords');
        if(!$A.util.isEmpty(selectedRecord)){
            console.log('selectedRecord ', selectedRecord[0]);
            component.set("v.modalVisibility", 'slds-hide');
            component.set("v.showModal", false);
            component.set('v.selectedRecord',selectedRecord[0]);
            component.set('v.value',selectedRecord[0].value);
            component.set("v.checkValue" , false);
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
            helper.searchField( component, event, helper,selectedRecord[0].label,selectedRecord[0].value);
        }
        else{
             console.log('inside else');
            component.set("v.modalVisibility", 'slds-hide');
            component.set("v.showModal", false);
        }
        //component.set("v.recordDetail.description", selectedRecord[0].description);
        //component.set('v.selectedRecord',selectedRecord);
    },
    
    // To remove the selected item.
    removeItem : function( component, event, helper ){
        component.set('v.selectedRecord','');
        component.set("v.selectedRecordId", '');
        component.set("v.selectedRecordName", '');
        component.set('v.value','');
        component.set('v.searchString','');
         component.set('v.recordsList', []);
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
    },
    
    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
        
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
})