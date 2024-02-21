({
    init: function(component) {
        var today = new Date();
        var nameSpace = 'ElixirSuite__';
        // component.get('v.todayString'
        component.set('v.todayString', today.toISOString());
        
        // Older approval code- start
        var action1 = component.get("c.getCode");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action1.setParams({  
            accId : component.get("v.recordId")
        });
        
        action1.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var code = response.getReturnValue(); 
                
                
                
                component.set("v.passcode", code); 
            }
            else{
                console.log('failure');
            }                           
        });
        $A.enqueueAction(action1);
        // Older approval code- end
       
          var options = {
                    year: 'numeric',
                    month: 'numeric',
                    day: 'numeric',
                    hour: 'numeric',
                    minute: 'numeric',
                    second: 'numeric',
                    timeZone: 'America/New_York', // Set the desired time zone for the USA, e.g., Eastern Time
                    hour12: true // Use 12-hour clock format
                };

        var action = component.get("c.getOrder");
        console.log('OrderId'+component.get("v.OrderID"));
        
        action.setParams({  
            OrderId : component.get("v.OrderID")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var OrderData = response.getReturnValue().listOfRecords;
                  console.log('hey '+JSON.stringify(OrderData));
                 for(var key in OrderData){
                    var originalDateTime = OrderData[key]['CreatedDate'];
                    var dateObj = new Date(originalDateTime);
                    var originalDateTime1 = OrderData[key]['LastModifiedDate']
                    var dateObj1 = new Date(originalDateTime);
          
                    component.set("v.createdDateValue",dateObj.toLocaleString('en-US', options));
                     component.set("v.modifiedDateValue",dateObj1.toLocaleString('en-US', options));
                     component.set("v.ownerNameValue",OrderData[key]['Owner']['Name']);
                }
                

                // Older approval code- start
                var OrderParent = response.getReturnValue().listOforder;
                component.set("v.attachId" ,OrderParent.ElixirSuite__Signature_Link__c );
                component.set("v.dateTodayForForm" ,OrderParent.ElixirSuite__Signed_Date__c );
                component.set("v.signee1" ,OrderParent.ElixirSuite__Account__r.Name );
                component.set("v.signComment" ,OrderParent.ElixirSuite__Signature_Comments__c );
                if(OrderParent.ElixirSuite__Signature_Link__c  !=null){
                    component.set("v.showSign",false)
                }
                // Older approval code- end

                console.log('hey '+JSON.stringify(OrderData));
                
                for(var name in OrderData){
                    OrderData[name].isAlreadyExisting= true;
                    console.log('tt',OrderData[name][nameSpace+'Type__c']);
                    if(OrderData[name][nameSpace+'Type__c'] == 'PRN'){
                        component.set("v.PRNvalue",true);
                    }
                    else if(OrderData[name][nameSpace+'Type__c'] == 'Taper'){
                        component.set("v.Tapersvalue",true);
                        
                    }
                    
                        else if(OrderData[name][nameSpace+'Type__c'] == 'Action Order'){
                            component.set("v.Actionvalue",true);
                        }
                }
                component.set("v.OrderList", OrderData); 
                console.log('order list way  '+JSON.stringify(component.get("v.OrderList")));
            }
            else{
                Console.log('failure');
            }                           
        });
        $A.enqueueAction(action);
        
        
        
    }, 
    handleSectionToggle: function(component, event) {
        var SlectedItems = event.getParam('openSections');
        console.log('SlectedItems '+SlectedItems);
    },
    
    openModel: function(component) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component) {
        // Set isModalOpen attribute to false  
        var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                    appEvent.setParams({
                        "screenType" : "Medication",
                        "action" : "Edit",
                        "button" : "Cancel"
                         });
                    appEvent.fire();
        component.set("v.isModalOpen", false);
    },
    parentComponentEvent : function(component , event){
        console.log('att id' , event.getParam("attachementId"));
        var attId = event.getParam("attachementId"); 
        var commentSign = event.getParam("signComment");
        var dateToday = event.getParam("dateToday");
        component.set("v.signComment" ,  commentSign);
        component.set("v.attachId" , '/servlet/servlet.FileDownload?file='+attId);
        component.set("v.dateTodayForForm" ,  dateToday );
        console.log('the val is' , component.get("v.signComment"));
        console.log('the val is' , component.get("v.dateTodayForForm"));
        component.set("v.showSign",false);
    },
    showVerifyOtp :  function(component){
        
        console.log("dfghjk" ,component.get("v.passcode"));
        if( $A.util.isUndefinedOrNull(component.get("v.passcode")) ){
            alert('You do not have the appropriate access, please contact your administrator');
        }
        else{
            
            //component.set("v.showSign",false);
            component.set("v.verifyOtp",true);
        }
        
    },
    AddPrescription: function(component) {
        component.set("v.EditPrescriptionOrders", true);
        component.set("v.MaintainOrderList",component.get("v.SelectedRecords"));
        component.set("v.SelectedRecords",{});
        
        //component.set("v.MaintainOrderList",component.get("v.SelectedRecords"));
    },
    procedureValidity  : function(component ,event ,helper){
        var valid = true;
        valid = helper.validityProcedure(component , valid);
    },
    kk: function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        var action = component.get("c.getOrder");
        action.setParams({  
            OrderId : component.get("v.OrderID")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {              
                var OrderData = response.getReturnValue().listOfRecords;                
                for(var j in OrderData){
                    if(OrderData[j]['Id'] == selectedMenuItemValue){
                        //  alert('hie');
                        helper.DelSelectedRec(component, event, helper);
                    }
                }
                
                //debugger;
                //alert('kishan--'+JSON.stringify(component.get("v.MaintainOrderList")));
                OrderData =  component.get("v.OrderList");
                helper.arrangeAuraIfFForEntities(component, event, helper,OrderData);
                var SelRec= component.get("v.SelectedRecords");
                var screenData =component.get("v.MaintainOrderList");
                var Sdata = screenData.filter(function( element ) {
                    return element !== undefined;
                });
                if(Sdata != null){
                    for(var l in Sdata){
                        SelRec.push(Sdata[l]);
                    } 
                } 
                var orderDatalist=[]; 
                
                for(var i in SelRec){
                    if(SelRec[i]['Id'] == selectedMenuItemValue){
                        delete SelRec[i];
                        
                    }
                    orderDatalist.push(SelRec[i]);
                }
                var filtered = orderDatalist.filter(function (el) {
                    return el != null;
                });
                //  alert('orderDatalist'+JSON.stringify(orderDatalist));
                for(var k in filtered){
                    if(filtered[k]['Id'] != null){
                        OrderData.push(filtered[k]);
                    }
                }
                
                
                
                component.set("v.OrderList", OrderData); 
                /*  for(var name in OrderData){
                    
                    if(OrderData[name][nameSpace+'Type__c'] == 'PRN'){
                        component.set("v.PRNvalue",true);
                    }
                    else if(OrderData[name][nameSpace+'Type__c'] == 'Taper'){
                        component.set("v.Tapersvalue",true);
                    }
                    
                        else if(OrderData[name][nameSpace+'Type__c'] == 'Action Order'){
                            component.set("v.Actionvalue",true);
                        }
                }*/
                // component.set("v.OrderList", OrderData);  
                
                
            }
            else{
                Console.log('failure');
            }                           
        });
        $A.enqueueAction(action);
        
    },
    itemsChange: function(component, event, helper) {
        // alert(component.get("v.SelectedRecords"));
        helper.AddSelectedRec(component, event, helper);
    },
    SetJSON: function(component, event) {
        // 
        var PresRec = event.getParam("PresRecord");
        // alert('hey'+PresRec);
        component.set("v.jsonList",PresRec);
    },
     SetJSON1: function(component, event) {
       console.log('enter in selected record Dosage***');
        var message = event.getParam("lookUpData");
        var actStatus = event.getParam("actionStatus");
        var objName =  event.getParam("objectName");
        console.log('messageAppointment****',message);
        console.log('messageAppointment****objName',objName);
        var PresRec = event.getParam("dosageJsonList");
         
         console.log('PresRec',PresRec);
         component.set("v.jsonList",PresRec);
    },
    Save: function(component, event, helper) { 
        var nspc = 'ElixirSuite__';
        var valid = true;
        valid = helper.validityProcedure(component , valid);
        var oldJsonList = component.get("v.jsonList");
        console.log('oldJsonList '+ JSON.stringify(oldJsonList));
        var medicationName = oldJsonList[0].medicationName;
        var dosageForm = oldJsonList[0].dosageForm;
        var Route = oldJsonList[0].Route;
        var types = oldJsonList[0].types;
       
        console.log('medicationName '+ medicationName);
        //var types = oldJsonList.types;
        console.log('types '+ types);
        //var dosageForm = oldJsonList.dosageForm;
        console.log('dosageForm '+ dosageForm);
       // var Route = oldJsonList.Route;
        console.log('Route '+ Route);
        console.log('valid '+ valid);
        if(types =='PRN'|| types =='Taper'){
            if(medicationName ==undefined || medicationName ==''){
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Failed!",
                "message": "Please fill the medication field."
            });
            toastEvent.fire();
             valid=false;
            }
            if(dosageForm ==undefined || dosageForm ==''){
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Failed!",
                "message": "Please fill the Dosage field."
            });
            toastEvent.fire();
             valid=false;
            }
            if(Route ==undefined || Route ==''){
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Failed!",
                "message": "Please fill the Route field."
            });
            toastEvent.fire();
            valid=false;
            }
        }
        console.log('valid '+ valid);
        if(types =='Action Order'){
            if(medicationName ==undefined || medicationName ==''){
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Failed!",
                "message": "Please fill the medication field."
            });
            toastEvent.fire();
            valid=false;
            }
           
        }
        console.log('valid '+ valid);
        var jsonListForPRN = [];
        var jsonListForTaper = [];
        var jsonListForAOrder = [];
        var toInsertjsonListForPRN = [];
        var toInsertjsonListForTaper = [];
        var toInsertjsonListForAOrder = [];
        var toInsertnewData = [];
        var toInsertData =component.get("v.SelectedRecords");
        console.log('oldJsonList --- '+ JSON.stringify(oldJsonList));
        for(var rec in oldJsonList){
            for(var record in toInsertData){
                if(oldJsonList[rec]['medicationName'] == toInsertData[record][nspc+'Medication__r.Name']){
                    toInsertnewData.push(oldJsonList[rec]);
                }
            }
        }
        console.log('toInsertnewData --- '+ JSON.stringify(toInsertnewData));
        component.set("v.toInsertjsonList",toInsertnewData)
        var toInsertDataRecord =component.get("v.toInsertjsonList");
        for(var rec in oldJsonList){       
            if(oldJsonList[rec]['types'] == 'PRN'){               
                
                
                jsonListForPRN.push(oldJsonList[rec]);
            }
            else if(oldJsonList[rec]['types'] == 'Taper'){       
                
                jsonListForTaper.push(oldJsonList[rec]);
            }
                else {
                    jsonListForAOrder.push(oldJsonList[rec]);
                }  
        }
        for(var record in toInsertDataRecord){       
            if(toInsertDataRecord[record]['types'] == 'PRN'){               
                
                
                toInsertjsonListForPRN.push(toInsertDataRecord[record]);
            }
            else if(toInsertDataRecord[record]['types'] == 'Taper'){       
                
                toInsertjsonListForTaper.push(toInsertDataRecord[record]);
            }
                else {
                    toInsertjsonListForAOrder.push(toInsertDataRecord[record]);
                }  
        }
        var toinsertjsonString={
            "toInsertjsonListForTaper" :	JSON.parse(JSON.stringify(toInsertjsonListForTaper)),
            "toInsertjsonListForPRN"   :		JSON.parse(JSON.stringify(toInsertjsonListForPRN)),
            "toInsertjsonListForAOrder" :	JSON.parse(JSON.stringify(toInsertjsonListForAOrder))
        };   
        
        var jsonString={
            "jsonListForTaper" :	JSON.parse(JSON.stringify(jsonListForTaper)),
            "jsonListForPRN"   :		JSON.parse(JSON.stringify(jsonListForPRN)),
            "jsonListForAOrder" :	JSON.parse(JSON.stringify(jsonListForAOrder))
        };
        console.log('String bnn gyi'+JSON.stringify(jsonString)); 
        console.log('String bnn gyi2'+JSON.stringify(toinsertjsonString)); 
        console.log('approval data '+ component.get('v.signComment') + ',' +  component.get("v.dateTodayForForm") + ',' +  ',' +
                    component.get('v.attachId'));
        console.log('valid '+ valid);
        if(valid == true){
            var action = component.get("c.saveOrder");
            component.find("Id_spinner").set("v.class" , 'slds-show');
            action.setParams({ 
                accId	: component.get('v.recordId'),
                orderId  : component.get('v.OrderID'),
                jsonList : JSON.stringify(jsonString),
                toInsertjsonList : JSON.stringify(toinsertjsonString),
                sizeOfOldDays  : 1,
                attachId:component.get('v.attachId'),
                commentSign:component.get('v.signComment'),
                signedDate: component.get("v.dateTodayForForm"),
                starttimeProcedure : component.get('v.todayString'),
                endtimeProcedure : component.get('v.endString'),
                orderToDel : component.get("v.orderToDelLst")
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('state '+ state);
                if(state === "SUCCESS"){
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    console.log('Success');

                    var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                    appEvent.setParams({
                        "screenType" : "Medication",
                        "action" : "Edit",
                         });
                    appEvent.fire();
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "success",
                        "title": "ORDER UPDATED SUCCESSFULLY!",
                        "message": "Updation Successfull!"
                    });
                    toastEvent.fire();
                    component.set("v.isModalOpen", false);
                    $A.get('e.force:refreshView').fire();
                    
                }
                else if(state ==="ERROR"){
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                    appEvent.setParams({
                        "screenType" : "Medication",
                        "action" : "Edit",
                        "button" : "Cancel"
                         });
                    appEvent.fire();
                    console.log('Failure');
                    
                    
                }
            }); 
            
            $A.enqueueAction(action);
        }
        
    }
})