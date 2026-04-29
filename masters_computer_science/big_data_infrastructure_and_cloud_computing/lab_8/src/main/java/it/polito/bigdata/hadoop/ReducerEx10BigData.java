package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * Exercise 10 Reducer: Pass-through (identity) reducer
 *
 * Input: (sensorId, [records])
 * Output: (sensorId, records)
 */
class ReducerEx10BigData extends Reducer<
                Text,
                Text,
                Text,
                Text> {

    @Override
    protected void reduce(
            Text key,
            Iterable<Text> values,
            Context context) throws IOException, InterruptedException {

        for (Text value : values) {
            context.write(key, value);
        }
    }
}
