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
                    for (var cmp1 in btnCmp) {
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
            let evt = $A.get("e.c:dcPatient");
            let open = new Boolean(1);
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
    redirectToSobject: function(component) {
        console.log('9ij');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },
    handleClickForOTP : function(component  ){
        var action = component.get("c.sendEmail");
        action.setParams({  
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var sentEmailId = data.regEmail ;
                console.log('the data is' , data);
                
                component.set("v.result" , data.regEmail);
                component.set("v.vfCode" , data.code);
                console.log('the data is' , component.get("v.result"));
                var msg =  'The Verification Code has been sent to' + ' ' + sentEmailId ;
                var msg1 = 'The Patient emailId is not registered , Please contact the Administrator ';
                if($A.util.isUndefinedOrNull(data.regEmail) || $A.util.isEmpty(data.regEmail)){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: msg1 ,
                        duration:' 5000',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                else{
                    var toastEvent1 = $A.get("e.force:showToast");
                    toastEvent1.setParams({
                        title : 'Success !',
                        message: msg,
                        duration:' 5000',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent1.fire();    
                }
            }
            else{
                console.log('nhjl');
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    travelRelatedList : function(component){
        var p  = component.get("v.recordId");
        //var nameSpace = '';
        //var p  = component.get("v.recordId");
        
        var dummy = '/lightning/r/'+p+'/related/'+'ElixirSuite__Transports__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
        console.log('demo url '+dummy);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": dummy
        });
        urlEvent.fire();
        
    },
    signaturePad : function(component  ){
        component.set("v.recordVal" ,component.get("v.recordId"));
        component.set("v.openSignaturePad",true); 
    },
    OpenCostOfCare :function(component){
        
        /*component.set("v.CostOfCare",true);
    component.set("v.PaymentSchedule",false);
    component.set("v.Claims",false);
    component.set("v.Payment",false);
component.set("v.PatientStatement",false);*/
        
        component.set("v.OpPatientStatement",false);
        
        
        
        
        
    },
    OpenPaymentSchedule :function(component){
        
        
        
        
        component.set("v.OpPatientStatement",false);
        
        
        
        
    },
    OpenPayment :function(component){
        
        
        
        component.set("v.OpPatientStatement",false);
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:PaymentHistory_for_ehr",
            componentAttributes: {
                patId : component.get("v.recordId")
            }
        });
        evt.fire();
        
        
        
        
    },
    
    OpenClaims :function(component){
        
        
        component.set("v.OpPatientStatement",false);
        
        
    },
    
    genericWorkspaceLaunch : function(component , event , helper,obj){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openSubtab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": obj.eventParams.componentDef,
                },
                "state": obj.eventParams.componentAttributes
            },
            focus: true
        }).then(function(subtabId){
            workspaceAPI.setTabLabel({
                tabId: subtabId,
                label: obj.label
            });
            
        }).catch(function(error) {
            console.log(error);
        });
        
        
        
    },
    genericComponentLaunch :  function(component, event, helper,obj) {
        try{
            
            
            $A.createComponent(
                obj.eventParams.componentDef,
                obj.eventParams.componentAttributes,
                function(msgBox){                
                    if (component.isValid()) {
                        var targetCmp = component.find('ModalPlaceholder');
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body); 
                    }
                }
            );
        }
        catch(e){
            alert(e);
        }
    },
    genericEventLaunch :  function(component, event, helper,obj) {
        if(obj.elementChild.ElixirSuite__TAB_Navigation_Event__c == 'e.force:navigateToURL'){   
            let evt = $A.get(obj.navigationEvent);
            evt.setParams(helper.resolveURLParam(component, event, helper,obj.elementChild));
            evt.fire();  
        }
        else {
            let evt = $A.get(obj.navigationEvent);
            evt.setParams(obj.eventParams);
            evt.fire();  
        } 
    },
    mapOfAttributeValues : function(component) {
        var attributeValMap = {'openSignaturePad' : component.get("v.openSignaturePad"),
                               'orgWideValidNamespace' :  component.get("v.orgNamespace"),
                               'OrgWideNameSpace' :  component.get("v.orgNamespace"),
                               'patientID' : component.get("v.recordId"),
                               'openCareplan': true,
                               'patId' : component.get("v.recordId"),
                               "isOpen" : true,
                               "recordId": component.get("v.recordId")
                              };
        return attributeValMap;
    },
    resolveURLParam : function(component, event, helper,elementChild) {
        var runTimeObj = {};
        console.log('BUILD ID '+JSON.stringify(elementChild.Id));
        console.log('BUILD NAME '+JSON.stringify(elementChild.Name)); 
        console.log('BUILD TABCOMPATTRIBUTE '+JSON.stringify(elementChild.ElixirSuite__TAB_Component_Attributes__c));
        let attributesObj = JSON.parse(elementChild.ElixirSuite__TAB_Component_Attributes__c);
        
        var url = '';   
        if(attributesObj.hasOwnProperty('objectApiName')){
            let objctApibuild = attributesObj['objectApiName'].replace('__c' , '__r');
            url = '/lightning/r/'+component.get("v.recordId")+'/related/'+objctApibuild+'/view?ws=%2Flightning%2Fr%2FAccount%2F'+component.get("v.recordId")+'%2Fview';
        }
        runTimeObj['url'] = url;
        return runTimeObj;
        
    },
    resolveComAttributes : function(component, event, helper,elementChild) {
        var runTimeObj = {};
        var attributeValMap = helper.mapOfAttributeValues(component, event, helper);
        console.log('BUOLD 345 '+JSON.stringify(elementChild.Id));
        console.log('BUILD NAME '+JSON.stringify(elementChild.Name)); 
        console.log('BUOLD 345 '+JSON.stringify(elementChild.ElixirSuite__TAB_Component_Attributes__c));
        let attributesObj = JSON.parse(elementChild.ElixirSuite__TAB_Component_Attributes__c);
        runTimeObj['recordVal'] =  component.get("v.recordId");
        runTimeObj['openSignaturePad']  =  component.get("v.openSignaturePad");
        runTimeObj['orgWideValidNamespace'] = component.get("v.orgNamespace");
        runTimeObj['OrgWideNameSpace'] =  component.get("v.orgNamespace");
        runTimeObj['patientID'] = component.get("v.recordId");
        runTimeObj['openCareplan']= true;
        runTimeObj['patId'] = component.get("v.recordId");
        runTimeObj['isOpen'] = true;
        runTimeObj['recordId']= component.get("v.recordId");
        runTimeObj['isActive']= component.get("v.openModalMorMar");
        runTimeObj['c__crecordId']= component.get("v.recordId");
        runTimeObj['enableSessionNotes']= elementChild.ElixirSuite__Enable_Session_Note__c;
        if(elementChild.ElixirSuite__TAB_Form_Categories__c){    
            console.log('split '+JSON.stringify(elementChild.ElixirSuite__TAB_Form_Categories__c.split(';')));
            runTimeObj['customCategory'] = elementChild.ElixirSuite__TAB_Form_Categories__c.split(';'); 
        }
        for(const rec in attributesObj){
            if(attributesObj[rec].startsWith('$')){
                let keySet = attributesObj[rec].split('$');
                if(attributeValMap.hasOwnProperty(keySet[1])){
                    runTimeObj[rec] = attributeValMap[keySet[1]];  
                }
            }
            else {
                runTimeObj[rec] = attributesObj[rec];
            }
        }
        
        return runTimeObj;
    },

    manipulatedMap : function(component, event, helper, tabPermissionMap) {
        //var tabPermissionValues = component.get("v.TabPermission");
        if(tabPermissionMap['ElixirSuite__LabOrder_Priority__c'] =='CHC LabOrder'){
            tabPermissionMap['ElixirSuite__Integrated_Lab_Order__c'] = true;
            tabPermissionMap['ElixirSuite__Lab_Orders__c'] = false;
        }
        if(tabPermissionMap['ElixirSuite__LabOrder_Priority__c'] =='Dummy LabOrder'){
            tabPermissionMap['ElixirSuite__Integrated_Lab_Order__c'] = false;
            tabPermissionMap['ElixirSuite__Lab_Orders__c'] = true;
        }
        if(tabPermissionMap['ElixirSuite__LabOrder_Priority__c'].includes('Dummy LabOrder') && tabPermissionMap['ElixirSuite__LabOrder_Priority__c'].includes('CHC LabOrder') ){
            tabPermissionMap['ElixirSuite__Integrated_Lab_Order__c'] = true;
            tabPermissionMap['ElixirSuite__Lab_Orders__c'] = true;
        }
        if(tabPermissionMap['ElixirSuite__Prescription_Priority__c'] == 'Dummy Prescription'){
            tabPermissionMap['ElixirSuite__NewCrop_Prescription_Order__c'] = false;
            tabPermissionMap['ElixirSuite__Prescriptions__c'] = true;
        }
        if(tabPermissionMap['ElixirSuite__Prescription_Priority__c'] == 'NewCrop Prescription'){
            tabPermissionMap['ElixirSuite__NewCrop_Prescription_Order__c'] = true;
            tabPermissionMap['ElixirSuite__Prescriptions__c'] = false;
        }
     },
 
    
    createDynamicJSON :  function(component, event, helper) {
        var applicationName = component.get("v.appName");
        console.log('applicationName55115',applicationName);
        var action = component.get("c.fetchDynamicTabStructureData");
        action.setParams({
            "Recid":applicationName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    // alert('--> '+JSON.stringify(response.getReturnValue()));
                    var subTabPicklistValueMap =  component.get("v.subTabPicklistValueMap");
                    var tabPermissionMap = component.get("v.TabPermission");
                    helper.manipulatedMap(component, event, helper, tabPermissionMap);
                    console.log(tabPermissionMap);
                    var result = response.getReturnValue().allObjectsToDisplayOnTimeline;
                    result.sort(function(a, b) {
                        return parseFloat(a.ElixirSuite__Sort_Order__c) - parseFloat(b.ElixirSuite__Sort_Order__c);
                    });
                    var buildJSON = [];
                    result.forEach(function(element, index) {
                        console.log(index);
                        let sObj =   {
                            label : element.ElixirSuite__Tab_Label__c,
                            isDirectTabLaunch : element.ElixirSuite__TAB_Is_Direct_Tab_Launch__c, 
                            iconName : element.ElixirSuite__TAB_Icon_Name__c,
                            auraId : element.ElixirSuite__Aura_ID__c,
                            subTabs : []
                        };                     
                        if(element.hasOwnProperty('ElixirSuite__Master_Objects__r')){
                            element.ElixirSuite__Master_Objects__r = element.ElixirSuite__Master_Objects__r.sort((a, b) => (a.ElixirSuite__Sort_Order__c > b.ElixirSuite__Sort_Order__c) ? 1 : -1);
                            element.ElixirSuite__Master_Objects__r.forEach(function(elementChild, indexChild) {
                                {
                                    console.log(indexChild);
                                    if(tabPermissionMap.hasOwnProperty(elementChild.ElixirSuite__TABSub_Tab_Label__c)){              
                                        if(tabPermissionMap[elementChild.ElixirSuite__TABSub_Tab_Label__c]){
                                            sObj.isParentTabAllowed = true;
                                        }
                                    }
                                    console.log('PINT '+JSON.stringify(elementChild.Name));
                                    sObj.subTabs.push(
                                        {label : subTabPicklistValueMap[elementChild.ElixirSuite__TABSub_Tab_Label__c],
                                         isSubTabAllowed:tabPermissionMap[elementChild.ElixirSuite__TABSub_Tab_Label__c],
                                         typeOfLaunch : elementChild.ElixirSuite__TAB_Type_Of_Launch__c,
                                         elementChild : elementChild,
                                         eventParams : {
                                             componentDef:elementChild.ElixirSuite__TAB_Component_Definition__c,
                                             
                                             componentAttributes:helper.resolveComAttributes(component, event, helper,elementChild)
                                         },
                                         navigationEvent : elementChild.ElixirSuite__TAB_Navigation_Event__c,
                                         methodName : elementChild.ElixirSuite__TAB_Method_Name_If_Any__c
                                        }
                                    );  
                                }});
                        }
                        else {
                            if(tabPermissionMap.hasOwnProperty(element.ElixirSuite__TABSub_Tab_Label__c)){              
                                if(tabPermissionMap[element.ElixirSuite__TABSub_Tab_Label__c]){
                                    sObj.isParentTabAllowed = true;
                                }
                            }
                            
                            sObj.label = element.ElixirSuite__Tab_Label__c;
                            sObj.typeOfLaunch = element.ElixirSuite__TAB_Type_Of_Launch__c;
                            sObj.elementChild = element;
                            sObj.eventParams = {
                                componentDef:element.ElixirSuite__TAB_Component_Definition__c,
                                
                                componentAttributes:helper.resolveComAttributes(component, event, helper,element)
                            };
                            sObj.navigationEvent = element.ElixirSuite__TAB_Navigation_Event__c;
                            sObj.methodName = element.ElixirSuite__TAB_Method_Name_If_Any__c;
                            
                            
                        }
                        
                        
                        //   sObj.isParentTabAllowed = true;
                        buildJSON.push(sObj);
                        
                    });
                    
                    component.set("v.dynamicTabLst",buildJSON);
                    console.log('FINAL BUILD ' + JSON.stringify(component.get("v.dynamicTabLst")));  
                }
                catch(e){
                    alert('Error' + e);
                }
                
            }
            else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
            
        });
        
        $A.enqueueAction(action);
        /*  var buildJSON = [
        {
            label : "Admin",
            systemprovided : false,
            isDirectTabLaunch : false, 
            iconName : 'utility:edit_form',
            auraId : 'articleFour',
            subTabs : [
                {'label' : 'Generate Verification Code','isSubTabAllowed':true,'methodName' : 'handleClickForOTP'
                },
                {'label' : 'Capture Signature for E-sign','isSubTabAllowed':true,'typeOfLaunch' : 'component',
                    'eventParams' : {
                        'componentDef':'c:signaturePadCmp',
                        'componentAttributes':  {
                            "isActive": component.get("v.openSignaturePad"),
                            "recordVal": component.get("v.recordVal"),
                            body : 'mesage'
                        }
                    }
                },
                {'label' : 'Patient Care','isSubTabAllowed':true,'methodName' : '',  'typeOfLaunch' : 'event',
                    'navigationEvent' : 'e.force:navigateToComponent',
                    'eventParams' : {
                        'componentDef':'c:VisitListView',
                        'componentAttributes':  {
                            'recordVal' : component.get("v.recordId"),               
                        }
                    }
                    ,
                },
                {'label' : 'Admin Forms','isSubTabAllowed':true,'methodName' : '',   
                    'navigationEvent' : 'e.force:navigateToComponent',  'typeOfLaunch' : 'event',
                    'eventParams' : {
                        'componentDef':'c:Elixir_NewAccountAssociatedForms',
                        'componentAttributes':  {
                            recordVal : component.get("v.recordId"),
                            categorized : "Admission",
                            subCategorized: "Assessment",
                            headingTitle: "Administrative Documentation",
                            isOpen1 : true             
                        }
                    },
                },
                {'label' : 'Transportation',
                    'isSubTabAllowed':true,'methodName' : '',  'typeOfLaunch' : 'event',
                    'navigationEvent' : 'e.force:navigateToURL',
                    'eventParams' : {
                        "url": '/lightning/r/'+component.get("v.recordId")+'/related/'+'ElixirSuite__Transports__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+component.get("v.recordId")+'%2Fview'
                    },
                },                    
            ]
                },
                
                {
                label : "Medical Orders",
                systemprovided : false,
                isDirectTabLaunch : false,
                iconName : 'utility:adduser',
                auraId : 'articleThree',
                subTabs : [
                {'label' : 'Medical Examination',
                'isSubTabAllowed':true,'methodName' : '',
                'navigationEvent' : 'e.force:navigateToURL',  'typeOfLaunch' : 'event',
                'eventParams' : {
                "url": '/lightning/r/'+component.get("v.recordId")+'/related/ElixirSuite__Medical_Examinations__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+component.get("v.recordId")+'%2Fview'
                },
                },
                {'label' : 'Immunization','typeOfLaunch' : 'event',
                'isSubTabAllowed':true,'methodName' : '',
                'navigationEvent' : 'e.force:navigateToURL',
                'eventParams' : {
                "url": '/lightning/r/'+component.get("v.recordId")+'/related/ElixirSuite__Vaccines__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+component.get("v.recordId")+'%2Fview'
                },
                },
                {'label' : 'Lab Orders','isSubTabAllowed':true,'methodName' : '', 
                'typeOfLaunch' : 'event',  'navigationEvent' : 'e.force:navigateToURL',
                'eventParams' : {
                'componentDef':"c:ElixirHC_LabOrderListView",
                'componentAttributes': {
                patientID : component.get("v.recordId"),
                nameSpace : 'ElixirSuite__'
                }
                }
                },
                {'label' : 'Lab Tests','isSubTabAllowed':true,'methodName' : '',  'typeOfLaunch' : 'workspace',                  
                'eventParams' : {
                'componentDef':'c__labOrdersCHCSuTab',
                'componentAttributes':  {
                c__crecordId: component.get("v.recordId")
                }
                }
                },
                
                {'label' : 'Prescriptions',
                'isSubTabAllowed':true,'methodName' : '',
                'typeOfLaunch' : 'event',
                'navigationEvent' : 'e.force:navigateToComponent',
                'eventParams' : {
                componentDef:"c:MedicationListView",
                componentAttributes: {
                recordVal : component.get("v.recordId"),
                orgWideValidNamespace : component.get("v.orgNamespace")
                }
                },
                },
                {'label' : 'MOR/MAR',
                'isSubTabAllowed':true,'methodName' : '',
                'typeOfLaunch' : 'component',
                'eventParams' : {
                'componentDef':'c:MAR',
                'componentAttributes':  {
                "isActive": component.get("v.openModalMorMar"),
                "recordVal": component.get("v.recordId"),
                body : 'mesage'
                },
                
                },
                } 
            ]
        },
        
        {
            label : "Notes",
            systemprovided : false,
            isDirectTabLaunch : true,
            typeOfLaunch : 'event',
            iconName : 'utility:edit_form',
            'navigationEvent' : 'e.force:navigateToComponent',
            auraId : 'allocateBed',                              
            'eventParams' :{
                componentDef:"c:Elixir_NewAccountAssociatedForms",
                componentAttributes: {
                    recordVal : component.get("v.recordId"),
                    //  categorized : "Other",
                    subCategorized: "Assessment",
                    headingTitle: "All Notes"
                }
            },
        },
        {
            label : "Care Plan",
            systemprovided : false,
            isDirectTabLaunch : true,
            typeOfLaunch : 'component',
            iconName : 'utility:multi_picklist',
            auraId : 'articleEleven',                              
            'eventParams' : {
                'componentDef':'c:CarePlan_ListView',
                'componentAttributes':  {
                    "openCareplan": true,
                    "recordVal": component.get("v.recordId"),
                    body : 'mesage'
                },   
            }
        },
        {
            label : "Utilization Review",
            systemprovided : false,
            isDirectTabLaunch : false,
            iconName : 'utility:questions_and_answers',
            auraId : 'articleSix',
            subTabs : [
                {'label' : 'Review Forms',
                    'isSubTabAllowed':true,'methodName' : '',
                    'navigationEvent' : 'e.force:navigateToComponent',  'typeOfLaunch' : 'event',
                    'eventParams' : {
                        componentDef:"c:ElixirHC_URListView",
                        componentAttributes: {
                            patientID : component.get("v.recordId"),
                            OrgWideNameSpace : 'ElixirSuite__'
                        }
                    }
                },
                
            ]
                },
                {
                label : "Problem & Diagnosis",
                systemprovided : false,
                isDirectTabLaunch : false,
                iconName : 'utility:multi_picklist',
                auraId : 'articleEleven',
                isDirectTabLaunch : true,
                typeOfLaunch : 'event',
                'navigationEvent' : 'e.force:navigateToComponent',
                'eventParams' : {
                componentDef:"c:masterProblemlist",
                componentAttributes: {
                recordVal : component.get("v.recordId")
                }
                } 
                },
                {
                label : "Billing",
                systemprovided : false,
                isDirectTabLaunch : false,
                iconName : 'utility:change_owner',
                auraId : 'articleTen',
                subTabs : [
                {'label' : 'Medical Coding',
                'isSubTabAllowed':true,'methodName' : '',
                'navigationEvent' : 'e.force:navigateToComponent',  'typeOfLaunch' : 'event',
                'eventParams' :{
                componentDef:"c:MedicalCodingListView",
                componentAttributes: {
                recordVal : component.get("v.recordId"),
                orgWideValidNamespace : component.get("v.orgNamespace")
                }
                },
                },
                {'label' : 'Cost Of Care','typeOfLaunch' : 'event',
                'isSubTabAllowed':true,'methodName' : '',
                'navigationEvent' : 'e.force:navigateToComponent',
                'methodName' : '',
                'eventParams' :{
                componentDef:"c:Past_Estimates_for_EHR",
                componentAttributes: {
                patId : component.get("v.recordId")
                }
                },
                },
                {'label' : 'Payment Schedule','typeOfLaunch' : 'event',
                'isSubTabAllowed':true,'methodName' : ' OpenPaymentSchedule',
                'navigationEvent' : 'e.force:navigateToComponent',
                'methodName' : '',
                'eventParams' :{
                componentDef:"c:View_Payment_Schedule_for_EHR",
                componentAttributes: {
                patId : component.get("v.recordId")
                }
                },
                },
                {'label' : 'Claims','typeOfLaunch' : 'event',
                'isSubTabAllowed':true,'methodName' : ' OpenClaims',
                'navigationEvent' : 'e.force:navigateToComponent',
                'methodName' : '',
                'eventParams' :{
                componentDef:"c:ClaimListView_for_Ehr",
                componentAttributes: {
                patId : component.get("v.recordId")
                }
                },
                },
                {'label' : 'Payments','typeOfLaunch' : 'component',
                'isSubTabAllowed':true,'methodName' : '',
                'navigationEvent' : '',
                'methodName' : '',
                'eventParams' : {
                'componentDef':'c:ParentStatement',
                'componentAttributes':  {
                "isOpen": true,
                "recordId": component.get("v.recordId"),
                body : 'mesage'
                },   
                },
                }
                
            ]
        },
        {
            label : "DC & Transfer",
            systemprovided : false,
            isDirectTabLaunch : false,
            iconName : 'utility:change_owner',
            auraId : 'articleTen',
            subTabs : [
                {'label' : 'Discharge Form',
                    'isSubTabAllowed':true,'methodName' : '',
                    'navigationEvent' : 'e.force:navigateToComponent',  'typeOfLaunch' : 'event',
                    'eventParams' :{
                        componentDef:"c:Elixir_NewAccountAssociatedForms",
                        componentAttributes: {
                            recordVal : component.get("v.recordId"),
                            //  categorized : "Other",
                            subCategorized: "Assessment",
                            headingTitle: "All Notes"
                        }
                    },
                },
                {'label' : 'Referral','typeOfLaunch' : 'event',
                    'isSubTabAllowed':true,'methodName' : '', 
                    'navigationEvent' : 'e.force:navigateToComponent',
                    'methodName' : '',
                    'eventParams' :{
                        componentDef:"c:ElixirOEM_ReferralListView",
                        componentAttributes: {
                            recordVal : component.get("v.recordId")
                        }
                    },
                },
                
            ]
                },
                {
                label : "Timeline",
                systemprovided : false,
                isDirectTabLaunch : true,
                typeOfLaunch : 'event',
                iconName : 'utility:multi_picklist',
                auraId : 'articleTwelve',                              
                'navigationEvent' : 'e.force:navigateToComponent',  'typeOfLaunch' : 'event',                             
                'eventParams' : {
                componentDef:"c:TimeLineParent",
                componentAttributes: {
                recordVal : component.get("v.recordId"),
                orgWideValidNamespace : component.get("v.orgNamespace")
                }
                }
                },
            ];
            
            component.set("v.dynamicTabLst",buildJSON);
            console.log('FINAL BUILD ' + JSON.stringify(component.get("v.dynamicTabLst")));*/
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
    runValiDationAndOpenLabOrder : function(component  ){
        //helper.showToastValidation(component , event , helper);
        //this.showToastValidation(component, event, helper);
        //var self = this;
		//self.showToastValidation(component, event, helper);
        console.log('helper function called for validation');
        var action = component.get("c.accountFieldValidation");
        action.setParams({ accId : component.get("v.recordId")
                          
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                console.log('in helper fetchSessionCompleted**',response.getReturnValue());
                var abc = response.getReturnValue();
                //var xyz;
                //console.log('data check for toast Himanshu'+abc);
                if(abc[0] == true){
                    //xyz = true;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'Date Of Birth should not be future date',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    return;
                }
                else if(abc[1] == true){
                    //xyz = true;
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'Phone length should be equals to 10',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    return;
                }
                    else if(abc[2] == true){
                        //xyz = true;
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message:'Zipcode length should be equals to 5 or 9',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        return;
                    }
                        else {
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef:"c:labOrdersCHCSuTab",
                                componentAttributes: {
                                    crecordId : component.get("v.recordId"),
                                    nameSpace : 'ElixirSuite__'
                                }
                            });
                             //window.location.reload();
                            evt.fire();   
                    }
            }
            
            else {
                //ErrorToast = true;
                console.log("failure for namespace");
                
            }
            
        });
        
        $A.enqueueAction(action);
        
        
    },
    runValidationAndOpenNewCrop:function(component , event , helper,arrJSON,parentIndex,childIndex,launchHelperName){
        var action = component.get("c.accNewCropFieldValidation");
        action.setParams({ accId : component.get("v.recordId")
                          
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            
           if (state === "SUCCESS") {
                
                console.log('in helper fetchSessionCompleted**',response.getReturnValue());
                var abc = response.getReturnValue();
                //var xyz;
                //console.log('data check for toast Himanshu'+abc);
                //Pluggable Message
                var pMsg='Pluggable class missing from custommetadata';
               var sMsg ='Date Of Birth should not be future date \n';
                sMsg +='Phone length should be equals to 10\n'; 
                sMsg += 'Enter First Name \n';
                sMsg += 'Enter Last Name \n';
                sMsg += 'Enter Gender \n';
                    sMsg += ' Enter BillingStreet \n';
                sMsg += ' Enter BillingCity \n';
                sMsg += ' Enter BillingState(E.g. MA) \n';
                sMsg += ' Enter BillingCountry(US/CA/MX) \n';
                sMsg +='BillingZipcode length should be equals to 5 \n' ;

                if(abc[10] == true ){
                    var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                           title : 'NewCrop not configured properly, please contact your administrator',
                           message:pMsg ,
                           type: 'error',
                           mode: 'sticky'
                       });
                       toastEvent.fire();
                       return;  
                  }
                if(abc[0] == true || abc[1] == true ||abc[2] == true|| abc[3] == true||abc[4] == true ||abc[5] == true||abc[6] == true||abc[7] == true || abc[8] == true || abc[9] == true){
                    //xyz = true;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Mandatory Fields',
                        message:sMsg ,
                        type: 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                    return;
                }
                
                        else {
                            helper[launchHelperName](component, event, helper,arrJSON[parentIndex].subTabs[childIndex]);
                        }
            }
            
            else {
                //ErrorToast = true;
                console.log("failure for namespace");
                
            }
            
        });
        
        $A.enqueueAction(action);
    },
    //added by vishal for Transportation - LX3-6695
    checkTransportation : function (component, event, helper,arrJSON,parentIndex,childIndex,launchHelperName) {
        console.log('inside checkTransportation');
        var action = component.get("c.checkCareEpisodePrompt");
        //var nameSpace = '';
        //var p  = component.get("v.recordId");
        action.setParams({
            "patientId":component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                var returnval=response.getReturnValue();
                if(returnval==true){          
                    component.set("v.careModal",true);
                    component.set("v.heading" , 'Transport');
                }
                else{
                    helper[launchHelperName](component, event, helper,arrJSON[parentIndex].subTabs[childIndex]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    //added by vishal for Medical Examination - LX3-6695
    checkMedicalExamination : function (component, event, helper,arrJSON,parentIndex,childIndex,launchHelperName) {
        console.log('inside checkTransportation');
        var action = component.get("c.checkCareEpisodePrompt");
        //var nameSpace = '';
        //var p  = component.get("v.recordId");
        action.setParams({
            "patientId":component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                var returnval=response.getReturnValue();
                if(returnval==true){          
                    component.set("v.careModal",true);
                    component.set("v.heading" , 'Medical Examination');
                }
                else{
                    helper[launchHelperName](component, event, helper,arrJSON[parentIndex].subTabs[childIndex]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    //added by vishal for Immunization - LX3-6695
    checkImmunization : function (component, event, helper,arrJSON,parentIndex,childIndex,launchHelperName) {
        console.log('inside checkTransportation');
        var action = component.get("c.checkCareEpisodePrompt");
        //var nameSpace = '';
        //var p  = component.get("v.recordId");
        action.setParams({
            "patientId":component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                var returnval=response.getReturnValue();
                if(returnval==true){          
                    component.set("v.careModal",true);
                    component.set("v.heading" , 'Immunization');
                }
                else{
                    helper[launchHelperName](component, event, helper,arrJSON[parentIndex].subTabs[childIndex]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    //added by vishal for MOR and MAR - LX3-6695
    checkMORAndMAR : function (component, event, helper,arrJSON,parentIndex,childIndex,launchHelperName) {
        console.log('inside checkTransportation');
        var action = component.get("c.checkCareEpisodePrompt");
        //var nameSpace = '';
        //var p  = component.get("v.recordId");
        action.setParams({
            "patientId":component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                var returnval=response.getReturnValue();
                if(returnval==true){          
                    component.set("v.careModal",true);
                    component.set("v.heading" , 'MOR/MAR');
                }
                else{
                    helper[launchHelperName](component, event, helper,arrJSON[parentIndex].subTabs[childIndex]);
                }
            }
        });
        $A.enqueueAction(action);
    }
})