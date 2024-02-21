({

    myAction : function(component, event, helper) {

        var adLst =  component.get("v.invValue");

        var len = adLst.length;

        if(len>0){

            component.set("v.appendCheck",true);

            component.set("v.prevAddedLst",adLst);

        }
    },
    
    getValueFromLwc : function(component, event, helper) {

        var addLst = component.get("v.invValue");

        var len = addLst.length;

        console.log('addLst****',JSON.stringify(addLst));

        var newAddLst = event.getParam('itemList2');

        console.log('newAddLst****',JSON.stringify(newAddLst));

        console.log('newAddLst length****',newAddLst.length);

        var addLen = newAddLst.length;

        var dmlCh = 0; //added by Anmol

        var modCh = false;

        for(var i=0;i<newAddLst.length;i++){

            if(len==0){
    
                if(newAddLst[i].mode == 'new'){
                addLst.push(newAddLst[i]);
                console.log('if48 addlst***',JSON.stringify(addLst));
                }
                else{
                    addLst.splice(i,1);
                }
            }

            else{

                if(newAddLst[i].mode == 'new'){

                    addLst.push(newAddLst[i]);
                    dmlCh++;
                    modCh = true;
                    console.log('if new47****');
                 }

                 if(newAddLst[i].mode == 'delete'){

                    addLst.splice(i,1);
                    dmlCh--;
                    modCh = true;
                    console.log('if delete53****');
                 }

                 if(newAddLst[i].mode == 'old'){

                    if(modCh){
                    addLst[dmlCh] = newAddLst[i];
                    }
                    else{
                        addLst[i] = newAddLst[i];
                    }

                    /*
                        addLst[i].Avail = newAddLst[i].Avail;
                        addLst[i].req = newAddLst[i].req; 
                        addLst[i].Type = newAddLst[i].Type;
                        addLst[i].Lot = newAddLst[i].Lot; 
                        addLst[i].proid = newAddLst[i].proid;
                        addLst[i].eid = newAddLst[i].eid; */

                        console.log('if old 68****');
    
        }

           
        }
    }

      /*  const length = addLst.length;

        console.log('addLst before****',JSON.stringify(addLst));

        for(let i=0;i<length - 1;i++){
            for (let j = i + 1; j < length; j++) {
            if(addLst[i].eid==addLst[j].eid){
                addLst.splice(j,1);
            }
        }
        }*/

        console.log('addLst after****',JSON.stringify(addLst));

        component.set("v.invValue",addLst);
        
        var columns = component.get("v.column");
        columns['inventoryLst']=addLst;
        component.set("v.column",columns);
        
      //  component.set("v.invValue",event.getParam('itemList2'));
        
        component.set("v.addedLst",event.getParam('itemList2'));
        
        component.set("v.InvTable", true);
        
        component.set("v.invMode", true);
        
        component.set("v.addInv", false);

      //  component.set("v.appendCh", true);
    },
    
    closeLwc : function(component, event) {
        
        component.set("v.addInv", false);
        
    }
})