({
    doInit : function(component) {
        component.set("v.loaded",false);
        var action = component.get('c.fetchPortalNotifications');
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state+' state for patient portal notifications');
            if(state === 'SUCCESS'){
                component.set("v.loaded",true);
                var result = response.getReturnValue();
                if (!$A.util.isUndefinedOrNull(result)) {
                    var arr = [];
                    var paymentArr = [];
                    console.log('result is',result);
                    component.set("v.baseURL",result.baseURL);
                    
                    if(result.UADetails){
                        for(var i in result.UADetails){
                            result.UADetails[i].type = 'Lab Order';
                            arr.push(result.UADetails[i]);
                        }
                    }
                    if(result.lo){
                        for(let i in result.lo){
                            result.lo[i].type = 'Lab Order CHC';
                            arr.push(result.lo[i]);
                        }
                    }
                    if(result.forms){
                        for(let i in result.forms){
                            result.forms[i].type = 'Forms';
                            arr.push(result.forms[i]);
                        }
                    }
                    const today = new Date().toLocaleDateString();
                    console.log('duedate is',today);
                    if(result.payments){
                        for(let i in result.payments){
                            result.payments[i].type = 'Payments';
                            console.log('duedate is',result.payments[i].ElixirSuite__Due_Date__c);
                            if(new Date(result.payments[i].ElixirSuite__Due_Date__c).toLocaleDateString() < today){
                                result.payments[i].dueDate = true;
                            }
                            else{
                                result.payments[i].dueDate = false;
                            }
                            paymentArr.push(result.payments[i]);
                        }
                    }
                    
                    arr.sort(function(a,b){
                        return new Date(b.CreatedDate) - new Date(a.CreatedDate);
                    });
                    var finalArr = paymentArr.concat(arr);
                    console.log('arr after ',arr);
                    component.set("v.CustomNotificationRecords",finalArr);
                  /*  
                    if(!$A.util.isEmpty(arr)){
                        var finalArr = arr.slice(0,5);
                        console.log('after slicing finalArr ',finalArr);
                        component.set("v.CustomNotificationRecords",finalArr);
                        
                    }*/
                }
            }
        });
        $A.enqueueAction(action);
    },
    navToPage: function(component, event) {
        
        if(event.getSource().get("v.label")  == 'Lab Order'){
            let navService = component.find("navigationService");
            let pageReference = {
                type: "standard__webPage", 
                attributes: {
                    url: "/lab-order"
                }
            }
            
            navService.navigate(pageReference);
        }
        if(event.getSource().get("v.label")  == 'Lab Order CHC'){
            let navService = component.find("navigationService");
            let pageReference = {
                type: "standard__webPage", 
                attributes: {
                    url: component.get("v.baseURL")+"/apex/ElixirSuite__LabOrderResults?id="+event.getSource().get("v.name")
                }
            }
            
            navService.navigate(pageReference);
        }
        if(event.getSource().get("v.label")  == 'Forms'){
            let navService = component.find("navigationService");
            let pageReference = {
                type: "standard__webPage", 
                attributes: {
                    url: "/portal-form"
                }
            }
            
            navService.navigate(pageReference);
        }
        if(event.getSource().get("v.label")  == 'Payments'){
            let navService = component.find("navigationService");
            let pageReference = {
                type: "standard__webPage", 
                attributes: {
                    url: "/payment-schedule/ElixirSuite__Payment_Schedule__c/Default"
                }
            }
            
            navService.navigate(pageReference);
        }
    }
})