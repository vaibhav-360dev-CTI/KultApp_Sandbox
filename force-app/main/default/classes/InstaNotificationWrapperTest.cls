@isTest
public class InstaNotificationWrapperTest {
    
    @isTest
    static void testParse() {
        // Example JSON string to test the parse method
        String jsonString = '{' +
            '"entry": [{' +
                '"id": "0",' +
                '"time_c": 1690447351,' +
                '"changes": [{' +
                    '"field": "feed",' +
                    '"value": {' +
                        '"item": "status",' +
                        '"id": "44444444_444444444",' +
                        '"verb": "add",' +
                        '"published": 1,' +
                        '"created_time": 1690447351,' +
                        '"text": "Example post content.",' +
                        '"from_c": {' +
                            '"name": "Test Page",' +
                            '"id": "1067280970047460"' +
                        '}' +
                    '}' +
                '}]' +
            '}],' +
            '"object_c": "page"' +
        '}';
        
        // Parse the JSON string
        InstaNotificationWrapper wrapper = InstaNotificationWrapper.parse(jsonString);
        
        // Perform assertions to verify the parsing
        System.assertNotEquals(null, wrapper);
        System.assertEquals('page', wrapper.object_c);
        System.assertNotEquals(null, wrapper.entry);
        System.assertEquals(1, wrapper.entry.size());
        
        InstaNotificationWrapper.cls_entry entry = wrapper.entry[0];
        System.assertEquals('0', entry.id);
        System.assertEquals(1690447351, entry.time_c);
        System.assertNotEquals(null, entry.changes);
        System.assertEquals(1, entry.changes.size());
        
        InstaNotificationWrapper.cls_changes changes = entry.changes[0];
        System.assertEquals('feed', changes.field);
        System.assertNotEquals(null, changes.value);
        
        InstaNotificationWrapper.cls_value value = changes.value;
        System.assertEquals('status', value.item);
        System.assertEquals('44444444_444444444', value.id);
        System.assertEquals('add', value.verb);
        System.assertEquals(1, value.published);
        System.assertEquals(1690447351, value.created_time);
        System.assertEquals('Example post content.', value.text);
        
    }
    
    @isTest
    static void testParseWithEmptyJson() {
        // Test with an empty JSON string
        String jsonString = '{}';
        
        // Parse the JSON string
        InstaNotificationWrapper wrapper = InstaNotificationWrapper.parse(jsonString);
        
        // Perform assertions to verify the parsing
        System.assertNotEquals(null, wrapper);
        System.assertEquals(null, wrapper.object_c);
        System.assertEquals(null, wrapper.entry);
    }
    
    @isTest
    static void testParseWithInvalidJson() {
        // Test with an invalid JSON string
        String jsonString = 'invalid json';
        
        // Parse the JSON string
        try {
            InstaNotificationWrapper wrapper = InstaNotificationWrapper.parse(jsonString);
            System.assert(false, 'Expected JSON.deserialize exception not thrown');
        } catch (System.JSONException e) {
            // Expected exception
        }
    }
}