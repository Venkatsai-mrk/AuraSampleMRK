import { LightningElement, wire } from 'lwc';
import getProviderPaymentWrapper from '@salesforce/apex/PortalBillingClass.getProviderPaymentWrapper';

export default class CommunityBillingOverView extends LightningElement {
    providerPaymentWrappers = [];

    @wire(getProviderPaymentWrapper)
    wiredProviderPaymentWrapper({ error, data }) {
        if (data) {
            console.log('data ' + JSON.stringify(data));
            this.providerPaymentWrappers = data.map(wrapper => ({
                accDetails: wrapper.accDetails,
                provider: wrapper.provider,
                totalRemainingAmount: wrapper.totalRemainingAmount,
                imageUrls: wrapper.imageUrls
            }));
            console.log('this.providerPaymentWrappers ' + JSON.stringify(this.providerPaymentWrappers));
        } else if (error) {
            console.error('Error fetching provider payment wrapper data:', error);
        }
    }
}