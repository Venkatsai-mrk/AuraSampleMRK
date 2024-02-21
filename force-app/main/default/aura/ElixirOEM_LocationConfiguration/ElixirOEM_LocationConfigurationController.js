({
    doInit: function(component, event, helper) {       
        helper.initHelperCallback(component, event, helper);
    },
    onRender : function(component, event, helper) {
        alert('after re render start');
        component.set("v.tabs", component.get("v.tabs"));
        alert('after re render comploete');
    },
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    onTabChange : function(component, event, helper) {
        
    },
    handleSelect :  function(component, event, helper) {
       
            var tabArray = component.get("v.tabs");
            var tab = event.getSource();
            var index;
            var tabIndex = component.get("v.selTabId");
            tabIndex.toString();
            if(tabIndex.includes(';')){
                index = 0;
            }
            else {
                index = parseInt(tabIndex);
            }
            component.set("v.index",index);
            
            index-=1;
            tabArray[index].isOpen = true;
            for(let rec in tabArray){
                let indexStringified = index.toString();
                if(rec!=indexStringified){
                    tabArray[rec].isOpen = false; 
                }
            }
            component.set("v.tabs",tabArray);
     
        
        console.log(component.get("v.selTabId"));
        console.log('-- 0987 '+JSON.stringify(component.get("v.tabs")));
        
    }
    
})