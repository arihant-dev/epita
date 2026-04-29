package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

/**
 * Exercise 12 Mapper: Top 2 Most Profitable Dates
 *
 * Input format: date\tincome
 * Output: ("top2", "date:income")
 */
class MapperEx12BigData extends Mapper<
                    LongWritable,
                    Text,
                    Text,
                    Text> {

    private Text keyOut = new Text("top2");
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
