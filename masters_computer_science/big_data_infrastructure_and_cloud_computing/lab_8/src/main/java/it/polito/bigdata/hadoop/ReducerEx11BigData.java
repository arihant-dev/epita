package it.polito.bigdata.hadoop;

import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * Exercise 11 Reducer: Find date with max income
 *
 * Input: ("maxDate", ["date1:income1", "date2:income2", ...])
 * Output: ("maxDate", "date")
 */
class ReducerEx11BigData extends Reducer<
                Text,
                Text,
                Text,
                Text> {

    private Text result = new Text();

    @Override
    protected void reduce(
            Text key,
            Iterable<Text> values,
            Context context) throws IOException, InterruptedException {

        String maxDate = "";
        long maxIncome = Long.MIN_VALUE;

        for (Text value : values) {
            String[] parts = value.toString().split(":");
            String date = parts[0];
            long income = Long.parseLong(parts[1]);

            if (income > maxIncome) {
                maxIncome = income;
                maxDate = date;
            }
        }

        result.set(maxDate);
        context.write(key, result);
    }
}
