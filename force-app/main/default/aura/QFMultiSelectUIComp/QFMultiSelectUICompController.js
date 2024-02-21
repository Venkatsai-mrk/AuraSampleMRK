({
    onRender : function(component, event, helper) {
        try{
            
        //   alert('meghna');
       /* var column = component.get("v.column");
        var selectedTemp = column['formMacro'];
        component.set("v.selectedLabelDuplicate",selectedTemp);*/
            
       
        }
        
        catch(e){
          alert('error' + e);
        }
    },
      handleValueChangeNew : function(component, event, helper) {
       var column = component.get("v.column");
        column['formMacro'] = component.get("v.selectedLabelDuplicate1");
        component.set("v.column",column);
        console.log('group' + JSON.stringify(component.get("v.column")));
      }
})