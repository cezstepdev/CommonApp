import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getOpps from '@salesforce/apex/FirstClass.getOpps';
import addCall from "@salesforce/apex/FirstClass.addCall";

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
    selectedRows;
    callDate;
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
        let selectedProducts = this.template.querySelector('lightning-datatable').getSelectedRows();
        selectedProducts.forEach(element => {
            this.selectedRows.push(element.id);
        })
    }

    onDateChange(event) {
        this.callDate = event.target.value;
    }
    
    onSaveClick() {
        this.getSelectedProducts();
        console.log(this.selectedRows);
        addCall({
            accountId: this.selectedAccount,
            callDate: this.callDate,
            members: this.selectedRows
        }).then(res => {
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