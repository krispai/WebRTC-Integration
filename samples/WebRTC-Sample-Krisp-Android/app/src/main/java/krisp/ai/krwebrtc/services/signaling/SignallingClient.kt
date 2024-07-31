package krisp.ai.krwebrtc.services.signaling

import android.util.Log
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.websocket.*
import io.ktor.http.*
import io.ktor.serialization.gson.*
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.collectLatest
import com.google.gson.Gson
import com.google.gson.JsonObject
import io.ktor.websocket.*

import org.webrtc.IceCandidate
import org.webrtc.SessionDescription


class SignallingClient(
    private val listener: SignallingClientListener
) : CoroutineScope {

    companion object {
        private const val HOST_ADDRESS = "192.168.10.30"
    }

    private val job = Job()

    private val gson = Gson()

    override val coroutineContext = Dispatchers.IO + job

    private val client = HttpClient(CIO) {
        install(WebSockets)
        install(ContentNegotiation) {
            gson()
        }
    }

    private val sendChannel = MutableSharedFlow<String>(replay = 1)

    init {
        connect()
    }

    private fun connect() = launch {
        try {
            client.webSocket(method = HttpMethod.Get, host = HOST_ADDRESS, port = 8085, path = "/connect") {
                listener.onConnectionEstablished()
                launch {
                    sendChannel.collectLatest { message ->
                        Log.v("SignallingClient", "Sending: $message")
                        outgoing.send(Frame.Text(message))
                    }
                }
                for (frame in incoming) {
                    if (frame is Frame.Text) {
                        val data = frame.readText()
                        Log.v(this@SignallingClient.javaClass.simpleName, "Received: $data")
                        val jsonObject = gson.fromJson(data, JsonObject::class.java)

                        withContext(Dispatchers.Main) {
                            when {
                                jsonObject.has("serverUrl") -> {
                                    listener.onIceCandidateReceived(gson.fromJson(jsonObject, IceCandidate::class.java))
                                }
                                jsonObject.has("type") && jsonObject.get("type").asString == "OFFER" -> {
                                    listener.onOfferReceived(gson.fromJson(jsonObject, SessionDescription::class.java))
                                }
                                jsonObject.has("type") && jsonObject.get("type").asString == "ANSWER" -> {
                                    listener.onAnswerReceived(gson.fromJson(jsonObject, SessionDescription::class.java))
                                }
                            }
                        }
                    }
                }
            }
        } catch (exception: Throwable) {
            Log.e("SignallingClient", "Error in websocket connection", exception)
        }
    }

    fun send(dataObject: Any?) = runBlocking {
        sendChannel.emit(gson.toJson(dataObject))
    }

    fun destroy() {
        client.close()
        job.complete()
    }
}
