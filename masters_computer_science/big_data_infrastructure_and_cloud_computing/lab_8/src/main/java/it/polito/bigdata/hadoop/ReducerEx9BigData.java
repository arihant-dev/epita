package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * Exercise 9 Reducer: Calculate final average
 *
 * Input: (sensorId, ["sum,count", "sum,count", ...])
 * Output: (sensorId, average)
 */
class ReducerEx9BigData extends Reducer<
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

        double totalSum = 0;
        long totalCount = 0;

        for (Text value : values) {
            String[] parts = value.toString().split(",");
            totalSum += Double.parseDouble(parts[0]);
            totalCount += Long.parseLong(parts[1]);
        }

        double average = totalSum / totalCount;
        result.set(String.format("%.1f", average));
        context.write(key, result);
    }
}
