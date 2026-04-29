package it.polito.bigdata.hadoop;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * Exercise 12 Reducer: Find top 2 dates with max income
 *
 * Input: ("top2", ["date1:income1", "date2:income2", ...])
 * Output: ("top2", "date1,date2") sorted by income descending
 */
class ReducerEx12BigData extends Reducer<
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

        List<DateIncome> list = new ArrayList<>();

        for (Text value : values) {
            String[] parts = value.toString().split(":");
            String date = parts[0];
            long income = Long.parseLong(parts[1]);
            list.add(new DateIncome(date, income));
        }

        // Sort by income descending
        Collections.sort(list, new Comparator<DateIncome>() {
            public int compare(DateIncome a, DateIncome b) {
                return Long.compare(b.income, a.income);
            }
        });

        // Get top 2
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < Math.min(2, list.size()); i++) {
            if (i > 0) sb.append(",");
            sb.append(list.get(i).date);
        }

        result.set(sb.toString());
        context.write(key, result);
    }

    private static class DateIncome {
        String date;
        long income;

        DateIncome(String date, long income) {
            this.date = date;
            this.income = income;
        }
    }
}
