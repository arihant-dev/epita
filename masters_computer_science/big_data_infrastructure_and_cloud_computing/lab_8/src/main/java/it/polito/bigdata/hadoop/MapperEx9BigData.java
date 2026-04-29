package it.polito.bigdata.hadoop;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

/**
 * Exercise 9 Mapper: Average PM10 with In-Mapper Combiner
 *
 * Input format: sensorId,date,PM10_value
 * Output in map: (sensorId, "sum,count")
 * Uses in-mapper combiner pattern for efficiency
 */
class MapperEx9BigData extends Mapper<
                    LongWritable,
                    Text,
                    Text,
                    Text> {

    private Map<String, double[]> sensorStats = new HashMap<>();

    @Override
    protected void map(
            LongWritable key,
            Text value,
            Context context) throws IOException, InterruptedException {

        try {
            String[] parts = value.toString().split(",");
            if (parts.length == 3) {
                String sensor = parts[0];
                double pm10 = Double.parseDouble(parts[2]);

                if (!sensorStats.containsKey(sensor)) {
                    sensorStats.put(sensor, new double[]{0, 0});
                }

                double[] stats = sensorStats.get(sensor);
                stats[0] += pm10;  // sum
                stats[1] += 1;     // count
            }
        } catch (Exception e) {
            // Skip malformed records
        }
    }

    @Override
    protected void cleanup(Context context) throws IOException, InterruptedException {
        Text sensorId = new Text();
        Text statValue = new Text();

        for (Map.Entry<String, double[]> entry : sensorStats.entrySet()) {
            sensorId.set(entry.getKey());
            double[] stats = entry.getValue();
            statValue.set(stats[0] + "," + (long)stats[1]);
            context.write(sensorId, statValue);
        }
    }
}
