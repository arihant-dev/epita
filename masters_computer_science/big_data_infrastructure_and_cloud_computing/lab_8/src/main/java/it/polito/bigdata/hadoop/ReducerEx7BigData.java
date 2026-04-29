package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * Exercise 7 Reducer: Find max and min PM10 per sensor
 *
 * Input: (sensorId, [value1, value2, ...])
 * Output: (sensorId, max=X_min=Y)
 */
class ReducerEx7BigData extends Reducer<
                Text,
                Text,
                Text,
                MaxMinWritable> {

    private MaxMinWritable result = new MaxMinWritable();

    @Override
    protected void reduce(
            Text key,
            Iterable<Text> values,
            Context context) throws IOException, InterruptedException {

        result = new MaxMinWritable();

        for (Text value : values) {
            float pm10 = Float.parseFloat(value.toString());
            result.update(pm10);
        }

        context.write(key, result);
    }
}
