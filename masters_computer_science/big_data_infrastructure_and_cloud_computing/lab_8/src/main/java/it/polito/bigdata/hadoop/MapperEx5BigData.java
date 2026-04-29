package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

/**
 * Exercise 5 Mapper: PM10 per Zone
 *
 * Input format: zoneId,date\tPM10_value
 * Output: (zoneId, date) for each record where PM10 > 50
 */
class MapperEx5BigData extends Mapper<
                    LongWritable,
                    Text,
                    Text,
                    Text> {

    private static final float THRESHOLD = 50.0f;
    private Text zoneId = new Text();
    private Text date = new Text();

    @Override
    protected void map(
            LongWritable key,
            Text value,
            Context context) throws IOException, InterruptedException {

        try {
            String[] parts = value.toString().split("\t");
            if (parts.length == 2) {
                float pm10Value = Float.parseFloat(parts[1]);

                String[] zoneInfo = parts[0].split(",");
                String zone = zoneInfo[0];
                String dateStr = zoneInfo[1];

                if (pm10Value > THRESHOLD) {
                    zoneId.set(zone);
                    date.set(dateStr);
                    context.write(zoneId, date);
                }
            }
        } catch (NumberFormatException e) {
            // Skip malformed records
        }
    }
}
