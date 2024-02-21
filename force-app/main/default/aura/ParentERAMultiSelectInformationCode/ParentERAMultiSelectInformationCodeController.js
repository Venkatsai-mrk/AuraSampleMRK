({
    myAction : function(component,event,helper){
        
       var values =  component.get("v.MultipleoptnId");
        if($A.util.isUndefinedOrNull(values)){
            values = [];
        }
            helper.setInfoText(component, values);
        
    },

    clear: function(component, event, helper) {
        if(!component.get("v.disabled")){
        var selectedPillValue = event.getSource().get("v.name");
        var valueSet =  component.get("v.MultipleoptnId");
        
      //  var index = valueSet.indexOf(selectedPillValue);
       var index = valueSet.findIndex(eachName => eachName.Name == selectedPillValue);
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

 

                    if (element.Name === label) {

                        element.selected = selected === "true" ? false : true;

                    }

                });

            } else {

                options.forEach(function(element) {

                    if (element.Name === label) {

                        element.selected = selected === "true" ? false : true;

                    } else {

                        element.selected = false;

                    }

                });

                var mainDiv = component.find('main-div');

            //    $A.util.removeClass(mainDiv, 'slds-is-open');

            }

            component.set("v.options_", options);

 
            var labels = helper.getSelectedLabels(component);
            
            
 

            helper.setInfoText(component, labels);
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