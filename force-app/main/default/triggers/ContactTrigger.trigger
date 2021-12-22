trigger ContactTrigger on Contact (after insert, before update) {
    new ContactTriggerHandler().run();
}