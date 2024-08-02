package krisp.ai.krwebrtc

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.Switch

import android.Manifest

import org.webrtc.KrispAudioProcessingImpl
import org.webrtc.*
import org.webrtc.PeerConnectionFactory

import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioManager
import android.widget.Toast

import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.widget.CompoundButton
import java.io.File
import java.io.InputStream
import android.util.Log

import org.webrtc.IceCandidate
import org.webrtc.SessionDescription
import org.webrtc.SurfaceViewRenderer

import androidx.appcompat.app.AlertDialog
import android.widget.Button
import android.widget.TextView
import android.widget.ProgressBar
import krisp.ai.krwebrtc.services.signaling.AppSdpObserver
import krisp.ai.krwebrtc.services.signaling.SignallingClient
import krisp.ai.krwebrtc.services.signaling.SignallingClientListener
import krisp.ai.krwebrtc.services.webrtc.PeerConnectionObserver
import krisp.ai.krwebrtc.services.webrtc.WebRTCClient

final class MainActivity : AppCompatActivity() {

    companion object {
        private const val REQUEST_RECORD_AUDIO_PERMISSION = 200
        init {
            try {
                System.loadLibrary("jingle_peerconnection_so")
                System.loadLibrary("krisp-audio-sdk")
            } catch (e: UnsatisfiedLinkError) {
                Log.e("LibraryLoad", "Failed to load native library: ${e.message}")
            } catch (e: Exception) {
                println("LibraryLoad Unexpected error occurred while loading libraries")
            }
        }
    }

    private lateinit var signalingStatus: TextView
    private lateinit var sendOfferButton: Button
    private lateinit var sendAnswerButton: Button
    private lateinit var localView: SurfaceViewRenderer
    private lateinit var remoteView: SurfaceViewRenderer
    private lateinit var remoteViewLoading: ProgressBar
    private lateinit var switchEnable: Switch

    private lateinit var rtcClient: WebRTCClient
    private lateinit var signallingClient: SignallingClient
    private var audioProcessorModule = KrispAudioProcessingImpl()

    private val sdpObserver = object : AppSdpObserver() {
        override fun onCreateSuccess(p0: SessionDescription?) {
            super.onCreateSuccess(p0)
            signallingClient.send(p0)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        signalingStatus = findViewById(R.id.SignalingStatusValue)
        sendOfferButton = findViewById(R.id.SendOfferButton)
        sendAnswerButton = findViewById(R.id.SendAnswerButton)
        sendAnswerButton.isEnabled = false

        localView = findViewById(R.id.localClientView)
        remoteView = findViewById(R.id.remoteClientView)
        remoteViewLoading = findViewById(R.id.remoteViewSpinner)

        switchEnable = findViewById(R.id.KrispEnableNC)
        switchEnable.isChecked = true
        switchEnable.setOnCheckedChangeListener { _: CompoundButton, isChecked: Boolean ->
            audioProcessorModule.Enable(isChecked)
        }
        requestPermissions()
    }

    private fun initializePeerConnectionFactory() {
        val initializationOptions = PeerConnectionFactory.InitializationOptions.builder(this)
            .setFieldTrials("WebRTC-SomeTrial/Enabled/")
            .setEnableInternalTracer(true)
            .createInitializationOptions()
        PeerConnectionFactory.initialize(initializationOptions)
    }

    fun getKrispDLLPath(context: Context): String {
        return context.applicationInfo.nativeLibraryDir
    }

    fun listDirectoryContents(directoryPath: String) {
        val directory = File(directoryPath)
        if (directory.exists() && directory.isDirectory) {
            val files = directory.listFiles()
            if (files != null) {
                for (file in files) {
                    println(file.name)
                }
            } else {
                println("The specified path does not denote a directory or an I/O error occurred.")
            }
        } else {
            println("The specified directory does not exist or is not a directory.")
        }
    }

    fun getKrispProcessor() : AudioProcessingFactory {
        val modelFilePath = getRawResourceFilePath(this, R.raw.model)
        val nativeLibraryPath = getKrispDLLPath(this)
        val krispDllpath = "libkrisp-audio-sdk.so"
        var retValue = audioProcessorModule.Init(modelFilePath, krispDllpath)
        if (!retValue) {
            return null
        }
        audioProcessorModule.Enable(switchEnable.isChecked)
        return audioProcessorModule
    }

    fun getRawResourceFilePath(context: Context, resourceId: Int): String {
        val inputStream: InputStream = context.resources.openRawResource(resourceId)
        val tempFile = File(context.cacheDir, "model.kw")
        tempFile.outputStream().use { inputStream.copyTo(it) }
        return tempFile.absolutePath
    }

    private fun showAlertDialog(message: String) {
        val builder = AlertDialog.Builder(this)
        builder.setTitle("Alert")
        builder.setMessage(message)
        builder.setPositiveButton("OK") { dialog, _ ->
            dialog.dismiss()
        }
        builder.setNegativeButton("Cancel") { dialog, _ ->
            dialog.dismiss()
        }

        val alertDialog = builder.create()
        alertDialog.show()
    }

    private fun onStartCommunicationSession() {
        var krispProcessor = getKrispProcessor()
        if (krispProcessor == null) {
            showAlertDialog("Unable initialize Krisp SDK")
        } else {
            rtcClient = WebRTCClient(
                application,
                object : PeerConnectionObserver() {
                    override fun onIceCandidate(p0: IceCandidate?) {
                        super.onIceCandidate(p0)
                        signallingClient.send(p0)
                        rtcClient.addIceCandidate(p0)
                    }

                    override fun onTrack(transceiver: RtpTransceiver?) {
                        super.onTrack(transceiver)
                        if (transceiver?.receiver?.track() is VideoTrack) {
                            (transceiver.receiver.track() as VideoTrack).addSink(remoteView)
                        }
                    }
                },
                krispProcessor,
            )
            rtcClient.initSurfaceView(remoteView)
            rtcClient.initSurfaceView(localView)
            rtcClient.startLocalVideoCapture(localView)

            signallingClient = SignallingClient(createSignallingClientListener())
            sendOfferButton.setOnClickListener {
                rtcClient.call(sdpObserver)
            }

            sendAnswerButton.setOnClickListener {
                rtcClient.call(sdpObserver)
            }
         }
        }

    private fun requestPermissions() {
        val permissionsNeeded = mutableListOf<String>()

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            permissionsNeeded.add(Manifest.permission.RECORD_AUDIO)
        }

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            permissionsNeeded.add(Manifest.permission.CAMERA)
        }

        if (permissionsNeeded.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this,
                permissionsNeeded.toTypedArray(),
                REQUEST_RECORD_AUDIO_PERMISSION
            )
        } else {
            // Permissions are already granted
            onStartCommunicationSession()
        }
    }

    private fun createSignallingClientListener() = object : SignallingClientListener {
        override fun onConnectionEstablished() {
            runOnUiThread {
                signalingStatus.text = "Connected"
                sendOfferButton.isClickable = true
                sendAnswerButton.isEnabled = true
            }
        }

        override fun onOfferReceived(description: SessionDescription) {
            rtcClient.onRemoteSessionReceived(description)
            rtcClient.answer(sdpObserver)
            (getSystemService(Context.AUDIO_SERVICE) as AudioManager).apply {
                stopBluetoothSco()
                isBluetoothScoOn = false
                isSpeakerphoneOn = true
            }
           remoteViewLoading.visibility = View.GONE
        }

        override fun onAnswerReceived(description: SessionDescription) {
            rtcClient.onRemoteSessionReceived(description)
            remoteViewLoading.visibility = View.GONE
        }

        override fun onIceCandidateReceived(iceCandidate: IceCandidate) {
            rtcClient.addIceCandidate(iceCandidate)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {
            REQUEST_RECORD_AUDIO_PERMISSION -> {
                val permissionResults = permissions.zip(grantResults.toTypedArray()).toMap()
                val audioGranted = permissionResults[Manifest.permission.RECORD_AUDIO] == PackageManager.PERMISSION_GRANTED
                val cameraGranted = permissionResults[Manifest.permission.CAMERA] == PackageManager.PERMISSION_GRANTED

                if (audioGranted && cameraGranted) {
                    onStartCommunicationSession()
                } else {
                    // One or both permissions denied
                    if (!audioGranted) {
                        Toast.makeText(this, "Permission denied to record audio", Toast.LENGTH_SHORT).show()
                    }
                    if (!cameraGranted) {
                        Toast.makeText(this, "Permission denied to access camera", Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
    }

    override fun onDestroy() {
        signallingClient.destroy()
        super.onDestroy()
    }
}

