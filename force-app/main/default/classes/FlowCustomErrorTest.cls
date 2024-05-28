@IsTest
public class FlowCustomErrorTest {
    
    @IsTest
    static void testThrowCustomFlowException() {
        FlowCustomError.Inputs input = new FlowCustomError.Inputs();
        input.message = 'Test error message';

        FlowCustomError.Inputs[] inputs = new FlowCustomError.Inputs[]{input};
        
        try {

            FlowCustomError.throwCustomFlowException(inputs);
            System.assert(false, 'Expected CustomException was not thrown.');
        } catch (FlowCustomError.CustomException ex) {
            System.assertEquals('Test error message', ex.getMessage(), 'The exception message does not match.');
        } catch (Exception ex) {
        }
    }
}