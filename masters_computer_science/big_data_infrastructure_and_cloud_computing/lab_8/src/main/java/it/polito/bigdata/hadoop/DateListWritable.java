package it.polito.bigdata.hadoop;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.hadoop.io.Writable;

/**
 * Custom Writable type to store a list of dates for PM10 analysis
 */
public class DateListWritable implements Writable {
    private List<String> dates;

    public DateListWritable() {
        dates = new ArrayList<>();
    }

    public DateListWritable(List<String> dates) {
        this.dates = new ArrayList<>(dates);
    }

    public void addDate(String date) {
        dates.add(date);
    }

    public List<String> getDates() {
        return dates;
    }

    @Override
    public void write(DataOutput out) throws IOException {
        out.writeInt(dates.size());
        for (String date : dates) {
            out.writeUTF(date);
        }
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        dates.clear();
        int size = in.readInt();
        for (int i = 0; i < size; i++) {
            dates.add(in.readUTF());
        }
    }

    @Override
    public String toString() {
        return dates.toString();
    }
}
