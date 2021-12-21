trigger ContactTrigger on SOBJECT (after insert) {
    new ContactTriggerHandler().run();
}