({
    getValueFromLwc : function(component, event, helper) {
        
        component.set("v.invValue",event.getParam('itemList2'));
        
        var addInvLst = component.get("v.invRecords");
        
        var inLst = event.getParam('itemList2');

        var addedLst = component.get("v.addLst");

        console.log('addInvLst****',JSON.stringify(addInvLst));

        console.log('addInvLst****addedLst',JSON.stringify(addedLst));
        
        for(var i=0;i<inLst.length;i++){
            
            console.log('inlst***',JSON.stringify(inLst[i].mode));
            if(inLst[i].mode != 'delete'){
            addInvLst.push(inLst[i]);
            addedLst.push(inLst[i]);
            }
        }
        
        component.set("v.invRecords", addInvLst);

        component.set("v.addLst", addedLst);

        var columns = component.get("v.column");
        columns['inventoryLst']=addedLst;
        component.set("v.column",columns);
        
        component.set("v.InvTable", true);
        
        component.set("v.changesSave", true);

        component.set("v.addInv", false);
        
    },
    
    closeLwc : function(component, event) {
        
        component.set("v.addInv", false);
        component.set("v.changesSave", false);
        
    }
})