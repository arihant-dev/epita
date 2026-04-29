package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * Exercise 6 Reducer: Calculate average PM10 per sensor
 *
 * Input: (sensorId, [value1, value2, ...])
 * Output: (sensorId, average)
 */
class ReducerEx6BigData extends Reducer<
                Text,
                Text,
                Text,
                Text> {

    private Text result = new Text();

    @Override
    protected void reduce(
            Text key,
            Iterable<Text> values,
            Context context) throws IOException, InterruptedException {

        float sum = 0.0f;
        int count = 0;

        for (Text value : values) {
            sum += Float.parseFloat(value.toString());
            count++;
        }

        float average = sum / count;
        result.set(String.format("%.1f", average));
        context.write(key, result);
    }
}
