({
    openSubTabs : function(cmp, event)
    {console.log('73');
        console.log('### na - ' + event.currentTarget.dataset.name);
     	console.log('### id - ' + event.currentTarget.id);
        console.log('### type - ' + event.currentTarget.dataset.type);
        console.log('### record - ' + event.currentTarget.dataset.new);
        var p  = cmp.get("v.recId");
        console.log('p - ' +p);
        if(event.currentTarget.dataset.type == 'CustomMetaDataType')
        {
            /*var componentName = event.currentTarget.dataset.name ;
            alert('hh1',componentName);
                    var appEvent = $A.get("e.ElixirHC:ProgressNoteAftersearch");
                    appEvent.setParams( { 
                        "cmpName" :  componentName ,
                        "recordVal" : cmp.get("v.recId")
                    } );
                    appEvent.fire();
            alert('hh');*/
        }
        else if(event.currentTarget.dataset.type == 'ElixirHC__Form__c')
        {
        //   alert('After selection -- ' + JSON.stringify(cmp.get("v.accName")));
            
            if(event.currentTarget.dataset.new == 'true')
            {
                console.log('### new id - ' + event.currentTarget.id);
                /*var appEvent = $A.get("e.ElixirHC:ProgressNoteAftersearch");
                appEvent.setParams( { 
                    "cmpName" :  event.currentTarget.dataset.name ,
                    "formId" : event.currentTarget.id ,
                    "typeOfForm" : event.currentTarget.dataset.new,
                    "recordVal" : cmp.get("v.recordId"),
                    "formData" : cmp.get("v.accName"),
                } );
                appEvent.fire();*/
                component.set("v.progressNote",true);        
            }
            if(event.currentTarget.dataset.new == 'false'){
                console.log('### old id - ' + event.currentTarget.id);
                var appEvent = $A.get("e.ElixirHC:ProgressNoteAftersearch");
                appEvent.setParams( { 
                    "cmpName" :  event.currentTarget.dataset.name ,
                    "formId" : event.currentTarget.id ,
                    "typeOfForm" : event.currentTarget.dataset.new,
                    "recordVal" : cmp.get("v.recId"),
                    "formData" : cmp.get("v.accName")
                } );
                appEvent.fire();
            }
            
        }
        
    }
})