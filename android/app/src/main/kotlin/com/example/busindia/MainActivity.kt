package com.example.busindia

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.CellInfo
import android.telephony.CellInfoCdma
import android.telephony.CellInfoGsm
import android.telephony.CellInfoLte
import android.telephony.CellInfoNr
import android.telephony.CellInfoWcdma
import android.telephony.CellSignalStrengthNr
import android.telephony.CellIdentityNr
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Reads the device's serving cell tower(s) and exposes them to Flutter over a
 * MethodChannel. This is the same primitive "Where is My Train" relies on to
 * locate a train without GPS — the cellular modem already knows which tower it
 * is camped on, so we can infer position from a crowd-sourced tower→stop map.
 */
class MainActivity : FlutterActivity() {

    private val channelName = "com.busindia/cell_tower"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isSupported" -> result.success(true)
                    "hasPermission" -> result.success(hasCellPermission())
                    "requestPermission" -> {
                        requestCellPermission()
                        // The dialog is async; report current state immediately.
                        result.success(hasCellPermission())
                    }
                    "getServingCells" -> getServingCells(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasCellPermission(): Boolean {
        val fine = ContextCompat.checkSelfPermission(
            this, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        val phone = ContextCompat.checkSelfPermission(
            this, Manifest.permission.READ_PHONE_STATE
        ) == PackageManager.PERMISSION_GRANTED
        return fine && phone
    }

    private fun requestCellPermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.READ_PHONE_STATE
            ),
            7321
        )
    }

    private fun getServingCells(result: MethodChannel.Result) {
        if (!hasCellPermission()) {
            result.error("PERMISSION_DENIED", "Location/phone permission not granted", null)
            return
        }

        val tm = getSystemService(TELEPHONY_SERVICE) as? TelephonyManager
        if (tm == null) {
            result.error("NO_TELEPHONY", "TelephonyManager unavailable", null)
            return
        }

        try {
            val mccMnc = tm.networkOperator ?: ""
            val homeMcc = if (mccMnc.length >= 3) mccMnc.substring(0, 3) else ""
            val homeMnc = if (mccMnc.length > 3) mccMnc.substring(3) else ""

            val cells = ArrayList<HashMap<String, Any?>>()
            val infos: List<CellInfo>? = tm.allCellInfo
            if (infos != null) {
                for (info in infos) {
                    parseCell(info, homeMcc, homeMnc)?.let { cells.add(it) }
                }
            }
            result.success(cells)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, null)
        } catch (e: Exception) {
            result.error("READ_FAILED", e.message, null)
        }
    }

    private fun parseCell(info: CellInfo, homeMcc: String, homeMnc: String): HashMap<String, Any?>? {
        val map = HashMap<String, Any?>()
        map["isRegistered"] = info.isRegistered

        when (info) {
            is CellInfoLte -> {
                val id = info.cellIdentity
                val ss = info.cellSignalStrength
                map["radioType"] = "lte"
                map["mcc"] = id.mccString ?: homeMcc
                map["mnc"] = id.mncString ?: homeMnc
                map["lac"] = nullIfMax(id.tac)
                map["cid"] = nullIfMax(id.ci)
                map["pci"] = nullIfMax(id.pci)
                map["signalDbm"] = ss.dbm
            }
            is CellInfoGsm -> {
                val id = info.cellIdentity
                val ss = info.cellSignalStrength
                map["radioType"] = "gsm"
                map["mcc"] = id.mccString ?: homeMcc
                map["mnc"] = id.mncString ?: homeMnc
                map["lac"] = nullIfMax(id.lac)
                map["cid"] = nullIfMax(id.cid)
                map["pci"] = null
                map["signalDbm"] = ss.dbm
            }
            is CellInfoWcdma -> {
                val id = info.cellIdentity
                val ss = info.cellSignalStrength
                map["radioType"] = "wcdma"
                map["mcc"] = id.mccString ?: homeMcc
                map["mnc"] = id.mncString ?: homeMnc
                map["lac"] = nullIfMax(id.lac)
                map["cid"] = nullIfMax(id.cid)
                map["pci"] = nullIfMax(id.psc)
                map["signalDbm"] = ss.dbm
            }
            is CellInfoCdma -> {
                val id = info.cellIdentity
                val ss = info.cellSignalStrength
                map["radioType"] = "cdma"
                map["mcc"] = homeMcc
                map["mnc"] = homeMnc
                map["lac"] = nullIfMax(id.networkId)
                map["cid"] = nullIfMax(id.basestationId)
                map["pci"] = null
                map["signalDbm"] = ss.dbm
            }
            else -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && info is CellInfoNr) {
                    val id = info.cellIdentity as? CellIdentityNr
                    val ss = info.cellSignalStrength as? CellSignalStrengthNr
                    map["radioType"] = "nr"
                    map["mcc"] = id?.mccString ?: homeMcc
                    map["mnc"] = id?.mncString ?: homeMnc
                    map["lac"] = id?.let { nullIfMax(it.tac) }
                    map["cid"] = id?.nci?.takeIf { it != Long.MAX_VALUE }
                    map["pci"] = id?.let { nullIfMax(it.pci) }
                    map["signalDbm"] = ss?.dbm ?: 0
                } else {
                    return null
                }
            }
        }
        return map
    }

    private fun nullIfMax(value: Int): Int? = if (value == Int.MAX_VALUE) null else value
}
