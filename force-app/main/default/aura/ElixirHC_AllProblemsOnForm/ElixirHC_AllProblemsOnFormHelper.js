({
    SearchHelper: function(component,event) {
        var masterListForSearchHelper = component.get("v.problem");
        var allData = component.get('v.allOptions');         
        var searchKeyWord = component.get("v.searchKeyword");
        var fillData = allData.relatedDiagnoses.filter(function(dat) {               
            return (dat.ElixirSuite__Diagnosis_Code_and_Name__c.toLowerCase()).startsWith(searchKeyWord.toLowerCase());
        });
        masterListForSearchHelper.relatedDiagnoses = fillData;
        component.set("v.problem", masterListForSearchHelper);
        if(!$A.util.isEmpty(fillData)){
            component.set("v.isSearchInAction", true);  
             component.set("v.descriptionTag", 'SELECT RELATED DIAGNOSES : ');
        }
        else {
            component.set("v.isSearchInAction", false);
              component.set("v.descriptionTag", '');
        }
        
        
        
    },
})