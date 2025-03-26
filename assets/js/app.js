// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

import AudioRecorder from "./hooks";

let Hooks = {}

// let hooks = { AudioRecorder };

Hooks.Microphone = {
  mounted() {
    this.mediaRecorder = null;

    // Check for browser support
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      console.error("Browser does not support microphone access")
      return
    }

    this.el.addEventListener("mousedown", (event) => {
      this.startRecording();
    });

    this.el.addEventListener("mouseup", (event) => {
      this.stopRecording();
    });
  },

  startRecording() {
    this.audioChunks = [];

    navigator.mediaDevices.getUserMedia({ audio: true }).then((stream) => {
      this.mediaRecorder = new MediaRecorder(stream);

      this.mediaRecorder.addEventListener("dataavailable", (event) => {
        if (event.data.size > 0) {
          this.audioChunks.push(event.data);
        }
      });

      this.mediaRecorder.start();
    }).catch(err => {
      console.error("Error accessing microphone", err);
    });
  },

  stopRecording() {
    if (!this.mediaRecorder) return;

    this.mediaRecorder.addEventListener("stop", (event) => {
      if (this.audioChunks.length === 0) return;

      const audioBlob = new Blob(this.audioChunks);

      audioBlob.arrayBuffer().then((buffer) => {
        const context = new AudioContext({ sampleRate: SAMPLING_RATE });

        context.decodeAudioData(buffer, (audioBuffer) => {
          const pcmBuffer = this.audioBufferToPcm(audioBuffer);
          const buffer = this.convertEndianness32(
            pcmBuffer,
            this.getEndianness(),
            this.el.dataset.endianness || this.getEndianness()
          );
          
          // Convert buffer to base64 for LiveView
          //const base64data = btoa(String.fromCharCode.apply(null, new Uint8Array(buffer)));
          
          // Push event to LiveView
          //this.pushEvent("audio_recorded", { audio: base64data });
          this.upload("audio", [new Blob([buffer])]);
        });
      });
    });

    this.mediaRecorder.stop();
  },

  isRecording() {
    return this.mediaRecorder && this.mediaRecorder.state === "recording";
  },

  audioBufferToPcm(audioBuffer) {
    const numChannels = audioBuffer.numberOfChannels;
    const length = audioBuffer.length;

    const size = Float32Array.BYTES_PER_ELEMENT * length;
    const buffer = new ArrayBuffer(size);

    const pcmArray = new Float32Array(buffer);

    const channelDataBuffers = Array.from(
      { length: numChannels },
      (x, channel) => audioBuffer.getChannelData(channel)
    );

    // Average all channels upfront, so the PCM is always mono
    for (let i = 0; i < pcmArray.length; i++) {
      let sum = 0;

      for (let channel = 0; channel < numChannels; channel++) {
        sum += channelDataBuffers[channel][i];
      }

      pcmArray[i] = sum / numChannels;
    }

    return buffer;
  },

  convertEndianness32(buffer, from, to) {
    if (from === to) {
      return buffer;
    }

    const uint8Array = new Uint8Array(buffer);

    // If the endianness differs, we swap bytes accordingly
    for (let i = 0; i < uint8Array.length; i += 4) {
      const b1 = uint8Array[i];
      const b2 = uint8Array[i + 1];
      const b3 = uint8Array[i + 2];
      const b4 = uint8Array[i + 3];
      
      uint8Array[i] = b4;
      uint8Array[i + 1] = b3;
      uint8Array[i + 2] = b2;
      uint8Array[i + 3] = b1;
    }

    return uint8Array.buffer;
  },

  getEndianness() {
    const buffer = new ArrayBuffer(2);
    const int16Array = new Uint16Array(buffer);
    const int8Array = new Uint8Array(buffer);

    int16Array[0] = 1;

    return int8Array[0] === 1 ? "little" : "big";
  },
};


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content") || "";

let liveSocket = new LiveSocket("/live", Socket, {
    longPollFallbackMs: 2500,
    params: {_csrf_token: csrfToken},
    hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

