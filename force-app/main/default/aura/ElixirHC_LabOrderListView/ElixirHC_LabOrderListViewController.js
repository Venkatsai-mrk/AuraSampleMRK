({
  doInit: function(component, event, helper) {
    helper.initMovedToHelper(component, event, helper);
  },
  
  selectedRows: function(component, event) {
    console.log(
      "seleceted rows" + JSON.stringify(event.getParam("selectedRows"))
    );
    console.log("all rows " + JSON.stringify(component.get("v.selectedRows")));
    component.set("v.selectedLabOrders", event.getParam("selectedRows"));
    //  var selectedRows = component.get('v.selectedRows');
    var selectedRows = event.getParam("selectedRows");
    if (selectedRows.length >= 1) {
      component.set("v.showDeleteButton", true);
    } else {
      component.set("v.showDeleteButton", false);
    }
  },
  handleRowAction: function(component, event) {
    var nameSpace = "ElixirSuite__";
    var action = event.getParam("action");
    console.log(action.name);
    var row = event.getParam("row");
    component.set("v.RowId", row.Id);
    console.log("row is 99 " + JSON.stringify(row.Id));
    component.set("v.SelectedRec", row);
    // component.set("v.PresId",event.getParams().row["Id"]);
    console.log("row3456 " + JSON.stringify(component.get("v.PresId")));

    switch (action.name) {
      case "EDIT":
        var getStatus = row[nameSpace + "Status__c"];
        debugger;
        if (getStatus == "Approved") {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "info",
            title: "CANNOT EDIT LAB ORDER AFTER IT HAS BEEN APPROVED!",
            message: "Lab Order is in Approved state!"
          });
          toastEvent.fire();
        } else {
          component.set("v.isEnabledEditButton", false);
          component.set("v.editScreenDisabled", false);
          component.set("v.editScreen", true);
          console.log(
            "Lab Order Id" + JSON.stringify(component.get("v.RowId"))
          );
        }

        break;

      case "recLink":
        component.set("v.isEnabledEditButton", false);
        component.set("v.editScreenDisabled", true);
        component.set("v.editScreen", true);
        // console.log('Lab Order Id'+JSON.stringify(component.get("v.RowId")));
        break;

      case "recLinklab":
        // helper.getLabResults(component,event,'articleNew','Lab Result');
        // helper.redirectToSobject(component, event, helper);
        component.set("v.labresult", true);
        console.log(component.get("v.labresult"));
        break;

      case "DELETE":
        component.set("v.showConfirmDialog", true);
        break;
    }
  },
  handleClick: function(component, event, helper) {
    helper.checkCareEpisodehelper(component,event,helper,component.get("v.patientID")); //NK----LX3-5932
    //  component.set("v.openNewForm",true);
  },
  handleConfirmDialogNo: function(component) {
    component.set("v.showConfirmDialog", false);
  },
  handleConfirmDialogYes: function(component) {
    // alert(component.get("v.RowId"));
    var action = component.get("c.deleteLabOrderRecord");
    action.setParams({ recordToDelete: component.get("v.RowId") });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          title: "RECORD DELETED SUCCESSFULLY!",
          message: "Deletion Successfull!"
        });
        toastEvent.fire();
        component.set("v.isOpen", false);
        $A.get("e.force:refreshView").fire();
        //  component.set("v.data",res);
      }
    });
    $A.enqueueAction(action);
  },
  deleteSelectedRows: function(component, event, helper) {
    var selectedRows = component.get("v.selectedLabOrders");
    console.log("Lab Order Id" + JSON.stringify(selectedRows));
    var selectedIds = [];
    for (var i = 0; i < selectedRows.length; i++) {
      selectedIds.push(selectedRows[i].Id);
    }
    helper.deleteSelectedHelper(component, event, selectedIds);
  },

  updateSelectedRows: function(component, event, helper) {
    var selectedRows = component.get("v.selectedLabOrders");
    console.log("Lab Order Id" + JSON.stringify(selectedRows));
    var selectedIds = [];
    for (var i = 0; i < selectedRows.length; i++) {
      selectedIds.push(selectedRows[i].Id);
    }
    helper.updateSelectedHelper(component, event, selectedIds);
  },
  handleChange: function(cmp, event) {
    var changeValue = event.getParam("value");
    //alert(changeValue);
    if (changeValue == "Lab Orders") {
      cmp.set("v.LabOrders", true);
      cmp.set("v.heading", "Lab Orders");
      cmp.set("v.UrineAnalysis", false);
      $A.get('e.force:refreshView').fire(); 
    } else if (changeValue == "Urine Analysis") {
      cmp.set("v.UrineAnalysis", true);
      cmp.set("v.heading", "Urine Analysis");
      cmp.set("v.LabOrders", false);
    }
  },
  //Added by Ashwini//
  navToListView: function() {
    // Sets the route to /lightning/o/Account/home
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url": '/lightning/o/Account/home'
    });
    urlEvent.fire();
    },
    navToAccRecord: function(component) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.patientID")
        });
        navEvt.fire();
    },
    //End
	
  parentComponentEvent: function(component) {
    // alert('hi');
    component.set("v.UrineAnalysis", true);
  },

  configureColumns: function(component) {
    component.set("v.columnsSelected", component.get("v.columnsSelectedCleanCopy"));
    component.set("v.showColumnConfiguration", !component.get("v.showColumnConfiguration"));
  },

  saveColumns: function(component, event, helper) {
    console.log('saving: ', component.get('v.columnsSelected').join(';'));
    let action = component.get("c.saveColumnsApex");
    action.setParams({'columnsText':component.get('v.columnsSelected').join(';')});
    action.setCallback(this, function () {
      component.set("v.showColumnConfiguration", false);
      console.log('updated columns');
      helper.initMovedToHelper(component, event, helper);
    });

    $A.enqueueAction(action);
  }
});