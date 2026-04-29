package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

/**
 * Exercise 8 Mapper: Total Count
 *
 * Input format: sensorId,date,PM10_value
 * Output: ("count", 1) for each record to aggregate
 */
class MapperEx8BigData extends Mapper<
                    LongWritable,
                    Text,
                    Text,
                    LongWritable> {

    private Text countKey = new Text("count");
    private LongWritable one = new LongWritable(1);

    @Override
    protected void map(
            LongWritable key,
            Text value,
            Context context) throws IOException, InterruptedException {

        try {
            String[] parts = value.toString().split(",");
            if (parts.length == 3) {
                context.write(countKey, one);
            }
        } catch (Exception e) {
            // Skip malformed records
        }
    }
}
