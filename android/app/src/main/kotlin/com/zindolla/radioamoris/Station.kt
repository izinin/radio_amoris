package com.zindolla.radioamoris

import android.os.Parcel
import android.os.Parcelable

class Station : Parcelable {
    var id: Int
    var name: String?
    var logo: String?
    var url: String?

    private constructor(`in`: Parcel) {
        id = `in`.readInt()
        name = `in`.readString()
        logo = `in`.readString()
        url = `in`.readString()
    }

    constructor(id: Int, name: String?, logo: String?, url: String?) {
        this.id = id
        this.name = name
        this.logo = logo
        this.url = url
    }

    override fun describeContents(): Int {
        return 0
    }

    override fun writeToParcel(dest: Parcel, flags: Int) {
        dest.writeInt(id)
        dest.writeString(name)
        dest.writeString(logo)
        dest.writeString(url)
    }

    companion object {
        @JvmField
        val CREATOR: Parcelable.Creator<Station> = object : Parcelable.Creator<Station> {
            override fun createFromParcel(`in`: Parcel): Station {
                return Station(`in`)
            }

            override fun newArray(size: Int): Array<Station?> {
                return arrayOfNulls(size)
            }
        }
    }
}
