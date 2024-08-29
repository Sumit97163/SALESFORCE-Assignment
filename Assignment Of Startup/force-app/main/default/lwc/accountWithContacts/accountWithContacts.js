// Processed Accounts with Contacts data
import { LightningElement, track, wire } from 'lwc';
import getAccountsWithContacts from '@salesforce/apex/AccountWithContactsController.getAccountsWithContacts';
import getAccountsCount from '@salesforce/apex/AccountWithContactsController.getAccountsCount';

export default class AccountWithContacts extends LightningElement {
    @track accounts = [];
    @track currentPage = 1;
    @track totalRecords;
    @track pageSize = 10; // Set the number of records per page
    @track totalPages;
    @track error;

    @track columns = [
        { label: 'Account Name', fieldName: 'Name' },
        { label: 'Contact Names', fieldName: 'ContactNames' }
    ];

    connectedCallback() {
        this.loadAccounts();
    }

    loadAccounts() {
        const offset = (this.currentPage - 1) * this.pageSize;

        // Fetch total number of accounts to calculate total pages
        getAccountsCount()
            .then(count => {
                this.totalRecords = count;
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
            })
            .catch(error => {
                this.handleErrors(error, 'Error fetching account count');
            });

        // Fetch accounts with contacts based on the current page and page size
        getAccountsWithContacts({ recordOffset: offset, recordLimit: this.pageSize })
            .then(data => {
                this.accounts = data.map(acc => {
                    let contactNames = acc.Contacts ? acc.Contacts.map(con => `${con.FirstName} ${con.LastName}`).join(', ') : 'No Contacts';
                    return { ...acc, ContactNames: contactNames };
                });
                this.error = undefined;
            })
            .catch(error => {
                this.handleErrors(error, 'Error fetching accounts');
            });
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.loadAccounts();
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.loadAccounts();
        }
    }

    get disablePrevious() {
        return this.currentPage <= 1;
    }

    get disableNext() {
        return this.currentPage >= this.totalPages;
    }

    // Utility method for error handling
    handleErrors(error, customMessage) {
        if (error && error.body && error.body.message) {
            this.error = customMessage + ': ' + error.body.message;
        } else {
            this.error = customMessage + ': ' + (error ? error.message : 'Unknown error');
        }
        this.accounts = [];
    }
}
