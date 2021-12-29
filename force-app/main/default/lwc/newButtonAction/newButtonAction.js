import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getOpps from '@salesforce/apex/CallController1.getOpps';
import addCall from "@salesforce/apex/CallController1.addCall";

const columns = [{
    label: 'Name',
    fieldName: 'Name',
    type: 'text',
    sortable: true
}];

export default class newButtonAction extends NavigationMixin(
  LightningElement
) {
   
    selectedAccount;
    selectedRows = [];
    selectedOption = 'account';
    @track value;
    @track error;
    @track data;
    @api sortedDirection = 'asc';
    @api sortedBy = 'Name';
    @api searchKey = '';
    result;
    @track items = []; 
    @track data = []; 
    @track columns; 
    callDate;
    callType = 'Szkolenie';

    connectedCallback() {
        this.callDate = this.currentDate = new Date().toISOString();
    }

    handleAccountSelection(event) {
        this.selectedAccount = event.target.value;
    }

    navigateToObjectHome() {
        this.closeBillingprocessModal = false;
        this[NavigationMixin.Navigate]({
        type: "standard__objectPage",
        attributes: {
            objectApiName: "Call__c",
            actionName: "list"
        }
        });
    }

    onSwitchChange(event) {
        this.selectedOption = event.target.value;
    }

    get isAccountSelected() {
        return this.selectedOption == "account" ? true : false;
    }

    get options() {
        return [
            { label: 'Group', value: 'account' },
            { label: 'Member', value: 'members' },
        ];
    }
  
    @wire(getOpps, {searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection'})
    wiredAccounts({ error, data }) {
        if (data) {
            this.data = data;
            this.columns = columns;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    } 
    
    sortColumns( event ) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        return refreshApex(this.result);
        
    }
  
    handleKeyChange( event ) {
        this.searchKey = event.target.value;
        return refreshApex(this.result);
    }

    getSelectedProducts() {
        if(this.template.querySelector('lightning-datatable')) {
            let selectedProducts = this.template.querySelector('lightning-datatable').getSelectedRows();
            selectedProducts.forEach(element => {
                this.selectedRows.push(element.Id);
            })
        }
    }

    onDateChange(event) {
        this.callDate = event.target.value;
        console.log(event.target.value);
    }

    onTypeChange(event) {
        this.callType = event.target.value;
    }
    
    onSaveClick() {
        this.getSelectedProducts();
        let call = {
            accountId: this.selectedAccount,
            callDate: this.callDate,
            members: this.selectedRows,
            callType: this.callType
        };

        addCall({myCall: call}).then(res => {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: res,
                    actionName: 'view'
                }
            });
        });
    }
}