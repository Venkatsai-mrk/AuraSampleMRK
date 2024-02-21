({
    init : function(component, event, helper) {
        helper.fetchAccountName(component, event, helper);
        console.log('application event passed');
       component.find("select").set("v.value", component.get("v.filterVal"));
        console.log("filter value"+component.get("v.filterVal"));
        component.get("v.filterVal")
        component.set("v.loaded",false); 
        component.set("v.loaded",true);
       console.log(component.get("v.recordId")+' patient id in custom listview');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            // console.log('afctab',focusedTabId);
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(response1){
                    
                });
                workspaceAPI.setTabLabel({
                    
                    label: "Message Centre"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Message Centre"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:collection_alt",
                iconAlt: "Message Centre"
            });
        })

        let toAddCol = [];

        toAddCol.push({ label: 'Name',
        fieldName: 'Name',
        type: 'button' ,typeAttributes:  {label: { fieldName: 'Name' }, target: '_blank' , name: 'recLink',variant:'Base' } });

        toAddCol.push({ label: 'Subject', fieldName: 'ElixirSuite__Subject__c', type: 'text',sortable: true });
        
        toAddCol.push({
            label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true,
            typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true }
        });
        toAddCol.push({ label: 'Sender', fieldName: 'CreatedBy', type: 'text',sortable: true });

        component.set('v.columns', toAddCol);

      // helper.fetchRecords( component, event, component.get("v.patientID") );
        helper.getTotalInitRecords(component, event, helper);
     // helper.getData(component, event, helper);



    },
   refreshMethod: function (component, event, helper) {
       // component.find("select").set("v.value", 'Inbox');
       // var filter = 'Inbox';
         var filter = component.get("v.filterVal");
     component.set("v.filterVal", filter);
      component.set("v.loaded",true);
    	component.set('v.enableInfiniteLoading', true);
        component.set("v.initialRows",5);
        component.set("v.currentCount",0);
     	component.set("v.totalNumberOfRows",0);
     	component.set("v.rowNumberOffset",0);
        helper.getTotalRecords(component, event, helper);
    
    },
    
   loadMoreData: function (component, event, helper) {
        helper.getData(component, event, helper);
    
    },

 onSelectChange : function(component, event, helper){
        component.set("v.loaded",true);
      //  alert(cmp.find('select').get('v.value') + ' pie is good.');
        component.set('v.enableInfiniteLoading', true);
        var selVal  = component.find('select').get('v.value');
        console.log('selected value: ',selVal);
        component.set("v.filterVal", selVal);
     	component.set("v.initialRows",5);
         component.set("v.currentCount",0);
     	component.set("v.totalNumberOfRows",0);
     	component.set("v.rowNumberOffset",0);
        
    // helper.filterListView(component, event, helper);//added by Anmol
     helper.getTotalRecords(component, event, helper);
    },
    
    navToAccRecord: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.patientID")
        });
        navEvt.fire();
    },

    viewRecord: function(component, event, helper) {
    console.log(component.get("v.patientID"));
    var action = event.getParam('action');
    var row = event.getParam('row');
    console.log('viewRecord*****action',action);
    console.log('viewRecord*****row',row.Id);

    var msgId = row.Id;

    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        componentDef:"c:ActualMsgCmpAura",
        componentAttributes: {
            recordId : msgId,
            isShowModal : true,
            patientId: component.get("v.patientID"),
            filterValue: component.get("v.filterVal")
        }
    });
    evt.fire(); 

    // Close the current subtab
    var workspaceAPI = component.find("workspace");
    workspaceAPI.getEnclosingTabId().then(function(tabId) {
        workspaceAPI.closeTab({tabId: tabId});
    });
}
,

    navToListView: function(component, event, helper) {
        // Sets the route to /lightning/o/Account/home
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/Account/home'
        });
        urlEvent.fire();
    },

    archMsg : function(component, event, helper){
        console.log('archMsg is called');
        var filter = 'Archived';
        component.set("v.filterVal", filter);
        helper.filterListView(component, event, helper);//added by Anmol

    },
     onChange1 : function(component, event, helper) {
          component.set("v.loaded",true);
          component.set('v.enableInfiniteLoading', true);
          var selectedVal = component.find('searchField').get('v.value');
        console.log('selectedVal'+selectedVal);
	   component.set("v.searchKeyword", selectedVal);
         var allDataMessaging=component.get("v.Originaldata");
         component.set("v.initialRows",5);
         component.set("v.currentCount",0);
     	component.set("v.totalNumberOfRows",0);
     	component.set("v.rowNumberOffset",0);
        helper.getTotalRecords(component, event, helper);
          //helper.filterListView(component, event, helper);
         },
   
    handleKeyUp: function(component, event, helper) {
        
       var selectedVal = component.find('searchField').get('v.value');
       console.log('selectedVal'+selectedVal);
	   component.set("v.searchKeyword", selectedVal);
         var allDataMessaging=component.get("v.Originaldata");
         component.set('v.enableInfiniteLoading', true);
          component.set("v.loaded",true);
         
        var isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
          
            component.set("v.initialRows",5);
         component.set("v.currentCount",0);
     	component.set("v.totalNumberOfRows",0);
     	component.set("v.rowNumberOffset",0);
        helper.getTotalRecords(component, event, helper);   
        }
        
        
    },
     handleClear: function(component, event, helper) {
        component.set("v.searchKeyword"," ");
          component.set("v.initialRows",5);
         component.set("v.currentCount",0);
     	component.set("v.totalNumberOfRows",0);
     	component.set("v.rowNumberOffset",0);
        helper.getTotalRecords(component, event, helper);  
     },
    /*onChange1: function (component, event, helper) {
       var selectedVal = component.find('searchField').get('v.value');
        console.log('selectedVal'+selectedVal);
	   component.set("v.searchKeyword", selectedVal);
      // helper.searchHelper(component, event);
        helper.filterData(component, event, helper);
    },*/

    bookmarkMsg : function(component, event, helper){

        var filter = 'Bookmark';
        component.set("v.filterVal", filter);
        helper.filterListView(component, event, helper);//added by Anmol

    },

    allMsg : function(component, event, helper){

        var filter = 'AllMsg';
        component.set("v.filterVal", filter);
        helper.filterListView(component, event, helper);//added by Anmol

    },


    newMessage : function(component, event, helper){
        component.set("v.newMessage",true);
        //component.set("v.patientID",component.get("v.recordId"));
        
    },
    handleSort : function(component, event, helper){
        var sortBy = event.getParam("fieldName");       
        var sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        
        helper.sortData(component,sortBy,sortDirection);
    }
})