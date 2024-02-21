({
  searchHelper: function (component, event, getInputkeyWord) {
    // call the apex class method 
    var action = component.get("c.fetchSingleLookUpValue1");
    // set param to method  
    var starting;
    var ending;
    if (component.get("v.AllDayEvent") === true) {
      starting = component.get("v.SelectedStartDate");
      ending = component.get("v.SelectedEndDate");
    } else {
      starting = component.get("v.SelectedStartTime");
      ending = component.get("v.SelectedEndTime");
    }
    console.log('starting', component.get("v.EuipIdLst"));
    action.setParams({
      'searchKeyWord': getInputkeyWord,
      'ObjectName': component.get("v.objectAPIName"),
      'locationObj': component.get("v.selectedRecordOfLocation"),
      'ExcludeitemsList': JSON.stringify(component.get("v.EuipIdLst")),
      'startt': starting,
      'endt': ending
    });
    // set a callBack    
    action.setCallback(this, function (response) {
      $A.util.removeClass(component.find("mySpinner"), "slds-show");
      var state = response.getState();
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
        if (storeResponse.length == 0) {
          component.set("v.Message", 'No Result Found...');
        } else {
          component.set("v.Message", '');
        }
        // set searchResult list with return value from server.
        component.set("v.listOfSearchRecords", storeResponse);

      }

    });
    // enqueue the Action  
    $A.enqueueAction(action);

  },
})