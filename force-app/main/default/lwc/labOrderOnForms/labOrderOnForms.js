import { api, LightningElement } from 'lwc';
import getLabOrderPriority from '@salesforce/apex/LabOrderOnForms.getLabOrderPriority';
import fetchLabOrders from '@salesforce/apex/LabOrderOnForms.fetchLabOrders';

export default class LabOrderOnForms extends LightningElement {
    @api accountId;
    allLabOrders = [];
    columns = [
        { label: 'Lab Order #', fieldName: 'labOrderSerial' },
        { label: 'Lab', fieldName: 'labName' },
        { label: 'Type', fieldName: 'labOrderType' },
        { label: 'Test Name', fieldName: 'testName' },
        { label: 'Status', fieldName: 'status' },
        { label: 'Created Date', fieldName: 'createdDate', type: 'date', sortable: true },
        { label: 'Last Modified Date', fieldName: 'lastModifiedDate', type: 'date' },
        { label: 'Reports', type: "button", typeAttributes: { variant: "brand-outline", label: 'Download Report', name: 'Fetch Record', value: 'Fetch record', disabled: { fieldName: 'noLabOrderResultAvailable' } } }
    ];

    defaultSortDirection = 'desc';
    sortDirection = 'desc';
    sortedBy = 'createdDate';

    allLabOrders = [];

    connectedCallback() {
        this.fetchLabOrders();
    }
get hasData() {
        return this.allLabOrders && this.allLabOrders.length > 0;
    }
    fetchLabOrders() {
        fetchLabOrders({ accountId: this.accountId })
            .then((labOrders) => {
                this.allLabOrders = labOrders;
            })
            .catch((error) => {
                console.log('Error while fetching lab orders');
                console.log(error);
            });
    }

    getLabOrderPriority() {
        return new Promise((resolve, reject) => {
            getLabOrderPriority()
                .then((result) => {
                    resolve(result);
                })
                .catch((error) => {
                    reject(error);
                });
        });
    }

    sortData() {
        let fieldName = this.sortedBy;
        let sortDirection = this.sortDirection;
        let sortResult = [...this.allLabOrders]; // Same as Object.assign([], this.data)
        let parser = (v) => v;
        let column = this.columns.find(c=>c.fieldName===fieldName);
        if(column.type==='date' || column.type==='datetime') {
          parser = (v) => (v && new Date(v));
        }
        let sortMult = sortDirection === 'asc'? 1: -1;
        this.allLabOrders = sortResult.sort((a,b) => {
          let a1 = parser(a[fieldName]), b1 = parser(b[fieldName]);
          let r1 = a1 < b1, r2 = a1 === b1;
          return r2? 0: r1? -sortMult: sortMult;
        });
      }

    onHandleSort() {
        try {
            this.sortDirection = this.sortDirection == 'asc' ? 'desc' : 'asc';
            this.sortData(); 
        } catch (error) {
         console.error(error);   
        }
    }

   onRowAction(event) {
        if (event.detail.action.name === "Fetch Record") {
            if (!event.detail.row.noLabOrderResultAvailable) {
                window.open(event.detail.row.linkToLabOrderResult, '_blank');
            }
        }
    }
}