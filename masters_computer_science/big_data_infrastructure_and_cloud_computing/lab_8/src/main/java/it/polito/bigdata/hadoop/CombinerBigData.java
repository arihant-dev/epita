package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * Exercise 3: Combiner for Word Count
 *
 * A Combiner performs local pre-aggregation on the mapper node
 * to reduce network traffic during the shuffle and sort phase.
 *
 * Since word count addition is commutative and associative,
 * the same logic as the Reducer can be used here.
 */
class CombinerBigData extends Reducer<
                Text,           // Input key type
                IntWritable,    // Input value type
                Text,           // Output key type
                IntWritable> {  // Output value type

    @Override

    protected void reduce(
        Text key, // Input key type
        Iterable<IntWritable> values, // Input value type
        Context context) throws IOException, InterruptedException {

        int occurrences = 0;

        // Iterate over the set of values and sum them locally
        for (IntWritable value : values) {
            occurrences = occurrences + value.get();
        }

        // Emit the local sum to reduce network traffic
        context.write(key, new IntWritable(occurrences));
    }
}
