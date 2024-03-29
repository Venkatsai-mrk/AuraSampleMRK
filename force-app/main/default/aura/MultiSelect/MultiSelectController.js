({
    /**
     * This function will be called on component initialization
     * Attaching a document listner to detect clicks on the page
     * 1. Handle logic when click on dropdown/picklist button itself
     * 2. Handle logic when picklist option is clicked
     * 3. Handle logic when anywhere within picklist is clicked
     * 4. Handle logic if clicked anywhere else
     * */
    onRender : function(component, event, helper) {
        if(!component.get("v.initializationCompleted")){
            //Attaching document listener to detect clicks
            component.getElement().addEventListener("click", function(event){
                //handle click component
                helper.handleClick(component, event, 'component');
            });
            //Document listner to detect click outside multi select component
            document.addEventListener("click", function(event){
                helper.handleClick(component, event, 'document');
            });
            //Marking initializationCompleted property true
            component.set("v.initializationCompleted", true); 
            
            //added by Neha
            helper.initialsetPills(component,event,helper);
            //
            
            //Set picklist name
            helper.setPickListName(component, component.get("v.selectedOptions"));
            
            
        }
        
       // console.log('====msOptions==='+JSON.stringify(component.get("v.msoptions")));
       // console.log('====msLabel==='+JSON.stringify(component.get("v.mslabel")));
        //console.log('====infoAlreadySelected==='+JSON.stringify(component.get("v.infoAlreadySelected")));    
       
        //component.set("v.selectedOptions",alreadySelectedList);
    },
        
    /**
     * This function will be called when input box value change
     * */
    onInputChange : function(component, event, helper) {
        //get input box's value
        var inputText = event.target.value;
        //Filter options
        helper.filterDropDownValues(component, inputText);
    },
    
    /**
     * This function will be called when refresh button is clicked
     * This will clear all selections from picklist and rebuild a fresh picklist
     * */
    onRefreshClick : function(component, event, helper) {
        //clear selected options
        component.set("v.selectedOptions", []);
        //Clear check mark from drop down items
        helper.rebuildPicklist(component);
        //Set picklist name
        helper.setPickListName(component, component.get("v.selectedOptions"));
    },
    
    /**
     * This function will be called when clear button is clicked
     * This will clear any current filters in place
     * */
    onClearClick : function(component, event, helper) {
        //clear filter input box
        component.getElement().querySelector('#ms-filter-input').value = '';
        //reset filter
        helper.resetAllFilters(component);
    },
    
    // To remove the selected item.
    removePill : function( component, event, helper ){
        helper.removePillHelper(component, event);
    },
    
    
})