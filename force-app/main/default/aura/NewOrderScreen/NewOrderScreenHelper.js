({
	navToListView: function (component, event, helper) {

                    var relatedListEvent = $A.get("e.force:navigateToRelatedList");
                    relatedListEvent.setParams({
                        "relatedListId": "ElixirSuite__Orders__r",
                        "parentRecordId": component.get("v.recordId")
                    });
                    relatedListEvent.fire();
                window.setTimeout($A.getCallback(function() {
                    window.location.reload();
                }), 300);
              }
})