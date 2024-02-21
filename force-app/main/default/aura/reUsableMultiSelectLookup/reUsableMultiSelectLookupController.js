({
    onblur : function(component){
        // on mouse leave clear the listOfSeachRecords & hide the search result component 
        component.set("v.listOfSearchRecords", null );
        component.set("v.SearchKeyWord", '');
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onfocus : function(component,event,helper){
        // show the spinner,show child search result component and call helper function
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        component.set("v.listOfSearchRecords", null ); 
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC 
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    
    keyPressController : function(component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");

        // call the helper 
        // else close the lookup result List part.   
        if(getInputkeyWord.length > 0){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event){
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.lstSelectedRecords"); 
        console.log('selectedPillId',selectedPillId);
         console.log('AllPillsList',JSON.stringify(AllPillsList));
        
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Id == selectedPillId){
                 var compEvent = component.getEvent("selectedRecordRemovalEvent");
                // set the Selected sObject Record to the event attribute.  
                compEvent.setParams({"clearedRecordByEvent" : AllPillsList[i] });  
                // fire the event  
                compEvent.fire();
                AllPillsList.splice(i, 1);
               
                component.set("v.lstSelectedRecords", AllPillsList);
               
               // alert('AllPillsList',JSON.stringify(AllPillsList));
            }  
        }
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );      
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event) {
        component.set("v.SearchKeyWord",null);
        // get the selected object record from the COMPONENT event 	 
        var listSelectedItems =  component.get("v.lstSelectedRecords");
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        listSelectedItems.push(selectedAccountGetFromEvent);
        component.set("v.lstSelectedRecords" , listSelectedItems); 
        console.log('listSelectedItems',JSON.stringify(listSelectedItems));
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forcloses = component.find("searchRes");
        $A.util.addClass(forcloses, 'slds-is-close');
        $A.util.removeClass(forcloses, 'slds-is-open'); 
    },
})