import { LightningElement,api, wire, track } from 'lwc';
import fetchRecords from '@salesforce/apex/LabTestBundleController.fetchRecords';
import fetchData from '@salesforce/apex/LabTestBundleController.fetchData';
import fetchDataTest from '@salesforce/apex/LabTestBundleController.fetchDataTest';
import fetchDataDiagnosis from '@salesforce/apex/LabTestBundleController.fetchDataDiagnosis';


export default class LabTestBundle_editPage extends LightningElement {
    @api recordId;
    @api objectApiName;
    
    name = '';
    description = '';
    selectedDiagnosisCodes = [];
    selectedProcedureCodes = [];
    selectedTests = [];
    name1 = '';
    procedureCode = '';
    diagnosisCode = '' ;
    labTests = '' ;

    
        
    //Tables data for Diagnosis,Procedure and Tests
    columnsDiagnosisCodes = [
        { label: 'Name', fieldName: 'Name'},
    ];
    columnsProcedureCodes = [
        { label: 'Name', fieldName: 'Name'},
    ];
    columnsLabTests = [
        { label: 'Test Id', fieldName: 'Name'},
        { label: 'Test Name', fieldName: 'ElixirSuite__Test_Name__c'},
    ];

    connectedCallback(){
        //method to fetch SF Id fields of Diagnosis,procedure and Lab tests by Shubhangi
        fetchRecords({bundleId: this.recordId}).then((result)=>{
            this.name = (result.Name);
            this.description = (result.ElixirSuite__DescriptionField__c);  
            this.procedureCode = (result.ElixirSuite__Procedure_Codes_SF_Ids__c);
            this.labTests =(result.ElixirSuite__Lab_Tests_SF_Ids__c);
            this.diagnosisCode = (result.ElixirSuite__Diagnosis_Codes_SF_Ids__c);

                let testSfArrayId = this.labTests.split(';');
                const LabEmpty = testSfArrayId.filter((str) => str !== '');                
                for(let i=0; i < LabEmpty.length;i++){ 
                //Using SF Ids, fetching the fields of Lab test

                    fetchDataTest({test:LabEmpty[i]})
                    .then((response)=>{
                        this.selectedTests = [...this.selectedTests,{Name:response[0].Name,ElixirSuite__Test_Name__c:response[0].ElixirSuite__Test_Name__c}];
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
                        this.selectedDiagnosisCodes = [...this.selectedDiagnosisCodes,{Name:response[0].Name}];
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
                            this.selectedProcedureCodes = [...this.selectedProcedureCodes,{Name:response[0].Name}];
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
}