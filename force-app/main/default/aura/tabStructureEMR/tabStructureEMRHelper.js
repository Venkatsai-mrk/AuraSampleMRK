({
    helperFun: function(component, event, secId) {
        var btnIds = ['articleOne', 'articleTwo', 'articleThree','articleFour', 'articleFive', 'articleSix', 'articleSeven', 'articleEight', 'articleNine', 'articleTen', 'articleEleven', 'articleThirteen','articleSubTab1', 'articleSubTab2','allocateBed'];
        //articleEight is unused
        var t = 0;
        //var b=0;
        for (var i = 0; i < btnIds.length; i++) {
            var btnId = btnIds[i];
            var btnCmp = component.find(btnId);
            var acc = component.find(secId);
            if (secId == 'articleSubTab1') {
                t = 1;
            }
            /* else if(secId == 'articleSubTab2'){
                  b=1;
                  
              }*/
            if ((btnId === secId)) {
                //alert('I am working');
                for (var cmp in acc) {
                    $A.util.addClass(acc[cmp], 'slds-is-active');
                    if ($A.util.hasClass(acc[cmp], 'slds-tabs_scoped__content')) {
                        $A.util.toggleClass(acc[cmp], 'slds-show');
                        $A.util.toggleClass(acc[cmp], 'slds-hide');                      
                    }
                }
            } else {
                if (t == 1) {
                    if (btnId != 'articleTen') {
                        for (var cmp1 in btnCmp) {
                            $A.util.removeClass(btnCmp[cmp1], 'slds-is-active');
                            if ($A.util.hasClass(btnCmp[cmp1], 'slds-tabs_scoped__content')) {
                                $A.util.removeClass(btnCmp[cmp1], 'slds-show');
                                $A.util.addClass(btnCmp[cmp1], 'slds-hide');
                            }
                        }
                    }
                }
                /* else if(b==1){
						if(btnId!='articleTwo'){
                        
                        for(var cmp1 in btnCmp) {
                            $A.util.removeClass(btnCmp[cmp1], 'slds-is-active');
                            if($A.util.hasClass(btnCmp[cmp1], 'slds-tabs_scoped__content')){
                                $A.util.removeClass(btnCmp[cmp1], 'slds-show');
                                $A.util.addClass(btnCmp[cmp1], 'slds-hide');
                            }} }                   
                    
                }*/
                else {
                    for (let cmp1 in btnCmp) {
                        $A.util.removeClass(btnCmp[cmp1], 'slds-is-active');
                        if ($A.util.hasClass(btnCmp[cmp1], 'slds-tabs_scoped__content')) {
                            $A.util.removeClass(btnCmp[cmp1], 'slds-show');
                            $A.util.addClass(btnCmp[cmp1], 'slds-hide');
                        }
                    }
                }
            }
        }
        
        window.setTimeout(
            $A.getCallback(function() {       
                var cmps = component.find(secId);
                for (var cm in cmps) {
                    if ($A.util.hasClass(cmps[cm], 'slds-tabs_scoped__content')) {
                        $A.util.removeClass(cmps[cm], 'slds-show');
                        $A.util.removeClass(cmps[cm], 'slds-is-active');
                        $A.util.addClass(cmps[cm], 'slds-hide');
                    }
                }
            }),5000);
    },
    renderRelatedList: function(component, event, res, res2, fld1, articleName) {
        var comp = component.find(articleName);
        for (var cm in comp) {
            if ($A.util.hasClass(comp[cm], 'slds-tabs_scoped__content')) {
                $A.util.removeClass(comp[cm], 'slds-show');
                $A.util.removeClass(comp[cm], 'slds-is-active');
                $A.util.addClass(comp[cm], 'slds-hide');
            }
        }
        var evt = $A.get("e.ElixirSuite:result");
        evt.setParams({
            "sobj": res,
            "recdtype": res2,
            "patId": component.get("v.recordId"),
            "fld1": fld1
        },500);
        evt.fire();
    },
    
    getLabResults: function(component, event, articleName, resultName) {
        console.log('fghjkiu', articleName +  resultName );
        var comp = component.find(articleName);
        for (var cm in comp) {
            if ($A.util.hasClass(comp[cm], 'slds-tabs_scoped__content')) {
                $A.util.removeClass(comp[cm], 'slds-show');
                $A.util.removeClass(comp[cm], 'slds-is-active');
                $A.util.addClass(comp[cm], 'slds-hide');
            }
        }
        //  boolean open= true;
        var evt = $A.get("e.ElixirFDC:labOtherTestEvent");
        var open = new Boolean(1);
        evt.setParams({
            "isOpen": open,
            "resultName": resultName,
        });
        evt.fire();
    },
    renderSubtabsOfSubtabs: function(component, articleName, dctransfertype) {
        var comp = component.find(articleName);
        for (var cm in comp) {
            if ($A.util.hasClass(comp[cm], 'slds-tabs_scoped__content')) {
                $A.util.removeClass(comp[cm], 'slds-show');
                $A.util.removeClass(comp[cm], 'slds-is-active');
                $A.util.addClass(comp[cm], 'slds-hide');
            }
        }
        if (dctransfertype == 'DcPatient') {
            var evt = $A.get("e.c:dcPatient");
            var open = new Boolean(1);
            evt.setParams({
                "isOpen": open,
            });
            evt.fire();
        }
        if (dctransfertype == 'uploadForms') {
            let evt = $A.get("e.ElixirFDC:labOtherTestEvent");
            let open = new Boolean(1);
            evt.setParams({
                "isOpen": open,
                "resultName": 'Uploaded Signed Forms',
            });
            evt.fire();
        }
    },
    showToastValidation: function(component) {
        var action = component.get("c.vobValidation");
        action.setParams({ accId : component.get("v.recordId")
                          
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                console.log('in helper fetchSessionCompleted**',response.getReturnValue());
                var abc = response.getReturnValue();
                console.log('data check for toast Himanshu'+abc);
                if(abc[0] == true){
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'VOB: Phone field should not be blank',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    return;
                }
                else if(abc[1] == true){
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'VOB: Gender field should not be blank',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    return;
                }
                    else if(abc[2] == true){
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message:'VOB: ZipCode length should be equal to 5 or 9',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        return;
                    }
                        else if(abc[3] == true){
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message:'VOB: FirstName field should not be blank',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                            return;
                        }
                            else if(abc[4] == true){
                                let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Error',
                                    message:'VOB: LastName field should not be blank',
                                    type: 'error',
                                    mode: 'pester'
                                });
                                toastEvent.fire();
                                return;
                            }
                                else if(abc[5] == true){
                                    let toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        title : 'Error',
                                        message:'VOB: For relationship Child State and City is mandatory',
                                        type: 'error',
                                        mode: 'pester'
                                    });
                                    toastEvent.fire();
                                    return;
                                }
                                    else if(abc[6] == true){
                                        let toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title : 'Error',
                                            message:'VOB: Account field is mandatory',
                                            type: 'error',
                                            mode: 'pester'
                                        });
                                        toastEvent.fire();
                                        return;
                                    }
                                        else if(abc[7] == true){
                                            let toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                title : 'Error',
                                                message:'VOB: Insurance group number field is mandatory',
                                                type: 'error',
                                                mode: 'pester'
                                            });
                                            toastEvent.fire();
                                            return;
                                        }
                                            else if(abc[8] == true){
                                                let toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    title : 'Error',
                                                    message:'VOB: Insurance Policy Id field is mandatory',
                                                    type: 'error',
                                                    mode: 'pester'
                                                });
                                                toastEvent.fire();
                                                return;
                                            }
                                                else if(abc[9] == true){
                                                    let toastEvent = $A.get("e.force:showToast");
                                                    toastEvent.setParams({
                                                        title : 'Error',
                                                        message:'VOB: Insurance Provider field is mandatory',
                                                        type: 'error',
                                                        mode: 'pester'
                                                    });
                                                    toastEvent.fire();
                                                    return;
                                                }
                
            }
            
            else {
                
                console.log("failure for namespace");
                
            }
            
        });
        
        $A.enqueueAction(action);
    },
    redirectToSobject: function(component) {
        console.log('9ij');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    }
})