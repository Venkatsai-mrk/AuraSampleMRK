({
    // To prepopulate the seleted value pill if value attribute is filled
    doInit : function( component, event, helper ) {
        $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
        if( !$A.util.isEmpty(component.get('v.value')) ) {
        helper.searchRecordsHelper( component, event, helper, component.get('v.value') );
        }
        console.log('account id========///////===='+component.get('v.accountId'));
        // component.set("v.selectedRecordId", component.get("v.selectedRecord.value"));
        //component.set("v.selectedRecordName", component.get("v.selectedRecord.label"));
        //component.set("v.selectedRecordDescription", component.get("v.selectedRecord.description"));

        // debugger;
    },
    
    // When a keyword is entered in search box
    searchRecords : function( component, event, helper ) {
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
            var val ='';
            var problemName = component.get('v.problemName');
            if( !$A.util.isUndefinedOrNull(problemName)){
            console.log('problemName '+ problemName);
            }
            helper.searchRecordsHelperDup( component, event, helper, '' );
            /*if(!problemName){
            helper.searchRecordsHelperDup( component, event, helper, '' );
            }else{
            helper.searchProblemRelatedDiagnosis( component, event, helper,problemName);
            }*/
            if( $A.util.isEmpty(val) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    // When an item is selected
    selectItem : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            var recordsList = component.get('v.recordsList');
            console.log('recordsList'+JSON.stringify(recordsList));
            var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            console.log('selectedRecord '+JSON.stringify(selectedRecord));
            component.set('v.selectedRecord',selectedRecord);
            component.set('v.value',selectedRecord.value);
            component.set("v.checkValue" , false);
             helper.searchField( component, event, helper,selectedRecord.label,event.currentTarget.id);
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
        
       
    },
    
    selectItemDup : function( component, event, helper ) {
        if(component.get("v.diagnosisVersionChange") == true){
            helper.searchRecordsHelper( component, event, helper, component.get('v.value'));
            
        }
        var recId = component.get("v.selectedRecordId");
        if(!$A.util.isEmpty(recId)) {
            var recordsList = component.get('v.recordsList');
            console.log('recordsList 64'+JSON.stringify(recordsList));
            /*var index = recordsList.findIndex(x => x.value === recId);
            if(index != -1) {
                var selectedRecord = recordsList[index];
                console.log('selectedRecord '+JSON.stringify(selectedRecord));
                component.set('v.selectedRecord',selectedRecord);
                component.set('v.value',selectedRecord.value);
            }*/
            var action = component.get('c.fetchIcdRecords');
            action.setParams({
                'icdId' : recId
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS') {
                    console.log('selectedRecord 78'+response.getReturnValue());
                    component.set('v.selectedRecord',response.getReturnValue());
                    component.set('v.value',response.value);
                    
                }
            });
                               
            $A.enqueueAction(action);
            
            component.set("v.checkValue" , false);
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
        else{
            component.set('v.selectedRecord','');
            component.set("v.selectedRecordId", '');
            component.set("v.selectedRecordName", '');
            component.set('v.value','');
            component.set('v.searchString','');
            setTimeout( function() {
                component.find( 'inputLookup' ).focus();
            }, 250);
            helper.searchRecordsHelperDup( component, event, helper, component.get('v.value') );
        }
        component.set("v.diagnosisVersionChange",false);
    },
    itemsChange : function (component, event, helper) {
       
        component.set("v.selectedRecordId", component.get("v.selectedRecord.value"));
        component.set("v.selectedRecordName", component.get("v.selectedRecord.label"));
        component.set("v.selectedRecordDescription", component.get("v.selectedRecord.description"));
    },
    
    showRecords : function( component, event, helper ) {
        component.set("v.modalVisibility", 'slds-show');
        component.set("v.showModal", 'true');
        console.log('selectedRecordId in diagnosiscmp '+component.get('v.selectedRecordId'));
        /*commented as per bulk handling requirement.
         if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        
        }*/
       
    },
    
    handleModalSave: function(component, event, helper){ 
       
        console.log('this is the data', event.getParam('selectedRecords'));
        var selectedRecord = event.getParam('selectedRecords');
         var deSelectedRecord = event.getParam('deSelectedRecords');
        console.log('deSelectedRecords', event.getParam('selectedRecords'));
        if(!$A.util.isEmpty(selectedRecord)){
            console.log('selectedRecord ', selectedRecord[0]);
           
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
             helper.insertDiagnosisCode(component, event, helper,selectedRecord);
            
            console.log(' Records'+JSON.stringify(component.get('v.selectedRecord')));
        	//var deleteRecord =component.get('v.selectedRecord');
            //if(deleteRecord != null)
            //{
        	//helper.deleteDiagnosisCode(component, event, helper,deleteRecord);
            // }
        }
         
        else{
             console.log('inside else');
            component.set("v.modalVisibility", 'slds-hide');
            component.set("v.showModal", false);
        }
        //component.set("v.recordDetail.description", selectedRecord[0].description);
        //component.set('v.selectedRecord',selectedRecord);
    },
        handleModalCancel: function(component, event, helper){ 
       	console.log(' handleModalCancel Records'+JSON.stringify(component.get('v.selectedRecord')));
        console.log('this is the data handleModalCancel', event.getParam('selectedRecords'));
        var selectedRecord = event.getParam('selectedRecords');
         var deSelectedRecord = event.getParam('deSelectedRecords');
        console.log('deSelectedRecords', event.getParam('selectedRecords'));
        if(!$A.util.isEmpty(selectedRecord)){
            component.set("v.modalVisibility", 'slds-hide');
            component.set("v.showModal", false);
            component.set("v.checkValue" , false);
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
             
        }
        else{
             console.log('inside else');
            component.set("v.modalVisibility", 'slds-hide');
            component.set("v.showModal", false);
        }
       
    },
    
    // To remove the selected item.
    removeItem : function( component, event, helper ){
        console.log('Abcc '+JSON.stringify(event));
        //component.set('v.selectedRecordCopy',JSON.parse(JSON.stringify(component.get('v.selectedRecord')));
                      //var recordId =event.getParam('selectedRecordCopy');
                      console.log(' Records'+JSON.stringify(component.get('v.selectedRecord')));
        var deleteRecord =component.get('v.selectedRecord');
        console.log(' Records'+JSON.stringify(deleteRecord));
        if(deleteRecord){
            console.log(' inside dletet'+JSON.stringify(deleteRecord.value));
            
        	helper.deleteDiagnosisCode(component, event, helper,deleteRecord.value);
            
        }
           
        component.set('v.selectedRecord','');
        component.set("v.selectedRecordId", '');
        component.set("v.selectedRecordName", '');
        component.set('v.value','');
        component.set('v.searchString','');
         component.set('v.recordsList', []);
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
        helper.searchRecordsHelperDup( component, event, helper, component.get('v.value') );
         //$A.get('e.force:refreshView').fire();
    },
    
    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
        
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
})