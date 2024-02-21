({
  initMovedToHelper: function(component, event, helper) {
    helper.fetchAccountName(component, event, helper) ;
    
    //component.set("v.LabOrders",true);
    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function(response) {
      // var focusedTabId = response.tabId;
      // console.log('afcresponse',response);
      var focusedTabId = response.tabId;
      var issubTab = response.isSubtab;
      console.log('afctab--------------',component.get("v.nameSpace"));
      if (issubTab) {
        workspaceAPI
          .getTabInfo({ tabId: focusedTabId })
          .then(function() {
            //console.log('afctabinfo',response1);
          });
        workspaceAPI.setTabLabel({
          label: "Lab Orders"
        });
      } else {
        workspaceAPI
          .getTabInfo({ tabId: response.subtabs[0].tabId })
          .then(function() {
            //console.log('afctabinfo',response1);
          });
        workspaceAPI.setTabLabel({
          label: "Lab Orders"
        });
      }
      workspaceAPI.setTabIcon({
        tabId: focusedTabId,
        icon: "utility:variable",
        iconAlt: "Lab Order"
      });
    });

    var action = component.get("c.getRelatedLabOrder");
    action.setParams({ patient: component.get("v.patientID") });
    //debugger;

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("form data " + JSON.stringify(response.getReturnValue()));
        var records = response.getReturnValue().labOrders;
        let numberOfApprovalLevels = response.getReturnValue().totalApprovalLevels;

        // start setting approval icons and text(NA)
        let approvalMetaData = [
          { level: 1, field: 'ElixirSuite__Date_Of_Approval_1__c', iconField: 'iconApprovalLevel1', textField: 'textApprovalLevel1' },
          { level: 2, field: 'ElixirSuite__Date_Of_Approval_2__c', iconField: 'iconApprovalLevel2', textField: 'textApprovalLevel2'},
          { level: 3, field: 'ElixirSuite__Date_Of_Approval_3__c', iconField: 'iconApprovalLevel3', textField: 'textApprovalLevel3'},
        ];

        for (const i of approvalMetaData) {
          for (const labOrder of records) {
            if (labOrder[i.field]) {
              labOrder[i.iconField] = "utility:check";
            } 
            else if (i.level <= numberOfApprovalLevels) {
              labOrder[i.iconField] = "utility:close";
            }
            else {
              labOrder[i.textField] = "NA";
            }
          }
        }
        // end setting approval icons and text(NA)

        // adding static columns
        var actions = [
          { label: "EDIT", name: "EDIT" },
          { label: "DELETE", name: "DELETE" }
        ];
        var nameSpace = "ElixirSuite__";
        component.set("v.mycolumns", [
          {
            label: "Lab Order",
            fieldName: "Name",
            type: "button",
            typeAttributes: {
              label: { fieldName: "Name" },
              target: "_blank",
              name: "recLink",
              variant: "Base"
            }
          },
          {
            label: "Medical Test",
            fieldName: nameSpace + "Medical_Test__c",
            type: "text",
            sortable: true
          },
          {
            label: "Start Date",
            fieldName: nameSpace + "Start_Date__c",
            type: "Date",
            sortable: true
          },
          {
            label: "Last Modified Date",
            fieldName: "LastModifiedDate",
            type: "Date",
            sortable: true
          },
          {
            label: "Status",
            fieldName: nameSpace + "Status__c",
            type: "text",
            sortable: true
          },
          {
            label: "Lab Result",
            fieldName: "LabResult",
            type: "button",
            typeAttributes: {
              label: { fieldName: "LabResult" },
              disabled: { fieldName: "isActive" },
              target: "_blank",
              name: "recLinklab",
              variant: "Base"
            }
          },
          /*{
                fieldName: nameSpace + "On_Admission__c",
                label: "On Admission",
                type: "boolean",
                cellAttributes: {
                iconName: {
                fieldName: nameSpace + "On_Admission__c"
                },
                iconPosition: "left"
                }
             },*/
          {
            fieldName: "Actions",
            type: "action",
            typeAttributes: { rowActions: actions }
          }
        ]);

        // start setting configurable columns
        let columnsAvailable = [
          { label: "Approval Level 1", value: "approvalLevel1" },
          { label: "Approval Level 2", value: "approvalLevel2" },
          { label: "Approval Level 3", value: "approvalLevel3" }
        ];
        component.set("v.columnsAvailable", columnsAvailable);
        let columnsSelected = [];

        let configurableColumns = {
          "approvalLevel1": {
            label: "Approval Level 1",
            fieldName: "textApprovalLevel1",
            cellAttributes: { iconName: { fieldName: 'iconApprovalLevel1' }, class: 'approvalIcon' }
          },

          "approvalLevel2": {
              label: "Approval Level 2",
              fieldName: "textApprovalLevel2",
              cellAttributes: { iconName: { fieldName: 'iconApprovalLevel2' }, class: 'approvalIcon' }
          },

          "approvalLevel3": {
              label: "Approval Level 3",
              fieldName: "textApprovalLevel3",
              cellAttributes: { iconName: { fieldName: 'iconApprovalLevel3' }, class: 'approvalIcon' }
          }
        };

        try {
          let columnsToShow = response.getReturnValue().columns;

          let currentColumns = component.get("v.mycolumns");
          for (const i of columnsToShow) {
            currentColumns.splice(currentColumns.length - 1, 0, configurableColumns[i]);
            columnsSelected.push(i);
          }

          component.set("v.mycolumns", currentColumns);
          component.set("v.columnsSelected", columnsSelected);
          component.set("v.columnsSelectedCleanCopy", columnsSelected);
        } catch (error) {
          console.log("error adding configurable columns-");
          console.error(error);
        }

        // end setting configurable columns

        var nameSpace = "ElixirSuite__";
        /* records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });*/
        for (var rec in records) {
          records[rec].LastModifiedDate = records[
            rec
          ].LastModifiedDate.substring(0, 10);
          records[rec]["LabResult"] = "Lab Result";
          records[rec]["isActive"] = true;
        }

        records.forEach(function(record) {
          if (typeof record.Id != "undefined") {
            if (
              record[nameSpace + "Status__c"] == "Sent To Lab" ||
              record[nameSpace + "Status__c"] == "Result Received"
            ) {
              record.isActive = false;
            }
          }
        });
        component.set("v.data", records);
        // console.log('final ' + JSON.stringify(res));
        component.set("v.listDetails", records.formData);
        //  component.set("v.data",res);
      }
    });
    $A.enqueueAction(action);
  },

  //Added by Ashwini
  fetchAccountName:function(component){
    var action = component.get("c.fetchAccountName");
       action.setParams({ accountId : component.get("v.patientID") });
       action.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               
               console.log('Patient name  data '+JSON.stringify(response.getReturnValue()));                
               var records =response.getReturnValue();
               component.set("v.accName", records);
               
           }
       
        });
       
       $A.enqueueAction(action);
   },
   //End
    /***Nikhil-----****/
    checkCareEpisodehelper: function(component, event, helper, patientId) {
        var action = component.get("c.checkCareEpisode");
        action.setParams({
            patientId: patientId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var returnval = response.getReturnValue();
                
                if (returnval == true) {
                    component.set("v.careModal", true);
                } else {
                    component.set("v.labOrderNew",true);
                /*var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:ElixirHC_LabOrder",
                        componentAttributes: {
                            AcctIden: patientId,
                            popFlag: true,
                            isOpen:true
                        }
                    });
                    evt.fire();*/
                }
            }
        });
        $A.enqueueAction(action);
    },

  downloadDocument: function(component) {
    var sendDataProc = component.get("v.sendData");
    var dataToSend = {
      label: "This is test"
    }; //this is data you want to send for PDF generation

    //invoke vf page js method
    sendDataProc(dataToSend, function() {
      //handle callback
    });
  },
  deleteSelectedHelper: function(component, event, selectedIds) {
    var action = component.get("c.deleteRecords");
    action.setParams({
      lstRecordId: selectedIds
    });
    console.log("****Id****", selectedIds);
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          title: "PROCEDURE REQUEST(S) DELETED SUCCESSFULLY!",
          message: "Deletion Successfull!"
        });
        toastEvent.fire();

        component.set("v.isOpen", false);
        $A.get("e.force:refreshView").fire();
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "error",
          title: "PROCEDURE REQUEST INSERTION FAILED!",
          message: "Failed!"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },
  updateSelectedHelper: function(component, event, selectedIds) {
    var action = component.get("c.updateRecords");
    action.setParams({
      lstRecordId: selectedIds
    });
    console.log("****Id****", selectedIds);
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          title: "Lab test has been successfully sent to the Lab",
          message: "Successfully sent"
        });
        toastEvent.fire();

        component.set("v.isOpen", false);
        $A.get("e.force:refreshView").fire();
      }
    });
    $A.enqueueAction(action);
  },

  getLabResults: function(component, event, articleName, resultName) {
    console.log("fghjkiu", articleName + resultName);

    var evt = $A.get("e.Elixir_HC:labOtherTestEvent");
    var open = new Boolean(1);
    evt.setParams({
      isOpen: open,
      resultName: resultName
    });
    evt.fire();
  },
  redirectToSobject: function(component) {
    console.log("9ij");
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: component.get("v.recordId")
    });
    navEvt.fire();
  }
});