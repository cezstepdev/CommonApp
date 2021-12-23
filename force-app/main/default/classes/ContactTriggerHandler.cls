public with sharing class ContactTriggerHandler extends TriggerHandler {
    private List<Contact> newList;
    private List<Contact> oldList;
    private Map<Id, Contact> newMap;
    private Map<Id, Contact> oldMap;

    public ContactTriggerHandler () {
        this.newList = Trigger.new;
        this.oldList = Trigger.old;
        this.newMap = (Map<Id, Contact>)Trigger.newMap;
        this.oldMap = (Map<Id, Contact>)Trigger.oldMap;
    }

    public override void afterInsert() {
        handleAccountNameChange();
    }
    public override void beforeUpdate() {
        handleAccountNameChange();
    }
    public void handleAccountNameChange(){
        Account account = [SELECT Name FROM Account WHERE Id = :newList.get(0).AccountId];
        account.Name = '';

        for (Contact contact : [SELECT FirstName FROM Contact WHERE AccountId = :account.Id]) {
            account.Name += contact.FirstName + ' ';
        }
        update account;
    }
}
