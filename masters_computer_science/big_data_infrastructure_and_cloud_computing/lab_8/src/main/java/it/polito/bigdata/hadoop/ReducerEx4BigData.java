package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * Exercise 4 Reducer: Count days with PM10 above threshold per sensor
 *
 * Input: (sensorId, [1, 1, 1, ...]) - only for days with PM10 > 50
 * Output: (sensorId, count) - only if count > 0
 *
 * Process:
 * - Sum the 1's emitted by mapper for each sensor
 * - This gives the number of days with PM10 > threshold
 * - Only output sensors with at least 1 day above threshold
 */
class ReducerEx4BigData extends Reducer<
                Text,           // Input key type
                IntWritable,    // Input value type
                Text,           // Output key type
                IntWritable> {  // Output value type

    private IntWritable result = new IntWritable();

    @Override
    protected void reduce(
            Text key,                        // sensorId
            Iterable<IntWritable> values,    // counts
            Context context) throws IOException, InterruptedException {

        int daysAboveThreshold = 0;

        // Sum all the 1's (days above threshold)
        for (IntWritable value : values) {
            daysAboveThreshold += value.get();
        }

        // Only output sensors with at least one day above threshold
        if (daysAboveThreshold > 0) {
            result.set(daysAboveThreshold);
            context.write(key, result);
        }
    }
}
