({
	myAction : function(component, event, helper) {
		// alert(JSON.stringify(component.get("v.mapKey")));
      //  console.log('kkiol,--------' ,JSON.stringify(component.get("v.allVal")));
      /*  var initlist = JSON.stringify(component.get("v.mapKey"));
        console.log('kkiol,--------' ,initlist.ended );
       if ($A.util.isUndefinedOrNull(initlist.ended));
        component.set("v.flag", true);*/
        //   component.set("v.jsonList",JSON.parse(JSON.stringify(completeJson)));
    },
    ToggleCollapse : function(component, event, helper) {
         var existingText = component.get("v.collpaseText"); 
         var acc = component.find("attendSec");
         if(existingText === "Notes »"){
             component.set("v.collpaseText","Notes <<");
            
         }else{
             component.set("v.collpaseText","Notes »");
         }
          var acc = component.find("attendSec");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        
    },
     handleChange : function(component, event, helper) {
       //  console.log("jdn--- " , JSON.stringify(component.get("v.mapKey")));
         var count = component.get("v.attended");
         var lessCount = component.get("v.count");
         var val = event.getSource().get("v.value");
         var name = event.getSource().get("v.name");
         var array = name.split('$');
         var upperIndex = array[0];
         var insideIndex = array[1]; 
         var abc= component.get("v.allVal");
         var jsonInside = JSON.stringify(abc[insideIndex]);
       //  console.log('test if this' , component.get("v.allVal"));
       
         
         if(val==true)count=count+1;
         else count=count-1;
         component.set("v.attended",count);
         if(val==true)lessCount=lessCount-1;
         else lessCount=lessCount+1;
         component.set("v.count",lessCount);
           
         var cmpEvent = component.getEvent("cmpAttEvent");
         // Get the value from Component and set in Event
         cmpEvent.setParams( { 
             "attended" : component.get("v.attended") ,
             "missed" : component.get("v.count")
         } );
        cmpEvent.fire();
    },
    
    recordEdit	: function(component,event,helper){
    
       // console.log('test if this' , component.get("v.allVal"));
       var cmpEvents = component.getEvent("cmpAttEvent");
         // Get the value from Component and set in Event
         cmpEvents.setParams({ 
             "attended" : component.get("v.attended") ,
             "missed" : component.get("v.count"),
             "listVal" :  component.get("v.allVal")
        });
        cmpEvents.fire();
    },
    
     removeSection :	function(component, event, helper) {
        var acc = component.find("mapKeyId");
        var taskIdx = component.get("v.idx");
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        var task =  component.get('v.allVal');
       // var listOfTasks = task.listOfTask;  
        task.splice(taskIdx,1);
        component.set('v.allVal',task);
         
         var count = component.get("v.attended");
         var lessCount = component.get("v.count");
         var val = false ;
     //    console.log('jj' , val);
         if(val==true)count=count+1;
         else count=count-1;
         component.set("v.attended",count);
        /* if(val==true)lessCount=lessCount-1;
         else lessCount=lessCount+1;
         component.set("v.count",lessCount);*/
         
         var cmpEvent = component.getEvent("cmpAttEvent");
         // Get the value from Component and set in Event
         cmpEvent.setParams( { 
             "attended" : component.get("v.attended") 
         //    "missed" : component.get("v.count")
         } );
         cmpEvent.fire();
         
    }
})