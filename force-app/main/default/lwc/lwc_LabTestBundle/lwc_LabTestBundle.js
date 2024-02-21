import { LightningElement, api, wire, track} from 'lwc';
import getNamespace from '@salesforce/apex/LabTestBundleController.getNamespace';
import saveRecords from '@salesforce/apex/LabTestBundleController.saveRecords';
import getFieldValue from '@salesforce/apex/LabTestBundleController.getFieldValue';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwc_LabTestBundle extends LightningElement {
    showModal = true;
    @wire(getNamespace) nameSpace;
    @api horizontalAlign = 'space';
    @track dataArray;
    @track value;
    @track labTestBundleName = '';
    @track labTestBundleDescription = '';
    @api labRecordId;
    attributeType;
    labid;
    
    connectedCallback(){
        console.log("Record Id "+ this.labRecordId);
        console.log("Initial Row"+ JSON.stringify(this.row));

        getFieldValue({recordId:this.labRecordId})
        .then((result)=>{
            this.labid = result;
            console.log('labid ' + result);
        })
        .catch((error) => {
            this.error = error;
            console.log("Error " + JSON.stringify(error));
        });

        console.log('Labid '+ this.labid);
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
        // this.showModal = false;
        var url = window.location.href;
        var value = url.substr(0, url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    }

    handleShowModalOfTests() {
        console.log("function called");
        const modal = this.template.querySelector("c-add-more-tests");
        console.log(this.labid);
        modal.labid='';
        if (this.labid!=null || this.labid!='' ){
            modal.labid = this.labid;
        }
        // modal.labid = this.labRecordId;
        console.log('Lab Id in Handle show Modal' + this.labRecordId);
        modal.show();
    }

    handleShowModalOfDiagnosis() {
        console.log("function called");
        const modal = this.template.querySelector("c-add-more-diagnosis-code");
        // modal.labid = this.lab;
        console.log('Lab Id in Handle show Modal' + this.labRecordId);
        // modal.labid = this.labRecordId;
        modal.show();
    }

    handleShowModalOfProcedure() {
        console.log("function called");
        const modal = this.template.querySelector("c-add-more-procedure-code");
        // modal.labid = this.selectedLab;
        console.log('Lab Id in Handle show Modal' + this.labRecordId);
        // modal.labid = this.labRecordId;
        modal.show();
    }

    //Arrays for Diagnosis Codes
    @track selectedDiagnosisCodes = [];
    @track selectedRowsDiagnosisCodes = [];
    
    //Arrays for Procedure Code
    @track selectedProcedureCodes = [];
    @track selectedRowsProcedureCodes = [];

    //Arrays for Tests
    @track selectedTests = [];
    @track selectedRows = [];

    //Handle custom onDiagnosisAdd Event
    handleDiagnosisCodesAdded(event) {
        this.selectedRowsDiagnosisCodes = event.detail;
        console.log(this.selectedRowsDiagnosisCodes);
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
                    this.selectedDiagnosisCodes = [...this.selectedDiagnosisCodes, { recordId: this.selectedRowsDiagnosisCodes[i]['Id'], diagnosisCodeName: this.selectedRowsDiagnosisCodes[i]['Name'], index: this.selectedDiagnosisCodes.length+1}];
                    }
        }
        console.log('Selected Rows2 ' + JSON.stringify(this.selectedRowsDiagnosisCodes));
        console.log('Selected Tests2 ' + JSON.stringify(this.selectedDiagnosisCodes));
        //this.selectedRowsDiagnosisCodes = [];
    }

    //Handle custom onProcedureAdd Event
    handleProcedureCodesAdded(event) {
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
                    this.selectedProcedureCodes = [...this.selectedProcedureCodes, { recordId: this.selectedRowsProcedureCodes[i]['Id'], procedureCodeName: this.selectedRowsProcedureCodes[i]['Name'], index: this.selectedProcedureCodes.length+1}];
                    }
        }
        console.log('Selected Rows2 ' + JSON.stringify(this.selectedRowsProcedureCodes));
        console.log('Selected Tests2 ' + JSON.stringify(this.selectedProcedureCodes));
        //this.selectedRowsProcedureCodes = [];
    }
    
    
    handelTestsAdded(event){
        this.selectedRows = event.detail;
        console.log('Selected Rows ' + JSON.stringify(this.selectedRows));


        for (let i = 0; i < this.selectedRows.length; i++) {
            let check = true;
            console.log('Inside for Loop1')
            
            for(let j=0;j<this.selectedTests.length;j++){
                console.log('Inside for Loop2')
                if(this.selectedTests[j]['testId'] === this.selectedRows[i]['ElixirSuite__Test_Id__c'] 
                    && this.selectedTests[j]['testName'] === this.selectedRows[i]['ElixirSuite__Test_Name__c']){
                        check = false;
                        break;
                    }
            }

            if(check){
                this.selectedTests = [...this.selectedTests, { testId: this.selectedRows[i]['ElixirSuite__Test_Id__c'], testName: this.selectedRows[i]['ElixirSuite__Test_Name__c'],recordId:this.selectedRows[i]['Id'], index: this.selectedTests.length+1}];
            }
        }

        console.log('Selected Rows2 ' + JSON.stringify(this.selectedRows));
        console.log('Selected Tests2 ' + JSON.stringify(this.selectedTests));
        this.selectedRows = [];
    }

    // Toast when new bundle is created
    showToastBundelCreated(){
        const event = new ShowToastEvent({
            title: "Bundle Save",
            message: 'Lab Test Bundle has been created',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        return;
    }

    rowDeleteDiagnosisCode(event){
        console.log(JSON.stringify(this.selectedDiagnosisCodes));

        console.log('Delete current Row');
        console.log(event.target.value);

        // Remove the current row
        var halfBeforeTheUnwantedElement  = this.selectedDiagnosisCodes.slice(0,event.target.value-1);
        var halfAfterTheUnwantedElement  = this.selectedDiagnosisCodes.slice(event.target.value);

        for(var i = 0;i<halfAfterTheUnwantedElement.length;i++){
            halfAfterTheUnwantedElement[i].index -= 1;
        }
        this.selectedDiagnosisCodes = halfBeforeTheUnwantedElement.concat(halfAfterTheUnwantedElement);
    }

    rowDeleteProcedureCode(event){
        console.log(JSON.stringify(this.selectedProcedureCodes));

        console.log('Delete current Row');
        console.log(event.target.value);

        // Remove the current row
        var halfBeforeTheUnwantedElement  = this.selectedProcedureCodes.slice(0,event.target.value-1);
        var halfAfterTheUnwantedElement  = this.selectedProcedureCodes.slice(event.target.value);

        for(var i = 0;i<halfAfterTheUnwantedElement.length;i++){
            halfAfterTheUnwantedElement[i].index -= 1;
        }
        this.selectedProcedureCodes = halfBeforeTheUnwantedElement.concat(halfAfterTheUnwantedElement);
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

    showToastBundleValidation(){
        const event = new ShowToastEvent({
        title: "Select atleast one each of Diagnosis Code and Lab Test",
        //message: '',
        variant: 'Error',
        mode: 'dismissable'
        });
        this.dispatchEvent(event);
        return;
    }

    

    // Save all the records in the same lab as lab test bundle 
    saveRecord(){

        console.log("Record Id " + this.labRecordId);
        console.log("Bundle Name " + this.labTestBundleName);
        console.log("Bundle Description " + this.labTestBundleDescription);
        console.log("Tests " + JSON.stringify(this.selectedTests));
        console.log("Diagnosis Codes " + JSON.stringify(this.selectedDiagnosisCodes));
        console.log("Procedure Codes " + JSON.stringify(this.selectedProcedureCodes));

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

        console.log('Diagnosis Codes SF Ids ' + JSON.stringify(diagnosisCodesSFIds));
        console.log('Procedure Codes SF Ids ' + JSON.stringify(procedureCodesSFIds));
        console.log('Test SF Ids ' + JSON.stringify(labTestsSFIds));
        
        const JSONDiagnosisCodes = JSON.stringify(this.selectedDiagnosisCodes);1
        const JSONProcedureCodes = JSON.stringify(this.selectedProcedureCodes);
        const JSONTESTS = JSON.stringify(this.selectedTests);

    
        if(this.selectedTests.length>0 && this.selectedDiagnosisCodes.length>0){
        saveRecords({labId: this.labRecordId, 
                     labTestBundleName: this.labTestBundleName, 
                     description: this.labTestBundleDescription, 
                     listOfLabTest: JSONTESTS,
                     listOfDiagnosisCodes: JSONDiagnosisCodes,
                     listOfProcedureCodes: JSONProcedureCodes,
                     listOfDiagnosisCodesSFIds:diagnosisCodesSFIds,
                     listOfProcedureCodesSFIds:procedureCodesSFIds,
                     listOfLabTestsSFIds:labTestsSFIds
                    })
                .then((result)=>{
                    console.log("Inside save records");
                })
                .catch((error) => {
                    this.error = error;
                    console.log("Error2 " + JSON.stringify(error));
                });
        
        console.log("After save records call");

        console.log('New Selected Test');
        console.log("Tests " + JSON.stringify(this.selectedTests));

        this.showToastBundelCreated();
        this.handleDialogClose();
             }

            else{
                this.showToastBundleValidation();
            }        
            
    }
    
}