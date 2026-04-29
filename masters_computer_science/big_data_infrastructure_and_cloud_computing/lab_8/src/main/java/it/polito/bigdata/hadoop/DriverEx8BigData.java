package it.polito.bigdata.hadoop;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

/**
 * Exercise 8: Total Count
 *
 * Input format: sensorId,date,PM10_value
 * Output: ("count", total_records)
 */
public class DriverEx8BigData extends Configured implements Tool {

    @Override
    public int run(String[] args) throws Exception {

        Path inputPath = new Path(args[1]);
        Path outputDir = new Path(args[2]);
        int numberOfReducers = Integer.parseInt(args[0]);

        Configuration conf = this.getConf();
        Job job = Job.getInstance(conf);

        job.setJobName("Exercise 8: Total Count");

        FileInputFormat.addInputPath(job, inputPath);
        FileOutputFormat.setOutputPath(job, outputDir);

        job.setJarByClass(DriverEx8BigData.class);
        job.setInputFormatClass(TextInputFormat.class);
        job.setOutputFormatClass(TextOutputFormat.class);

        job.setMapperClass(MapperEx8BigData.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(LongWritable.class);

        job.setReducerClass(ReducerEx8BigData.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(LongWritable.class);

        job.setNumReduceTasks(numberOfReducers);

        int exitCode = job.waitForCompletion(true) ? 0 : 1;
        return exitCode;
    }

    public static void main(String args[]) throws Exception {
        int res = ToolRunner.run(new Configuration(), new DriverEx8BigData(), args);
        System.exit(res);
    }
}
