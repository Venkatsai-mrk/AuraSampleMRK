({
    onRender : function(component, event, helper) {
        try{
            
            var column = component.get("v.column");
            var selectedTemp = column['formMacro'];
            component.set("v.selectedLabelDuplicate",selectedTemp);
            component.set("v.selectedLabelDuplicateToBeUsed",selectedTemp);
            component.set("v.meg" , true);
           
        }
        
        catch(e){
            alert('error' + e);
        }
        
    },
    handleValueChange1 : function(component, event, helper) {
        var column = component.get("v.column");
        column['formMacro'] = component.get("v.selectedLabelDuplicate");
        component.set("v.column",column);
        console.log('group' + JSON.stringify(component.get("v.column")));
    },
})