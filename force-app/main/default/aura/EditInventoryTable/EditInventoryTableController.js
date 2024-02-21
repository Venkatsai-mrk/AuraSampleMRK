({
    
    doInit : function(component, event, helper) {
        var wrapListItems = component.get( "v.wrapListItems" );
        console.log('wrapListItems child',JSON.stringify(wrapListItems));
        
        for(var i=0;i<wrapListItems.length;i++){
            
            if(wrapListItems[i].Lot==null){
                wrapListItems[i].Lot = 'N/A';
            }
            
        }
        console.log('wrapListItems*****',component.get( "v.wrapListItems" ));
        component.set("v.wrapListItems",wrapListItems);
        
        //component.set("v.inValue",JSON.stringify(lw));
		
	},
    
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
        component.set("v.changesSave",false);
        
    },
    
    deleteRowId : function(component, event, helper) { 
        
        var wrapListItems = component.get( "v.wrapListItems" );
        
        var index = event.getSource().get("v.name");
        
        var mod = wrapListItems[index].modetype;
        
        if(mod=='insert'){
            wrapListItems.splice(index, 1);
            component.set("v.wrapListItems",wrapListItems);
            component.set("v.changesSave",true);
        }
        else{
            wrapListItems[index].modetype = 'delete';
            
            helper.mg.push(wrapListItems[index]);
            
            component.set("v.wrapListItems",wrapListItems);
            
            var wrapListItems2 = component.get( "v.wrapListItems" );
            
            var deletedLst = wrapListItems2;
            
            wrapListItems.splice(index, 1);
            
            component.set("v.wrapListItems",wrapListItems);
            
            component.set("v.changesSave",true);
        }
        
    },
    
    saveEditedTalent:function(component, event, helper){
        
        var wrapListItems = component.get( "v.wrapListItems" );
        
        for(var i=0;i<wrapListItems.length;i++){
            
            console.log('inside for loop editInventory',wrapListItems[i].modetype);
            if(wrapListItems[i].modetype=='insert'){
                helper.mg.push(wrapListItems[i]);
            }
            
        }
        
        var columns = component.get("v.column");
        columns['inventoryLst']= helper.mg;
        component.set("v.column",columns);
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": "The records has been updated successfully."
        });
        toastEvent.fire();
    },
    
    getValueFromLwc : function(component, event, helper) {
        
        var columns = event.getParam('type');
        
        helper.mg.push(JSON.parse(JSON.stringify(columns)));
        
        var ind = event.getParam('model');
        
        var wrapListItems = component.get( "v.wrapListItems" ); 
        
        wrapListItems[ind] = columns;
        
        component.set("v.wrapListItems",wrapListItems);
        
        var editedListItems = component.get( "v.wrapListItems" );

      
        console.log('editedListItems columns****',JSON.stringify(columns));
        console.log('editedListItems****',JSON.stringify(editedListItems));

        var columns = component.get("v.column");
        columns['inventoryLst']= editedListItems;
        component.set("v.column",columns);
        
        component.set("v.editMode",false);
    },
    
    editTalent : function(component, event, helper) {
        var index = event.getSource().get("v.name");
        
        var wrapListItems = component.get( "v.wrapListItems" ); 
        
        var recId = wrapListItems[index].rid;
        
        var lot = wrapListItems[index].Lot;
        
        var lotrequired = true;
        
        if(lot=='Not Available'){
            
            lotrequired = false;
        }
        
        component.set("v.recordId",recId);
        
        component.set("v.editInvlst",wrapListItems[index]);
        component.set("v.ind",index);
        
        component.set("v.lotReq",lotrequired);

        component.set("v.editMode",true);
        
        component.set("v.changesSave",true);
        
        var lst = component.get( "v.editInvlst" ); 
        var mod = component.get( "v.editMode" ); 
        var i = component.get( "v.ind" );
        
    }
})