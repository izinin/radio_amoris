package com.zindolla.myradio;

import android.os.Parcel;
import android.os.Parcelable;

public class Station implements Parcelable {
    int id;
    String name;
    String logo;
    String url;

    private Station(Parcel in) {
        id = in.readInt();
        name = in.readString();
        logo = in.readString();
        url = in.readString();
    }

    Station(int id, String name, String logo, String url) {
        this.id = id;
        this.name = name;
        this.logo = logo;
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
        dest.writeString(name);
        dest.writeString(logo);
        dest.writeString(url);
    }
}
