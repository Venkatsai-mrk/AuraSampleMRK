({
	search: function(component) {
        // Search term
        var term = component.get("v.termInt");
        // Show all when no filter, or when filter matches label or value
        component.set("v.optionsInt",
                      component.get("v.allOptionsInt")
                      .filter(
                          item => !term || 
                          item.label.toLowerCase().startsWith(term.toLowerCase())))
    }
})