({
    // To prepopulate the seleted value pill if value attribute is filled
    doInit : function( component, event, helper ) {
         console.log('ccc')
        $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
        console.log('ddd')
        if( !$A.util.isEmpty(component.get('v.value')) ) {
            console.log('ABc')
            helper.searchRecordsHelper( component, event, helper, component.get('v.value') );
        }
    },
    
    // When a keyword is entered in search box
    searchRecords : function( component, event, helper ) {
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
            helper.searchRecordsHelper( component, event, helper, '' );
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    // When an item is selected
    selectItem : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            var recordsList = component.get('v.recordsList');
            var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            component.set('v.selectedRecord',selectedRecord);
            component.set('v.value',selectedRecord.value);
            component.set("v.checkValue" , false);
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
             var cmpEvent = component.getEvent("FiringSelectedId");
        // Get the value from Component and set in Event
        cmpEvent.setParams( { "SelectedId" : selectedRecord.value} );
        cmpEvent.fire();
        }
    },
    
    showRecords : function( component, event, helper ) {
        console.log('1111');
        console.log('recordsList '+component.get('v.recordsList'));
        console.log('searchString '+component.get('v.searchString'));
        console.log('1111');
        if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            console.log('222');
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    // To remove the selected item.
    removeItem : function( component, event, helper ){
        if(!component.get("v.disabled")){
        component.set('v.selectedRecord','');
        component.set('v.value','');
        component.set('v.searchString','');
             var cmpEvent = component.getEvent("FiringSelectedId");
        // Get the value from Component and set in Event
        cmpEvent.fire();
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
        }
    },
    
    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
        var searchList =  component.get('v.recordsList'); 
        var searchWord = component.get("v.searchString");
        var selectedRecord = component.get("v.selectedRecord");
        if(selectedRecord == ""){
            component.set("v.checkValue" , true);
        }
        else{
             component.set("v.checkValue" , false);
        }
         $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
       
    },
})