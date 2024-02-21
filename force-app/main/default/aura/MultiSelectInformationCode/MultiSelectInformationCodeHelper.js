({

    setInfoText: function(component, labels) {

        
        
        if (labels.length === 0) {

            component.set("v.infoText", "Select an option...");

        }

        if (labels.length === 1) {

            component.set("v.infoText", labels.length + " option selected");

        }

        else if (labels.length > 1) {

            component.set("v.infoText", labels.length + " options selected");

        }

    },

    

    getSelectedValues: function(component){

        var options = component.get("v.options_");

        console.log('options:='+options);

        var values = [];

        if(options!==undefined){

            options.forEach(function(element) {

                if (element.selected) {

                    values.push(element.value);

                }

            });

        }

   return values;

    },

    

    getSelectedLabels: function(component){

        var options = component.get("v.options_");
        var valueSet =  component.get("v.MultipleoptnId");
        var labels = [];

        if(options!==undefined){

            options.forEach(function(element) {

                if (element.selected) {

                    labels.push(element.label);
                    if(!valueSet.includes(element.label)){
                        valueSet.push(element.label);
                    }else{
                        
                    }
                    
                }

            });  

        }
  
        component.set("v.MultipleoptnId",valueSet);

        return labels;

    },

    

    despatchSelectChangeEvent: function(component,values){

        var compEvent = component.getEvent("selectChange");

        compEvent.setParams({ "values": values });

        compEvent.fire();

    }

})