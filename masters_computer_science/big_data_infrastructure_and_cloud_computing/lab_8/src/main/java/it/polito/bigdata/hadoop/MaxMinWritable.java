package it.polito.bigdata.hadoop;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import org.apache.hadoop.io.Writable;

/**
 * Custom Writable type to store max and min PM10 values
 */
public class MaxMinWritable implements Writable {
    private float max;
    private float min;

    public MaxMinWritable() {
        max = Float.NEGATIVE_INFINITY;
        min = Float.POSITIVE_INFINITY;
    }

    public MaxMinWritable(float max, float min) {
        this.max = max;
        this.min = min;
    }

    public void update(float value) {
        if (value > max) max = value;
        if (value < min) min = value;
    }

    public float getMax() {
        return max;
    }

    public float getMin() {
        return min;
    }

    @Override
    public void write(DataOutput out) throws IOException {
        out.writeFloat(max);
        out.writeFloat(min);
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        max = in.readFloat();
        min = in.readFloat();
    }

    @Override
    public String toString() {
        return String.format("max=%.1f_min=%.1f", max, min);
    }
}
