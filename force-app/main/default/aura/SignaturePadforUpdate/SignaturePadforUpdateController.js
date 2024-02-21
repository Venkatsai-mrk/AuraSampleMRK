({
    doInit : function(component, event, helper) {
        console.log('the newVal is' );
        component.set("v.isActive", true);
        component.set('v.showSignPad' , false); 
        component.set("v.displayedSection","section2");
        var modal = component.find("exampleModal");
        $A.util.removeClass(modal, 'hideDiv');  
        var newVal = component.get("v.recordVal");
        console.log('the newVal is' , newVal);
        var canvas, ctx, flag = false,
            prevX = 0,
            currX = 0,
            prevY = 0,
            currY = 0,
            dot_flag = false;
        
        var x = "black",
            y = 2,
            w,h;
        canvas=component.find('new_canvas').getElement();
        var ratio = Math.max(window.devicePixelRatio) ;
        w = canvas.width*ratio;
        h = canvas.height*ratio;
        ctx = canvas.getContext("2d");
        console.log('ctx:='+ctx);
        
        canvas.addEventListener("mousemove", function (e) {
            findxy('move', e)
        }, false);
        canvas.addEventListener("mousedown", function (e) {
            findxy('down', e)
        }, false);
        canvas.addEventListener("mouseup", function (e) {
            findxy('up', e)
        }, false);
        canvas.addEventListener("mouseout", function (e) {
            findxy('out', e)
        }, false);
        
        function findxy(res, e){
            const rect = canvas.getBoundingClientRect();
            if (res == 'down') {
                prevX = currX;
                prevY = currY;
                currX = e.clientX - rect.left ;
                currY = e.clientY -  rect.top;
                
                flag = true;
                dot_flag = true;
                if (dot_flag) {
                    ctx.beginPath();
                    ctx.fillStyle = x;
                    ctx.fillRect(currX, currY, 2, 2);
                    ctx.closePath();
                    dot_flag = false;
                }
            }
            if (res == 'up' || res == "out") {
                flag = false;
            }
            if (res == 'move') {
                if (flag) {
                    prevX = currX;
                    prevY = currY;
                    currX = e.clientX -  rect.left;
                    currY = e.clientY - rect.top;
                    draw(component,ctx);
                }
            }
        }
        function draw() {
            ctx.beginPath();
            ctx.moveTo(prevX, prevY);
            ctx.lineTo(currX, currY);
            ctx.strokeStyle = x;
            ctx.lineWidth = y;
            ctx.stroke();
            ctx.closePath();
        }
    },
    erase: function(component, event, helper){
        var m = confirm("Do you want to clear this signature?");
        if (m) {
            var canvas=component.find('new_canvas').getElement();
            var ctx = canvas.getContext("2d");
            var w = canvas.width;
            var h = canvas.height;
            ctx.clearRect(0, 0, w, h);
        }
    },
    hideExampleModal : function(component, event, helper) {
        var modal = component.find("exampleModal");
        $A.util.addClass(modal, 'hideDiv');
        component.set("v.isActive" , false);
    },
    save:function(component, event, helper){
        var pad=component.find('new_canvas').getElement();
        var dataUrl = pad.toDataURL();
        console.log('dataUrl:='+dataUrl);
        var strDataURI=dataUrl.replace(/^data:image\/(png|jpg);base64,/, "");
        var action = component.get("c.saveSignature");
        action.setParams({
            signatureBody : strDataURI,
            parentId      : component.get("v.recordVal")
        });
        action.setCallback(this,function(res){
            var state = res.getState();
            if(state==="SUCCESS"){
                var modal = component.find("exampleModal");
                $A.util.addClass(modal, 'hideDiv');
                component.set("v.isActive" , false);
                alert("Signature has been saved successfully.");
                
            }
        });       
        $A.enqueueAction(action);
    },
    
    validateOTP:function(component,event,helper){
       
       var attVal = component.get("v.OTPVal") ;
        if ($A.util.isUndefinedOrNull(attVal) || $A.util.isEmpty(attVal)){
            var toastEvent2 = $A.get("e.force:showToast");
                    toastEvent2.setParams({
                        "type": "error",
                        "title": "No Code Entered! ",
                        "message":    "Please enter the code and proceed."
                    });
                    toastEvent2.fire();
        }
        else{
            alert('otp '+component.get("v.OTPVal"));
            alert('patId '+component.get("v.recordVal"));
        var action1 = component.get("c.matchOtp");
        action1.setParams({  
            veriCode : component.get("v.OTPVal"), // value which is added in the box
            patientId : component.get("v.recordVal")
        });
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var allData = response.getReturnValue();
                if(allData == true){
                    var toastEvent1 = $A.get("e.force:showToast");
                    toastEvent1.setParams({
                        "type": "success",
                        "title": "The Verification Code matches. ",
                        "message": "Please proceed by adding your signatures!"
                    });
                    toastEvent1.fire(); 
                    component.set('v.showSignPad' , true);  
                    component.set("v.displayedSection","section1");
                    //    component.set('v.showField' , true);     
                    //    this.canvasMethod(component);
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "The Verification Code entered is incorrect. ",
                        "message":    "Please check it again or click cancel to go back."
                    });
                    toastEvent.fire();
                    component.set('v.showSignPad' , false);  
                }
            }
            /*  else if(state ==="ERROR"){
                    console.log('Failure');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Info!",
                        "title": "The Verification Code entered is incorrect. ",
                        "message":    "Please check it again or click cancel to go back to the form."
                    });
                    toastEvent.fire();
             //   var m = confirm("The Verification Code entered is incorrect. Please check it again or click cancel to go back to the form.");
              
            }*/
        });  
        
        $A.enqueueAction(action1);
        }
    }
})