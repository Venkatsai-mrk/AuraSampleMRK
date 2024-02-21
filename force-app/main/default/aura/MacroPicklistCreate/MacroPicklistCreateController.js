({
    onRender : function(component, event, helper) {
        try{
       /* var column = component.get("v.column");
        var selectedTemp = column['formMacro'];
        component.set("v.selectedLabelDuplicate",selectedTemp);*/
          
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
            //Set picklist name
            helper.setPickListName(component, component.get("v.selectedOptions"));
        }
        }
        catch(e){
          alert('error' + e);
        }
    },
    handleSearch: function(component, event, helper) {
        
        var searchKeyword = component.get("v.searchKeyword");
        var formName = component.get("v.formName");
        var action = component.get("c.formLabels");
        action.setParams({ keyword: searchKeyword, formName: formName});
        
        action.setCallback(this, function(response) {

            if (response.getState() === "SUCCESS") {

                component.set("v.msoptions", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    abc : function(component, event, helper) {
        var message = event.getParam("message");
        console.log('meghna val' + message);
        component.set('v.dupVal' , message);
    },
        
    /**
     * This function will be called when input box value change
     * @author - Manish Choudhari
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
     * @author - Manish Choudhari
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
     * @author - Manish Choudhari
     * */
    onClearClick : function(component, event, helper) {
        //clear filter input box
        component.getElement().querySelector('#ms-filter-input').value = '';
        //reset filter
        helper.resetAllFilters(component);
    },
    
})