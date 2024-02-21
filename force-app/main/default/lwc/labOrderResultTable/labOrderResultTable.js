import { LightningElement, wire, api, track } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/Result_CHC';
import My_Resource_Image from '@salesforce/resourceUrl/ResultImageCHC';
import { publish, MessageContext } from 'lightning/messageService';
import getTestResultsLWC from '@salesforce/apex/LabOrderDetails.getTestResultsLWC';
import fetchIsPrintMC from '@salesforce/messageChannel/FetchLabIsPrint__c';
import { loadStyle } from 'lightning/platformResourceLoader';
import datatablestyles from '@salesforce/resourceUrl/datatablestyles';
import datatablestylesRed from '@salesforce/resourceUrl/datatablestylesRed';
const columns = [{
    label: 'Name',
    fieldName: 'ElixirSuite__Test_Result_Detail_Name__c', hideDefaultActions : 'true'
   
},
{ label: 'Result', fieldName: 'ElixirSuite__DataforTrends__c' , hideDefaultActions : 'true' },
{
    fieldName: '',
    label: '',
    type: 'button-icon',
    typeAttributes: { iconName: 'utility:lower_flag',
                      name: 'flag',
                      iconClass: {fieldName: 'iconColour'}},
    hideDefaultActions : 'true'
},
{ label: 'Normal Range', fieldName: 'ElixirSuite__References_Range__c' , hideDefaultActions : 'true'},
{
    label: 'Units',
    fieldName: 'ElixirSuite__Units__c', hideDefaultActions : 'true'
    
},
{ label: 'Observations', fieldName: 'ElixirSuite__Observation_Value__c', hideDefaultActions : 'true'},
{ label: 'Note', fieldName: 'ElixirSuite__Notes__c', hideDefaultActions : 'true'}
];
export default class LabOrderResultTable extends LightningElement {

    @track nameSpace='ElixirSuite__'
    @track hl7data ='';
    columns = columns;
    data =''; 
    myVal = My_Resource ;
    ecgImg = My_Resource_Image;
    @track
    image;
    result;
    error;
    @api rid;
    @api testdatalength;
    havedata = false;
    @api collectiontime;
    imagedata = '';
    @track fid;
    @track imageCount = 0;
    @track dataLength = 0;
    @track alldatalength = 0;

    connectedCallback(){
        loadStyle(this, datatablestyles);
        loadStyle(this, datatablestylesRed);
    }
resultWrapper;
   
    @wire(getTestResultsLWC, {r_id : "$rid"})
    testresult(result){
        if (result.data) {
            console.log('labOrders1'+JSON.stringify(result.data));
            this.resultWrapper = result.data;
            console.log('labOrders2'+JSON.stringify(this.resultWrapper));
             console.log('labOrders3'+JSON.stringify(this.resultWrapper.labOrders));

      // Iterate over labOrders and collect all attachments in aLbas array
var aLbas = [];

this.resultWrapper.labOrders.forEach(labOrder => {
    // Perform logic with each labOrder
    console.log('labOrders' + JSON.stringify(labOrder.Attachments));

    if (labOrder.Attachments && labOrder.Attachments.length > 0) {
        labOrder.Attachments.forEach(attached => {
            // Add each attachment to the aLbas array
            aLbas.push(attached);
        });
    }
});

console.log('aLbas', aLbas);

// Get the length of testResults
this.testdatalength = this.resultWrapper.testResults ? this.resultWrapper.testResults.length : 0;
console.log('this.testdatalength', this.testdatalength);
           
// Check if testResults are present and aLbas is not empty
if (this.testdatalength > 0 && aLbas.length > 0) {
    // Iterate over aLbas array
    aLbas.forEach(attachment => {
        // Check if the attachment name starts with 'pdfReport'
        if (attachment.Name && attachment.Name.startsWith('pdfReport')) {
               this.havedata = true;
        this.dispatchEvent(
            new CustomEvent('havechange', {
                detail: { havedata: this.havedata }
            })
            );
           }
            });
}


            this.data = JSON.parse(JSON.stringify(this.resultWrapper.testResults));
            console.log('test res data : '+JSON.stringify(this.resultWrapper.testResults));
            
            for(var i = 0; i < this.data.length; i++){
                if(this.data[i].ElixirSuite__Observation_Value__c == 'Normal' || this.data[i].ElixirSuite__Observation_Value__c == undefined){
                    this.data[i].iconColour = 'myCustomDatatableIconColor'
                }else{
                    this.data[i].iconColour = 'myCustomDatatableIconColorRed'
                }
            }
           
            //this.data[0].image = this.image;
            console.log(' before parsing testdatalength '+ this.testdatalength);
            window.console.log('data '+this.data.length);
            //if(this.data.length > 0 ){
            this.alldatalength = parseInt(this.data.length) + parseInt(this.testdatalength);
            this.dataLength = this.data.length;
           // }
            this.error = undefined;
            console.log('After set data '+this.dataLength);
            console.log('testdatalength '+ this.testdatalength);
            console.log('Alldatalength '+ this.alldatalength);

            
        }
        
        else if (result.error) {
                
            
            this.error = result.error;
            this.data = undefined;
            window.console.log(this.error);
            
        }
        
        
    }
    @track phone;
    @track age;
    @track patientName = '';
    @track gender = '';
    @track patientID = '';
    @track dateOfBirth ;
    @track ssn = 'NA';
    @track physicianName = '';
    @track ReqNo = '';
    @track AccessionNo = '';
    @wire(MessageContext)
    messageContext;

    disablePrint(){
        const payload = { isPrint: false };
        publish(this.messageContext, fetchIsPrintMC, payload);
    }
    @track facilityName;
    @track facilityAddress;
    @track reportDate = 'NA';
    handleFacilityReportDateTime(){
        window.console.log('facility id' + this.fid);
        getFacilityDetails({f_id : this.fid})
        .then((result) => {
            
            this.error = undefined;
            this.facilityName = result.Name;
            this.facilityAddress = result[this.nameSpace+'Address__c'];
            //window.console.log(JSON.stringify(result));
            //window.console.log('facilityInfo '+JSON.stringify(this.facilityInfo));
        })
        .catch((error) => {
            this.error = error;
            //this.returnedOrderID = undefined;
            window.console.log('getFacilityDetails Function Call NOT Completed!!');
            window.console.log('ERROR : '+error.body.message);
        });
        getReportDate({r_id : this.rid})
        .then((result) => {
            
            this.error = undefined;
            this.reportDate = result[this.nameSpace+'Results_RptStatus_Change_Date_Time__c'];
           
           window.console.log('obr data ' +JSON.stringify(result));
        })
        .catch((error) => {
            this.error = error;
            //this.returnedOrderID = undefined;
            window.console.log('getReportDate Function Call NOT Completed!!');
            window.console.log('ERROR : '+error.body.message);
        });
        calculateAge({dob : this.hl7data[this.nameSpace+'PID_Date_of_Birth__c']})
        .then((result) => {
            
            this.error = undefined;
            this.age = result;
           
           window.console.log('obr data ' +JSON.stringify(result));
        })
        .catch((error) => {
            this.error = error;
            //this.returnedOrderID = undefined;
            window.console.log('getReportDate Function Call NOT Completed!!');
            window.console.log('ERROR : '+error.body.message);
        });
    }

}