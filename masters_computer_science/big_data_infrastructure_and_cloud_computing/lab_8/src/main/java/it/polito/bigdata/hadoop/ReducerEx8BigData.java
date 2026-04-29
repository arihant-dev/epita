package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * Exercise 8 Reducer: Sum total count
 *
 * Input: ("count", [1, 1, 1, ...])
 * Output: ("count", total_number)
 */
class ReducerEx8BigData extends Reducer<
                Text,
                LongWritable,
                Text,
                LongWritable> {

    private LongWritable result = new LongWritable();

    @Override
    protected void reduce(
            Text key,
            Iterable<LongWritable> values,
            Context context) throws IOException, InterruptedException {

        long sum = 0;
        for (LongWritable value : values) {
            sum += value.get();
        }

        result.set(sum);
        context.write(key, result);
    }
}
