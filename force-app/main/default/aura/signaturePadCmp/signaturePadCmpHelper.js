({
	helperMethod : function() {
		
	},
    
     // works on generate OTP button
  handleClickForOTP : function(component , event , helper){
      //var recordVal = component.get("v.recordVal")
      
      var action = component.get("c.sendEmails");
      action.setParams({"recordId" : component.get("v.recordVal")});
      console.log('recordIdrecordId',component.get("v.recordVal"));
      action.setCallback(this, function(response){
          var state = response.getState();
          //var data = response.getReturnValue();
          console.log('state16',response.getState());
          if (state === "SUCCESS") {
              var data = response.getReturnValue();
              var sentEmailId = data.regEmail;
              console.log('the data is' , data);
              
              component.set("v.result" , data.regEmail);
              component.set("v.vfCode" , data.code);
              console.log('the data is' , response.getReturnValue());
              var msg =  'The Verification Code has been sent to' + ' ' + sentEmailId;
              var msg1 = 'The Patient emailId is not registered , Please contact the Administrator ';
              if($A.util.isUndefinedOrNull(data.regEmail) || $A.util.isEmpty(data.regEmail)){
                  var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                      title : 'Error',
                      message: msg1 ,
                      duration:' 5000',
                      type: 'error',
                      mode: 'dismissible'
                  });
                  toastEvent.fire();
              }
              else{
                  var toastEvent1 = $A.get("e.force:showToast");
                  toastEvent1.setParams({
                      title : 'Success !',
                      message: msg,
                      duration:' 5000',
                      type: 'success',
                      mode: 'dismissible'
                  });
                  toastEvent1.fire();
                  //component.set("v.recordVal" ,component.get("v.recordId"));
                  //component.set("v.showSignature" , true); // bharti added
                  //console.log(component.get("v.recordVal"));
              }
          }
          else{
              console.log('nhjl');
	}
      });
      $A.enqueueAction(action);
  },
})