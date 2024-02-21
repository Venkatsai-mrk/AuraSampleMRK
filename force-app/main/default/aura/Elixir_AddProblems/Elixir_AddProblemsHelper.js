({
	search: function(component) {
        // Search term
        var term = component.get("v.term");
        // Show all when no filter, or when filter matches label or value
        component.set("v.options",
                      component.get("v.allOptions")
                      .filter(
                          item => !term || 
                          item.label.toLowerCase().startsWith(term.toLowerCase())))
    }
})