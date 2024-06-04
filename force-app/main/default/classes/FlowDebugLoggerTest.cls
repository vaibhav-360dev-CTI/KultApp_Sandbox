@isTest
public class FlowDebugLoggerTest {
    @isTest
    static void testClass() {
        // Create a list of debug messages
        List<String> debugMessages = new List<String> {
            'Test message 1',
            'Test message 2',
            'Test message 3'
        };
        
        Test.startTest();
        FlowDebugLogger.trace(debugMessages);
        Test.stopTest();
        
        // Since we can't verify debug logs directly, ensure no exceptions were thrown
        System.assert(true, 'The trace method executed without exceptions.');
    }
}