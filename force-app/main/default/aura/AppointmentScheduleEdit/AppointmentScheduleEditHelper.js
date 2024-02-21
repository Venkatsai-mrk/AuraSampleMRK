({
    showToast: function(component,event, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
	getMuliSelectedData : function(component,event,eventDataRecordId) {
		 var action = component.get("c.getMultiSelectedObjectRecords");
        console.log('eventDataRecordId',eventDataRecordId);
        action.setParams({
                "evenDataId": eventDataRecordId
                
            });
        
        action.setCallback(this, function(response){
                var state = response.getState();
                if(state ==='SUCCESS'){
                    var res = response.getReturnValue();
                    console.log('res 2',res);
                    console.log('res 2',JSON.stringify(res));
                    if(res.selectedLocation != undefined){
                        component.set("v.selectedRecordOfLocation",res.selectedLocation);
                        let childComponent = component.find("childComponent");
                        
                        var forclose = childComponent.find("lookup-pill");
                        $A.util.addClass(forclose, 'slds-show');
                        $A.util.removeClass(forclose, 'slds-hide');
                        
                        var forclose = childComponent.find("searchRes");
                        $A.util.addClass(forclose, 'slds-is-close');
                        $A.util.removeClass(forclose, 'slds-is-open');
                        
                        var lookUpTarget = childComponent.find("lookupField");
                        $A.util.addClass(lookUpTarget, 'slds-hide');
                        $A.util.removeClass(lookUpTarget, 'slds-show');  
                    }
                                      
                    
                    
                    console.log('loc',JSON.stringify(component.get("v.selectedRecordOfLocation")));
                    
                    component.set("v.selectedAccountRecords",res.selectedpatientAccounts);
                    component.set("v.selectedGroupRecords",res.selectedGroups);
                    component.set("v.selectedBussinessAccountsRecords",res.selectedbussinessAccounts);
                    component.set("v.selectedCoFacilitatorsRecords",res.selectedCoFacilitators);
                    //component.set("v.ByPassEvent",res.selectedbyPass);
                    console.log('selectedbyPass',res.selectedbyPass);
                    component.set("v.equipMessage",'');
                    console.log('equipMessage',component.get("v.equipmentErr"));
                    
                    if(res.selectedbyPass === true){
                       component.set("v.ByPassEvent",true); 
                        console.log('selectedbyPass',res.selectedbyPass);
                    }else{
                        component.set("v.ByPassEvent",false);
                        console.log('selectedbyPass',res.selectedbyPass);
                    }
                    console.log('ll',component.get("v.ByPassEvent"));
                    
                    //3component.set("v.ByPassEvent",event.getSource().get('v.checked'));
                    console.log('equipList',JSON.stringify(res.selectedEquipList));
                    if(res.selectedRoom != undefined){
                        component.set("v.selectedRecordOfRoom",res.selectedRoom);
                        let childComponentRoom = component.find("childComponentRoom");
                        
                        var forclose = childComponentRoom.find("lookup-pill");
                        $A.util.addClass(forclose, 'slds-show');
                        $A.util.removeClass(forclose, 'slds-hide');
                        
                        var forclose = childComponentRoom.find("searchRes");
                        $A.util.addClass(forclose, 'slds-is-close');
                        $A.util.removeClass(forclose, 'slds-is-open');
                        
                        var lookUpTarget = childComponentRoom.find("lookupField");
                        $A.util.addClass(lookUpTarget, 'slds-hide');
                        $A.util.removeClass(lookUpTarget, 'slds-show'); 
                    }
                    
                    
                    
                    
                    var AllRowsList =  component.get("v.equipList");
                    var equipmentLst = res.selectedEquipList;
                    //var AllRowsList=[];
                   
                    if(equipmentLst.length >0){
                        equipmentLst.forEach(eq => AllRowsList.push({'Equipment' :eq.Equipment, 'noOfAvEquip': eq.noOfAvEquip,
                                                                     'Needed' : eq.Needed, 'Id': eq.Id, 'disabled': eq.disabled}));
                        
                        console.log('AllRowsList1',JSON.stringify(AllRowsList));
                        
                    }else{
                        
                        AllRowsList.push({
                            
                            'Equipment': '',
                            'noOfAvEquip': '',
                            'Needed': '',
                            'Id' : '',
                            'disabled' : true
                            
                        });
                    }
                    
                     component.set("v.equipList",AllRowsList);
                    component.set("v.equipmentErr",false);
                   /* let childComponenteq = component.find("childComponentEq");
                    
                    var forclose = childComponenteq.find("lookup-pill");
                    $A.util.addClass(forclose, 'slds-show');
                    $A.util.removeClass(forclose, 'slds-hide');
                    
                    var forclose = childComponenteq.find("searchRes");
                    $A.util.addClass(forclose, 'slds-is-close');
                    $A.util.removeClass(forclose, 'slds-is-open');
                    
                    var lookUpTarget = childComponenteq.find("lookupField");
                    $A.util.addClass(lookUpTarget, 'slds-hide');
                    $A.util.removeClass(lookUpTarget, 'slds-show'); */
                    
                }
        });
        $A.enqueueAction(action);
	}
})