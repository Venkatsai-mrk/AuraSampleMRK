({
    myAction : function(component,event,helper){
       
        var geg = component.get("v.options_");
       var values =  component.get("v.MultipleoptnId");
        //alert('geg',component.get("v.MultipleoptnId"))
        // var values = helper.getSelectedValues(component);

        helper.setInfoText(component, values);
        
    },
  /*  onblur : function(component,event,helper){
        // on mouse leave clear the listOfSeachRecords & hide the search result component 
        component.set("v.listOfSearchRecords", null );
        component.set("v.SearchKeyWord", '');
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onfocus : function(component,event,helper){
       var AllRowList = component.get("v.listOfSearchRecords");
        var opts = [
            { value: "CO", label: "CO - Contractual Obligations" },
            { value: "OA", label: "OA - Other Adjustments" },
            { value: "PI", label: "PI - Payer Initiated Reductions" },
            { value: "PR", label: "PR - Patient Responsibility" }
        ];
        component.set("v.listOfSearchRecords", opts);
        var ct = component.get("v.listOfSearchRecords");
        console.log('selectedPillId',ct);
    },
    
    keyPressController : function(component, event, helper) {
        var AllRowList = component.get("v.listOfSearchRecords");
        var opts = [
            { value: "CO", label: "CO - Contractual Obligations" },
            { value: "OA", label: "OA - Other Adjustments" },
            { value: "PI", label: "PI - Payer Initiated Reductions" },
            { value: "PR", label: "PR - Patient Responsibility" }
        ];
        component.set("v.listOfSearchRecords", opts);
        var ct = component.get("v.listOfSearchRecords");
        console.log('selectedPillId',ct);
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        var selectedPillValue = event.getSource().get("v.name");
        var selectedPillLabel = event.getSource().get("v.label");
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        
        var AllPillsList = component.get("v.lstSelectedRecords");
        var AllRowList = component.get("v.listOfSearchRecords");
        
        console.log('selectedPillId',selectedPillId);
        console.log('AllPillsList',JSON.stringify(AllPillsList));
        AllRowList.push({
            label : selectedPillLabel,
            value : selectedPillValue
        });
        
        AllPillsList.splice(index,1); 
        
         component.set("v.lstSelectedRecords", AllPillsList );
        component.set("v.listOfSearchRecords", AllRowList );      
    },
    
     selectRecord : function(component, event, helper){      
        
          var selectedPillValue = event.getSource().get("v.name");
        var selectedPillLabel = event.getSource().get("v.label");
         
         var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        
        var AllPillsList = component.get("v.lstSelectedRecords");
        var AllRowList = component.get("v.listOfSearchRecords");
        
        console.log('selectedPillId',selectedPillId);
        console.log('AllPillsList',JSON.stringify(AllPillsList));
        AllPillsList.push({
            label : selectedPillLabel,
            value : selectedPillValue
        });
        
        AllRowList.splice(index,1); 
        
         component.set("v.lstSelectedRecords", AllPillsList );
        component.set("v.listOfSearchRecords", AllRowList );
         
    },*/
    
    clear: function(component, event, helper) {
        if(!component.get("v.isDisabled")){
        var selectedPillValue = event.getSource().get("v.name");
        var pill = event.getSource().get("v.value");
        var valueSet =  component.get("v.MultipleoptnId");
        
        var index = valueSet.indexOf(selectedPillValue);
        if (index !== -1) {
            valueSet.splice(index, 1);
        }

        component.set("v.MultipleoptnId",valueSet);
        helper.setInfoText(component, valueSet);  
        }
    },
    //google copied
    handleClick: function(component, event, helper) {

        var mainDiv = component.find('main-div');

        $A.util.addClass(mainDiv, 'slds-is-open');

    },

 

    handleSelection: function(component, event, helper) {

        var item = event.currentTarget;

        
        if (item && item.dataset) {

            var label = item.dataset.value;

            var selected = item.dataset.selected;

            var options = component.get("v.options_");

 

 

            //contro(ctrl) key ADDS to the list (unless clicking on a previously selected item)

            //also, ctrl key does not close the dropdown (uses mouse out to do that)

            if (event.ctrlKey) {

                options.forEach(function(element) {

 

                    if (element.label === label) {

                        element.selected = selected === "true" ? false : true;

                    }

                });

            } else {

                options.forEach(function(element) {

                    if (element.label === label) {

                        element.selected = selected === "true" ? false : true;

                    } else {

                        element.selected = false;

                    }

                });

                var mainDiv = component.find('main-div');

            //    $A.util.removeClass(mainDiv, 'slds-is-open');

            }

            component.set("v.options_", options);

 

           // var values = helper.getSelectedValues(component);

            var labels = helper.getSelectedLabels(component);
            var valueSet =  component.get("v.MultipleoptnId");
 

            helper.setInfoText(component, valueSet);
           // helper.setInfoText(component, labels);

           // helper.despatchSelectChangeEvent(component, values);

           

        }

    },

 

    handleMouseLeave: function(component, event, helper) {

        component.set("v.dropdownOver", false);

        var mainDiv = component.find('main-div');

        $A.util.removeClass(mainDiv, 'slds-is-open');

    },

 

    handleMouseEnter: function(component, event, helper) {

        component.set("v.dropdownOver", true);

    },

 

    handleMouseOutButton: function(component, event, helper) {

        window.setTimeout(

            $A.getCallback(function() {

                if (component.isValid()) {

                    //if dropdown over, user has hovered over the dropdown, so don't close.

                    if (component.get("v.dropdownOver")) {

                        return;

                    }

                    var mainDiv = component.find('main-div');

                    $A.util.removeClass(mainDiv, 'slds-is-open');

                }

            }), 200

        );

    }

})