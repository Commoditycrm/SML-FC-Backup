trigger PalletLocationEventTrigger on Pallet_Location_Event__e (after insert) {
    
    //AssetEventProcessor processor = new AssetEventProcessor(trigger.new);
    //processor.process();
    ProcessAPIResponse.process(trigger.new);
    
}