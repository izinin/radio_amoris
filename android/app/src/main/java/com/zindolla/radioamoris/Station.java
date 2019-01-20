package com.zindolla.radioamoris;

import android.os.Parcel;
import android.os.Parcelable;

public class Station implements Parcelable {
    int id;
    String descr;
    String url;

    private Station(Parcel in) {
        id = in.readInt();
        descr = in.readString();
        url = in.readString();
    }

    Station(int id, String descr, String url) {
        this.id = id;
        this.descr = descr;
        this.url = url;
    }

    public static final Creator<Station> CREATOR = new Creator<Station>() {
        @Override
        public Station createFromParcel(Parcel in) {
            return new Station(in);
        }

        @Override
        public Station[] newArray(int size) {
            return new Station[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(id);
        dest.writeString(descr);
        dest.writeString(url);
    }
}
