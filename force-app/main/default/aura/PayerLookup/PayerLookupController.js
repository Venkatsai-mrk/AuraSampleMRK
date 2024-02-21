({
    doInit : function(component, event, helper){
        
        
    },
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
         component.set("v.SelectRecordName" , '');
                
         component.set("v.VobList" , []);
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");        
        var action = component.get("c.fetchChildVOBs");
      
        component.set('v.mycolumns', [
            {label: 'Insured First Name', fieldName: 'ElixirSuite__Insured_First_Name__c', type: 'text'},
            {label: 'Insured Last Name', fieldName: 'ElixirSuite__Insured_Last_Name__c', type: 'text'},
            {label: 'Insurance Policy Number', fieldName: 'ElixirSuite__Member_Id__c', type: 'text'},
            {label: 'Insurance Plan Name', fieldName: 'ElixirSuite__Insurance_Plan_Name__c', type: 'text'},
            {label: 'Patient Relationship with Insured', fieldName: 'ElixirSuite__Patient_Relationship_With_Insured__c', type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            },
            {label: 'Insurance Status', fieldName: 'ElixirSuite__Status__c', type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' },},
            {label: 'Insurance Verification Status', fieldName: 'ElixirSuite__VOB_Verification_Status__c', type: "text",
            sortable: true,
            cellAttributes: { alignment: 'left' },},
            {label: 'Insurance verification date', fieldName: 'ElixirSuite__Last_Verified_Date__c', type: 'date',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            },
            {label: 'VOB Created Date', fieldName: 'CreatedDate', type: 'date',
             sortable: true,
            cellAttributes: { alignment: 'left' },
            }
        ]);
        
        action.setParams({
            'selectedPayer': selectedAccountGetFromEvent.Id,
            'recordtypeLabel' : component.get("v.recordtypeLabel"),
            'accountId' : component.get("v.accId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.selectedRecord" , selectedAccountGetFromEvent);
                component.set("v.SelectRecordName" , selectedAccountGetFromEvent.Name);
                var forclose = component.find("lookup-pill");
                $A.util.addClass(forclose, 'slds-show');
                $A.util.removeClass(forclose, 'slds-hide');
                
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
                
                var lookUpTarget = component.find("lookupField");
                $A.util.addClass(lookUpTarget, 'slds-hide');
                $A.util.removeClass(lookUpTarget, 'slds-show');
                var res=[];
                var vobLstFinal = response.getReturnValue();
                 vobLstFinal.forEach(function(element, index) {
                     if(element.ElixirSuite__Set_Default_VOB__c == 'Yes'){
                         res.push(element);
                     }                       
                     });
                if(res.length==0){
                   res = response.getReturnValue();
                }
                console.log('res',res);
                var selectedRowsIds =[];
                var firstId;
               
                if(res.length >0){
                    firstId = res[0].Id;
                }
                 const that = this;
                for(let rec in res){
                    
                    var st = res[rec].ElixirSuite__VOB_Verification_Status__c;
                    console.log('st',st);
                    if(!$A.util.isUndefinedOrNull(res[rec].ElixirSuite__VOB_Verification_Status__c)){
                        var atl = st.replace(/(<([^>]+)>)/gi, "");
                        console.log(atl);
                        res[rec]['ElixirSuite__VOB_Verification_Status__c'] = st.replace(/(<([^>]+)>)/gi, "");
                    }
                    
                        
                }
                selectedRowsIds.push(firstId);
                
                component.set("v.selectedVOBList", res[0]);
                component.set("v.VobList", res);
               
                component.set("v.selectedRows", selectedRowsIds);
               
                component.set("v.displayTable", true);
              
            }
        });
        $A.enqueueAction(action);
        
    },
    stringHTMLFilter : function(component, event,helper,html) {
        var regex = /(<([^>]+)>)/ig
           var body = html;
           result = body.replace(regex, "");
        return result;

    },
    
})