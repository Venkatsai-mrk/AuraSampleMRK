({
    sendToVF : function(component, event, helper) {
        alert('vf loaded'); 
        var message = '{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}';
        var vfOrigin = "https://" + component.get("v.vfHost");
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(message, vfOrigin); 
    },
    
    doInit : function(cmp, event, helper) {
        try{
            var workspaceAPI = cmp.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                // var focusedTabId = response.tabId;
                // console.log('afcresponse',response);
                var focusedTabId = response.tabId;
                var issubTab = response.isSubtab;
                console.log('afctab',focusedTabId);
                if(issubTab)
                {
                    workspaceAPI.getTabInfo(
                        { tabId:focusedTabId}
                    ).then(function(response1){
                        
                        console.log('afctabinfo',response1);
                    });
                    workspaceAPI.setTabLabel({
                        
                        label: "VOB Details"
                    });                
                }
                else 
                { 
                    workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                        console.log('afctabinfo----',response1);
                    });
                    workspaceAPI.setTabLabel({
                        label: "VOB Details"
                    });         
                }     
                
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "utility:answer",
                    iconAlt: "VOB Details"
                });
            })
            
            
            
        }
        catch(e){
            alert('error '+e);
        }
        
        var action = cmp.get("c.checkValidDetails");
        action.setParams({
            'vobId' : cmp.get("v.recordId")
        });
        action.setCallback(this,function(resp){
            if(resp.getState() == 'SUCCESS')
            {
                if(resp.getReturnValue() != null)
                {
                    var wrapRes = resp.getReturnValue();
                    console.log('wrapRes : ');
                    console.log('TestString',wrapRes);
                    if(wrapRes.msgState == 'Success')
                    {
                        cmp.set("v.VOB",wrapRes.vob);
                        cmp.set("v.benefitTypeCode",wrapRes.vob.ElixirSuite__Benefit__c);
                        
                        cmp.set("v.patRelCode",wrapRes.patRelationCode);
                        var vobRec1 = cmp.get("v.VOB");
                        //  alert(JSON.stringify(vobRec1));
                        var innerAction = cmp.get("c.getPatientData");
                        innerAction.setParams({
                            'vobRec' : wrapRes.vob,
                            'patRelationCode' : wrapRes.patRelationCode
                        });
                        innerAction.setCallback(this,function(innerResp){
                            
                            var mapVobFields = new Map();
                            var vobRec = cmp.get("v.VOB");
                            console.log('vobRec--:');
                            console.log(JSON.stringify(vobRec));
                            var isActive = false;
                            var result = new Map();
                            
                            if(innerResp.getState() == 'SUCCESS')
                            {
                                let parentJSON = {'vobRecordID' : cmp.get("v.recordId"), 
                                                  'response' : innerResp.getReturnValue().jsonResp};
                                console.log('data stringified '+JSON.stringify(innerResp.getReturnValue().blobJSON));
                                console.log('data not '+innerResp.getReturnValue().jsonResp);
                                console.log('Tan '+JSON.stringify(innerResp.getReturnValue()));
                                console.log('undergroun '+JSON.stringify(innerResp.getReturnValue()));
                                cmp.set("v.message",parentJSON);
                                /**************LIGHTNING MESSAGE SERVICE PAYLOAD********************/
                                var payload = {
                                    recordId: "some string",
                                    recordData: {
                                        value:parentJSON
                                    }
                                };
                                
                                cmp.find("sampleMessageChannel").publish(payload);
                                /*******************************************************************/
                                /* alert('vf loading start '+JSON.stringify(cmp.get("v.message"))); 
                                //   var message = '{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}{"jsonResp":"{\"result\":{\"error\":{\"error_code\": \"430\",\"error_mesg\": \"Provider NPI [1922678689] has not been configured in Claim.MD.\"}}}","vobFieldsMap":{"c#fam#Y":"Deductible_Family_In_Plan_Network__c","c#ind#Y":"Deductible_Individual_In_Plan_Network__c","g#ind#N":"out_of_network_outOfPocket_total__c","c#ind#N":"Deductible_Individual_Out_Plan_Network__c","g#fam#Y":"in_network_outOfPocket_family_total__c","b#ind#Y":"Co_Payment_In_Plan_Network__c","a#ind#Y":"Co_Insurance_In_Plan_Network__c","g#fam#N":"outOfPocketFamily_total__c","a#ind#N":"Co_Insurance_Out_Of_Plan_Network__c","g#ind#Y":"in_network_outOfPocket_total_Individual__c","c#fam#N":"Deductible_Family_Out_Of_Plan_Network__c","b#ind#N":"Co_Payment_Out_Of_Plan_Network__c"}';
                                var vfOrigin = "https://" + cmp.get("v.vfHost");
                                var vfWindow = cmp.find("vfFrame").getElement().contentWindow;
                                vfWindow.postMessage(cmp.get("v.message"), vfOrigin);
                                var obj = JSON.parse(innerResp.getReturnValue().jsonResp); */
                                
                                
                            }else{
                                let error = innerResp.getError();
                                let message = 'Unknown error'; // Default error message
                                // Retrieve the error message sent by the server   
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Error",
                                    "message": error[0].message,
                                    "type" : "error",
                                    "mode" : "dismissible"
                                });
                                toastEvent.fire();
                            }
                        });
                        $A.enqueueAction(innerAction);
                    }
                    else if(wrapRes.msgState == 'Error')
                    {
                        cmp.set("v.VOB",wrapRes.vob);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": wrapRes.msgStr,
                            "type" : "error",
                            "mode" : "dismissible"
                        });
                        toastEvent.fire();
                    }
                }
            }
            
            
        });
        $A.enqueueAction(action);
        
        
    }   
    
})