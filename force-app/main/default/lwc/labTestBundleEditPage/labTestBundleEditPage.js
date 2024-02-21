import { LightningElement, api, wire, track} from 'lwc';
import getNamespace from '@salesforce/apex/LabTestBundleController.getNamespace';
import updateRecords from '@salesforce/apex/LabTestBundleController.updateRecords';
//import getRecordData from '@salesforce/apex/LabTestBundleController.getRecordData';
import getFieldValue from '@salesforce/apex/LabTestBundleController.getFieldValue';
import fetchRecords from '@salesforce/apex/LabTestBundleController.fetchRecords';
import fetchData from '@salesforce/apex/LabTestBundleController.fetchData';
import fetchDataTest from '@salesforce/apex/LabTestBundleController.fetchDataTest';
import fetchDataDiagnosis from '@salesforce/apex/LabTestBundleController.fetchDataDiagnosis';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwc_LabTestBundle extends LightningElement {
    showModal = true;
    defType;
    @api recordId;
    @wire(getNamespace) nameSpace;
    @api horizontalAlign = 'space';
    @track dataArray;
    @track value;
    @track labTestBundleName = '';
    @track labTestBundleDescription = '';
    @api labBundleRecordId;
    @api labRecordId;
    attributeType;
    labid;
    procedureCode = '';
    diagnosisCode = '' ;
    labTests = '' ;
    
    // Row creation for table elements of Add Bundles Attributes
    // @track row = [];
    @track selectedTests = [];
    @track selectedDiagnosisCodes = [];
    @track selectedProcedureCodes = [];
    // newRowIndex;

    connectedCallback(){
        console.log("Record Id "+ this.labRecordId);
        getFieldValue({recordId:this.labRecordId})
        .then((result)=>{
            this.labid = result;

        })

        .catch((error) => {
            this.error = error;
            console.log("Error " + JSON.stringify(error));
        });

        //method to fetch SF Id fields of Diagnosis,procedure and Lab tests by Sanjay
        fetchRecords({bundleId: this.labBundleRecordId}).then((result)=>{
                this.labTestBundleName = (result.Name);
                this.labTestBundleDescription = (result.ElixirSuite__DescriptionField__c);
                this.procedureCode = (result.ElixirSuite__Procedure_Codes_SF_Ids__c);
                this.labTests =(result.ElixirSuite__Lab_Tests_SF_Ids__c);
                this.diagnosisCode = (result.ElixirSuite__Diagnosis_Codes_SF_Ids__c);

                let testSfArrayId = this.labTests.split(';');
                const LabEmpty = testSfArrayId.filter((str) => str !== '');
                console.log(JSON.stringify(LabEmpty));
                
                for(let i=0; i < LabEmpty.length;i++){ 
                    //Using SF Ids, fetching the fields of Lab test
                    fetchDataTest({test:LabEmpty[i]})
                    .then((response)=>{
                        console.log('Result coming Apex Call ' +JSON.stringify(response[0]));
                        this.selectedTests = [...this.selectedTests,{index:this.selectedTests.length+1, Name:response[0].Name ,ElixirSuite__Test_Name__c:response[0].ElixirSuite__Test_Name__c,recordId:response[0].Id}];
                        console.log('final OUTCOME ' + JSON.stringify(this.selectedTests));
                    })
             
                    .catch((error) => {
                        this.error = error;
                    });

                }

                let diagnosisSfArrayId = this.diagnosisCode.split(';');
                const diagnosisEmpty = diagnosisSfArrayId.filter((str) => str !== ''); 
                for(let i=0; i < diagnosisEmpty.length;i++){ 
                    //Using SF Ids, fetching the fields of Diagnosis codes
                    fetchDataDiagnosis({diagnosis:diagnosisEmpty[i]})
                    .then((response)=>{
                    this.selectedDiagnosisCodes = [...this.selectedDiagnosisCodes,{index:this.selectedDiagnosisCodes.length+1, Name:response[0].Name,recordId:response[0].Id}];
                    console.log('Diagnosis code result '+ JSON.stringify(this.selectedDiagnosisCodes));
                })
             
                    .catch((error) => {
                        this.error = error;
                    });

                }

                if(this.procedureCode.length > 0){
                    
                    let procedureSfArrayId = this.procedureCode.split(';');
                    const procedureEmpty = procedureSfArrayId.filter((str) => str !== '');
        
                    for(let i=0; i < procedureEmpty.length;i++){
                        //Using SF Ids, fetching the fields of Procedure codes
                        fetchData({procedure:procedureEmpty[i]})
                        .then((response)=>{
                            this.selectedProcedureCodes = [...this.selectedProcedureCodes,{index:this.selectedProcedureCodes.length+1 ,Name:response[0].Name,recordId:response[0].Id}];
                            console.log('procedure code result '+ JSON.stringify(this.selectedProcedureCodes));
                        })
                 
                        .catch((error) => {
                            this.error = error;
                        });
    
                    }    
                }

            })
            .catch((error) => {
                this.error = error;
            });
    }
    
    @api show() {
        window.console.log('Modal Show Called');
        // window.console.log('Child : LabID : ' + this.labid);
        this.showModal = true;
    }

    handleInputChangeName(event) {
        this.labTestBundleName = event.detail.value;
    }

    handleInputChangeDescription(event) {
        this.labTestBundleDescription = event.detail.value;
    }
    
    handleDialogClose(event) {
        //this.showModal = false;
        var url = window.location.href;
        var value = url.substr(0, url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    }

    handleChangeAttributeType(event) {
        const selectedOption = event.detail.value;
        let index = event.target.dataset.index;
        this.row[index].Name = selectedOption;
        console.log(index);
        console.log("Before row");
        console.log(JSON.stringify(this.row));

        let tempArray = [];

        getAttributeList({ attributeType: selectedOption })
        .then(result => {
            this.dataArray = result;
            this.dataArray.forEach(function (element) {
                var option =
                {
                    label: element.Name,
                    value: element.Name
                };
                tempArray.push(option);
                console.log("TempArray " + JSON.stringify(tempArray));
                console.log("Option" + JSON.stringify(option));
            });
                this.row[index].opp = tempArray;
                console.log("this.row[index].opp inside " + JSON.stringify(this.row[index].opp));
                console.log("tempArray" + tempArray);
                this.fields = tempArray;
            })
            .catch(error => {
                this.error = error;
            });

            console.log("abc");
            
            console.log("After row")
            console.log(JSON.stringify(this.row));
            console.log("this.row[index].opp outside" + JSON.stringify(this.row[index].opp));
    }

    handleChangeAttribute(event) {
        let index = event.target.dataset.index;
        const selectedOption2 = event.detail.value;
        this.row[index].Title = selectedOption2;
        console.log(index);
        console.log(selectedOption2);
    }
    
    handleShowModal() {
        console.log("function called");
        const modal = this.template.querySelector("c-add-more-tests");
        modal.labid = this.selectedLab;
        modal.show();
    }


    @track selectedRows = [];
    
    handelTestsAdded(event) {
        this.selectedRows = event.detail;
        console.log('Selected Rows ' + JSON.stringify(this.selectedRows));


        for (let i = 0; i < this.selectedRows.length; i++) {
            let check = true;

            for(let j=0;j<this.selectedTests.length;j++){
                if(this.selectedTests[j]['Name'] === this.selectedRows[i]['ElixirSuite__Test_Id__c'] 
                    && this.selectedTests[j]['ElixirSuite__Test_Name__c'] === this.selectedRows[i]['ElixirSuite__Test_Name__c']){
                        check = false;
                        break;
                    }
            }

            if(check){
                this.selectedTests = [...this.selectedTests, { Name: this.selectedRows[i]['ElixirSuite__Test_Id__c'], ElixirSuite__Test_Name__c: this.selectedRows[i]['ElixirSuite__Test_Name__c'], index: this.selectedTests.length+1,recordId:this.selectedRows[i]['Id']}];
            }
        }

        console.log('Selected Rows ' + JSON.stringify(this.selectedRows));
        console.log('Selected added Tests  ' + JSON.stringify(this.selectedTests));
        this.selectedRows = [];
    }
    handleDiagnosisCodesAdded(event){
        this.selectedRowsDiagnosisCodes = event.detail;
        console.log('Selected Rows ' + JSON.stringify(this.selectedRowsDiagnosisCodes));
        console.log('Total selected codes count' + this.selectedRowsDiagnosisCodes.length);


        for (let i = 0; i < this.selectedRowsDiagnosisCodes.length; i++) {
            let check = true;
            console.log('Inside for Loop1');

            for(let j=0;j<this.selectedDiagnosisCodes.length;j++){
                console.log('Inside for Loop2')
                if(this.selectedDiagnosisCodes[j]['recordId'] === this.selectedRowsDiagnosisCodes[i]['Id']){
                    check = false;
                    break;
                }          
        }    
                
                if(check){
                    this.selectedDiagnosisCodes = [...this.selectedDiagnosisCodes, { recordId: this.selectedRowsDiagnosisCodes[i]['Id'], Name: this.selectedRowsDiagnosisCodes[i]['Name'], index: this.selectedDiagnosisCodes.length+1}];
                    }

        }
        console.log('Selected Rows2 ' + JSON.stringify(this.selectedRowsDiagnosisCodes));
        console.log('Selected Tests2 ' + JSON.stringify(this.selectedDiagnosisCodes));
        this.selectedRowsDiagnosisCodes = [];
        }    

    // Show Toast function for false row addition in Add bundle Attributes
    showToast(){
        const event = new ShowToastEvent({
            title: "Addition not allowed",
            message: 'Row addition now allowed while there are empty rows',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        return;
    }

    // Toast when new bundle is created
    showToastBundelUpdated(){
        const event = new ShowToastEvent({
            title: "Bundle Saved",
            message: 'Lab Test Bundle has been Updated',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        return;
    }
    showToastBundleValidation(){
        const event = new ShowToastEvent({
            title: "Select atleast one each of Diagnosis Code and Lab Test!",
            //message: 'There should be at least 1 Lab Test in the Bundle!',
            variant: 'Error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        return;
    }


    // Shaurya Pratap Singh (28/11/2022)
    // New row addition for add bundle attribute 
    addNewRow(event){
        function nonEmptyRowCounter(row){
            let counter = 0;
            for(let i=0;i<row.length;i++){
                if(row[i].Name!='Attribute' && row[i].Title!='Attribute Type'){
                    counter++;
                }
            }
            return counter;
        };

        this.data = event.target.value;

        console.log('Row ' + JSON.stringify(this.row));
        console.log('Data ' + JSON.stringify(this.data));
        console.log('Name ' + this.data.Name);
        this.checkName = this.data.Name;
        console.log('checkName ' + this.checkName);
        console.log('Title ' + this.data.Title);
        this.checkTitle = this.data.Title;
        console.log('checkTitle ' + this.checkTitle);

        // let n = this.row.length;
        // console.log('Length ' + n);
        let i = 0;
        
        for(i=0;i<this.row.length-1;i++){
    
            console.log('Match');
            
            if(this.row[i].Title == this.checkTitle && this.row[i].Name == this.checkName){
                console.log('Found Culprit');
                this.row.pop();
                break;
            }
        }

        console.log('New Row Length ' + this.row.length);

        // this.row.forEach((ele)=>{
        //     delete ele['Id'];
        // })
        // console.log('Row '+ this.row);

        // const uniqueSet = new Set(this.row);
        // console.log('Uniqe Vaule ' + JSON.stringify([...uniqueSet]));

        // this.tempRow = this.removeDuplicates(this.row, this.checkName, this.checkTitle);
        
        // console.log('Temp Row ' + JSON.stringify(this.tempRow));
        
        console.log("Before");
        console.log(JSON.stringify(this.row));
        console.log('Inside add new row');

        let nonEmptyRowCount = nonEmptyRowCounter(this.row);
        console.log("NonEmptyRow " + nonEmptyRowCount);

        if(nonEmptyRowCount == this.row.length){
            this.row = [...this.row, {
                Id: ++this.row.length,
                Name: 'Attribute',
                Title: 'Attribute Type',
                opp: []
            }];
        }
        else{
            console.log("Addition not allowed");
            this.showToast();
            //Show toast --> Row addition now allowed while there are empty rows
        }

        console.log(JSON.stringify(this.row));
    }
    handleProcedureCodesAdded(event){
        this.selectedRowsProcedureCodes = event.detail;
        console.log('Selected Rows ' + JSON.stringify(this.selectedRowsProcedureCodes));
        console.log('Total selected codes count ' + this.selectedRowsProcedureCodes.length);


        for (let i = 0; i < this.selectedRowsProcedureCodes.length; i++) {
            let check = true;
            console.log('Inside for Loop1');
        
            for(let j=0;j<this.selectedProcedureCodes.length;j++){
                console.log('Inside for Loop2')
                if(this.selectedProcedureCodes[j]['recordId'] === this.selectedRowsProcedureCodes[i]['Id']){
                    check = false;
                    break;
                }          
        }
                
                if(check){
                    this.selectedProcedureCodes = [...this.selectedProcedureCodes, { recordId: this.selectedRowsProcedureCodes[i]['Id'], Name: this.selectedRowsProcedureCodes[i]['Name'], index: this.selectedProcedureCodes.length+1}];
                    }
    

        }
        console.log('Selected Rows2 ' + JSON.stringify(this.selectedRowsProcedureCodes));
        console.log('Selected Tests2 ' + JSON.stringify(this.selectedProcedureCodes));
        this.selectedRowsProcedureCodes = [];
    }

    // newRowIndex = 1;
    //New
    rowDeleteBundleAttributes(event){
        if(this.row.length>1){
            console.log('Delete current Row');
            console.log(event.target.value);

            // this.newRowIndex -= 1;
            
            console.log('Before Deleting '+JSON.stringify(this.row));
            console.log('Length '+ this.row.length);

            // Remove the current row
            var halfBeforeTheUnwantedElement  = this.row.slice(0,event.target.value-1);
            var halfAfterTheUnwantedElement  = this.row.slice(event.target.value);
            console.log(halfBeforeTheUnwantedElement);
            console.log(halfAfterTheUnwantedElement);

            for(var i=0;i<halfAfterTheUnwantedElement.length;i++){
                halfAfterTheUnwantedElement[i].Id -= 1;
            }
            this.row = halfBeforeTheUnwantedElement.concat(halfAfterTheUnwantedElement);

            console.log('After Deleting ' + JSON.stringify(this.row));
            console.log('Length '+ this.row.length);

        }
        else{
            console.log('Deletion not allowed');
        }
    }
    handleShowModalOfTests(){
        console.log("function called");
        const modal = this.template.querySelector("c-add-more-tests");
        console.log(this.labid);
        
        if (this.labid!=null || this.labid!='' ){
            modal.labid = this.labid;
        }
        //modal.labid = this.selectedLab;
        // modal.labid = this.labRecordId;
        console.log('Lab Id in Handle show Modal' + this.labRecordId);
        modal.show();
    }
    handleShowModalOfDiagnosis(){
        console.log("function called");
        const modal = this.template.querySelector("c-add-more-diagnosis-code");
        modal.show();
    }
    //To add more Procedure codes
    handleShowModalOfProcedure(){
        console.log("function called");
        const modal = this.template.querySelector("c-add-more-procedure-code");
        modal.show();
    }

    rowDeleteLabTest(event){
        console.log(JSON.stringify(this.selectedTests));

        console.log('Delete current Row');
        console.log(event.target.value);

        // Remove the current row
        var halfBeforeTheUnwantedElement  = this.selectedTests.slice(0,event.target.value-1);
        var halfAfterTheUnwantedElement  = this.selectedTests.slice(event.target.value);

        for(var i = 0;i<halfAfterTheUnwantedElement.length;i++){
            halfAfterTheUnwantedElement[i].index -= 1;
        }
        this.selectedTests = halfBeforeTheUnwantedElement.concat(halfAfterTheUnwantedElement);
    }
    rowDeleteProcedureCode(event){
        console.log('clicked');
        // Remove the current row
        var halfBeforeTheUnwantedElement  = this.selectedProcedureCodes.slice(0,event.target.value-1);
        var halfAfterTheUnwantedElement  = this.selectedProcedureCodes.slice(event.target.value);

        for(var i = 0;i<halfAfterTheUnwantedElement.length;i++){
            halfAfterTheUnwantedElement[i].index -= 1;
        }
        this.selectedProcedureCodes = halfBeforeTheUnwantedElement.concat(halfAfterTheUnwantedElement);
    }

    rowDeleteDiagnosisCode(event){
      // Remove the current row
      var halfBeforeTheUnwantedElement  = this.selectedDiagnosisCodes.slice(0,event.target.value-1);
      var halfAfterTheUnwantedElement  = this.selectedDiagnosisCodes.slice(event.target.value);

      for(var i = 0;i<halfAfterTheUnwantedElement.length;i++){
          halfAfterTheUnwantedElement[i].index -= 1;
      }
      this.selectedDiagnosisCodes = halfBeforeTheUnwantedElement.concat(halfAfterTheUnwantedElement);  
    }

    // Save all the records in the same lab as lab test bundle 
    saveRecord(){
        console.log("Record Id " + this.labRecordId);
        console.log("Bundle Name " + this.labTestBundleName);
        console.log("Bundle Description " + this.labTestBundleDescription);
        console.log("SF Ids of the Tests" + JSON.stringify(this.selectedTests));
        console.log("SF Ids of the Procedure" + JSON.stringify(this.selectedProcedureCodes));
        console.log("SF Ids of the Diagnosis" + JSON.stringify(this.selectedDiagnosisCodes));

         //Strings to store sf ids
         let diagnosisCodesSFIds = "";
         let procedureCodesSFIds = "";
         let labTestsSFIds = "";

         // Loop for saving sf ids in the array
        for(let i=0;i<this.selectedDiagnosisCodes.length;i++){
            diagnosisCodesSFIds += (this.selectedDiagnosisCodes[i]['recordId'] + ";")
        }
        
        for(let i=0;i<this.selectedProcedureCodes.length;i++){
            procedureCodesSFIds += (this.selectedProcedureCodes[i]['recordId'] + ";")
        }

        for(let i=0;i<this.selectedTests.length;i++){
            labTestsSFIds += (this.selectedTests[i]['recordId'] + ";")
        }

        console.log('Diagnosis SF ' + diagnosisCodesSFIds);
        console.log('Procedure SF ' + procedureCodesSFIds);
        console.log('Test SF ' + labTestsSFIds);
      
      
        // console.log("Row Json "+JSONROW);
        //console.log("Tests Json " + JSON.stringify(this.selectedTests));
        const JSONTESTS = JSON.stringify(this.selectedTests);
        const JSONDiagnosisCodes = JSON.stringify(this.selectedDiagnosisCodes);
        const JSONProcedureCodes = JSON.stringify(this.selectedProcedureCodes);

        if (this.selectedTests.length>0 && this.selectedDiagnosisCodes.length>0){
            updateRecords({labId: this.labRecordId, 
                bundleRecordId: this.labBundleRecordId,
                labTestBundleName: this.labTestBundleName, 
                description: this.labTestBundleDescription,  
                listOfLabTest: JSONTESTS,listOfDiagnosisCodes: JSONDiagnosisCodes,
                listOfProcedureCodes: JSONProcedureCodes,
                listOfDiagnosisCodesSFIds:diagnosisCodesSFIds,
                listOfProcedureCodesSFIds:procedureCodesSFIds,
                listOfLabTestsSFIds:labTestsSFIds})
                        .then((result)=>{
                            console.log("Inside save records");
                        })
                        .catch((error) => {
                            this.error = error;
                            console.log("Error " + JSON.stringify(error));
                        });
            console.log("After save records call");
            this.showToastBundelUpdated();
            this.handleDialogClose();
                }
        else{
            this.showToastBundleValidation();
        }      
        
        // window.location.reload();
        // this.handleDialogClose();

    }
    
}