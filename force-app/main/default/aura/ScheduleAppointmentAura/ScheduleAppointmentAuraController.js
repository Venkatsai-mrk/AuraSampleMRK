({
    doInit : function(component, event, helper) {
        // fetching accountId
        if(component.get("v.recordId")==""){
            var pageRef = component.get("v.pageReference");
            
            console.log(JSON.stringify(pageRef));
            console.log('line8***upd1');
            var state = pageRef.state; // state holds any query params
            
            console.log('state = '+JSON.stringify(state));
            // var accId = state.ElixirSuite__accountId;
            console.log('accountId = '+state.ElixirSuite__accountId);
            //  component.set("v.recordId", accId);
            var base64Context = state.ws;
            if(!$A.util.isUndefinedOrNull(base64Context)){
                console.log('base64Context = '+base64Context);
                var parts = base64Context.split('/'); 
                var recordId = parts[4];
                component.set("v.recordId", recordId);
                console.log("recordId page ref*** "+component.get("v.recordId"));
                
                console.log('url*****',component.get("v.url"));
                console.log('recordId****',component.get("v.recordId"));
            }else{
                var accId = state.ElixirSuite__accountId;
                console.log('accountId = '+state.ElixirSuite__accountId);
                component.set("v.recordId", accId); 
            }
        }
        var paramName = 'key';
        let value = helper.getUrlParameter(component, event, helper, paramName);
        component.set("v.route",value);
        console.log('route is',component.get("v.route"));
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            // console.log('afctab',focusedTabId);
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(){
                    
                });
                workspaceAPI.setTabLabel({
                    
                    label: "Schedule Appointment"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(){                 
                });
                workspaceAPI.setTabLabel({
                    label: "Schedule Appointment"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:collection_alt",
                iconAlt: "Schedule Appointment"
            });
        })
        var action1 = component.get("c.getUserInfo"); 
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var res = response.getReturnValue();
                if(res.IsPortalEnabled){
                    component.set("v.recordId",res.AccountId);
                    var portalAccountId = res.AccountId;
                    helper.getAccountTeamMember(component,portalAccountId,component.get("v.specialityId"),component.get("v.locationId"),component.get("v.genderVal"),component.get("v.filterVal"));
                    
                }
                else{
                    helper.getAccountTeamMember(component,component.get("v.recordId"),component.get("v.specialityId"),component.get("v.locationId"),component.get("v.genderVal"),component.get("v.filterVal"));
                }
            }
        });
        $A.enqueueAction(action1);
        helper.getColumnAndAction(component);
        
    },
    
    viewRecord: function(component, event) {
        
        var action = event.getParam('action');
        console.log('viewRecord*****action',action.name);
        
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        
        console.log('viewRecord*****action',action);
        
        var actName = action.name;
        
        var practName = event.getParams().row["pracName"];
        
        var locationName = event.getParams().row["provName"];
        
        var practId = event.getParams().row["practionerId"];
        
        var locationId = event.getParams().row["locationId"];
        
        var specialityName = event.getParams().row["specialityName"];
        
        console.log('specialityName',event.getParams().row["specialityName"]);
        component.set("v.practionerName", practName);
        component.set("v.locationName", locationName);
        component.set("v.practionerId", practId);
        component.set("v.locationId", locationId);
        component.set("v.startDateVal", today);
        component.set("v.specialityName", specialityName);
        
        if(actName=='recLink'){
            component.set("v.showAvail", true);
        }
        
        // Close the current subtab
        /*
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            workspaceAPI.closeTab({tabId: tabId});
        });
        */
    },
    
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    
    selectedRecord : function(component, event, helper){
        
        console.log('enter in selected record Appointment***');
        var message = event.getParam("lookUpData");
        var actStatus = event.getParam("actionStatus");
        var objName =  event.getParam("objectName");
        console.log('messageAppointment****',message);
        console.log('messageAppointment****objName',objName);
        
        var specId = component.get("v.specialityId");
        var locId = component.get("v.locationId");
        
        if(specId=='' && locId == ''){
            if(actStatus=='inserted' && objName=='ElixirSuite__Specialty__c'){
                
                component.set("v.specialityId", message);
                component.set("v.filterVal", 'Specialty');
                
            }
            
            
            else if(actStatus=='inserted' && objName=='ElixirSuite__Provider__c'){
                
                component.set("v.locationId", message);
                component.set("v.filterVal", 'Location');
                
            }
        }
        
        if(specId!='' && locId == '' && actStatus=='inserted' && objName=='ElixirSuite__Provider__c'){
            
            console.log('inside****locationnull');
            component.set("v.locationId", message);
            component.set("v.filterVal", 'SpecialityandLocation');
            
        }
        
        else if(specId=='' && locId != '' && actStatus=='inserted' && objName=='ElixirSuite__Specialty__c'){
            console.log('inside****specialitynull');
            component.set("v.specialityId", message);
            component.set("v.filterVal", 'SpecialityandLocation');
            
        }
        
        if(specId!='' && locId != ''){
            if(actStatus=='removed' && objName=='ElixirSuite__Specialty__c'){
                
                component.set("v.specialityId", message);
                component.set("v.filterVal", 'Location');
                
            }
            else if(actStatus=='removed' && objName=='ElixirSuite__Provider__c'){
                
                component.set("v.locationId", message);
                component.set("v.filterVal", 'Speciality');
                
            }
        }
        
        else if(specId!='' && locId == '' && actStatus=='removed' && objName=='ElixirSuite__Specialty__c'){
            
            component.set("v.specialityId", message);
            component.set("v.filterVal", '');
            
        }
        
            else if(specId=='' && locId != '' && actStatus=='removed' && objName=='ElixirSuite__Provider__c'){
                
                component.set("v.locationId", message);
                component.set("v.filterVal", '');
                
            }
        
        var filterValue = component.get("v.filterValue");
        
        if(filterValue=='existing'){
            
            helper.getAccountTeamMember(component, component.get("v.recordId"),component.get("v.specialityId"),component.get("v.locationId"),component.get("v.genderVal"),component.get("v.filterVal"));
        }
        else{
            console.log('speciality*****',component.get("v.specialityId"));
            console.log('filter*****',component.get("v.filterVal"));
            
            helper.getAllProviders(component, component.get("v.recordId"),component.get("v.specialityId"),component.get("v.locationId"),component.get("v.genderVal"),component.get("v.filterVal"));
        }
        
    },
    
    onFilterChange: function (component, event, helper) {
        
        var valueSelected = component.find('select').get('v.value');
        console.log('filter value: ',valueSelected);
        component.set("v.filterValue", valueSelected);
        
        if(valueSelected=='existing'){
            
            helper.getAccountTeamMember(component, component.get("v.recordId"),component.get("v.specialityId"),component.get("v.locationId"),component.get("v.genderVal"),component.get("v.filterVal"));
        }
        else{
            
            helper.getAllProviders(component, component.get("v.recordId"),component.get("v.specialityId"),component.get("v.locationId"),component.get("v.genderVal"),component.get("v.filterVal"));
        }
    },
    
    onGenderChange: function (component, event, helper) {
        
        var valueSelected;
        var selectedValue = component.find('genselect').get('v.value');
        console.log('gender value: ',selectedValue);
        if(selectedValue==='Male' || selectedValue==='Female' || selectedValue==='Unknown'){
            var genderMap = {
                'Male':'M',
                'Female':'F',
                'Unknown':'U'
            };
            var setvalue = genderMap[selectedValue];
            valueSelected = setvalue; 
        }else{
            valueSelected = selectedValue; 
        }
        var specId = component.get("v.specialityId");
        var locId = component.get("v.locationId");
        console.log('specId--'+specId);
        console.log('locId--'+locId);
        if(valueSelected == 'None'){
            
            if(specId=='' && locId == ''){
                
                component.set("v.genderVal", '');
                component.set("v.filterVal", '');
                
            }
            
            if(specId!='' && locId == ''){
                
                component.set("v.genderVal", '');
                component.set("v.filterVal", 'Speciality');
                
            }
            else if(specId=='' && locId != ''){
                
                component.set("v.genderVal", '');
                component.set("v.filterVal", 'Location');
            }
            
            if(specId!='' && locId != ''){
                
                component.set("v.genderVal", '');
                component.set("v.filterVal", 'SpecialityandLocation');
                
            }
            
        }
        
        else{
            
            if(specId=='' && locId == ''){
                
                component.set("v.genderVal", valueSelected);
                component.set("v.filterVal", 'Gender');
                
            }
            
            if(specId!='' && locId == ''){
                
                component.set("v.genderVal", valueSelected);
                component.set("v.filterVal", 'GenderplusSpeciality');
                
            }
            else if(specId=='' && locId != ''){
                
                component.set("v.genderVal", valueSelected);
                component.set("v.filterVal", 'GenderplusLocation');
            }
            
            if(specId!='' && locId != ''){
                
                component.set("v.genderVal", valueSelected);
                component.set("v.filterVal", 'GenderplusBoth');
                
            }
        }
        
        var filterValue = component.get("v.filterValue");
        
        if(filterValue=='existing'){
            
            helper.getAccountTeamMember(component, component.get("v.recordId"),component.get("v.specialityId"),component.get("v.locationId"),component.get("v.genderVal"),component.get("v.filterVal"));
        }
        else{
            console.log('speciality*****',component.get("v.specialityId"));
            console.log('filter*****',component.get("v.filterVal"));
            
            helper.getAllProviders(component, component.get("v.recordId"),component.get("v.specialityId"),component.get("v.locationId"),component.get("v.genderVal"),component.get("v.filterVal"));
        }
        
    },
    
    selectedRows: function(component, event) {
        
        var selectedRows =  event.getParam('selectedRows');
        
        console.log('selectedRows',selectedRows.length);
        
        if (selectedRows.length == 1) {
            component.set("v.isShowAvail", false);
            
        } else {
            component.set("v.isShowAvail", true);
        }
    },
    handleNext : function(component, event, helper) { 
        component.set("v.pageNumber", component.get("v.pageNumber") + 1);
        helper.setPaginateData(component);
        
        
        /*  var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber+1);
        var filterValue = component.get("v.filterValue");
        
        if(filterValue=='existing'){
            helper.getAccountTeamMember(component, component.get("v.recordId"),component.get("v.specialityId"),component.get("v.locationId"),component.get("v.genderVal"),component.get("v.filterVal"));
        }
        else{
            
            helper.getAllProviders(component, component.get("v.recordId"));
        }*/
     },
    
    handlePrev : function(component, event, helper) {  
        component.set("v.pageNumber", component.get("v.pageNumber") - 1);
        helper.setPaginateData(component);
        
        /*   var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber-1);
        var filterValue = component.get("v.filterValue");
        
        if(filterValue=='existing'){
            helper.getAccountTeamMember(component, component.get("v.recordId"),component.get("v.specialityId"),component.get("v.locationId"),component.get("v.genderVal"),component.get("v.filterVal"));
        }
        else{
            
            helper.getAllProviders(component, component.get("v.recordId"));
        }*/
    },
    
    navToAccRecord: function(component) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },
    navToListView: function() {
        // Sets the route to /lightning/o/Account/home
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/Account/home'
        });
        urlEvent.fire();
    },
    fetchFilteredList: function(component){
        component.find("Id_spinner").set("v.class" , 'slds-show');
        let parentData = component.get("v.parentData");
        let searchKeyword = component.get("v.searchKeyword");
        //let listDetails =  component.get("v.data");
        console.log('parentData1111***',parentData);
        if(parentData!=null){
            
            var fillData = parentData.filter(function(dat) {
                return (dat.Name.toLowerCase()).includes(searchKeyword.toLowerCase());
            });
            console.log('fillData****',fillData.length);
            if(fillData.length>0){
                component.set("v.recordsAvailable", true);
                for (var i = 0; i < fillData.length; i++) {
                    var row = fillData[i];
                    row.sno = i+1;
                }
                component.set("v.data",fillData);
                component.find("Id_spinner").set("v.class" , 'slds-hide');
            }
            else{
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                component.set("v.recordsAvailable", false);
                
            }
        }
        else{
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            component.set("v.recordsAvailable", false);
        }
    },
    handleBack: function(component) {
        var redirectUrl = '/lightning/r/Account/' + component.get("v.recordId") + '/related/OpenActivities/view?ws=%2Flightning%2Fr%2FAccount%2F' + component.get("v.recordId") + '%2Fview';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": redirectUrl,
            "isredirect": true
        });
        urlEvent.fire();
    },
})