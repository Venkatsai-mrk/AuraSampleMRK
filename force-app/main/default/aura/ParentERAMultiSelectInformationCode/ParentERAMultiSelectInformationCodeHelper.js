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
        
        if(options!=undefined){
            
            options.forEach(function(element) {
                
                if (element.selected) {
                    
                    values.push(element.Name);
                    
                }
                
            });
            
        }
        
        return values;
        
    },
    
    
    
    getSelectedLabels: function(component){
        var options = component.get("v.options_");
        var valueSet = component.get("v.MultipleoptnId");
        var labels = [];
        if(options!=undefined){
            for(var i in options){
                var element = options[i];
                var nameOfCode = element.Name;
                if (!$A.util.isUndefinedOrNull(element.selected) && element.selected) {
                    labels.push(nameOfCode);
                    if($A.util.isUndefinedOrNull(valueSet)){
                        valueSet = [];
                    }
                    var index = valueSet.findIndex(eachName => eachName.Name == nameOfCode);
                    if(index==-1){
                        valueSet.push({'Id':element.Name , 'Name':element.Name});    
                        
                    }else{
                        
                    }
                    
                }
            }
            
        }
        component.set("v.MultipleoptnId",valueSet);
        
        return valueSet;
        
    },
    
    
    
   despatchSelectChangeEvent: function(component,values){
        
        var compEvent = component.getEvent("selectChange");
        
        compEvent.setParams({ "values": values });
        
     //   compEvent.fire();
        
    }
    
})