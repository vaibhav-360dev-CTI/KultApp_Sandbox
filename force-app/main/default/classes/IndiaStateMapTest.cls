@isTest
public class IndiaStateMapTest {
    @isTest
    static void testGetIndiaStateMap() {
        // Call the method to get the map
        Map<String, List<String>> result = IndiaStateMap.getIndiaStateMap();
        
        // Define the expected list of states
        List<String> expectedStates = new List<String>{
            'Andaman and Nicobar Islands',
            'Andhra Pradesh',
            'Arunachal Pradesh',
            'Assam',
            'Bihar',
            'Chandigarh',
            'Chhattisgarh',
            'Dadra and Nagar Haveli',
            'Daman and Diu',
            'Delhi',
            'Goa',
            'Gujarat',
            'Haryana',
            'Himachal Pradesh',
            'Jammu and Kashmir',
            'Jharkhand',
            'Karnataka',
            'Kerala',
            'Lakshadweep',
            'Madhya Pradesh',
            'Maharashtra',
            'Manipur',
            'Meghalaya',
            'Mizoram',
            'Nagaland',
            'Odisha',
            'Puducherry',
            'Punjab',
            'Rajasthan',
            'Sikkim',
            'Tamil Nadu',
            'Tripura',
            'Uttarakhand',
            'Uttar Pradesh',
            'West Bengal'
        };
        
        // Verify that the result contains the key 'India'
        System.assert(result.containsKey('India'), 'Map should contain key "India"');
        
        // Verify that the list of states is correct
        System.assertEquals(expectedStates, result.get('India'), 'The list of states for key "India" is incorrect');
    }
}