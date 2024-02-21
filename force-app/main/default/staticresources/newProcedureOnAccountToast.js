$Lightning.use("c:NewProcedureApp", function() {
         $Lightning.createComponent("c:ProcedureCreationFrmListView",
             {
                accId : '{!$CurrentPage.parameters.id}'
             },
             "compContainer",
             function(cmp) {
                 
          console.log("c:VFPageApp loaded successfully in VF page");
             }
         );
     });