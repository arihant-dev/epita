package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

/**
 * Exercise 6 Mapper: Average PM10 per sensor
 *
 * Input format: sensorId,date,PM10_value
 * Output: (sensorId, PM10_value) for each record
 */
class MapperEx6BigData extends Mapper<
                    LongWritable,
                    Text,
                    Text,
                    Text> {

    private Text sensorId = new Text();
    private Text pm10Value = new Text();

    @Override
    protected void map(
            LongWritable key,
            Text value,
            Context context) throws IOException, InterruptedException {

        try {
            String[] parts = value.toString().split(",");
            if (parts.length == 3) {
                String sensor = parts[0];
                String pm10 = parts[2];

                sensorId.set(sensor);
                pm10Value.set(pm10);
                context.write(sensorId, pm10Value);
            }
        } catch (Exception e) {
            // Skip malformed records
        }
    }
}
