package it.polito.bigdata.hadoop;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * Exercise 5 Reducer: Collect all dates with PM10 > 50 per zone
 *
 * Input: (zoneId, [date1, date2, ...])
 * Output: (zoneId, [date1, date2, ...])
 */
class ReducerEx5BigData extends Reducer<
                Text,
                Text,
                Text,
                DateListWritable> {

    private DateListWritable dateList = new DateListWritable();

    @Override
    protected void reduce(
            Text key,
            Iterable<Text> values,
            Context context) throws IOException, InterruptedException {

        dateList = new DateListWritable();

        for (Text date : values) {
            dateList.addDate(date.toString());
        }

        context.write(key, dateList);
    }
}
