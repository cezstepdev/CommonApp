import { LightningElement, track } from 'lwc';
import getIncomingCalls from '@salesforce/apex/CallController.getIncomingCalls';
import { NavigationMixin } from 'lightning/navigation';

export default class IncomingMeets extends NavigationMixin(
    LightningElement
) {
    @track calls;

    connectedCallback() {
        this.getCalls();
    }

    getCalls(){
        getIncomingCalls()
        .then(result => {
            this.calls = result;
        })
        .catch(error => {
            this.error = error;
        });   
    }

    goToCall(event){
        let id = this.calls[event.target.dataset.index].Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'Call__c',
                actionName: 'view'
            }
        });
    }

    goToAccount(event){
        let id = this.calls[event.target.dataset.index].account.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
}