({
	init : function(component, event, helper) {
    component.get("v.isActive");  
    helper.getVobAndCustomsettings(component, event, helper); //Anusha 28/10/22
	},
    
    closePopUp : function(component){
     component.set("v.isActive",false);  
    },
    onCMSFormClick : function(component,event){
        var heading,subheading;
        var clickedFormName = event.getSource().get("v.name");
        if(clickedFormName == "CMS_1500")
        {
            heading = "CMS-1500 Form";
        }
        var cmpTarget = component.find('exampleModal');
        $A.util.addClass(cmpTarget, 'hideDiv');
        var action = component.get("c.fetchRecords");
        action.setParams({
            accountId : component.get("v.patId"),
            recordtypeLabel : 'Primary',
            recName : clickedFormName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
               component.set("v.payerList",res.payerList);
                 component.set("v.VobList",res.vobList);
                var payerLst = [];
                    payerLst =res.payerList;
                console.log('payerLst'+payerLst);
                console.log('payerLst Length'+payerLst.length);
                var singleVOB = false;
                var vobLst = [];
                console.log('res',res);
                vobLst =res.vobList;
                console.log('vobLst'+vobLst);
                console.log('vobLst Length'+vobLst.length);
                  vobLst.forEach(function(element) {
                     if(element.ElixirSuite__Set_Default_VOB__c == 'Yes'){
                   singleVOB = true;
                       }                        
                     }); 
                if(payerLst.length == 1 && vobLst.length == 1 && singleVOB){
                    component.set("v.isSingleVOB",true);
                    console.log('Only One');
                }else{
                    component.set("v.isSingleVOB",false);
                     console.log('More than One');
                }
                console.log('SingleVOB',component.get("v.isSingleVOB"));
                
                
                component.set('v.selectedVOBList', vobLst[0]);
                //var vlist = component.get('v.selectedVOBList');
                
                console.log('selectvob',component.get('v.selectedVOBList'));
                
                component.set("v.isCMS1500",true);
                component.set("v.isOpen",true);
                component.set("v.heading",heading);
                component.set("v.subheading",subheading);
                console.log('ks' , component.get("v.heading"));
                component.set("v.recordTypeId",res.recTypeid);
                console.log("recTypeid "+res.recTypeid);
            }
            
           
            
        });
        $A.enqueueAction(action);
    },
    onCMSFormClickCopy :  function(component,event){
        var heading,subheading;
        var clickedFormName = event.getSource().get("v.name");
        if(clickedFormName == "CMS_1500")
        {
            heading = "CMS-1500 Form";
        }
        console.log('ks----' , heading + subheading);
        var cmpTarget = component.find('exampleModal');
        $A.util.addClass(cmpTarget, 'hideDiv');
        var action = component.get("c.getRecordType");
        action.setParams({
            recName : clickedFormName
        });
        
        action.setCallback(this, function(response) {
            component.set("v.openCMSCopy",true);
            component.set("v.heading",heading);
            component.set("v.subheading",subheading);
            console.log('ks' , component.get("v.heading"));
            component.set("v.recordTypeId",response.getReturnValue());
            
        });
        $A.enqueueAction(action);
    },
    onUBFormClick : function(component,event){
        var heading,subheading;
        var clickedFormName = event.getSource().get("v.name");
        console.log('ghgcbhvhwvhwegfhwewe'+ event.getSource().get("v.name"));
        if(clickedFormName == "UB_04")
        {
            heading = "UB-04 Form";
        }
        console.log('ks----' , heading + subheading);
        var cmpTarget = component.find('exampleModal');
        $A.util.addClass(cmpTarget, 'hideDiv');
        var action = component.get("c.fetchRecords");
        action.setParams({
            accountId : component.get("v.patId"),
            recordtypeLabel : 'Primary',
            recName : clickedFormName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var payerLst = res.payerList;
                 component.set("v.payerList",res.payerList);
                 component.set("v.VobList",res.vobList);
                var singleVOB = false;
                var vobLst = [];
                vobLst =res.vobList;
                  vobLst.forEach(function(element) {
                     if(element.ElixirSuite__Set_Default_VOB__c == 'Yes'){
                   singleVOB = true;
                       }                        
                     }); 
                if(payerLst.length == 1 && vobLst.length == 1 && singleVOB){
                    component.set("v.isSingleVOB",true);
                }else{
                    component.set("v.isSingleVOB",false);
                }
                component.set('v.selectedVOBList', vobLst[0]);
                component.set("v.isUB04",true);
                component.set("v.heading",heading);
                component.set("v.isOpen",true);
                component.set("v.subheading",subheading);
                component.set("v.recordTypeId",res.recTypeid);
                console.log("recTypeid "+res.recTypeid);
            }
        });
        $A.enqueueAction(action);
   
    },
    handleComponentEvent : function(component) { //Anusha -start - 29/10/22
        console.log("event caught");
        component.set("v.isActive",false);
    }, //Anusha -start - 29/10/22
})