package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

/**
 * Exercise 11 Mapper: Top 1 Most Profitable Date
 *
 * Input format: date\tincome
 * Output: ("maxDate", "date:income")
 */
class MapperEx11BigData extends Mapper<
                    LongWritable,
                    Text,
                    Text,
                    Text> {

    private Text keyOut = new Text("maxDate");
    private Text valueOut = new Text();

    @Override
    protected void map(
            LongWritable key,
            Text value,
            Context context) throws IOException, InterruptedException {

        try {
            String[] parts = value.toString().split("\t");
            if (parts.length == 2) {
                String date = parts[0];
                String income = parts[1];
                valueOut.set(date + ":" + income);
                context.write(keyOut, valueOut);
            }
        } catch (Exception e) {
            // Skip malformed records
        }
    }
}
