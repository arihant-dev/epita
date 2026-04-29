package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

/**
 * Exercise 4 Mapper: PM10 Pollution Analysis
 *
 * Input format: sensorId,date\tPM10_value
 * Output: (sensorId, 1) for each record where PM10 > threshold (50)
 *
 * Process:
 * - Parse each line: extract sensorId and PM10 value
 * - Filter: only emit if PM10 > 50 μg/m³
 * - Mapper emits (sensorId, 1) for counting
 */
class MapperEx4BigData extends Mapper<
                    LongWritable,  // Input key type
                    Text,          // Input value type
                    Text,          // Output key type
                    IntWritable> { // Output value type

    private static final float THRESHOLD = 50.0f;
    private Text sensorId = new Text();
    private IntWritable one = new IntWritable(1);

    @Override
    protected void map(
            LongWritable key,   // Input key (file offset)
            Text value,         // Input value (line)
            Context context) throws IOException, InterruptedException {

        try {
            // Split by tab: sensorId,date \t PM10_value
            String[] parts = value.toString().split("\t");

            if (parts.length == 2) {
                // Extract PM10 value from second part
                float pm10Value = Float.parseFloat(parts[1]);

                // Extract sensorId from first part (before comma)
                String[] sensorInfo = parts[0].split(",");
                String sensor = sensorInfo[0];

                // Filter: only emit if PM10 > threshold
                if (pm10Value > THRESHOLD) {
                    sensorId.set(sensor);
                    context.write(sensorId, one);
                }
            }
        } catch (NumberFormatException e) {
            // Skip malformed records
        }
    }
}
