({
    handleClick : function(component, event, helper) {
        var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
        appEvent.setParams({
            "screenType" : "Medication" });
        appEvent.fire();
    }
})