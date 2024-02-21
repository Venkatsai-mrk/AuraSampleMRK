({
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.cmpName", '');
        component.set("v.isOpen", false);
        $A.get("e.force:closeQuickAction").fire();
    },
    
    init: function (component, event, helper) {
        var recId = component.get( "v.recId" );
        var selectedRows= component.get("v.selectedRows");
        component.set("v.loaded",false);
        var getSettingsAction = component.get("c.fetchFieldsForSelectedObject");
        
        getSettingsAction.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set("v.loaded",true);
                component.set("v.companySetting", response.getReturnValue());
                component.set( "v.probList",response.ElixirSuite__Problem_List__c);
                console.log("Company Setting loaded."+JSON.stringify(component.get("v.companySetting")));
                var resp = response.getReturnValue();
                var arr  = [];
                for(let rec in resp){
                    var sObjInstance = {'label' : resp[rec],'value' : rec};
                    arr.push(sObjInstance);
                }
                component.set( "v.lstOfCustomSetting",arr); 
                helper.fetchCSValues(component, event, helper);  
                helper.fetchCategoryfieldValues(component, event, helper); 
                
                // add css manually
                // component.set("v.body", JSON.stringify("<style>.slds-modal__content {height: auto !important;max-height: 100% !important;border-radius: 3px !important;padding: 0px !important;}.slds-modal__container {max-width: 100% !important;width: 80% !important;} .cuf-content {padding: 0px !important}</style>"));
                $A.createComponent(
                    "aura:html",
                    {
                        "tag": "style",
                        "body": "<style> .slds-p-around_medium {padding: 0px !important;} .slds-modal__content {height: auto !important;max-height: 100% !important;border-radius: 3px !important;padding: 0px !important;} .slds-modal__container {max-width: 100% !important;width: 80% !important;} .cuf-content {padding: 0px !important} .content-patient-chart {min-height: 300px !important}</style>"
                    },
                    function(auraHTML, status, errorMessage){
                        //Add the new button to the body array
                        if (status === "SUCCESS") {
                            var body = component.get("v.body");
                            body.push(auraHTML);
                            component.set("v.body", body);
                            console.log(component.get("v.body"));
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                            // Show offline error
                        }
                        else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                            // Show error message
                        }
                    }
                );
                
            } else {
                console.log("Failed to load Company Setting.");
            }
        });
        $A.enqueueAction(getSettingsAction);
        /*   cmp.set('v.mycolumns', [
           { label: "Date", fieldName: "Date", type: "date",typeAttributes:{ month: "2-digit", day: "2-digit" , year: "numeric"} },
            { label: 'Encounter ID', fieldName: 'eid', type: 'text'},
            { label: 'Reason', fieldName: 'reason', type: 'text'}
        ]);

            cmp.set('v.mydata', [{
                    id: 'a',
                    Date: '6/28/2021',
                    eid:'Enco-223',
                    reason: 'Pain in neck',
                },
                                 {
                    id: 'c',
                    Date: '7/23/2021',
                    eid:'Enco-222',
                    reason: 'Anxiety',
                },
                {
                   id: 'b',
                    Date: '8/05/2021',
                    eid: 'Enco-221',
                    reason: 'Pain',
            }]);*/
        
        //  helper.getLabels(component,event,helper);
        
    },
    
    generatePDF : function(component,event,helper){
        component.set("v.isOpen1", true);
    },
    
    gotoURL : function(component, event, helper) {
        var selectedRows = component.get("v.recId");
        var rowId = component.get("v.selectedRowId");
        console.log('for exportPDF row selected is '+JSON.stringify(selectedRows)); 
        console.log('for exportPDF row selected is '+JSON.stringify(rowId));

        let selectedFormsArray = component.get("v.lstOfCategoryvalues");
        let selectedForms = [];
        for(let rec in selectedFormsArray){
            if(selectedFormsArray[rec].valueForCAT){
                selectedForms.push(selectedFormsArray[rec].value);
            }
        }
        let customSettings = component.get("v.lstOfCustomSetting");
        let selectedUpperCategory = [];
        customSettings.forEach(function(record){
            if(record.valueForCB){
                selectedUpperCategory.push(record.value);
            }
        });
        console.log('value for form category '+selectedForms.join(';'));
        console.log('value for notes '+selectedUpperCategory.join(';'));
        var genPdf = component.get("c.generatePdf");
        
        console.log("gotoURL: careEpisodesSelected: ", component.get("v.careEpisodesSelected"));
        let careEpisodeIdsTmp = component.get("v.careEpisodesSelected").map(careEpisode => careEpisode.Id);
        console.log("gotoURL: careEpisodeIdsTmp: ", careEpisodeIdsTmp);
        let careEpisodeIds = [];
        if (careEpisodeIdsTmp) {
            for (let i of careEpisodeIdsTmp) {
                if (i) {
                    careEpisodeIds.push(i);
                }
            }
        }
        console.log('careEpisodeIds: ', careEpisodeIds);
            genPdf.setParams({episodeIds : careEpisodeIds,
            formAttributes : selectedForms.join(';'),
            otherAttributes : selectedUpperCategory.join(';')});
        genPdf.setCallback(this, function(response) {
            if (response !== null && response.getState() == 'SUCCESS') {        
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: 'Chart creation initiated. Please check the files section of Care Episode.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire(); 
                component.set("v.isOpen", false);
                $A.get("e.force:closeQuickAction").fire();
            } else {
                console.log("Failed PDF.");
            }
        });
        $A.enqueueAction(genPdf);
        // let selectedForms = 'NursingForms;Sleep_Physician_Notes;Dentists_Notes;Prescriptions';
        /*var url = '/apex/ElixirSuite__PatientChartPdfNew?caseId='+rowId+'&fBundle='+selectedForms.join(';');
        
        var newWindow;	
        newWindow = window.open(url);	
        newWindow.focus();*/
        
        // window.open("https://elixir-development-dev-ed--elixirhc.na112.visual.force.com/apex/PatientChartPdf?core.apexpages.request.devconsole=1");
    },


    handleGoToURL: function(component, helper, event) {
        try {
            let allSelectedCareEpisodes = component.get("v.careEpisodesSelected");
            console.log('care episodes: ', JSON.stringify(allSelectedCareEpisodes));

            if (allSelectedCareEpisodes && allSelectedCareEpisodes.length > 0) {
                // called from vists list view
                console.log("called from list view visits__c:");
                $A.enqueueAction(component.get("c.gotoURL"));
            }
            else {
                // Component called from record page, as required attribute is not set 
                console.log("we are called from record page");
            
                // Adding force:hasRecordId in component attribute gets recordId of record
                let careEpisodeId = component.get("v.recordId");
                component.set("v.selectedRowId", careEpisodeId);
                let allSelectedCareEpisodes = [{"Id":`${careEpisodeId}`}];
                component.set("v.careEpisodesSelected", allSelectedCareEpisodes);
                console.log("care episode id: ", careEpisodeId);
                console.log("allSelectedCareEpisodes: ", component.get("v.careEpisodesSelected"));

                $A.enqueueAction(component.get("c.gotoURL"));
            }
        } catch (error) {
            console.log("Error handleGotoURL: ", error.message);
        }
        
    }
})