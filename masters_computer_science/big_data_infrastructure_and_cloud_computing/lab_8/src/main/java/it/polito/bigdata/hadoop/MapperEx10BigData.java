package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

/**
 * Exercise 10 Mapper: Select Outliers below threshold
 *
 * Input format: sensorId,date,PM10_value
 * Output: (sensorId, "date,PM10_value") if PM10 < threshold
 * Configuration: threshold value passed from driver
 */
class MapperEx10BigData extends Mapper<
                    LongWritable,
                    Text,
                    Text,
                    Text> {

    private double threshold;
    private Text sensorId = new Text();
    private Text record = new Text();

    @Override
    protected void setup(Context context) {
        threshold = Double.parseDouble(
            context.getConfiguration().get("threshold", "40.0")
        );
    }

    @Override
    protected void map(
            LongWritable key,
            Text value,
            Context context) throws IOException, InterruptedException {

        try {
            String[] parts = value.toString().split(",");
            if (parts.length == 3) {
                String sensor = parts[0];
                String date = parts[1];
                double pm10 = Double.parseDouble(parts[2]);

                if (pm10 < threshold) {
                    sensorId.set(sensor);
                    record.set(date + "," + pm10);
                    context.write(sensorId, record);
                }
            }
        } catch (Exception e) {
            // Skip malformed records
        }
    }
}
