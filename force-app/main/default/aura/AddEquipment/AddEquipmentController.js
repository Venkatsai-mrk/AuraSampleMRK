({
    doInit : function(component, event, helper) {
        var equipmentLst = component.get("v.equipmentData");
        var AllRowsList =[];
        console.log('AllRowsList',AllRowsList);
        if(component.get("v.mode") === 'edit'){
            if(equipmentLst.length >0){
               equipmentLst.forEach(eq => AllRowsList.push({'Equipment' :eq.Equipment, 'noOfAvEquip': eq.noOfAvEquip,
                                                            'Needed' : eq.Needed, 'Id': eq.Id, 'disabled': eq.disabled, 'location': eq.location}));
                
                console.log('AllRowsList',AllRowsList);
                
            }
            component.set("v.equipmentData",AllRowsList);
            console.log('last',component.get("v.equipmentData"));
        }else{
            equipmentLst.push({
                
                'Equipment': '',
                'noOfAvEquip': '',
                'Needed': '',
                'Id' : '',
                'disabled' : true,
                'location' : ''
                
            });
            component.set("v.equipmentData", equipmentLst);
            var temequipList = [];
            temequipList.push({'index' : 0, 'message' : ''});
            component.set("v.tempEquipmentLst", temequipList);
        }
        
    },
    
    addRow: function(component, event, helper) {
        var tempArr = new Array();
    
        var equipmentLst = component.get("v.equipmentData");
        if(equipmentLst.length >0){
            for(var i=0; i<equipmentLst.length; i++){
                
                //tempArr.push(equipmentLst[i].Id);
                //equipmentLst[i].disabled = true;
            }
        }
        
        equipmentLst.push({ 
            'Equipment': '',
            'noOfAvEquip': '',
            'Needed': '',
            'Id' : '',
            'disabled' : true,
            'location' : ''
        });
        var ctarget = event.currentTarget;
        var index = ctarget.tabIndex;
        
        var temequipList = component.get("v.tempEquipmentLst");
        temequipList.push({'index' : equipmentLst.length - 1, 'message' : ''});
        component.set("v.tempEquipmentLst", temequipList);
        
        component.set("v.ErrorDivHide",false);
        component.set("v.equipmentData", equipmentLst);
      //  component.set("v.tempIdLst", tempArr);
    },
    removeRecord : function(component,event,helper){
        var ct = event.currentTarget;
        console.log('ct',ct);
        var ind = ct.tabIndex;
        console.log('ind',ind);
    },
    
    deleteRecord: function(component, event, helper) {
        
        try{
            
            
            var finalindex = event.currentTarget.dataset.name;
            var AllRowsList = component.get("v.equipmentData");
            var tempArr = new Array();
            if(AllRowsList.length!=1){
                AllRowsList.splice(finalindex, 1);
                
                component.set("v.equipmentData", AllRowsList);
                if(AllRowsList.length >0){
                    for(var i=0; i<AllRowsList.length; i++){
                        
                        tempArr.push(AllRowsList[i].Id);
                    }
                }
                component.set("v.tempIdLst", tempArr);
                var temequipList = component.get("v.tempEquipmentLst");
                temequipList.splice(finalindex, 1);
                
                component.set("v.tempEquipmentLst", temequipList);  
                var errorCount=0;
                if(temequipList.length >0 ){
                    var forclose = component.find("conflictingEvent");
                    
                    var mss='';
                    var msstemp='';
                    for(var i=0;i < temequipList.length; i++){
                        if(temequipList[i].message){
                            errorCount=errorCount+1;
                        }
                        mss= mss+temequipList[i].message+ "\n";
                        msstemp = msstemp+ temequipList[i].message;
                    }
                    // mss = mss.substring(0, mss.length - 1);
                    var fixmessage = component.get("v.fixedMessage");
                    component.set("v.equipMessage", mss);
                    
                }
                if(errorCount>=1){
                    component.set("v.equipmentErr",true);
                }else{
                    component.set("v.equipmentErr",false);
                }           
                
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Can not delete last row",
                    "message": " ",
                    "type" : "error"
                });
                toastEvent.fire();
            }
        }
        catch(e){
            alert('error '+e);
        }
    },
    	
    handleComponentEvent : function(component, event, helper) {
        
        component.set("v.equipmentData", component.get("v.equipmentData"));
    },
    handleChange : function(component, event, helper) {
       
        var index = event.getSource().get("v.name")
        var equiList = component.get("v.equipmentData");
        var currentEquip = equiList[index];
        
        var action = component.get("c.checkAvailableEquipmentLineItem");
        var starting;
        var ending;
        if(component.get("v.AllDayEvent") === true){
            starting =component.get("v.SelectedStartDate");
            ending =component.get("v.SelectedEndDate");
        }else{
            starting =component.get("v.SelectedStartTime");
            ending =component.get("v.SelectedEndTime");
        }
        console.log('starting',starting);
        if(starting!= undefined && ending!=undefined){
            action.setParams({
                'startt': starting,
                'endt' : ending,
                'equipId' : equiList[index].Id,
                'neededQn' : equiList[index].Needed
                
            });
            // set a callBack    
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                console.log('sts',state);
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    if (storeResponse!= undefined) {
                        //var temequipList = component.get("v.tempEquipmentLst");
                       // temequipList.splice(index,1);
                       // component.set("v.tempEquipmentLst", temequipList);
                        
                        var msg = 'Equipment Quantity requested is '+equiList[index].Needed+ ' while only '+ storeResponse+' '+ equiList[index].Equipment + ' are available for the requested time frame';
                        var temequipList = component.get("v.tempEquipmentLst");
                        if(temequipList.length > index){
                            temequipList[index].message = msg;
                        }else{
                            temequipList.push({'index' : index, 'message' : msg});
                        }
                       // temequipList.push({'index' : index, 'message' : msg});
                        component.set("v.tempEquipmentLst", temequipList);
                        
                        var forclose = component.find("conflictingEvent");
                        $A.util.removeClass(forclose, 'slds-hide');
                        $A.util.addClass(forclose, 'slds-show');
                        $A.util.addClass(forclose, 'slds-text-color_error');
                        var mss='';
                        var errorCount=0;
                        for(var i=0;i < temequipList.length; i++){
                            
                            mss= mss+temequipList[i].message+ "\n";
                            if(temequipList[i].message){
                                errorCount=errorCount+1;
                            }
                        }
                        
                      //  mss = mss.substring(0, mss.length - 1);
                        var fixmessage = component.get("v.fixedMessage");
                        component.set("v.equipMessage", mss);
                        if(errorCount>=1){
                            component.set("v.equipmentErr",true);
                        }else{
                            component.set("v.equipmentErr",false);
                        }
                        console.log('temequipList', JSON.stringify(temequipList));
                            console.log('errorCount', errorCount);
                        component.set("v.ErrorDivHide",true);
                        console.log('mss',mss + fixmessage);
                        console.log('equipmentErr', component.get("v.equipmentErr"));
                    }else{
                        var temequipList = component.get("v.tempEquipmentLst");
                       // temequipList.splice(index, 1);
                        temequipList[index].message = '';
                        component.set("v.tempEquipmentLst",temequipList);
                        
                        if(temequipList.length >0 ){
                            var forclose = component.find("conflictingEvent");
                            $A.util.removeClass(forclose, 'slds-hide');
                            $A.util.addClass(forclose, 'slds-show');
                            $A.util.addClass(forclose, 'slds-text-color_error');
                            var mss='';
                            var errorCount=0;
                            for(var i=0;i < temequipList.length; i++){
                                mss= mss+temequipList[i].message+ "\n";
                                if(temequipList[i].message){
                                    errorCount=errorCount+1;
                                }
                            }
                          //  mss = mss.substring(0, mss.length - 1);
                            //var fixmessage = component.get("v.fixedMessage");
                            component.set("v.equipMessage", mss);
                            if(errorCount>=1){
                                component.set("v.equipmentErr",true);
                            }else{
                                 component.set("v.equipmentErr",false);
                            }
                            console.log('temequipList', JSON.stringify(temequipList));
                            console.log('errorCount', errorCount);
                            component.set("v.ErrorDivHide",true);
                            console.log('equipmentErr', component.get("v.equipmentErr"));
                        }else{
                            var forclose = component.find("conflictingEvent");
                            $A.util.addClass(forclose, 'slds-hide');
                            
                            var errorCount=0;
                            for(var i=0;i < temequipList.length; i++){
                                if(temequipList[i].message){
                                    errorCount=errorCount+1;
                                }
                            }
                            if(errorCount>=1){
                                component.set("v.equipmentErr",true);
                            }else{
                                console.log('else');
                                component.set("v.equipmentErr",false);
                                 console.log('else');
                            }
                            console.log('temequipList', JSON.stringify(temequipList));
                            console.log('errorCount', errorCount);
                            component.set("v.ErrorDivHide",false);
                            console.log('equipmentErr', component.get("v.equipmentErr"));
                        }
                    }
                }
                
            });
            // enqueue the Action  
            $A.enqueueAction(action);
        }
      
    },
    handleEquipmentEvent: function(component, event, helper) {
       
        var index = event.getParam("currentIndex");
        
        let temequipList = component.get("v.tempEquipmentLst");
        console.log('indx',index);
        let equipLst = component.get("v.equipmentData");
        
        let tempArr = component.get("v.tempIdLst");
        const indexfin = tempArr.indexOf(equipLst[index].Id);
        if (indexfin > -1) {
            tempArr.splice(indexfin, 1); 
        }
        component.set("v.tempIdLst", tempArr);
        
        equipLst[index].noOfAvEquip = '';
        equipLst[index].Id ='';
        equipLst[index].Needed ='';
        equipLst[index].disabled =true;
        
       // var mesg='';
        if(temequipList[index] != undefined){
        temequipList[index].message ='';
        }
       
        component.set("v.tempEquipmentLst", temequipList);
        component.set("v.equipmentData",equipLst);
        var errorCount=0;
        for(var i=0;i < temequipList.length; i++){
            if(temequipList[i].message){
                errorCount=errorCount+1;
            }
        }
        if(errorCount>=1){
            component.set("v.equipmentErr",true);
        }else{
            component.set("v.equipmentErr",false);
        }
        console.log('temequipList', JSON.stringify(temequipList));
                            console.log('errorCount', errorCount);
        console.log('equip '+JSON.stringify(temequipList));
 5   },
})