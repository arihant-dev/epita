package it.polito.bigdata.hadoop;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

/**
 * Exercise 4: PM10 Pollution Analysis
 *
 * Description:
 * For each sensor, count the number of days with PM10 above 50 μg/m³.
 * Only report sensors with at least one day above threshold.
 *
 * Input format: sensorId,date\tPM10_value
 *
 * Usage:
 * hadoop jar target/MapReduceProject-1.0.0.jar \
 *     it.polito.bigdata.hadoop.DriverEx4BigData \
 *     <num_reducers> <input_path> <output_path>
 */
public class DriverEx4BigData extends Configured implements Tool {

    @Override
    public int run(String[] args) throws Exception {

        Path inputPath;
        Path outputDir;
        int numberOfReducers;
        int exitCode;

        // Parse parameters
        numberOfReducers = Integer.parseInt(args[0]);
        inputPath = new Path(args[1]);
        outputDir = new Path(args[2]);

        Configuration conf = this.getConf();
        Job job = Job.getInstance(conf);

        // Job configuration
        job.setJobName("Exercise 4: PM10 Pollution Analysis");

        FileInputFormat.addInputPath(job, inputPath);
        FileOutputFormat.setOutputPath(job, outputDir);

        job.setJarByClass(DriverEx4BigData.class);

        // Set input/output formats
        job.setInputFormatClass(TextInputFormat.class);
        job.setOutputFormatClass(TextOutputFormat.class);

        // Set mapper
        job.setMapperClass(MapperEx4BigData.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);

        // Set reducer
        job.setReducerClass(ReducerEx4BigData.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        // Number of reducers
        job.setNumReduceTasks(numberOfReducers);

        // Execute job
        if (job.waitForCompletion(true) == true)
            exitCode = 0;
        else
            exitCode = 1;

        return exitCode;
    }

    public static void main(String args[]) throws Exception {
        int res = ToolRunner.run(new Configuration(), new DriverEx4BigData(), args);
        System.exit(res);
    }
}
