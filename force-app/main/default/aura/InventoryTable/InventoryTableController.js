({
    
    cancelEdit : function(component, event, helper) {        
        var index = event.target.dataset.index;
        var wrapListItems = component.get( "v.wrapListItems" );
        wrapListItems[index].editMode = false;
        component.set( "v.wrapListItems", wrapListItems );         
        // helper.refreshView(component);
    },
    
    closeLwc : function(component, event) {
        
       component.set("v.addInv", false);
       component.set("v.editMode",false); 
        
    },
    
    deleteRowId : function(component, event, helper) { 
        
        var wrapListItems = component.get( "v.wrapListItems" );
        
        var index = event.getSource().get("v.name");
        
        wrapListItems.splice(index, 1);
        
        component.set("v.wrapListItems",wrapListItems);
        
        var editedListItems = component.get( "v.wrapListItems" );
        
        if(editedListItems.length == 0){
            
            component.set("v.invMode",false);
        }
        
        var columns = component.get("v.column");
        columns['inventoryLst']= editedListItems;
        component.set("v.column",columns);
        
    },
    
    saveEditedTalent:function(component, event, helper){
        
        var index = event.target.dataset.index;
        var type = component.find('typ').get('v.value');
        var lot = component.find('lt').get('v.value');
        var available = component.find('av').get('v.value');
        var required = component.find('re').get('v.value');
        
        var recIdName = component.get('v.recSelectId');        
        action.setParams({"editName":studentVal, "editAddress":addressId, "editEmail":emailId, "recId":recIdName});
        var wrapListItems = component.get( "v.wrapListItems" ); 
        
        wrapListItems[index].Type = type;
        wrapListItems[index].Lot = lot;
        wrapListItems[index].Avail = available;
        wrapListItems[index].req = required;
        
        component.set("v.wrapListItems",wrapListItems);
        
    },
    
    getValueFromLwc : function(component, event, helper) {
        
        console.log('getValueFromLwc2:',event.getParam('type'));
        var columns = event.getParam('type');
        
        console.log('table columns',JSON.parse(JSON.stringify(columns)));
        
        var ind = event.getParam('model');
        
        console.log('table index',ind);
        
        var wrapListItems = component.get( "v.wrapListItems" ); 
        
        wrapListItems[ind] = columns;
        
        console.log('table wrap',wrapListItems);
        
        component.set("v.wrapListItems",wrapListItems);
        
        var editedListItems = component.get( "v.wrapListItems" );
        
        var columns = component.get("v.column");
        columns['inventoryLst']= editedListItems;
        component.set("v.column",columns);
        component.set("v.editMode",false);
    },
    
    editTalent : function(component, event, helper) {
        var index = event.getSource().get("v.name");
        console.log('index in editTalent',index);
        
        // var recIdName = component.get('v.recSelectId');        
        
        var wrapListItems = component.get( "v.wrapListItems" ); 
        
        console.log('wrapListItems***',JSON.stringify(wrapListItems[index]));
        
        component.set("v.editInvlst",wrapListItems[index]);
        component.set("v.ind",index);
        component.set("v.editMode",true);
        
        
        var lst = component.get( "v.editInvlst" ); 
        var mod = component.get( "v.editMode" ); 
        var i = component.get( "v.ind" );
        
        console.log('editInvlst',lst);
        console.log('editMode',mod);
        console.log('index',i);
        
    }
})